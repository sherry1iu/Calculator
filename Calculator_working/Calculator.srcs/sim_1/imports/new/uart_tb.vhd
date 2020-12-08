--------------------------------------------------------------------------------
-- Course:	 		Engs 31 16S
--
-- Create Date:   17:11:39 07/25/2009
-- Design Name:   
-- Module Name:   SerialRx_tb.vhd
-- Project Name:  Lab5
-- Target Device:  
-- Tool versions:  
-- Description:   
-- 
-- VHDL Test Bench Created by ISE for module: SerialRx
-- 
-- Dependencies:
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:

--------------------------------------------------------------------------------
LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.all;
 
ENTITY SerialRx_tb IS
END SerialRx_tb;
 
ARCHITECTURE behavior OF SerialRx_tb IS 
 
component lab5top is
    Port ( Clk : in  STD_LOGIC;					-- 100 MHz board clock
           RsRx  : in  STD_LOGIC;				-- Rx input
--		   RsTx  : out  STD_LOGIC;				-- Tx output
           --
           -- Testing ports
--           clk10_p : out std_logic;				-- 10 MHz clock
--           RsRx_p : out std_logic;				-- serial data stream
--		   rx_shift_p : out std_logic;			-- Rx register shift           
--		   rx_done_tick_p : OUT  std_logic;	-- data ready
--           result_p : out std_logic_vector(9 downto 0);
		   
		   seg	: out std_logic_vector(0 to 6);
           dp   : out std_logic;
           an 	: out std_logic_vector(3 downto 0) );
           
end component lab5top;
   

   --Inputs
   signal clk : std_logic := '0';
   signal RsRx : std_logic := '1';

 	--Outputs
   signal rx_shift_p : std_logic;
   --signal rx_data : std_logic_vector(7 downto 0);
   signal rx_done_tick_p : std_logic;
   signal clk10_p: std_logic;
   signal RsRx_p: std_logic;
   signal RsTx: std_logic; 
   signal result_p: std_logic_vector(9 downto 0);

   -- Clock period definitions
   constant clk_period : time := 10ns;		-- 100 MHz clock
	
	-- Data definitions
	constant bit_time : time := 104us;		-- 9600 baud
--	constant bit_time : time := 8.68us;		-- 115,200 baud
--	constant TxData : std_logic_vector(7 downto 0) := "00111000";--"00111001";
	
	constant zero : std_logic_vector(7 downto 0) := "00110000";
    constant one : std_logic_vector(7 downto 0) := "00110001";
	constant two : std_logic_vector(7 downto 0) := "00110010";
	constant three : std_logic_vector(7 downto 0) := "00110011";
	constant four : std_logic_vector(7 downto 0) := "00110100";
	constant five : std_logic_vector(7 downto 0) := "00110101";
    constant six : std_logic_vector(7 downto 0) := "00110110";
	constant seven : std_logic_vector(7 downto 0) := "00110111";
	constant eight : std_logic_vector(7 downto 0) := "00111000";
    constant nine : std_logic_vector(7 downto 0) := "00111001";
	
	constant plus : std_logic_vector(7 downto 0) := "00101011";
    constant equals : std_logic_vector(7 downto 0) := "00111101";
    constant times : std_logic_vector(7 downto 0) := "00101010";                -- *
    constant divided_by : std_logic_vector(7 downto 0) := "00101111";           -- /
    constant minus : std_logic_vector(7 downto 0) := "00101101";
	
	
	signal seg : STD_LOGIC_VECTOR(0 to 6);				    -- segments (a...g)
    signal dp : std_logic;
    signal an : STD_LOGIC_VECTOR (3 downto 0);
	
BEGIN 
	-- Instantiate the Unit Under Test (UUT)
   uut: lab5top PORT MAP (
          clk => clk,
          RsRx => RsRx,
--          RsTx => RsTx,
--          clk10_p => clk10_p,
--          RsRx_p => RsRx_p,
--          rx_shift_p => rx_shift_p,
--          rx_done_tick_p => rx_done_tick_p,
--          result_p => result_p,
          seg => seg,
          an => an,
          dp => dp
        );

   -- Clock process definitions
   clk_process :process
   begin
		clk <= '0';
		wait for clk_period/2;
		clk <= '1';
		wait for clk_period/2;
   end process;
 
   -- Stimulus process
   stim_proc: process
   begin		
		wait for 100 us;
		wait for 10.25*clk_period;		
		
		RsRx <= '0';		-- Start bit
		wait for bit_time;		
		for bitcount in 0 to 7 loop
			RsRx <= one(bitcount);                  --CHANGEME
			wait for bit_time;
		end loop;		
		RsRx <= '1';		-- Stop bit
		wait for 200 us;		
		RsRx <= '0';		-- Start bit
		wait for bit_time;		
		for bitcount in 0 to 7 loop
			RsRx <= seven(bitcount);                  --CHANGEME
			wait for bit_time;
		end loop;		
		RsRx <= '1';		-- Stop bit
		wait for 200 us;		
		RsRx <= '0';		-- Start bit
		wait for bit_time;		
		for bitcount in 0 to 7 loop
			RsRx <= divided_by(bitcount);                  --PLUS
			wait for bit_time;
		end loop;		
		RsRx <= '1';		-- Stop bit
		wait for 200 us;		
		RsRx <= '0';		-- Start bit
		wait for bit_time;		
		for bitcount in 0 to 7 loop
			RsRx <= five(bitcount);                  --CHANGENE
			wait for bit_time;
		end loop;		
		RsRx <= '1';		-- Stop bit
		wait for 200 us;		
		RsRx <= '0';		-- Start bit
		wait for bit_time;
		for bitcount in 0 to 7 loop
			RsRx <= nine(bitcount);                 --CHANGME
			wait for bit_time;
		end loop;				
		RsRx <= '1';		-- Stop bit
		wait for 200 us;		
		RsRx <= '0';		-- Start bit
		wait for bit_time;
		for bitcount in 0 to 7 loop
			RsRx <= equals(bitcount);                 --CHANGME
			wait for bit_time;
--		end loop;		
--		RsRx <= '1';		-- Stop bit
--		wait for 200 us;		
--		RsRx <= '0';		-- Start bit
--		wait for bit_time;		
--		for bitcount in 0 to 7 loop
--			RsRx <= two(bitcount);                --CHANGME
--			wait for bit_time;
--		end loop;		
--		RsRx <= '1';		-- Stop bit
--		wait for 200 us;		
--	   RsRx <= '0';		      -- Start bit
--		wait for bit_time;		
--		for bitcount in 0 to 7 loop
--			RsRx <= equals(bitcount);                 --CHANGME
--			wait for bit_time;
		end loop;		
		RsRx <= '1';		-- Stop bit
		wait for 200 us;

		
		wait;
   end process;
END;

