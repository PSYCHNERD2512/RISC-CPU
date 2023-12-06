--16 bit adder
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity adder is
  port (s: out std_logic_vector(15 downto 0);
		c_o: out std_logic;
		a, b: in std_logic_vector(15 downto 0);
		c_i: in std_logic );
end adder;

architecture Behavioral of adder is
   signal temp : std_logic_vector(16 downto 0);
begin
   temp <= ('0' & a) + b + c_i;
   s    <= temp(15 downto 0);
   c_o  <= temp(16);
end Behavioral;


-- 16 bit subtractor
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity subtractor is
  port (s: out std_logic_vector(15 downto 0);
		c_o: out std_logic;
		a, b: in std_logic_vector(15 downto 0);
		c_i: in std_logic );
end subtractor;

architecture Behavioral of subtractor is
   signal temp : std_logic_vector(16 downto 0);
begin
   temp <= ('0' & a) - b - c_i;
   s    <= temp(15 downto 0);
   c_o  <= temp(16);
end Behavioral;


--16 bit mulitplier
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplier is
  port (a, b: in std_logic_vector (15 downto 0);
		mul: out std_logic_vector (31 downto 0) );
end multiplier;

architecture Behavioral of multiplier is
begin
    mul <= std_logic_vector(unsigned(a) * unsigned(b));
end Behavioral;


-- 8x3 MUX
library ieee;
use ieee.std_logic_1164.all;

entity MUX_8x3 is
  port (p_out: out std_logic_vector (15 downto 0);
		sel: in std_logic_vector (2 downto 0);
		in_0, in_1, in_2, in_3, in_4, in_5, in_6, in_7: in std_logic_vector (15 downto 0));
end MUX_8x3;

architecture Behavioral of MUX_8x3 is
begin
  with sel select
    p_out <=
      in_0 when "000",
      in_1 when "001",
      in_2 when "010",
      in_3 when "011",
      in_4 when "100",
      in_5 when "101",
      in_6 when "110",
      in_7 when "111",
      (others => '0') when others;
end Behavioral;


--ALU
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity alu is
  port (alu_a, alu_b: in std_logic_vector(15 downto 0);
		alu_sel: in std_logic_vector(2 downto 0);
		alu_c: out std_logic_vector(15 downto 0));
end alu;

architecture Behavioral of alu is
  signal s0, s1, s2, s3, s4, s5: std_logic_vector(15 downto 0);
  signal s6: std_logic_vector(31 downto 0);
begin
  
  addition: entity work.adder 
  port map (a => alu_a, b => alu_b, c_i => '0', s => s0);
  
  subtraction: entity work.subtractor
  port map (a => alu_a, b => alu_b, c_i => '0', s => s1);
  
  multiplication: entity work.multiplier
  port map (a => alu_a, b => alu_b, mul => s6);
 
  s2 <= s6(15 downto 0);
  s3 <= (alu_a AND alu_b);
  s4 <= (alu_a OR alu_b);
  s5 <= (NOT alu_a OR alu_b);
  
  MUX: entity work.MUX_8x3
  port map (sel => alu_sel, in_0 => s0, in_1 => s1, in_2 => s2, in_3 => s3, in_4 => s4, in_5 => s5, in_6 => "0000000000000000", in_7 => "0000000000000000", p_out => alu_c);

 end Behavioral;
