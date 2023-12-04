-- 2:1 MUX
library ieee;
use ieee.std_logic_1164.all;

entity MUX_2x1 is
  port (output: out std_logic_vector (15 downto 0);
    sel: in std_logic;
    in_0, in_1: in std_logic_vector (15 downto 0));
end MUX_2x1;

architecture bhv of MUX_2x1 is
begin
  with sel select
    output <=
      in_0 when '0',
      in_1 when '1',
      (others => '0') when others;
end bhv;