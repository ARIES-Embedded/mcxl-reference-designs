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



entity MCXL is
	port (
		clk_25M	: in  std_logic;
		button	: in  std_logic_vector(3 downto 0);
		led_mcxl    : out std_logic_vector(3 downto 0);
		pmod_p14 : inout std_logic_vector(7 downto 0);
		pmod_p15 : inout std_logic_vector(7 downto 0);
		pmod_p16 : inout std_logic_vector(7 downto 0);
		pmod_p17 : inout std_logic_vector(7 downto 0);
		pmod_p18 : inout std_logic_vector(7 downto 0);
		
		eth_rstn     : out   std_logic;
		eth_mdio     : inout std_logic;
		eth_mdc      : out   std_logic;
		eth_rx_clk   : in    std_logic;
		eth_rx_ctl   : in    std_logic;
		eth_rx_dat   : in    std_logic_vector(3 downto 0);
		eth_tx_clk   : out   std_logic;
		eth_tx_ctl   : out   std_logic;
		eth_tx_dat   : out   std_logic_vector(3 downto 0)
	);
end entity MCXL;



architecture rtl of MCXL is

	signal gpio : std_logic_vector(31 downto 0);
	signal i_uart_tx : std_logic;
	signal i_uart_rx : std_logic;

	signal clk_125M : std_logic;

	signal ethi_mdio_i : std_logic;
	signal ethi_mdio_o : std_logic;
	signal ethi_mdio_oen : std_logic;

	component qsys_vex is
		port (
			clk_clk              : in    std_logic := 'X';
			clk125m_clk          : out   std_logic;
			gpio_export          : inout std_logic_vector(31 downto 0) := (others => 'X');
			reset_reset_n        : in    std_logic := 'X';
			uart_rxd             : in    std_logic := 'X';
			uart_txd             : out   std_logic;
			eth_rgmii_rgmii_in   : in    std_logic_vector(3 downto 0) := (others => 'X');
			eth_rgmii_rgmii_out  : out   std_logic_vector(3 downto 0);
			eth_rgmii_rx_control : in    std_logic := 'X';
			eth_rgmii_tx_control : out   std_logic;
			eth_rxc_clk          : in    std_logic := 'X';
			eth_status_set_10    : in    std_logic := 'X';
			eth_status_set_1000  : in    std_logic := 'X';
			eth_status_eth_mode  : out   std_logic;
			eth_status_ena_10    : out   std_logic;
			eth_mdio_mdc         : out   std_logic;
			eth_mdio_mdio_in     : in    std_logic := 'X';
			eth_mdio_mdio_out    : out   std_logic;
			eth_mdio_mdio_oen    : out   std_logic
		);
	end component qsys_vex;

begin

	u0 : component qsys_vex
		port map (
			clk_clk              => clk_25M,
			clk125m_clk          => clk_125M,
			gpio_export          => gpio,
			reset_reset_n        => button(0),
			uart_rxd             => i_uart_rx,
			uart_txd             => i_uart_tx,
			eth_rgmii_rgmii_in   => eth_rx_dat,
			eth_rgmii_rgmii_out  => eth_tx_dat,
			eth_rgmii_rx_control => eth_rx_ctl,
			eth_rgmii_tx_control => eth_tx_ctl,
			eth_rxc_clk          => eth_rx_clk,
			eth_status_set_10    => '0',
			eth_status_set_1000  => '0',
			eth_status_eth_mode  => open,
			eth_status_ena_10    => open,
			eth_mdio_mdc         => eth_mdc,
			eth_mdio_mdio_in     => ethi_mdio_i,
			eth_mdio_mdio_out    => ethi_mdio_o,
			eth_mdio_mdio_oen    => ethi_mdio_oen
		);

	pmod_p14(1) <= i_uart_tx;
	i_uart_rx <= pmod_p14(2);

	pmod_p15 <= gpio(7 downto 0);
	pmod_p16 <= gpio(7 downto 0);
	pmod_p17 <= gpio(7 downto 0);
	pmod_p18 <= gpio(7 downto 0);

	eth_mdio <= ethi_mdio_o when ethi_mdio_oen = '0' else 'Z';
	ethi_mdio_i <= eth_mdio;

	eth_tx_clk <= clk_125M;
	eth_rstn <= '1';

end architecture rtl;
