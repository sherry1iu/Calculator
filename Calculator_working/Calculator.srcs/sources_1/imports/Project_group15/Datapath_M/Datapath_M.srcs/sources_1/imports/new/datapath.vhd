----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/19/2020 10:11:26 PM
-- Design Name: 
-- Module Name: datapath - Behavioral
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
use IEEE.NUMERIC_STD.ALL;


entity datapath is
  Port ( 
    clk     :   in  std_logic;
    input   :   in  std_logic_vector (7 downto 0);
    data_ready  :   in  std_logic;
    
    result  :   out std_logic_vector (9 downto 0);
    neg     :   out std_logic;
    
    dummy_var: in std_logic;
    dummy_var2: in std_logic
    
    --done    :   out std_logic

  );
end datapath;

architecture Behavioral of datapath is

    component addition_controller is  
        Port (
            clk         :   in  std_logic;
            input       :   in  std_logic_vector (7 downto 0);
            data_ready  :   in  std_logic;
--            clear       :   out std_logic;
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
    end component;
    
   COMPONENT div_gen_0
      PORT (
        aclk : IN STD_LOGIC;
        s_axis_divisor_tvalid : IN STD_LOGIC;
        s_axis_divisor_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        s_axis_dividend_tvalid : IN STD_LOGIC;
        s_axis_dividend_tdata : IN STD_LOGIC_VECTOR(15 DOWNTO 0);
        m_axis_dout_tvalid : OUT STD_LOGIC;
        m_axis_dout_tdata : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
      );
    END COMPONENT;


--    component long_division
--  Port ( 
--        clk       :   in std_logic;
--        divide_me :   in unsigned (15 downto 0);
--        divide_by :   in unsigned (15 downto 0);
        
--        div_en       :   in std_logic;
        
--        quot      :   out unsigned (15 downto 0);
--        div_done  :   out std_logic
--        );
--end component;

    -- Outputs from Controller
--    signal clear : std_logic;
    signal idle_en : std_logic;
    signal add_en : std_logic;
    signal sub_en : std_logic;
    signal mult_en : std_logic;
    signal curr_neg : std_logic;
    signal div_en : std_logic;
    
    signal err_disp : std_logic;
    signal dig_two : std_logic_vector(1 downto 0);
    signal go : std_logic; 
    
    
    signal s_axis_divisor_tvalid : STD_LOGIC := '1';
--    signal s_axis_divisor_tdata : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal s_axis_dividend_tvalid : STD_LOGIC := '1';
--    signal s_axis_dividend_tdata : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal m_axis_dout_tvalid : STD_LOGIC;
    signal m_axis_dout_tdata : STD_LOGIC_VECTOR(31 DOWNTO 0);
    
    signal testsignal : std_logic_vector (9 downto 0);      --25 downto 16 of the division module output
    
    signal quot: unsigned (15 downto 0) := (others => '0');
    signal div_done: std_logic := '0';
    
    constant ten : unsigned (3 downto 0) := "1010";
    constant hundred : unsigned (6 downto 0) := "1100100";
    
    -- ASCII characters
    constant zero : std_logic_vector(7 downto 0) := "00110000";
    constant nine : std_logic_vector(7 downto 0) := "00111001";
    constant nine_bin : std_logic_vector(7 downto 0) := "00001001";
    
    constant times : std_logic_vector(7 downto 0) := "00101010";                -- *
    constant divided_by : std_logic_vector(7 downto 0) := "00101111";           -- /
    constant plus : std_logic_vector(7 downto 0) := "00101011";
    constant minus : std_logic_vector(7 downto 0) := "00101101";
    constant equals : std_logic_vector(7 downto 0) := "00111101";

    -- Signals we will use
    signal input_bin : unsigned (7 downto 0) := (others => '0');  -- 10 bits for 0-999             -- 7 for hundreds place multiplication, 8 for input binary
    signal is_number : std_logic := '0';
    signal total : unsigned (15 downto 0) := (others => '0');  -- 10 bits for 0-999    
    signal current : unsigned (15 downto 0) := (others => '0');
    
    signal curr_clone : unsigned (15 downto 0) := (others => '0');

    signal div_storage :  unsigned (31 downto 0) := (others => '0');
    
    signal total_neg : std_logic := '0';

    signal recieved : std_logic := '0';
    
    signal dothisnext : std_logic_vector(2 downto 0) := (others => '0');
    
    signal diven_active : std_logic := '0';
    
    signal divcount : unsigned(4 downto 0) := (others => '0');

    signal currtick : unsigned (1 downto 0) := (others => '0');

begin

convert: process (clk, input)--, data_ready)
begin
    if rising_edge (clk) then    
