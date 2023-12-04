library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.all;

entity reg is
	port (input: in std_logic_vector(15 downto 0);
			en, clk: in std_logic;
			output: out std_logic_vector(15 downto 0));
end entity reg;

architecture bhv of reg is
	signal storage: std_logic_vector(15 downto 0):= "0000000000000000";
	begin
		output(15 downto 0) <= storage(15 downto 0);
		edit_process: process(clk)
		begin
			if(clk='1' and clk'event and en='1') then
				storage(15 downto 0) <= input(15 downto 0);
			else
				storage(15 downto 0) <= storage(15 downto 0);	-- to prevent an inferred latch from being created
			end if;
		end process;
end architecture bhv;