library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library work;
use work.all;

entity reg_file is
	port (A1, A2, A3: in std_logic_vector(2 downto 0);
			D1, D2: out std_logic_vector(15 downto 0);
			D3: in std_logic_vector(15 downto 0);
			clk, rf_write: in std_logic);
end entity reg_file;

architecture arch of reg_file is

component reg is
	port (input: in std_logic_vector(15 downto 0);
			en, clk: in std_logic;
			output: out std_logic_vector(15 downto 0));
end component reg;
	
	-- enable signals for respective register
	signal e0, e1, e2, e3, e4, e5, e6,  e7: std_logic;
	-- output signals for respective register
	signal r0, r1, r2, r3, r4, r5, r6, r7: std_logic_vector(15 downto 0);

begin

	-- enable signals of the regsiters
	e0 <= rf_write and (not(A3(2))) and (not(A3(1))) and (not(A3(0)));	-- rf_write and address '000'
	e1 <= rf_write and (not(A3(2))) and (not(A3(1))) and (A3(0));			-- rf_write and address '001'
	e2 <= rf_write and (not(A3(2))) and (A3(1)) and (not(A3(0)));			-- rf_write and address '010'
	e3 <= rf_write and (not(A3(2))) and (A3(1)) and (A3(0));					-- rf_write and address '011'
	e4 <= rf_write and (A3(2)) and (not(A3(1))) and (not(A3(0)));			-- rf_write and address '100'
	e5 <= rf_write and (A3(2)) and (not(A3(1))) and (A3(0));					-- rf_write and address '101'
	e6 <= rf_write and (A3(2)) and (A3(1)) and (not(A3(0)));					-- rf_write and address '110'
	e7 <= rf_write and (A3(2)) and (A3(1)) and (A3(0));						-- rf_write and address '111'
	
	-- Initialise the registers
	reg0: reg port map (input => D3, en => e0, clk => clk, output => r0);
	reg1: reg port map (input => D3, en => e1, clk => clk, output => r1);
	reg2: reg port map (input => D3, en => e2, clk => clk, output => r2);
	reg3: reg port map (input => D3, en => e3, clk => clk, output => r3);
	reg4: reg port map (input => D3, en => e4, clk => clk, output => r4);
	reg5: reg port map (input => D3, en => e5, clk => clk, output => r5);
	reg6: reg port map (input => D3, en => e6, clk => clk, output => r6);
	reg7: reg port map (input => D3, en => e7, clk => clk, output => r7);
	
	with A1 select
		D1 <= r0 when "000",
				r1 when "001",
				r2 when "010",
				r3 when "011",
				r4 when "100",
				r5 when "101",
				r6 when "110",
				r7 when "111",
				r0 when others;
	
	with A2 select
		D2 <= r0 when "000",
				r1 when "001",
				r2 when "010",
				r3 when "011",
				r4 when "100",
				r5 when "101",
				r6 when "110",
				r7 when "111",
				r0 when others;
end arch;
	