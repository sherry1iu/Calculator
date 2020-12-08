----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 09/01/2020 10:42:21 AM
-- Design Name: 
-- Module Name: caveman_division - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

entity long_division is
  Port ( 
        clk       :   in std_logic;
        divide_me :   in unsigned (15 downto 0);
        divide_by :   in unsigned (15 downto 0);
        
        div_en    :   in std_logic;
        
        quot      :   out unsigned (15 downto 0);
        div_done  :   out std_logic
             );
end long_division;

architecture Behavioral of long_division is

signal quotient : unsigned (15 downto 0) := (others => '0');
signal total : unsigned (15 downto 0) := (others => '0');

begin

    div_proc: process(clk, total, divide_by)
    begin
        if rising_edge(clk) then
        if div_en = '1' then
            if (total + divide_by) > divide_me then
                div_done <= '1';
                total <= total;
                quotient <= quotient;
            else
                div_done <= '0';
                total <= total + divide_by;    
                quotient <= quotient + 1;
            end if;
        else
            quotient <= (others => '0');
            total <= (others => '0');
        end if;
        end if;
    end process; 
    
    quot <= quotient;

end Behavioral;
