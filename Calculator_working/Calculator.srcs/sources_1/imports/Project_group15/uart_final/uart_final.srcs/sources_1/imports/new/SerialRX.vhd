----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 08/20/2020 02:14:21 AM
-- Design Name: 
-- Module Name: SerialRX - Behavioral
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


entity SerialRX is
    Port ( Clk : in STD_LOGIC;                          -- 10MHz master clock
           RsRx : in STD_LOGIC;                         -- received bit stream
           rx_data: out STD_LOGIC_VECTOR(7 downto 0);   -- data byte
           rx_done_tick: out STD_LOGIC;               -- data ready tick
           
           dummy_var: out STD_LOGIC ;               -- data ready tick
           dummy_var2: out STD_LOGIC );               -- data ready tick

end SerialRX;

architecture Behavioral of SerialRX is
-- signals for two flip flop synchronizer
signal inputff: std_logic; -- input after first flip flop
signal input: std_logic; -- stable input to use

--signal dummy_var: std_logic; -- stable input to use


-- signals for shift register
constant max_shifts: integer := 10;
signal clear: std_logic := '1';
signal shift: std_logic := '0';
signal shift_out: std_logic_vector(9 downto 0) := (others => '0');

-- signals for parallel load register
signal load: std_logic := '0';

-- signals for shift counter
signal n_shifts: integer range 0 to max_shifts - 1 := 0;
signal shift_tc: std_logic := '0';

-- signals for clock edge counter (baud register)
constant CLOCK_FREQUENCY : integer := 10000000;         
constant BAUD_RATE : integer := 9600;
constant BAUD_COUNT : integer := CLOCK_FREQUENCY / BAUD_RATE;
signal b_count: integer range 0 to BAUD_COUNT - 1 := 0;
signal b_tick: std_logic := '0';
signal b_tick_half: std_logic := '0';
signal first_wait: std_logic := '0';
signal waiting: std_logic := '0';

-- signals for fsm
type state_type is (idle, wait_tc_half, shifting, wait_tc, data_ready--); 
, DATAREADY2, DATAREADY3, DATAREADY4);
signal curr_state, next_state: state_type := idle;

begin
-- two flip flop synchronizer
TFF_sync: process(clk)
begin
    if rising_edge(clk) then
        inputff <= RsRx;
        input <= inputff;
    end if;
end process TFF_sync;

-- shift register
shift_reg: process(clk)
begin        
	if rising_edge(clk) then            
		if clear = '1' then
			shift_out <= (others => '0'); -- reset (all 0's ?)
		elsif shift = '1' then
			shift_out <= input & shift_out(max_shifts-1 downto 1);
        else
            shift_out <= shift_out; -- should never happen if fsm working properly
		end if;
	end if;
end process shift_reg;

-- parallel load register
load_reg: process(clk)
begin
    if rising_edge(clk) then
        if load = '1' then
            rx_data <= shift_out(8 downto 1);
        end if;
    end if;
end process load_reg;

-- shift register counter
shift_counter: process(clk)
begin
	if rising_edge(clk) then
	   --shift_tc <= '0';
	   --if rising_edge(shift) then
    	if shift = '1' then
        	if n_shifts = max_shifts - 1 then
        	    shift_tc <= '1';
        	    n_shifts <= 0;
            else 
            	n_shifts <= n_shifts + 1;
                shift_tc <= '0';
            end if;
        else
        	shift_tc <= '0';
       	end if;
    end if;
end process shift_counter;

-- clock edge counter (N/2 before the first shift, N between shifts)
-- baud register
clock_counter: process(clk)
begin
    if rising_edge(clk) then
        if first_wait = '1' then 
            if b_count = (BAUD_COUNT-1)/2 then
                b_count <= 0;
                b_tick_half <= '1';     -- emit tick every BAUD_COUNT/2 clock cycles
            else
                b_count <= b_count + 1;
                b_tick_half <= '0';
            end if;
        elsif waiting = '1' then
            if b_count = BAUD_COUNT-1 then
                b_count <= 0;
                b_tick <= '1';     -- emit tick every BAUD_COUNT clock cycles
            else
                b_count <= b_count + 1;
                b_tick <= '0';
            end if;
        else
            b_count <= 0;
            b_tick_half <= '0';
            b_tick <= '0';
        end if;
    end if;
end process clock_counter;

FSMcomb: process(curr_state, input, b_tick_half, b_tick, shift_tc)
begin
    -- default
    next_state <= curr_state;
    shift <= '0';
    load <= '0';
    first_wait <= '0';
    clear <= '0';
    rx_done_tick <= '0'; -- output
    waiting <= '0';
    
    case curr_state is
        when idle =>
            clear <= '1';
            dummy_var <= '0';
            dummy_var2 <= '0';
            if input = '0' then
		        next_state <= wait_tc_half;
			end if; 

		when wait_tc_half =>
		    first_wait <= '1';
		    if b_tick_half = '1' then
		        next_state <= shifting;
			end if;

		when shifting =>
		    shift <= '1';
			if shift_tc = '1' then
				next_state <= data_ready;
            else
                next_state <= wait_tc;
			end if;
	
	   when wait_tc =>
	       waiting <= '1';
	       if b_tick = '1' then
	           next_state <= shifting;
	       elsif shift_tc = '1' then 
	           next_state <= data_ready;
	       end if;
	       
--	   when data_ready =>
--	       rx_done_tick <= '1';
--	       load <= '1';
--	       next_state <= idle;

	   when data_ready =>
	       rx_done_tick <= '0';
	       load <= '1';
	       next_state <= DATAREADY2;
	       
	    when DATAREADY2 =>
	       rx_done_tick <= '1';
	       load <= '0';
	       dummy_var <= '0';
	       NEXT_state <= DATAREADY3;
	       
	    when DATAREADY3 =>
	       rx_done_tick <= '0';
	       load <= '0';
	       dummy_var <= '1';
	       NEXT_state <= DATAREADY4;
	       
	    when DATAREADY4 =>
	       rx_done_tick <= '0';
	       load <= '0';
	       dummy_var <= '0';
	       dummy_var2 <= '1';
	       NEXT_state <= IDLE;
	end case;
end process FSMcomb;


FSMupdate: process(clk)
begin
    if rising_edge(clk) then
        curr_state <= next_state;
	end if;
end process FSMupdate;

end Behavioral;

