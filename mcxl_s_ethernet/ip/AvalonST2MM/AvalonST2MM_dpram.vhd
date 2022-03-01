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

entity AvalonST2MM_dpram is
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
end entity AvalonST2MM_dpram;

architecture rtl of AvalonST2MM_dpram is
	--  build up 2D array to hold the memory
	type word_t is array (0 to 3) of std_logic_vector(7 downto 0);
	type ram_t is array (0 to 2 ** ADDR_WIDTH - 1) of word_t;

	signal ram : ram_t;
	signal q1_local : word_t;
	signal q2_local : word_t;  

begin  -- rtl
	-- Reorganize the read data from the RAM to match the output
	unpack: for i in 0 to 3 generate    
		data_out1(8*(i+1) - 1 downto 8*i) <= q1_local(i);
		data_out2(8*(i+1) - 1 downto 8*i) <= q2_local(i);    
	end generate unpack;
        
	process(clk)
	begin
		if(rising_edge(clk)) then 
			if(we1 = '1') then
				-- edit this code if using other than four bytes per word
				if(be1(0) = '1') then
					ram(addr1)(0) <= data_in1(7 downto 0);
				end if;
				if be1(1) = '1' then
					ram(addr1)(1) <= data_in1(15 downto 8);
				end if;
				if be1(2) = '1' then
					ram(addr1)(2) <= data_in1(23 downto 16);
				end if;
				if be1(3) = '1' then
					ram(addr1)(3) <= data_in1(31 downto 24);
				end if;
			end if;
			q1_local <= ram(addr1);
		end if;
	end process;

	process(clk)
	begin
	if(rising_edge(clk)) then 
		if(we2 = '1') then
				-- edit this code if using other than four bytes per word
			if(be2(0) = '1') then
				ram(addr2)(0) <= data_in2(7 downto 0);
			end if;
			if be2(1) = '1' then
				ram(addr2)(1) <= data_in2(15 downto 8);
			end if;
			if be2(2) = '1' then
				ram(addr2)(2) <= data_in2(23 downto 16);
			end if;
			if be2(3) = '1' then
				ram(addr2)(3) <= data_in2(31 downto 24);
			end if;
		end if;
		q2_local <= ram(addr2);
	end if;
	end process;  
  
end rtl;