--        if data_ready = '1' then        
            if ((unsigned(input) - unsigned(zero)) <= unsigned(nine_bin)) then            
                input_bin <= unsigned(input) - unsigned(zero);
                is_number <= '1';
            else
--                input_bin <= unsigned(input) - unsigned(zero);
                is_number <= '0';
            end if;
--        end if;
    end if;
end process;


set_curr: process (clk, data_ready, go)
begin
    if rising_edge(clk) then    
        if data_ready = '1' then--        
--        if dummy_var = '1' then               
            currtick <= currtick + 1;
--            if go = '0' then
            if go = '0' then
--            if ((unsigned(input) - unsigned(zero)) <= unsigned(nine_bin)) then
                current <= resize((ten * current) + input_bin, 16); 
--            elsif is_number <= '0' then
--                current <= current;
            else
                current <= (others => '0');
            end if;
--                end if;
            if ((unsigned(input) - unsigned(zero)) <= unsigned(nine_bin)) then
                curr_clone <= current;
            else
                curr_clone <= curr_clone;
            end if;
        end if;
    end if;
end process;
--            end if;
            

            
--procnext: process (clk, data_ready)
--begin
--    if rising_edge(clk) then    
----        if data_ready = '1' then               
----        if dummy_var2 = '1' then               
--            total <= total;
--            total_neg <= '0';
----            if idle_en = '1' and is_number = '1' then

--        if dummy_var2 = '1' then               

--            if idle_en = '1' and ((unsigned(input) - unsigned(zero)) <= unsigned(nine_bin)) then
--                total <= current;
--                total_neg <= curr_neg;
----            end if;
----           if data_ready = '1' then      
--            elsif go = '1' then
----            if go = '1' then
--                if add_en = '1' then
--                    total <= total + current; 
--                    if ((total > current) and (total_neg = '1')) or ((total < current) and (curr_neg = '1')) then
--                        total_neg <= '1';
--                    end if;
                    
--                elsif sub_en = '1' then
----                    total <= total - current;
--                    if (total_neg = '0' and curr_neg = '0' and total > current) then
--                        total <= total - current;
--                        total_neg <= '0';                         
--                    elsif (total_neg = '0' and curr_neg = '0' and total < current) then
--                        total <= current - total;
--                        total_neg <= '1';
--                    elsif (total_neg = '0' and curr_neg = '1') then
--                        total <= total + current;
--                        total_neg <= '0';           
--                    elsif (total_neg = '1' and curr_neg = '0') then
--                        total <= total + current;
--                        total_neg <= '1';      
--                    elsif (total_neg = '1' and curr_neg = '1' and total > current) then
--                        total <= total - current;
--                        total_neg <= '1';
--                    elsif (total_neg = '1' and curr_neg = '1' and total < current) then                    
--                        total <= current - total;
--                        total_neg <= '0';
--                    end if;
                    
--                elsif mult_en = '1' then
--                    total <= resize(total * current, 15);
--                    if ((total_neg = '1' and curr_neg = '0') or (total_neg = '1' and curr_neg = '0')) then             
--                        total_neg <= '1';
--                    end if;
                    
----                elsif div_en = '1' then
----                    total <= unsigned("00000" & m_axis_dout_tdata(25 downto 16));
----                    if ((total_neg = '1' and curr_neg = '0') or (total_neg = '1' and curr_neg = '0')) then             
----                        total_neg <= '1';
----                    end if;
                    
