-- Copyright (C) 2022 ARIES Embedded GmbH
--
-- Permission is hereby granted, free of charge, to any person obtaining a
-- copy of this software and associated documentation files (the "Software"),
-- to deal in the Software without restriction, including without limitation
-- the rights to use, copy, modify, merge, publish, distribute, sublicense,
-- and/or sell copies of the Software, and to permit persons to whom the
-- Software is furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
-- THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
-- DEALINGS IN THE SOFTWARE.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

-- Avalon Streaming-MemoryMapped-Bridge
-- A simple bridge between the two bus systems
-- via two 2 KiB buffer and ownership flag.
-- When the streaming interface has the ownership of a buffer,
-- it will stream the data in or out until the end of packet.
-- Then pass ownership back to the memory-mapped interface.

entity AvalonST2MM is
	port (

		clk    : in  std_logic;
		resetn : in  std_logic;

		mm_address       : in  std_logic_vector(10 downto 0);
		mm_readdata      : out std_logic_vector(31 downto 0);
		mm_writedata     : in  std_logic_vector(31 downto 0);
		mm_byteenable    : in  std_logic_vector(3 downto 0);
		mm_read          : in  std_logic;
		mm_write         : in  std_logic;
		mm_readdatavalid : out std_logic;
		mm_waitrequest   : out std_logic;

		avalon_interrupt : out std_logic;

		sti_data  : in  std_logic_vector(31 downto 0);
		sti_empty : in  std_logic_vector(1 downto 0);
		sti_valid : in  std_logic;
		sti_sop   : in  std_logic;
		sti_eop   : in  std_logic;
		sti_ready : out std_logic;

		sto_data  : out std_logic_vector(31 downto 0);
		sto_empty : out std_logic_vector(1 downto 0);
		sto_valid : out std_logic;
		sto_sop   : out std_logic;
		sto_eop   : out std_logic;
		sto_ready : in  std_logic

	);
end entity;

-- Address map for the simple buffered MM-ST bridge:

-- 0x0000 - 0x07FF Output Buffer (MM -> ST)
-- 0x0800 - 0x0FFF Input  Buffer (ST -> MM)
-- 0x1000 - 0x100f CSRs (csr, rx length, rx length, unused)

-- 10  9  [8 ... 0]
--  0  0  000000000
--  |  |  \_ 9 + 2 bit (access by word) = 2 KiB
--  |  \_ input/output buffer
--  \_ csr access

-- csr:
	-- 0 R  tx ready
	-- 1 R  rx ready
	-- 2  W tx start
	-- 3  W rx ack
	-- 4 RW tx irq enable
	-- 5 RW tx irq enable
	-- 6 RW rx irq disable
	-- 7 RW rx irq disable
	-- 8 RW tx irq pending
	-- 9 RW tx irq pending

