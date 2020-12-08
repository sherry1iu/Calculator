----------------------------------------------------------------------------------
-- Course:	 		 Engs 31 16S
-- 
-- Create Date:      15:44:25 07/25/2009 
-- Design Name: 
-- Module Name:      lab5top - Behavioral 
-- Project Name:	 Lab 5 
-- Target Devices:   Spartan 6 / Nexys 3
-- Tool versions:    ISE 14.4
-- Description:      Top level shell for Lab 5 (RS-232 serial link)
--
-- Dependencies:     SerialRx.vhd (eventually, SerialTx.vhd)
--
-- Revision: 
-- Revision 0.01 - File Created
--		Revised (EWH) 7.19.2014 for Nexys3 board and updated lab flow
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.numeric_std.all;

library UNISIM;					-- needed for the BUFG component
use UNISIM.Vcomponents.ALL;

entity lab5top is
    Port ( Clk : in  STD_LOGIC;					-- 100 MHz board clock
           RsRx  : in  STD_LOGIC;				-- Rx input
		   
		   seg	: out std_logic_vector(0 to 6);
           dp   : out std_logic;
           an 	: out std_logic_vector(3 downto 0) );
           
end lab5top;


architecture Structural of lab5top is

-- Signals for the 100 MHz to 10 MHz clock divider
constant CLOCK_DIVIDER_VALUE: integer := 5;
signal clkdiv: integer := 0;			-- the clock divider counter
signal clk_en: std_logic := '0';		-- terminal count
signal clk10: std_logic;				-- 10 MHz clock signal

-- Other signals
signal rx_data : std_logic_vector(7 downto 0);
signal rx_done_tick : std_logic;

signal result : std_logic_vector (9 downto 0);
signal neg : std_logic;

signal neg_sign : std_logic_vector (3 downto 0) := "0000";
signal bcd_result: std_logic_vector (11 downto 0);

signal dummy_var: STD_LOGIC; 
signal dummy_var2: STD_LOGIC; 



-- Component declarations
COMPONENT SerialRx
	PORT( Clk : IN std_logic;
		  RsRx : IN std_logic;    
		  rx_data :  out std_logic_vector(7 downto 0);
		  rx_done_tick : out std_logic;
		  dummy_var: out STD_LOGIC;
		  dummy_var2: out STD_LOGIC );
END COMPONENT;


component datapath is
  Port ( 
    clk     :   in  std_logic;
    input   :   in  std_logic_vector (7 downto 0);
    data_ready  :   in  std_logic;
    
    dummy_var : in STD_LOGIC ;
    dummy_var2 : in STD_LOGIC ;
    
    result  :   out std_logic_vector (9 downto 0);
    neg     :   out std_logic);
end component;


component binary_bcd is 
    port(
        clk, reset: in std_logic;
        binary_in: in std_logic_vector(9 downto 0);
        bcd_out: out std_logic_vector(11 downto 0) );
end component;

component mux7seg is
    Port ( 	clk : in  STD_LOGIC;
           	y0, y1, y2, y3 : in  STD_LOGIC_VECTOR (3 downto 0);	
           	dp_set : in std_logic_vector(3 downto 0);					
           	seg : out  STD_LOGIC_VECTOR (0 to 6);	
          	dp : out std_logic;
           	an : out  STD_LOGIC_VECTOR (3 downto 0) );			
end component;
-------------------------
	
begin

-- Clock buffer for 10 MHz clock
-- The BUFG component puts the slow clock onto the FPGA clocking network
Slow_clock_buffer: BUFG
      port map (I => clk_en,
                O => clk10 );

-- Divide the 100 MHz clock down to 20 MHz, then toggling the 
-- clk_en signal at 20 MHz gives a 10 MHz clock with 50% duty cycle
Clock_divider: process(clk)
begin
	if rising_edge(clk) then
	   	if clkdiv = CLOCK_DIVIDER_VALUE-1 then 
	   		clk_en <= NOT(clk_en);		
			clkdiv <= 0;
		else
			clkdiv <= clkdiv + 1;
		end if;
	end if;
end process Clock_divider;

negative: process(neg)
begin
    if neg = '0' then
        neg_sign <= "0000";
    else
        neg_sign <= "1111";
    end if;
end process negative;


Receiver: SerialRx PORT MAP(
		Clk => clk10,				-- receiver is clocked with 10 MHz clock
		RsRx => RsRx,
		rx_data => rx_data,
		rx_done_tick => rx_done_tick  ,
		
		dummy_var => dummy_var );
		
		
Datapath1 : datapath port map(
    clk => clk10,
    input => rx_data,
    data_ready => rx_done_tick,    
    result => result,
    neg => neg,
    
    dummy_var => dummy_var,
    dummy_var2 => dummy_var2
); 		


display: mux7seg port map( 
            clk => clk10,				
           	y3 => neg_sign, 	       
           	y2 => bcd_result(11 downto 8),  	
           	y1 => bcd_result(7 downto 4), 		
           	y0 => bcd_result(3 downto 0),		
           	dp_set => "0000",           -- decimal points off
          	seg => seg,
          	dp => dp,
           	an => an );
           	
bin2bcd: binary_bcd port map(
    clk => clk10,
    reset => '0', -- do we need this?
    binary_in => result,
    bcd_out => bcd_result);


		
end Structural;
