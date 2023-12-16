library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity top_level is
    Port(
        Clk : in std_logic;
        nRst : in std_logic;
        LCD_DATA : out  STD_LOGIC_VECTOR (7 downto 0);
        LCD_EN   : out  STD_LOGIC;
        LCD_RS   : out  STD_LOGIC
    );
end top_level;

architecture Behavioral of top_level is

    component LCD_Controller
    Port (
        Clk    : in  STD_LOGIC;
        nRst   : in  STD_LOGIC;
        iHex : in std_logic_vector(15 downto 0);
        LCD_DATA : out  STD_LOGIC_VECTOR (7 downto 0);
        LCD_EN   : out  STD_LOGIC;
        LCD_RS   : out  STD_LOGIC
    );
    end component; 
    
    component clk_enabler
    GENERIC (
		CONSTANT cnt_max : integer := 49999999);      --  1.0 Hz for 50Mhz clock
	port(	
		clock:		in std_logic;	 
		clk_en: 		out std_logic
	);
	end component;
    
    component state_machine
    Port (
        CLK_S     : in STD_LOGIC;
        RST       : in STD_LOGIC;
        GPIO      : out STD_LOGIC_VECTOR(15 downto 0);
        ostate : out std_logic_vector(3 downto 0)
    );
    end component; 
        
    signal SCLK : std_logic;
    signal HexData : STD_LOGIC_VECTOR(15 downto 0);
    
begin

    Inst_clk_en : clk_enabler
    port map(
    clock => Clk,
    clk_en => SCLK
    );
    
    Inst_state_machine : state_machine
    port map(
    CLK_S => SCLK,
    RST => nRst,
    GPIO => HexData,
    ostate => open
    );
    
    i_LCD_Controller : entity work.LCD_Controller(rtl)
    port map(
        Clk => Clk,
        nRst => nRst,
        iHex => HexData,
        LCD_DATA => LCD_DATA,
        LCD_EN => LCD_EN,
        LCD_RS => LCD_RS
        );

end Behavioral;
