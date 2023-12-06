library ieee;
use ieee.std_logic_1164.all;

entity SE6_shifter is
	port (input: in std_logic_vector(5 downto 0);
			output: out std_logic_vector(15 downto 0));
end entity SE6_shifter;

architecture bhv of SE6_shifter is
signal temp: std_logic_vector(15 downto 0);
begin
	extend: process(input,temp)
	begin
		if (input(5) = '0') then
			temp <= "0000000000" & input;
		else 
			temp <= "1111111111" & input;
		end if;
		output <= temp(14 downto 0) & '0';
	end process;
end bhv;