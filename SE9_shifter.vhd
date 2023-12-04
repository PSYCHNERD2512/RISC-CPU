library ieee;
use ieee.std_logic_1164.all;

entity SE9_shifter is
	port (input: in std_logic_vector(8 downto 0);
			output: out std_logic_vector(15 downto 0));
end entity SE9_shifter;

architecture bhv of SE9_shifter is
signal temp: std_logic_vector(15 downto 0);
begin
	extend: process(input)
	begin
		if (input(8) = '0') then
			temp <= "0000000" & input;
		else 
			temp <= "1111111" & input;
		end if;
		output <= temp(14 downto 0) & '0';
	end process;
end bhv;