library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity cpu_1 is
	port (clk, rst: in std_logic; final_out: out std_logic_vector(15 downto 0));
end entity cpu_1 ;

architecture main of cpu_1 is

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

component reg is
	port (input: in std_logic_vector(15 downto 0);
			en, clk: in std_logic;
			output: out std_logic_vector(15 downto 0));
end component reg;

component reg_file is
	port (A1, A2, A3: in std_logic_vector(2 downto 0);
			D1, D2: out std_logic_vector(15 downto 0);
			D3: in std_logic_vector(15 downto 0);
			clk, rf_write: in std_logic);
end component reg_file;

component MUX_4x2 is
  port (output: out std_logic_vector (15 downto 0);
    sel: in std_logic_vector (1 downto 0);
    in_0, in_1, in_2, in_3: in std_logic_vector (15 downto 0));
end component MUX_4x2;

component MUX_2x1 is
  port (output: out std_logic_vector (15 downto 0);
    sel: in std_logic;
    in_0, in_1: in std_logic_vector (15 downto 0));
end component MUX_2x1;

component Memory is
    Port ( clk,w_flag,r_flag : in STD_LOGIC;
           address : in STD_LOGIC_VECTOR(15 downto 0);
           data_w : in STD_LOGIC_VECTOR(15 downto 0);
           data_r : out STD_LOGIC_VECTOR(15 downto 0));
end component Memory;

component alu is
	port(
		ALU_A, ALU_B: in std_logic_vector(15 downto 0);
		ALU_op: in std_logic_vector(2 downto 0);
		ALU_Z, ALU_Carry: out std_logic;
		ALU_C: out std_logic_vector(15 downto 0));		
end component alu;

	

	--No component for left shift. Do it on the go
	
	type FSMState is (S1, S2, S3, S4, S5, S6, S7, S8, S9, S10, S11, S12, S13, S14, S15, S16, 
		S17, S18, S19, S20);
	signal fsm_state: FSMState;
	signal instr_reg, program_counter: std_logic_vector(15 downto 0);
	signal MEM_A, MEM_D, MEM_DOUT, ALU_A, ALU_B, ALU_C, RF_D1, RF_D2, RF_D3, SIGN_EXTENDER_6_OUTPUT, SIGN_SHIFTER_6_OUTPUT, SIGN_SHIFTER_9_OUTPUT : std_logic_vector(15 downto 0);
	signal RF_A1, RF_A2, RF_A3 : std_logic_vector(2 downto 0);
	signal T1, T2, T3, TZ: std_logic_vector(15 downto 0);
	signal ALU_SEL : std_logic_vector(2 downto 0);
	signal SIGN_EXTENDER_6_INPUT : std_logic_vector(5 downto 0);
	signal SIGN_SHIFTER_6_INPUT : std_logic_vector(5 downto 0);
	signal SIGN_SHIFTER_9_INPUT : std_logic_vector(8 downto 0);
	signal rf_write_in, w_en, r_en : std_logic;


	
	begin

		memory_unit : Memory port map (
			clk, w_en, r_en, MEM_A, MEM_D, MEM_DOUT
		);
		
		Arithmetic_Logical_Unit : alu port map (
			ALU_A, ALU_B, ALU_SEL,alu_z,alu_carry,ALU_C
		);


		Register_file : reg_file port map (
			RF_A1, RF_A2, RF_A3, RF_D3, RF_D1, RF_D2, RF_WRITE_IN, clk
		);

		Signed_Extender_6 : SE6 port map (
			SIGN_EXTENDER_6_INPUT, SIGN_EXTENDER_6_OUTPUT
		);
		
		Signed_Shifter_6 : SE6_shifter port map (
			SIGN_SHIFTER_6_INPUT, SIGN_SHIFTER_6_OUTPUT
		);

		Signed_Shifter_9 : SE9_shifter port map (
			SIGN_SHIFTER_9_INPUT, SIGN_SHIFTER_9_OUTPUT
		);

		
		process(clk, fsm_state)

 --signal MEM_WRITE_BAR_ENABLE := std_logic;


		variable next_fsm_state_var : FSMState;
		variable RF_WRITE_IN_var : std_logic;
		variable next_PC, temp_T1, temp_T2, temp_T3, temp_TZ, instr_reg_var : std_logic_vector(15 downto 0);
		

		begin
		
		next_fsm_state_var :=  fsm_state;
		next_PC := program_counter;
		temp_T1 := T1;
		temp_T2 := T2;
		temp_T3 := T3;
		temp_TZ := TZ;


		instr_reg_var := instr_reg;

		--MEM_WRITE_BAR_ENABLE_var := MEM_WRITE_BAR_ENABLE;
		--RF_WRITE_IN_var := RF_WRITE_IN;


		case( fsm_state ) is
			when S1 =>
