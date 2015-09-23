--***************************************************************************************************
 --*	Author: Tsotne Putkaradze, tsotnep@gmail.com
 --*	Professor: Peeter Ellervee
 --*	Lab Assitant: Siavoosh Payandeh Azad, Muhammad Adeel Tajammul
 --*	University: Tallinn Technical University, subject: IAY0340
 --*	Board: //simulation only
 --*	Manual of Board:
 --*	Manual of Board:
 --*	Description of Software:
 --*		FIR Filter : main file, coefficients are written below
 --*
 --* 	copyright: you can use anything from here, you can also add some manual
 --***************************************************************************************************/
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_signed.all;

entity Tsotne_FIR_RIPPLECARRY is
	port(data_in    : in  signed(15 downto 0);
		 data_out    : out signed(15 downto 0);
		 sample, clk : in  bit);
end Tsotne_FIR_RIPPLECARRY;

architecture rtl of Tsotne_FIR_RIPPLECARRY is

-- (0.125, 0.25, -0.75, 0.75, 1.0, 0.75, -0.75, 0.25, 0.125)-- my coefficients
	constant who_cares 	: signed(15 downto 0) := "----------------";
	constant ZERO 			: signed(15 downto 0) := "0000000000000000";

	-- State - type & signals
	type state_type is (S0, S1, S2, S3);
	signal state, next_state : state_type;

	signal del_0, del_1, del_2, del_3, del_4, del_5, del_6, del_7, del_8, 
	regA, regB, regC,	
	add1_out, add2_out, AddSub3_out : signed(15 downto 0);

	
	-- Shifters
	function asr3(inp : signed(15 downto 0)) return signed is
	begin
		return inp(15) & inp(15) & inp(15) & inp(15 downto 3);
	end asr3;
	
	function asr2(inp : signed(15 downto 0)) return signed is
	begin
		return inp(15) & inp(15) & inp(15 downto 2);
	end asr2;

begin

	-- Next state function of the state machine
	process(state, sample)
	begin
		case state is
			when S0 => 
				if sample = '1' then	next_state <= S1;
									 else next_state <= S0;
				end if;
			when S1 => next_state <= S2;
			when S2 => next_state <= S3;
			when S3 => next_state <= S0;
		end case;

	end process;

	-- State register
	process(clk)
	begin
		if clk'event and clk = '1' then
			state <= next_state;
		end if;
	end process;

	-- Input/output buffers
	process(clk)
	begin
		if clk'event and clk = '1' then		
			if state = S0 then --input
				del_0 	<= data_in;
			end if;
			if state = S1 then --output
				data_out	<= regA;
			end if;
		end if;
	end process;

	-- Data registers
	process(clk)
	begin
		if clk'event and clk = '1' then
			regA <= add1_out;
			regB <= add2_out;
			regC <= AddSub3_out;
		end if;
	end process;

	-- Shift register
	process(clk)
	begin
		if clk'event and clk = '1' then
			if state = S3 then
				del_8 <= del_7;
				del_7 <= del_6;
				del_6 <= del_5;
				del_5 <= del_4;
				del_4 <= del_3;
				del_3 <= del_2;
				del_2 <= del_1;
				del_1 <= del_0;
			end if;
		end if;
	end process;

	-- Adder #1 & its multiplexers
	process(del_0, del_8, del_4, regA, regB, regC, state)
	variable A_Adder1, B_Adder1 : signed(15 downto 0);
	begin
		case state is
			when S0 => A_Adder1 := regA;			B_Adder1 := regC;
			when S1 => A_Adder1 := del_0;			B_Adder1 := del_8;
			when S2 => A_Adder1 := asr3(regA);	B_Adder1 := asr2(regB);
			when S3 => A_Adder1 := regA;			B_Adder1 := del_4;
		end case;
		add1_out <= A_Adder1 + B_Adder1;
	end process;

	-- Adder #2 & its multiplexers
	process(del_1, del_7, del_2, del_6, regB, regC, state)
	variable A_Adder2, B_Adder2 : signed(15 downto 0);
	begin
		case state is
			when S0 => A_Adder2 := del_2;			B_Adder2 := del_6;
			when S1 => A_Adder2 := del_1;			B_Adder2 := del_7;
			when S2 => A_Adder2 := who_cares;	B_Adder2 := who_cares;
			when S3 => A_Adder2 := who_cares;	B_Adder2 := who_cares;
		end case;
		add2_out <= A_Adder2 + B_Adder2;
	end process;

	-- Adder_Subtracter #3 & its multiplexers
	process(del_3, del_5, regB, regC, state)
	variable IfAddWriteZero : STD_LOGIC :='0';		
	variable A_Adder3, B_Adder3, Bnew : signed(15 downto 0);
	begin
		IfAddWriteZero := '0';
		case state is
			when S0 => A_Adder3 := del_3;			B_Adder3 := del_5;
			when S1 => A_Adder3 := regC;			B_Adder3 := regB; 		IfAddWriteZero :='1';
			when S2 => A_Adder3 := regC;			B_Adder3 := asr2(regC); IfAddWriteZero :='1';
			when S3 => A_Adder3 := regC;			B_Adder3 := ZERO;
		end case;
		if IfAddWriteZero = '1' then
			Bnew := CONV_SIGNED(CONV_INTEGER(NOT CONV_STD_LOGIC_VECTOR(B_Adder3,16)+'1'),16); --NOT
		else
			Bnew := B_Adder3;
		end if;
		AddSub3_out <= A_Adder3 + Bnew;
	end process;
	
end rtl;

