--***************************************************************************************************
 --*	Author: Tsotne Putkaradze, tsotnep@gmail.com
 --*	Professor: Peeter Ellervee
 --*	Lab Assitant: Siavoosh Payandeh Azad, Muhammad Adeel Tajammul
 --*	University: Tallinn Technical University, subject: IAY0340
 --*	Board: //simulation only
 --*	Manual of Board:
 --*	Manual of Board:
 --*	Description of Software:
 --*		FIR Filter : test bench file
 --*
 --* 	copyright: you can use anything from here, you can also add some manual
 --***************************************************************************************************/
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;

entity Q_FIR is
end Q_FIR;

architecture testbench of Q_FIR is

 --Component declaration for FIR_beh or FIR_rtl
  component Tsotne_FIR_RIPPLECARRY  is
  port ( data_in: in signed (15 downto 0);
         data_out: out signed (15 downto 0);
         sample, clk: in bit );
  end component;
  
 --Local signal declarations
  signal Din: signed( 15 downto 0 ) ;
  signal Dout: signed( 15 downto 0 ); 
  signal samp, clock : bit ;
  constant T: time := 40 ns; 
  signal debug_out : real ;

begin
--Component instantiation of fir_filter
  FIR_comp: Tsotne_FIR_RIPPLECARRY port map (Din, Dout, samp, clock);
  --clock value generation  
  clock <= not clock after 10 ns ;
-- simulate clock  
clocksim: process 
  begin
    wait on clock until clock<='0';
    samp <= '1';
    wait for T/2;
    samp <= '0';
    wait for T;
  end process clocksim;
  
 --To output real number in VHDL
 debug_out <= real(conv_integer(Dout))/1024.0 ;
 
 --input testing process 
input_test: process
  begin
    Din <= "0000000000000000";
    wait for 1000 ns;
    wait on clock until clock<='0' and samp<='1'; 
    Din <= "0000010000000000" ;
    wait for 100 ns;
    Din <= "0000000000000000";
    wait;
  end process input_test; 
end testbench;

