----------------------------------------------------------------------------------
-- Company: CS56
-- Engineer: Group 15
-- 
-- Create Date: 08/17/2020 10:27:48 PM
-- Design Name: 
-- Module Name: controller - Behavioral
-- Project Name: Calculator
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
use IEEE.NUMERIC_STD.ALL;


entity addition_controller is
  Port (    clk         :   in  std_logic;
            input       :   in  std_logic_vector (7 downto 0);
            
            data_ready  :   in  std_logic;
            
            idle_en     :   out std_logic;
            add_en      :   out std_logic;
            
            sub_en      :   out std_logic;
            mult_en     :   out std_logic;
            
            div_en      :   out std_logic;
            
            curr_neg    :   out std_logic;
            
            err_disp    :   out std_logic;
            dig_two     :   out std_logic_vector(1 downto 0);
            go          :   out std_logic
      );
end addition_controller;

architecture Behavioral of addition_controller is
    type state_type is (idle, add, error       -- );
    , subtract,  multiply
    , divide);
    signal curr_state, next_state : state_type;
    
    signal valid : std_logic := '0';
    signal numerical : std_logic := '0';
    
    signal dig_num : unsigned (1 downto 0) := "00";
    
    -- Binary for ascii table
    -- https://www.rapidtables.com/code/text/ascii-table.html
    constant zero : std_logic_vector(7 downto 0) := "00110000";
    constant nine : std_logic_vector(7 downto 0) := "00111001";
    
    constant times : std_logic_vector(7 downto 0) := "00101010";                -- *
    constant divided_by : std_logic_vector(7 downto 0) := "00101111";           -- /
    constant plus : std_logic_vector(7 downto 0) := "00101011";
    constant minus : std_logic_vector(7 downto 0) := "00101101";
    constant equals : std_logic_vector(7 downto 0) := "00111101";
        
begin


    FSM: process(input, curr_state, dig_num, valid)                               
  	begin
        next_state <= curr_state;
            case curr_state is
            
                when idle =>                
                    idle_en <= '1';
                    add_en <= '0';
                    sub_en <= '0';        
                    
                    mult_en <= '0'; 
                    div_en <= '0';
                   
                       
                    err_disp <= '0';    
                     
--                    if data_ready = '1' then               
                        if (input <= nine) and (input >= zero) then
                            next_state <= idle;
                            if dig_num = "11" then
                                next_state <= error;   
                            end if;
--                        elsif valid = '0' and input = minus then                        
--                            next_state <= idle;                
--                        elsif  valid = '1' then
                        else
                            if input = plus then
                                next_state <= add;
                            elsif input = minus then
                                next_state <= subtract;
                            elsif input = times then
                                next_state <= multiply;
                            elsif input = divided_by then
                                next_state <= divide;
                            elsif input = equals then
                                next_state <= idle;
                            else
                                next_state <= error;
                            end if;
--                        else
--                            next_state <= error;
                        end if;
--                    end if;
                                    
                when add =>
                    idle_en <= '0';
                    add_en <= '1';             
                    sub_en <= '0';  
                    
                    mult_en <= '0';
                    div_en <= '0';
                    
                    err_disp <= '0';        
                           
--                    if data_ready = '1' then
                         
                        if (input <= nine) and (input >= zero) then
                            next_state <= add;
                            
                            if dig_num = "11" then
                                next_state <= error;   
                            end if;      
--                        elsif valid = '0' and input = minus then
--                            next_state <= add;          
--                        elsif  valid = '1' then
                        else
                            if input = plus then
                                next_state <= add;
                            elsif input = minus then
                                next_state <= subtract;
                            elsif input = times then
                                next_state <= multiply;
                            elsif input = divided_by then
                                next_state <= divide;
                            elsif input = equals then
                                next_state <= idle;
                            else
                                next_state <= error;
                            end if;
--                        else
--                            next_state <= error;
                        end if;
--                    end if;
                
                when subtract =>
                    idle_en <= '0';
                    add_en <= '0';
                    sub_en <= '1';               
                    
                    mult_en <= '1';
                    div_en <= '0';
                    err_disp <= '0';
