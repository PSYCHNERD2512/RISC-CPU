library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu is
	port (clk, rst: in std_logic); 
end entity cpu;

architecture main of cpu is

component Memory is
    port (clk, w_flag, r_flag : in std_logic;
				address, data_w : in std_logic_vector(15 downto 0);
				data_r : out std_logic_vector(15 downto 0));
end component Memory;

component reg_file is
	port (A1, A2, A3: in std_logic_vector(2 downto 0);
			D3: in std_logic_vector(15 downto 0);
			clk, rf_write: in std_logic;
			D1, D2: out std_logic_vector(15 downto 0));	
end component reg_file;

component alu is
  port (alu_a, alu_b: in std_logic_vector(15 downto 0);
		alu_sel: in std_logic_vector(2 downto 0);
		alu_c: out std_logic_vector(15 downto 0));
end component alu;

component SE6_shifter is
	port (input: in std_logic_vector(5 downto 0);
			output: out std_logic_vector(15 downto 0));
end component SE6_shifter;

component SE9_shifter is
	port (input: in std_logic_vector(8 downto 0);
			output: out std_logic_vector(15 downto 0));
end component SE9_shifter;

component SE6 is
	port (input: in std_logic_vector(5 downto 0);
			output: out std_logic_vector(15 downto 0));
