----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/31/2020 06:04:45 PM
-- Design Name: 
-- Module Name: divetest_tb - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity divetest_tb is
--  Port ( );
end divetest_tb;

architecture Behavioral of divetest_tb is
component datapath is 
  Port ( 
    clk     :   in  std_logic;
    current   :   in  std_logic_vector (15 downto 0);
    total :  in std_logic_vector(15 downto 0);
    result : out std_logic_vector(9 downto 0)

  );
 end component;
  
  
      signal clk : std_logic := '0';
          constant sclk_period : time := 500 ns;		   -- 2 MHz serial clock
signal current :std_logic_vector (15 downto 0);
    signal total :   std_logic_vector(15 downto 0);
 signal   result :  std_logic_vector(9 downto 0);

  
begin

uut: datapath
    port map ( clk => clk, current => current, total => total, result => result); -- => take_sample, x => x, y => y);
    
-- Clock process definitions
clk_process: process
begin
    clk <= '0';
    wait for sclk_period/2;
    clk <= '1';
    wait for sclk_period/2;
end process;
           
-- Stimulus process
stim_process:  process
begin

    total <= "0000000000001000";
    current <= "0000000000000100";
    
    wait for 5*sclk_period;

    total <= "0000000000000110";
    current <= "0000000000000101";

wait;

end process;
end Behavioral;
