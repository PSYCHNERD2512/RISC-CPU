library ieee;
use ieee.std_logic_1164.all;

entity cpu_tb is
end entity cpu_tb;

architecture bhv of cpu_tb is
component cpu is
	port (clk, rst: in std_logic );
end component cpu;

signal resetn : std_logic := '1';
signal clk_50: std_logic := '1';
constant clk_period : time := 500 ns;
begin
	
	dut_instance: cpu port map(clk_50, resetn);
	clk_50 <= not clk_50 after clk_period/2 ;
	resetn <= '1' , '0' after 100 ns;
end bhv;
	

