LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;

entity clock_divider_tb is
end entity clock_divider_tb;

architecture bhv of clock_divider_tb is
component cpu is
port (outp : out std_logic_vector(15 downto 0);
		clk, rst : in std_logic);
end component cpu;

signal resetn : std_logic := '1';
signal clk_50: std_logic := '1';
signal outp:std_logic_vector(15 downto 0):=(others=>'0');
constant clk_period : time := 20 ns;
begin
	
	dut_instance: cpu port map(outp, clk_50, resetn);
	clk_50 <= not clk_50 after clk_period/2 ;
	resetn <= '1' , '0' after 40 ns;
end bhv;
	