--                    if data_ready = '1' then
                         
                        if (input <= nine) and (input >= zero) then
                            next_state <= subtract;
                            
                            if dig_num = "11" then
                                next_state <= error;   
                            end if;           
--                        elsif valid = '0' and input = minus then
--                            next_state <= subtract;     
--                        elsif  valid = '1' then
                        else
                            if input = plus then
                                next_state <= add;
                            elsif input = minus then
                                next_state <= subtract;
                            elsif input = times then
                                next_state <= multiply;
                            elsif input = divided_by then
                                next_state <= divide;
                            elsif input = equals then
                                next_state <= idle;
                            else
                                next_state <= error;
                            end if;
--                        else
--                            next_state <= error;
                        end if;
--                    end if;

                when multiply =>
                    idle_en <= '0';
                    add_en <= '0';
                    sub_en <= '0'; 
                    mult_en <= '1';              
                    div_en <= '0';
                    err_disp <= '0';
--                    if data_ready = '1' then
                         
                        if (input <= nine) and (input >= zero) then
                            next_state <= multiply;
                           
                            if dig_num = "11" then
                                next_state <= error;   
                            end if;            
--                        elsif valid = '0' and input = minus then
--                            next_state <= multiply;    
--                        elsif  valid = '1' then
                        else
                            if input = plus then
                                next_state <= add;
                            elsif input = minus then
                                next_state <= subtract;
                            elsif input = times then
                                next_state <= multiply;
                            elsif input = divided_by then
                                next_state <= divide;
                            elsif input = equals then
                                next_state <= idle;
                            else
                                next_state <= error;
                            end if;
--                        else
--                            next_state <= error;
                        end if;
--                    end if;


                when divide =>
                    idle_en <= '0';
                    add_en <= '0';
                    sub_en <= '0'; 
                    mult_en <= '0';    
                    div_en <= '1';                 
                    err_disp <= '0';
--                    if data_ready = '1' then
                         
                        if (input <= nine) and (input >= zero) then
                            next_state <= divide;
                           
                            if dig_num = "11" then
                                next_state <= error;   
                            end if;            
--                        elsif valid = '0' and input = minus then
--                            next_state <= multiply;    
--                        elsif  valid = '1' then
                        else
                            if input = plus then
                                next_state <= add;
                            elsif input = minus then
                                next_state <= subtract;
                            elsif input = times then
                                next_state <= multiply;
                            elsif input = divided_by then
                                next_state <= divide;
                            elsif input = equals then
                                next_state <= idle;
                            else
                                next_state <= error;
                            end if;
--                        else
--                            next_state <= error;
                        end if;
                        
                                                        
                when error =>
                    idle_en <= '0';
                    add_en <= '0';
                    sub_en <= '0'; 
                    mult_en <= '0';
                    div_en <= '0';

                    err_disp <= '1';    
                    
--                    if data_ready = '1' then
                        next_state <= idle;
--                    end if;
                
            end case;
--	   end if;
--	   end if;
	end process;
	
	signaling: process(clk, input, data_ready)
	begin
	    if rising_edge(clk) then
--	       if (input <= nine) and (input >= zero) then
--	           valid <= '1';
--	       end if;
	    
	       if data_ready = '1' then
                if (input <= nine) and (input >= zero) then
                   go <= '0';
                   numerical <= '1';
                   valid <= '1';
                   if valid <= '1' then
                        if dig_num < "10" then
                            dig_num <= dig_num + 1;
                        end if;
                   else
                        dig_num <= "00";
                   end if; 
                elsif valid = '0' and input = minus then
                    curr_neg <= '1';  
                else
                    valid <= '0';
                    dig_num <= "00";
                    if numerical = '1' then
                        numerical <= '0';
                        if input = plus or input = equals or input = minus or input = times or input = divided_by then 
                            go <= '1';
                            curr_neg <= '0';
                        end if;
                    end if;
                end if;
           end if;
	   end if;
	end process;	

    dig_two <= std_logic_vector(dig_num);
        
    FSM_update: process(clk)
    begin
        if rising_edge(clk) then
            curr_state <= next_state;
        end if;
    end process FSM_update;
    
end Behavioral;