--                end if;
--    --        else                
--            end if;                        
--        end if;
--    end if;
--end process;
process(clk)
begin
if rising_edge(clk) then 
            if (m_axis_dout_tdata(0) = '0') and  ((unsigned(m_axis_dout_tdata(25 downto 16))) < "1111100111") then
                div_storage <= unsigned(m_axis_dout_tdata);
                if div_en = '1' then
                    diven_active <= '1';
                else
                    diven_active <= '0';
                end if;
            else 
                div_storage <= div_storage;
                diven_active <= diven_active;
            end if;
end if;
end process;


calc: process (clk, data_ready)
begin



    if rising_edge(clk) then    
        if data_ready = '1' then               
--        if dummy_var2 = '1' then    
            if dothisnext = "000" then      
                if add_en = '1' then
                    dothisnext <= "001";                    
                elsif sub_en = '1' then
                    dothisnext <= "010";                    
                elsif mult_en = '1' then
                    dothisnext <= "011";   
                elsif div_en = '1' then
                    dothisnext <= "100";  
                elsif idle_en = '1' then
                    dothisnext <= "101";                   
                end if;
            end if;
        end if;
        
            total <= total;
            total_neg <= total_neg;
            
            

--            if idle_en = '1' and ((unsigned(input) - unsigned(zero)) <= unsigned(nine_bin)) then
--                total <= current;
--            elsif go = '1' then
            if go = '1' then

                if dothisnext = "001" then
                    if (total_neg = curr_neg) then
                        total <= total + current;
                        total_neg <= total_neg;
                    elsif ((total > current) and (total_neg = '1')) then
                        total <= total - current;
                        total_neg <= '1';
                    elsif ((total > current) and (total_neg = '0')) then
                        total <= total - current;
                        total_neg <= '0';
                    elsif ((total < current) and (total_neg = '1')) then
                        total <= current - total;
                        total_neg <= '0';
                    elsif((total < current) and (total_neg = '0')) then
                        total <= current - total;
                        total_neg <= '1';
                    end if; 
                    dothisnext <= "000";                   
                elsif dothisnext = "010" then
                    total <= total - current;
                    if (total_neg = '0' and curr_neg = '0' and total > current) then
                        total <= total - current;
                        total_neg <= '0';                         
                    elsif (total_neg = '0' and curr_neg = '0' and total < current) then
                        total <= current - total;
                        total_neg <= '1';
                    elsif (total_neg = '0' and curr_neg = '1') then
                        total <= total + current;
                        total_neg <= '0';           
                    elsif (total_neg = '1' and curr_neg = '0') then
                        total <= total + current;
                        total_neg <= '1';      
                    elsif (total_neg = '1' and curr_neg = '1' and total > current) then
                        total <= total - current;
                        total_neg <= '1';
                    elsif (total_neg = '1' and curr_neg = '1' and total < current) then                    
                        total <= current - total;
                        total_neg <= '0';
                    end if;
                    dothisnext <= "000";         
                elsif dothisnext = "011" then
--                    total <= resize(total * current, 15);
                    total <= resize(total * current, 16);
                    if ((total_neg = '1' and curr_neg = '0') or (total_neg = '1' and curr_neg = '0')) then             
                        total_neg <= '1';
                    end if;
                    dothisnext <= "000";
                elsif dothisnext = "100" then
--                    total <= resize(unsigned(m_axis_dout_tdata(25 downto 16)), 16);
--                    if diven_active = '0' and 
--                    if divcount = "01110" then
                    if divcount = "00010" then

--                    total <= resize(div_storage(25 downto 16), 16);
                    total <= resize(unsigned(testsignal(9 downto 0)), 16);
--                    if div_done = '1' then
--                        total <= quot;
                        if ((total_neg = '1' and curr_neg = '0') or (total_neg = '1' and curr_neg = '0')) then             
                            total_neg <= '1';
                        end if;
                        dothisnext <= "000";
                        divcount <= (others => '0');
                        
                     else
                        divcount <= divcount + 1;
                        dothisnext <= dothisnext;
                        total <= total;
                        total_neg<= total_neg;
                     end if;
                elsif dothisnext = "101" then
                    total <= current;
                    total_neg <= curr_neg;
                    dothisnext <= "000"; 
                end if;
            end if;                        
    end if;