--				MEM_WRITE_BAR_ENABLE<='1';
			
				rf_write <= '0';
				w_en <= '0';
				r_en <= '1';
				
				
				MEM_A <= program_counter;
				instr_reg_var := MEM_DOUT;
				
				ALU_A <= program_counter;
				ALU_B <= x”0001";
				ALU_SEL <= "000";
				next_PC := ALU_C;
				
				case (instr_reg(15 downto 12)) is
					when "0001" =>
						next_fsm_state_var := S5;
					when "0000" | "0010" | "0011" | "0100" | "0101" | "0110" | "1011" | "1100"  =>
						next_fsm_state_var := S2;
					when "1010" =>
						next_fsm_state_var := S8;
					when "1111" | "1101" =>
						next_fsm_state_var := S14;
					when "1000" =>
						next_fsm_state_var := S18;
					when "1001" =>
						next_fsm_state_var := S20;
					when others =>
						null;
				end case;
			
			when S2 =>
--				MEM_WRITE_BAR_ENABLE<='1';
				
				rf_write <= '0';
				w_en <= '0';
				r_en <= '0';
				alu_sel <= "000" ;
				
				
				RF_A1 <= instr_reg(11 downto 9);
				RF_A2 <= instr_reg(8 downto 6);
				temp_T1:=RF_D1; 
				temp_T2:=RF_D2;
				
				case (instr_reg(15 downto 12)) is
					when "0000" |"0010" | "0011" | "0100" | "0101" | "0110" =>
						next_fsm_state_var := S3;
					when "1011" =>
						next_fsm_state_var := S6;
					when "1111" =>
						next_fsm_state_var := S15;
					when "1100" =>
						next_fsm_state_var := S12;
					when others =>
						null;
				end case;

			when S3 =>
--				MEM_WRITE_BAR_ENABLE<='1';
				
				
				rf_write <= '0';
				w_en <= '0';
				r_en <= '0';

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

	
				next_fsm_state_var := S4;

			when S4 =>
--				MEM_WRITE_BAR_ENABLE<='1';
				
				rf_write <= '1';
				w_en <= '0';
				r_en <= '0';
				alu_sel <= "000";
				
				RF_D3 <= T3; 
				instr_reg(5 downto 3) <= RF_A3;
				
				next_fsm_state_var := S1;

			when S5 =>
				
--				MEM_WRITE_BAR_ENABLE<='1
				rf_write<= '0';
				w_en <= '0';
				r_en <= '0';
				alu_sel <= "000";
				
				RF_A1 <= instr_reg(11 downto 9); 
				temp_T1 := RF_D1;

				next_fsm_state_var := S6;

			when S6 =>
--				MEM_WRITE_BAR_ENABLE<='1';
				
				rf_write <= '0';
				w_en <= '0';
				r_en <= '0';
			
				
				ALU_A <= T1;
				SIGN_EXTENDER_6_INPUT <= instr_reg(5 downto 0);
				ALU_B <= SIGN_EXTENDER_6_OUTPUT;
				ALU_SEL <= "000";
				temp_T3 := ALU_C;

				case (instr_reg(15 downto 12)) is
					when "0001" =>
						next_fsm_state_var := S7;
					when "1010" =>
						next_fsm_state_var := S9;
					when "1011" =>
						next_fsm_state_var := S11;
					when others =>
						null;
				end case;
			
			when S7 =>
				
--				MEM_WRITE_BAR_ENABLE<='1';
				rf_write <= '1';
				w_en <= '0';
				r_en <= '0';
				alu_sel <= "000";
				
				RF_D3 <= T3; 
				RF_A3 <= instr_reg(8 downto 6);

				next_fsm_state_var:= S1;

			when S8 =>
				
--				MEM_WRITE_BAR_ENABLE<='1';
				rf_write <= '0';
				w_en <= '0';
				r_en <= '0';
				alu_sel <= "000";
				
				RF_A1 <= instr_reg(8 downto 6);
				temp_T1 := RF_D1;

				next_fsm_state_var := S6;

			when S9 =>
			
--				MEM_WRITE_BAR_ENABLE<='1';
				rf_write<= '0';
				w_en <= '0';
				r_en <= '1';
				alu_sel <= "000";
				
				MEM_A <= T3;
				temp_T3 := MEM_D;

				next_fsm_state_var:=S10;

			when S10 =>