architecture rtl of AvalonST2MM is 

	component AvalonST2MM_dpram is
		generic (
			ADDR_WIDTH : natural := 8
		);
		port (
			we1, we2, clk : in  std_logic;
			be1      : in  std_logic_vector (3 downto 0);
			be2      : in  std_logic_vector (3 downto 0);    
			data_in1 : in  std_logic_vector(31 downto 0);
			data_in2 : in  std_logic_vector(31 downto 0);    
			addr1   : in  integer range 0 to 2 ** ADDR_WIDTH - 1 ;
			addr2   : in  integer range 0 to 2 ** ADDR_WIDTH - 1;
			data_out1 : out std_logic_vector(31 downto 0);
			data_out2 : out std_logic_vector(31 downto 0)
		);
	end component AvalonST2MM_dpram;

	-- DPRAM signals
	signal oram_mm_ad : integer;
	signal oram_mm_we : std_logic;
	signal oram_mm_be : std_logic_vector(3 downto 0);
	signal oram_mm_di : std_logic_vector(31 downto 0);
	signal oram_mm_do : std_logic_vector(31 downto 0);

	signal oram_st_ad : integer;
	signal oram_st_we : std_logic;
	signal oram_st_be : std_logic_vector(3 downto 0);
	signal oram_st_di : std_logic_vector(31 downto 0);
	signal oram_st_do : std_logic_vector(31 downto 0);

	signal iram_mm_ad : integer;
	signal iram_mm_we : std_logic;
	signal iram_mm_be : std_logic_vector(3 downto 0);
	signal iram_mm_di : std_logic_vector(31 downto 0);
	signal iram_mm_do : std_logic_vector(31 downto 0);

	signal iram_st_ad : integer;
	signal iram_st_we : std_logic;
	signal iram_st_be : std_logic_vector(3 downto 0);
	signal iram_st_di : std_logic_vector(31 downto 0);
	signal iram_st_do : std_logic_vector(31 downto 0);

	-- MM signals
	signal csr_rdata     : std_logic_vector(31 downto 0);
	signal imm_addrspace : std_logic_vector(2 downto 0);
	
	-- ST(MM) signals
	signal o_bytes : unsigned(31 downto 0);
	signal o_words : unsigned(31 downto 0);
	signal i_bytes : unsigned(31 downto 0);
	signal i_words : unsigned(31 downto 0);
	signal ost_pointer : integer;
	signal i_mm_nst : std_logic;
	signal o_mm_nst : std_logic;

	signal o_irq_p : std_logic := '0';
	signal i_irq_p : std_logic := '0';
	signal o_irq_e : std_logic := '0';
	signal i_irq_e : std_logic := '0';

