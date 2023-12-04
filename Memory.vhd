library STD;
use STD.STANDARD.ALL;

library IEEE;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Memory is
    Port ( clk,w_flag,r_flag : in STD_LOGIC;
           address : in STD_LOGIC_VECTOR(15 downto 0);
           data_w : in STD_LOGIC_VECTOR(15 downto 0);
           data_r : out STD_LOGIC_VECTOR(15 downto 0));
end Memory;

architecture form of Memory is
    type RAM_array is array (1 downto 0) of std_logic_vector(15 downto 0);
    signal RAM : RAM_array := ("0000000001010000","0000000000000000"); --("00000..","","");
begin
    process(w_flag,r_flag,data_w,address,clk)
    begin
	     if w_flag = '1' then
          if rising_edge(clk) then
                RAM(conv_integer(address)) <= data_w;
            end if;
        end if;
		  if r_flag = '1' then
          if rising_edge(clk) then
                data_r <= RAM(conv_integer(address));
				end if;
		  end if;	
    end process;
end form;