end component SE6;
	

	type FSMState is (S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, 
		S17, S18, S19, S20);
	signal fsm_state: FSMState;
	signal instr_reg: std_logic_vector(15 downto 0):="0000000000000000";
	
	signal MEM_ADD, MEM_Din, MEM_Dout: std_logic_vector(15 downto 0);
	signal rf_write_in, w_en, r_en : std_logic;

	signal ALU_A, ALU_B, ALU_C: std_logic_vector(15 downto 0);
	signal ALU_SEL : std_logic_vector(2 downto 0);

	signal RF_D1, RF_D2, RF_D3:  std_logic_vector(15 downto 0);
	signal RF_A1, RF_A2, RF_A3 : std_logic_vector(2 downto 0);
	signal T1, T2, T3, TZ: std_logic_vector(15 downto 0);
	
	signal SIGN_EXTENDER_6_INPUT, SIGN_SHIFTER_6_INPUT : std_logic_vector(5 downto 0);
	signal SIGN_SHIFTER_9_INPUT : std_logic_vector(8 downto 0);
	signal SIGN_EXTENDER_6_OUTPUT, SIGN_SHIFTER_6_OUTPUT, SIGN_SHIFTER_9_OUTPUT : std_logic_vector(15 downto 0);
	
	signal next_fsm_state_var : FSMState;
	signal next_PC : std_logic_vector(15 downto 0):="0000000000000000";
	
	begin

		memory_unit : Memory port map (clk, w_en, r_en, MEM_ADD, MEM_Din, MEM_Dout);
		
		Arithmetic_Logical_Unit : alu port map (ALU_A, ALU_B, ALU_SEL,ALU_C);

		Register_file : reg_file port map (RF_A1, RF_A2, RF_A3, RF_D3, clk, RF_WRITE_IN, RF_D1, RF_D2);

		Signed_Extender_6 : SE6 port map (SIGN_EXTENDER_6_INPUT, SIGN_EXTENDER_6_OUTPUT);
		
		Signed_Shifter_6 : SE6_shifter port map (SIGN_SHIFTER_6_INPUT, SIGN_SHIFTER_6_OUTPUT);

		Signed_Shifter_9 : SE9_shifter port map (SIGN_SHIFTER_9_INPUT, SIGN_SHIFTER_9_OUTPUT);

		
		process(fsm_state, MEM_Dout, instr_reg, MEM_ADD, MEM_Din, ALU_C)

		variable temp_T1, temp_T2, temp_T3, temp_TZ, instr_reg_var: std_logic_vector(15 downto 0);

		begin
		
		temp_T1 := T1;
		temp_T2 := T2;
		temp_T3 := T3;
		temp_TZ := TZ;		

		case(fsm_state) is
			when S1 =>
				-- control statements
				rf_write_in <= '1';
				w_en <= '0';
				r_en <= '1';

				-- dataflow
				RF_A1 <= "111";
				
				MEM_ADD <= RF_D1;
				instr_reg <= MEM_Dout;

				ALU_A <= RF_D1;
				ALU_B <= x"0001";
				ALU_SEL <= "000";
				
				RF_D3 <= ALU_C; 
				RF_A3 <= "111";
			   
				-- state transition
				case (instr_reg(15 downto 12)) is
					when "0001" =>
						next_fsm_state_var <= S5;
					when "0000" | "0010" | "0011" | "0100" | "0101" | "0110" | "1011" | "1100"  =>
						next_fsm_state_var <= S2;
					when "1010" =>
						next_fsm_state_var <= S8;
					when "1111" | "1101" =>
						next_fsm_state_var <= S14;
					when "1000" =>
						next_fsm_state_var <= S18;
					when "1001" =>
						next_fsm_state_var <= S20;
					when others =>
						null;
				end case;
			
			when S2 =>
				-- control statements
				rf_write_in <= '0';
				w_en <= '0';
				r_en <= '0';
				ALU_SEL <= "000" ;
				
				-- dataflow				
				RF_A1 <= instr_reg(11 downto 9);
				RF_A2 <= instr_reg(8 downto 6);
				temp_T1 := RF_D1; 
				temp_T2 := RF_D2;
				
				-- state transition
				case (instr_reg(15 downto 12)) is
					when "0000" |"0010" | "0011" | "0100" | "0101" | "0110" =>
						next_fsm_state_var <= S3;
					when "1011" =>
						next_fsm_state_var <= S6;
					when "1111" =>
						next_fsm_state_var <= S15;
					when "1100" =>
						next_fsm_state_var <= S12;
					when others =>
						null;
				end case;

			when S3 =>
				-- control statements
				rf_write_in <= '0';
				w_en <= '0';
				r_en <= '0';

				-- dataflow
				ALU_A <= T1; 
				ALU_B <= T2;
				
				case (instr_reg(15 downto 12)) is
					when "0000" | "0001" =>
						ALU_SEL <= "000";
					when "0010" =>
						ALU_SEL <= "001";
					when "0011" =>
						ALU_SEL <= "010";
					when "0100" =>
						ALU_SEL <= "011";
					when "0101" =>
						ALU_SEL <= "100";
					when "0110" =>
						ALU_SEL <= "101";
					when others =>
						null;
				end case;
				
				temp_T3 := ALU_C;

				-- state transition
				next_fsm_state_var <= S4;

			when S4 =>
				-- control statements
				rf_write_in <= '1';
				w_en <= '0';
				r_en <= '0';
				ALU_SEL <= "000";
				
				-- dataflow
				RF_D3 <= T3; 
				RF_A3 <= instr_reg(5 downto 3) ;
				
				-- state transition
				next_fsm_state_var <= S1;

			when S5 =>
				-- control statements
				rf_write_in <= '0';
				w_en <= '0';
				r_en <= '0';
				ALU_SEL <= "000";

				-- dataflow
				RF_A1 <= instr_reg(11 downto 9); 
				temp_T1 := RF_D1;

				-- state transition
				next_fsm_state_var <= S6;

			when S6 =>
				-- control statements
				rf_write_in <= '0';
				w_en <= '0';
				r_en <= '0';
			
				-- dataflow
				ALU_A <= T1;
				SIGN_EXTENDER_6_INPUT <= instr_reg(5 downto 0);
				ALU_B <= SIGN_EXTENDER_6_OUTPUT;
				ALU_SEL <= "000";
				temp_T3 := ALU_C;

				-- state transition
				case (instr_reg(15 downto 12)) is
					when "0001" =>
						next_fsm_state_var <= S7;
					when "1010" =>
						next_fsm_state_var <= S9;
					when "1011" =>
						next_fsm_state_var <= S11;
					when others =>
						null;
				end case;
			
			when S7 =>
				-- control statements
				rf_write_in <= '1';
				w_en <= '0';
				r_en <= '0';
				ALU_SEL <= "000";

				-- dataflow				
				RF_D3 <= T3; 
				RF_A3 <= instr_reg(8 downto 6);

				-- state transition
				next_fsm_state_var<= S1;

			when S8 =>
				-- control statements
				rf_write_in <= '0';
				w_en <= '0';
				r_en <= '0';
				ALU_SEL <= "000";
				
				-- dataflow				
				RF_A1 <= instr_reg(8 downto 6);
				temp_T1 := RF_D1;

				-- state transition
				next_fsm_state_var <= S6;

			when S9 =>
				-- control statements
				rf_write_in <= '0';
				w_en <= '0';
				r_en <= '1';
				ALU_SEL <= "000";

				-- dataflow				
				MEM_ADD <= T3;
				temp_T3 := MEM_Din;

				-- state transition
				next_fsm_state_var<=S10;

			when S10 =>
				-- control statements
				rf_write_in <= '1';
				w_en <= '0';
				r_en <= '0';
				ALU_SEL <= "000";

				-- dataflow
				RF_D3 <= T3;
				RF_A3 <= instr_reg(11 downto 9);

				-- state transition
				next_fsm_state_var <= S1;

			when S11 =>
				-- control statements
				rf_write_in <= '0';
				w_en <= '1';
				r_en <= '0';
				ALU_SEL <= "000";

				-- dataflow				
				MEM_ADD <= T3;
				MEM_Din <= T2;			
				
				-- state transition
				next_fsm_state_var <= S1;

			when S12 =>
				-- control statements
				rf_write_in <= '0';
				w_en <= '0';
				r_en <= '0';

				-- dataflow				
				ALU_A <= T1;
				ALU_B <= T2;
				ALU_SEL <= "001";
				temp_TZ := ALU_C;
				
				-- state transition
				if (temp_TZ = "0000000000000000") then
					next_fsm_state_var<= S1;
				else 
					next_fsm_state_var<= S13;
				end if;

			when S13 =>
				-- control statements
				rf_write_in <= '0';
				w_en <= '0';
				r_en <= '0';
				
				-- dataflow				
				RF_A1 <= "111";
				ALU_A <= RF_D1;
				ALU_B <= x"0001";
				ALU_SEL <= "001";

				RF_A3 <= "111";
				RF_D3 <= ALU_C; 

				-- state transition
				next_fsm_state_var <= S14;

			when S14 =>
				-- control statements
				rf_write_in <= '0';
				w_en <= '0';
				r_en <= '0';

				-- dataflow			
				RF_A1 <= "111";
				ALU_A <= RF_D1;
				SIGN_SHIFTER_6_INPUT <= instr_reg(5 downto 0);
				ALU_B <= SIGN_SHIFTER_6_OUTPUT;
				ALU_SEL <= "000";
			
				RF_A3 <= "111";
				RF_D3 <= ALU_C; 
				
				-- state transition
				case (instr_reg(15 downto 12)) is
					when "1101" =>
					 next_fsm_state_var <= S15;
					when "1111" =>
					 next_fsm_state_var <= S2;
					when "1100" =>
						next_fsm_state_var<=S1;
					when others =>
					 null;
				end case;

			when S15 =>
				-- control statements
				rf_write_in <= '1';
				w_en <= '0';
				r_en <= '0';
				ALU_SEL <= "000";

				-- dataflow			
				RF_A1 <= "111";
				RF_A3 <= instr_reg(11 downto 9);
				RF_D3 <= RF_D1; 
				
				-- state transition
				case (instr_reg(15 downto 12)) is
					when "1101" =>
						next_fsm_state_var <= S17;
					when "1111" =>
						next_fsm_state_var <= S16;
					when others =>
						null;
				end case;

			when S16 =>
				-- control statements
				rf_write_in <= '1';
				w_en <= '0';
				r_en <= '0';
				ALU_SEL <= "000";
				
				-- dataflow			
				RF_D3 <= T2;
				RF_A3<="111";
				
				-- state transition
				next_fsm_state_var <= S1;

			when S17 =>
				-- control statements
				rf_write_in <= '1';
				w_en <= '0';
				r_en <= '0';
				
				-- dataflow			
				RF_A1 <= "111";
				ALU_A <= RF_D1;
				
				SIGN_SHIFTER_9_INPUT <= instr_reg(8 downto 0);
				ALU_B <= SIGN_SHIFTER_9_OUTPUT;
				ALU_SEL <= "000";
				
				RF_A3 <= "111";
				RF_D3 <= ALU_C; 
				
				-- state transition
				next_fsm_state_var<=S1;

			when S18 =>
				-- control statements
				rf_write_in <= '0';
				w_en <= '0';
				r_en <= '0';
				ALU_SEL <= "000";
				
				-- dataflow			
				temp_T3 := instr_reg(8 downto 0) & "0000000";
				
				-- state transition
				next_fsm_state_var <= S19;

			when S19 =>
				-- control statements
				rf_write_in <= '1';
				w_en <= '0';
				r_en <= '0';
				ALU_SEL <= "000";
				
				-- dataflow			
				RF_A3 <= instr_reg(11 downto 9);
				RF_D3 <= T3;

				-- state transition
				next_fsm_state_var <= S1;

			when S20 =>
				-- control statements
				rf_write_in <= '0';
				w_en <= '0';
				r_en <= '0';
				ALU_SEL <= "000";

				-- dataflow						
				temp_T3 := "0000000" & instr_reg(8 downto 0);

				-- state transition
				next_fsm_state_var <= S19;

			when others =>
				null;
		end case;
		
		T1 <= temp_T1; 
		T2 <= temp_T2; 
		T3 <= temp_T3;
		TZ <= temp_TZ;

		end process;
		
		clk_process: process(clk,rst)
		begin
			if (rst = '1') then
					fsm_state <= S1;
					
			elsif(clk='1' and clk'event) then
				fsm_state <= next_fsm_state_var;
			end if;
		end process;
	
end main;