begin

	iram : component AvalonST2MM_dpram
		generic map (
			ADDR_WIDTH => 9
		)
		port map (
			clk => clk,
			we1 => iram_mm_we,
			we2 => iram_st_we,
			be1 => iram_mm_be,
			be2 => iram_st_be,
			data_in1 => iram_mm_di,
			data_in2 => iram_st_di,
			addr1 => iram_mm_ad,
			addr2 => iram_st_ad,
			data_out1 => iram_mm_do,
			data_out2 => iram_st_do
		);
		
	oram : component AvalonST2MM_dpram
		generic map (
			ADDR_WIDTH => 9
		)
		port map(
			clk => clk,
			we1 => oram_mm_we,
			we2 => oram_st_we,
			be1 => oram_mm_be,
			be2 => oram_st_be,
			data_in1 => oram_mm_di,
			data_in2 => oram_st_di,
			addr1 => oram_mm_ad,
			addr2 => oram_st_ad,
			data_out1 => oram_mm_do,
			data_out2 => oram_st_do
		);

	process(clk, resetn) begin

		if (resetn = '0') then

			o_bytes <= (others => '0');
			o_words <= (others => '0');
			i_bytes <= (others => '0');
			i_words <= (others => '0');
			ost_pointer <= 0;
			o_mm_nst <= '1';
			i_mm_nst <= '0';
			o_irq_p <= '0';
			i_irq_p <= '0';

		elsif (rising_edge(clk)) then

			-- Memory Mapped

			imm_addrspace <= mm_address(10 downto 9) & not (mm_address(10) or mm_address(9));

			if (mm_read = '1') then
				csr_rdata <= (others => '0');
				case mm_address(1 downto 0) is
					when "00" => csr_rdata(9 downto 0) <= i_irq_p & o_irq_p & '0' & i_irq_e & '0' & o_irq_e & "00" & i_mm_nst & o_mm_nst;
					when "01" => csr_rdata <= std_logic_vector(o_bytes);
					when "10" => csr_rdata <= std_logic_vector(i_bytes);
					when others => null;
				end case;
				mm_readdatavalid <= '1';
			else
				mm_readdatavalid <= '0';
				if (mm_write = '1') then

					if (mm_address = "10000000000") then -- csr access (csr)

						if (mm_writedata(2) = '1' and o_mm_nst = '1') then
							o_mm_nst <= '0';
							ost_pointer <= 0;
						end if;
						if (mm_writedata(3) = '1' and i_mm_nst = '1') then
							i_mm_nst <= '0';
							i_words <= (others => '0');
							i_bytes <= (others => '0');
						end if;
						if (mm_writedata(4) = '1') then
							o_irq_e <= '1';
						end if;
						if (mm_writedata(5) = '1') then
							o_irq_e <= '0';
						end if;

						if (mm_writedata(6) = '1') then
							i_irq_e <= '1';
						end if;
						if (mm_writedata(7) = '1') then
							i_irq_e <= '0';
						end if;

						if (mm_writedata(8) = '1') then
							i_irq_p <= '0';
						end if;
						if (mm_writedata(9) = '1') then
							i_irq_p <= '0';
						end if;

					elsif  (mm_address = "10000000001" and o_mm_nst = '1') then -- csr access (TX length)
						o_bytes <= unsigned(mm_writedata);
						o_words <= shift_right(unsigned(mm_writedata)+3, 2);
					end if;
				end if;
			end if;

			-- Streaming

			if (sto_ready = '1' and o_mm_nst = '0' and o_bytes > 0) then
				sto_valid <= '1';
				ost_pointer <= ost_pointer + 1;
				sto_eop <= '0';
				sto_sop <= '0';
				if (ost_pointer = 0) then
					sto_sop <= '1';
				end if;
				if (ost_pointer + 1 = o_words) then
					o_mm_nst <= '1';
					o_irq_p <= '1';
					sto_eop <= '1';
					sto_empty <= std_logic_vector(shift_left(o_words, 2) - o_bytes)(1 downto 0);
				else
					sto_empty <= "00";
				end if;
			else 
				if (o_bytes = 0) then
					o_mm_nst <= '1';
				end if;
				sto_eop <= '0';
				sto_valid <= '0';
			end if;

			if (i_mm_nst = '0') then
				if (sti_valid = '1') then
					i_words <= i_words + 1;
					-- It is expected that the end-of-packet arrives before the buffer overruns
					-- (2kB buffer vs 1.5kB max size of ethernet frames)
					if (sti_eop = '1') then
						i_mm_nst <= '1';
						i_irq_p <= '1';
						i_bytes <= shift_left(i_words + 1, 2) - unsigned(sti_empty);
					end if;
				end if;
			end if;

		end if;
	end process;

	-- DPRAM

	oram_mm_ad <= to_integer(unsigned(mm_address(8 downto 0)));
	oram_mm_we <= '1' when mm_write = '1' and mm_address(10 downto 9) = "00" else '0';
	oram_mm_be <= mm_byteenable;
	oram_mm_di <= mm_writedata;

	iram_mm_ad <= to_integer(unsigned(mm_address(8 downto 0)));
	iram_mm_we <= '0';
	iram_mm_be <= "0000";
	iram_mm_di <= x"00000000";

	oram_st_ad <= ost_pointer;
	oram_st_we <= '0';
	oram_st_be <= "0000";
	oram_st_di <= x"00000000";

	iram_st_ad <= to_integer(i_words);
	iram_st_we <= '1' when i_mm_nst = '0' and sti_valid = '1' else '0';
	iram_st_be <=
		"0001" when sti_empty = "11" else 
		"0011" when sti_empty = "10" else 
		"0111" when sti_empty = "01" else 
		"1111";

	-- Convert endianness little (RISC-V) <--> big (Ethernet)
	sto_data(31 downto 24) <= oram_st_do( 7 downto  0);
	sto_data(23 downto 16) <= oram_st_do(15 downto  8);
	sto_data(15 downto  8) <= oram_st_do(23 downto 16);
	sto_data( 7 downto  0) <= oram_st_do(31 downto 24);

	iram_st_di(31 downto 24) <= sti_data( 7 downto  0);
	iram_st_di(23 downto 16) <= sti_data(15 downto  8);
	iram_st_di(15 downto  8) <= sti_data(23 downto 16);
	iram_st_di( 7 downto  0) <= sti_data(31 downto 24);

	-- MM

	mm_waitrequest <= '0';
	mm_readdata <= -- Select readdata based on latched address of last read
		csr_rdata  when imm_addrspace(2) = '1' else
		iram_mm_do when imm_addrspace(1) = '1' else
		oram_mm_do;

	-- ST(MM)

	sti_ready <= not i_mm_nst;

	avalon_interrupt <= (o_irq_p and o_irq_e) or (i_irq_p and i_irq_e);

end architecture;
