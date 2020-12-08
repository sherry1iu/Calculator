
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;


entity datapath is
  Port ( 
    clk     :   in  std_logic;
    current   :   in  std_logic_vector (15 downto 0);
    total :  in std_logic_vector(15 downto 0);
    result : out std_logic_vector(9 downto 0)

  );
end datapath;


architecture Behavioral of datapath is

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
    
    signal s_axis_divisor_tvalid : STD_LOGIC := '1';
    signal s_axis_divisor_tdata : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal s_axis_dividend_tvalid : STD_LOGIC := '1';
    signal s_axis_dividend_tdata : STD_LOGIC_VECTOR(15 DOWNTO 0);
    signal m_axis_dout_tvalid : STD_LOGIC;
    signal m_axis_dout_tdata : STD_LOGIC_VECTOR(31 DOWNTO 0);


    signal quot : std_logic_vector(9 downto 0);
begin

calc: process(clk, current, total)
begin
end process;

assign: process(clk, total)
begin
    if rising_edge(clk) then
        quot <= ((m_axis_dout_tdata(25 downto 16)));
    end if;
end process;

res: process(clk)
begin
    if rising_edge(clk) then
        result <= quot; -- <= ("00000" & (m_axis_dout_tdata(25 downto 16)));
    end if;
end process;

 your_instance_name : div_gen_0
  PORT MAP (
    aclk => clk,
    s_axis_divisor_tvalid => s_axis_divisor_tvalid,
    s_axis_divisor_tdata => std_logic_vector(current),
    s_axis_dividend_tvalid => s_axis_dividend_tvalid,
    s_axis_dividend_tdata => (std_logic_vector(total)),
    m_axis_dout_tvalid => m_axis_dout_tvalid,
    m_axis_dout_tdata => m_axis_dout_tdata
  );
  end behavioral;