--				MEM_WRITE_BAR_ENABLE<='1';
			
				
				rf_write <= '1';
				w_en <= '0';
				r_en <= '0';
				alu_sel <= "000";
				
				RF_D3 <= T3;
				RF_A3 <= instr_reg(11 downto 9);

				next_fsm_state_var := S1;

			when S11 =>
				
--				MEM_WRITE_BAR_ENABLE<='1';
				rf_write<= '0';
				w_en <= '1';
				r_en <= '0';
				alu_sel <= "000";
				
				MEM_A <= T3;
				MEM_D <= T2;

				next_fsm_state_var := S1;

			when S12 =>
				
				--MEM_WRITE_BAR_ENABLE<='1';
				--MEM_WRITE_BAR_ENABLE <= '0';
				rf_write <= '0';
				w_en <= '0';
				r_en <= '0';
				
				ALU_A <= T1;
				ALU_B <= T2;
				ALU_SEL <= "001";
				temp_TZ := ALU_C;
				
			  if (temp_TZ = "0000000000000000") then
				next_fsm_state_var:= S1;
			  else 
				next_fsm_state_var:= S13;
			  end if;

			when S13 =>
--				MEM_WRITE_BAR_ENABLE<='1';
				
				rf_write <= '0';
				w_en <= '0';
				r_en <= '0';
				
				ALU_A <= program_counter;
				ALU_B <= x"0001";
				ALU_SEL <= "001";
				next_PC := ALU_C;

				next_fsm_state_var := S14;

			when S14 =>
				
--				MEM_WRITE_BAR_ENABLE<='1';
				rf_write<= '0';
				w_en <= '0';
				r_en <= '0';
				
				ALU_A <= program_counter;
				SIGN_SHIFTER_6_INPUT <= instr_reg(5 downto 0);
				ALU_B <= SIGN_SHIFTER_6_OUTPUT;
				ALU_SEL <= "000";
				next_PC := ALU_C;

				case (instr_reg(15 downto 12)) is
					when "1101" =>
					 next_fsm_state_var := S15;
					when "1111" =>
					 next_fsm_state_var := S2;
					when others =>
					 null;
				end case;

			when S15 =>
				
--				MEM_WRITE_BAR_ENABLE<='0';
				rf_write <= '1';
				w_en <= '0';
				r_en <= '0';
				alu_sel <= "000";
				
				RF_D3 <= program_counter; 
				RF_A3 <= instr_reg(11 downto 9);
				
				case (instr_reg(15 downto 12)) is
					when "1101" =>
						next_fsm_state_var := S17;
					when "1111" =>
						next_fsm_state_var := S16;
					when others =>
						null;
				end case;

			when S16 =>
				
--				MEM_WRITE_BAR_ENABLE<='1';
				rf_write <= '0';
				w_en <= '0';
				r_en <= '0';
				alu_sel <= "000";
				
				program_counter <= T2;
				
				next_fsm_state_var := S1;

			when S17 =>
				
--				MEM_WRITE_BAR_ENABLE<='1';
				rf_write <= '0';
				w_en <= '0';
				r_en <= '0';
				
				ALU_A <= program_counter;
				SIGN_SHIFTER_9_INPUT <= instr_reg(8 downto 0);
				ALU_B <= SIGN_SHIFTER_9_OUTPUT;
				ALU_SEL <= "000";
				next_PC := ALU_C;
				
				next_fsm_state_var:=S1;

			when S18 =>
				
--				MEM_WRITE_BAR_ENABLE<='1';
				rf_write <= '0';
				w_en <= '0';
				r_en <= '0';
				
				temp_T3 := instr_reg(8 downto 0) & "0000000";
				
				next_fsm_state_var := S19;

			when S19 =>
--				MEM_WRITE_BAR_ENABLE<='1';
				
				rf_write <= '1';
				w_en <= '0';
				r_en <= '0';
				alu_sel <= "000";
				
				RF_A3 <= instr_reg(11 downto 9);
				RF_D3 <= T3;
				
				next_fsm_state_var:=S1;

			when S20 =>
			
--				MEM_WRITE_BAR_ENABLE<='1';
				rf_write <= '0';
				w_en <= '0';
				r_en <= '0';
			
				temp_T3 := "0000000" & instr_reg(8 downto 0);
				
				next_fsm_state_var := S19;

			when others =>
				null;
		end case;
		T1 <= temp_T1; 
		T2 <= temp_T2; 
		T3 <= temp_T3;
		TZ <= temp_TZ;
		instr_reg <= instr_reg_var;

		if(clk='1' and clk'event) then
			if (rst = '1') then
				program_counter <= x"0000";
				fsm_state <= S1;
			else
				fsm_state <= next_fsm_state_var;
				program_counter <= next_PC;	
			end if;
		end if;
	end process;
end main;

