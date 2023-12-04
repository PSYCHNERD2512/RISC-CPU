-- 4:2 MUX
library ieee;
use ieee.std_logic_1164.all;

entity MUX_4x2 is
  port (output: out std_logic_vector (15 downto 0);
    sel: in std_logic_vector (1 downto 0);
    in_0, in_1, in_2, in_3: in std_logic_vector (15 downto 0));
end MUX_4x2;

architecture bhv of MUX_4x2 is
begin
  with sel select
    output <=
      in_0 when "00",
      in_1 when "01",
      in_2 when "10",
      in_3 when "11",
      (others => '0') when others;
end bhv;