library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;

entity Memory is
    port (clk, w_flag, r_flag : in std_logic;
				address, data_w : in std_logic_vector(15 downto 0);
				data_r : out std_logic_vector(15 downto 0));
end Memory;

architecture arch of Memory is
    type RAM_array is array (4095 downto 0) of std_logic_vector(15 downto 0);
    SIGNAL RAM : RAM_array := (
		0  => "1001000000000001",
		1  => "1001001000000001",
		2  => "1100000001000001",
		3  => "1010011001000001",
		4  => "1010100001000000",
		5  => "1010000001000000",
		6  => "1010110001000000",
		7  => "1000000011111111",
		8  => "1000000000000000",
		9  => "1001001000000000",
		10 => "1001000000000001",
		11 => "1010001000000000",
		12 => "1101000001000000",
		13 => "0110000001111000",
		14 => "1010001010000000",
		15 => "0110000001010000",
		16 => "0001000001000010",
		17 => "1000000000000010",
		18 => "1001000000000010",
		19 => "1010000001000010",
		20 => "1011000001000010",
		21 => "1100000001000010",
		22 => "1101000000000001",
		23 => "1111000001000000",
		others => "0000000000000001");
	-- hardcoded the instructions to test our CPU
		
begin
    process(w_flag, r_flag, data_w, address, clk)
    begin
	     if (w_flag = '1') then
				if (clk'event and clk='1') then
					RAM(conv_integer(address)) <= data_w;
				end if;
        end if;
		  if (r_flag = '1') then
				data_r <= RAM(conv_integer(address));
		  end if;	
    end process;
end arch;