end process;
--calc: process (clk, data_ready)
--begin
--    if rising_edge(clk) then    
----        if data_ready = '1' then               
----        if dummy_var2 = '1' then               
--            total <= total;
--            total_neg <= '0';
----            if idle_en = '1' and is_number = '1' then

--        if dummy_var2 = '1' then               

--            if idle_en = '1' and ((unsigned(input) - unsigned(zero)) <= unsigned(nine_bin)) then
--                total <= current;
--                total_neg <= curr_neg;
----            end if;
----           if data_ready = '1' then      
--            elsif go = '1' then
----            if go = '1' then
--                if add_en = '1' then
--                    total <= total + current; 
--                    if ((total > current) and (total_neg = '1')) or ((total < current) and (curr_neg = '1')) then
--                        total_neg <= '1';
--                    end if;
                    
--                elsif sub_en = '1' then
----                    total <= total - current;
--                    if (total_neg = '0' and curr_neg = '0' and total > current) then
--                        total <= total - current;
--                        total_neg <= '0';                         
--                    elsif (total_neg = '0' and curr_neg = '0' and total < current) then
--                        total <= current - total;
--                        total_neg <= '1';
--                    elsif (total_neg = '0' and curr_neg = '1') then
--                        total <= total + current;
--                        total_neg <= '0';           
--                    elsif (total_neg = '1' and curr_neg = '0') then
--                        total <= total + current;
--                        total_neg <= '1';      
--                    elsif (total_neg = '1' and curr_neg = '1' and total > current) then
--                        total <= total - current;
--                        total_neg <= '1';
--                    elsif (total_neg = '1' and curr_neg = '1' and total < current) then                    
--                        total <= current - total;
--                        total_neg <= '0';
--                    end if;
                    
--                elsif mult_en = '1' then
--                    total <= resize(total * current, 15);
--                    if ((total_neg = '1' and curr_neg = '0') or (total_neg = '1' and curr_neg = '0')) then             
--                        total_neg <= '1';
--                    end if;
                    
----                elsif div_en = '1' then
----                    total <= unsigned("00000" & m_axis_dout_tdata(25 downto 16));
----                    if ((total_neg = '1' and curr_neg = '0') or (total_neg = '1' and curr_neg = '0')) then             
----                        total_neg <= '1';
----                    end if;
                    
--                end if;
--    --        else                
--            end if;                        
--        end if;
--    end if;
--end process;




output: process (clk)
begin
    if rising_edge(clk) then
        --done <= '1';
        neg <= '0';
        if err_disp = '1' then
            result <= (others => '0');
        elsif total(15 downto 10) > "00000" then
            result <= "1111100111";     -- 999
            neg <= total_neg;
        else
            result <= std_logic_vector(total(9 downto 0));
            neg <= total_neg;
        end if;
    end if;
end process;

control: addition_controller port map(
    clk => clk, input => input, data_ready => data_ready,
--    clear => clear, 
    idle_en => idle_en, 
    add_en => add_en, 
    sub_en => sub_en, 
    mult_en => mult_en,
    div_en => div_en,
    curr_neg => curr_neg,
    err_disp => err_disp, dig_two => dig_two, go => go);
    
 div_calc: div_gen_0
  PORT MAP (
    aclk => clk,
    s_axis_divisor_tvalid => s_axis_divisor_tvalid,
--    s_axis_divisor_tdata => std_logic_vector(curr_clone),
    s_axis_divisor_tdata => std_logic_vector(current),
    s_axis_dividend_tvalid => s_axis_dividend_tvalid,
    s_axis_dividend_tdata => std_logic_vector(total),
    m_axis_dout_tvalid => m_axis_dout_tvalid,
    m_axis_dout_tdata => m_axis_dout_tdata
  );

testsignal <= m_axis_dout_tdata(25 downto 16);
--div_calc: long_division
--port map(
--        clk => clk, divide_me => total, div_en => div_en, divide_by => current, quot => quot, div_done => div_done);

end Behavioral;
