library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_level_tb is
--  Port ( );
end top_level_tb;

architecture Behavioral of top_level_tb is
    
    constant ClockFrequency : integer := 50e6;
    constant ClockPeriod : time := 1000ms / ClockFrequency;
    
    signal Clktb : std_logic := '1';
    signal nRsttb : std_logic := '0';
    
    signal LCD_DATAtb : STD_LOGIC_VECTOR (7 downto 0);
    signal LCD_ENtb   : STD_LOGIC;
    signal LCD_RStb   : STD_LOGIC;
    
begin

    -- Device Under Test DUT
    i_top_level : entity work.top_level(Behavioral)
    port map(
        Clk => Clktb,
        nRst => nRsttb,
        
        LCD_DATA => LCD_DATAtb,
        LCD_EN => LCD_ENtb,
        LCD_RS => LCD_RStb
        );

    Clktb <= not Clktb after ClockPeriod / 2;
    
    --TB
    process is
    begin
    
        nRsttb <= '1';
        wait for 100ns;
        nRsttb <= '0';
        wait for 100ns;
        nRsttb <= '1';
        wait for 100ns;
        wait;
        
    end process;
        

end Behavioral;
