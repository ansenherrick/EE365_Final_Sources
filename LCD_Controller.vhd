
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity LCD_Controller is
    Port (
        Clk    : in  STD_LOGIC;
        nRst   : in  STD_LOGIC;
        iHex : in std_logic_vector(15 downto 0);
        LCD_DATA : out  STD_LOGIC_VECTOR (7 downto 0);
        LCD_EN   : out  STD_LOGIC;
        LCD_RS   : out  STD_LOGIC
    );
end LCD_Controller;

architecture rtl of LCD_Controller is
    type State_Type is (INIT, WRITE_DATA, REPEAT_DATA);
    signal State : State_Type := INIT;
    signal Data_Index : INTEGER range 0 to 23 := 0;
    signal Update_Counter : INTEGER := 0;  -- Counter for 5ms delay
    constant Update_Period : INTEGER := 250000;  -- 5ms at 50MHz
    signal Passed_53 : BOOLEAN := false;  -- Flag for LCD_RS control

    type DATA_SEQ is array (0 to 22) of STD_LOGIC_VECTOR(7 downto 0);
    type REPEAT_SEQ is array (0 to 7) of std_logic_vector(7 downto 0);
    --signal Repeat_Sequence : REPEAT_SEQ;
    constant Data_Sequence : DATA_SEQ := (
        x"38", x"38", x"38", x"38", x"38", x"38", x"01", x"0C", 
        x"06", x"80", x"53", x"79", x"73", x"74", x"65", x"6D", 
        x"FE", x"52", x"65", x"61", x"64", x"79", x"20"
    );
    signal Repeat_Sequence : REPEAT_SEQ := (
        x"C0", x"3D", x"3D", x"3E", x"30", x"30", x"30", x"30"
    );
    
    signal iChar : std_logic_vector(3 downto 0);
    signal LCD_Char : std_logic_vector(7 downto 0);
    signal LCD_count_state : std_logic_vector(1 downto 0) := "00";

begin
    process(Clk, nRst)
    begin
        if nRst = '0' then
            State <= INIT;
            Data_Index <= 0;
            Update_Counter <= 250000;
            Passed_53 <= false;
            LCD_DATA <= (others => '0');
            LCD_EN <= '0';
            LCD_RS <= '0';
        elsif rising_edge(Clk) then
            if Update_Counter < Update_Period then
                if Update_Counter = 100000 then
                    LCD_EN <= '1';
                elsif Update_Counter = 150000 then
                    LCD_EN <= '0';
                end if;
                Update_Counter <= Update_Counter + 1;
                if LCD_count_state = "00" then
                    iChar <= iHex(15 downto 12);
                    Repeat_Sequence(7) <= LCD_Char;
                    LCD_count_state <= "01";
                elsif LCD_count_state = "01" then  
                    iChar <= iHex(11 downto 8);
                    Repeat_Sequence(4) <= LCD_Char;  
                    LCD_count_state <= "10"; 
                elsif LCD_count_state = "10" then
                    iChar <= iHex(7 downto 4);
                    Repeat_Sequence(5) <= LCD_Char;  
                    LCD_count_state <= "11"; 
                elsif LCD_count_state = "11" then
                    iChar <= iHex(3 downto 0);
                    Repeat_Sequence(6) <= LCD_Char;  
                    LCD_count_state <= "00";  
                end if;       
            else
                Update_Counter <= 0;
                case State is
                    when INIT =>
                        if Data_Index < 23 then
                            LCD_DATA <= Data_Sequence(Data_Index);
                            if Data_Sequence(Data_Index) = x"80" then
                                Passed_53 <= true;
                            end if;
                            if Passed_53 and Data_Sequence(Data_Index) = x"C0" then
                                LCD_RS <= '0';
                            elsif Passed_53 then
                                LCD_RS <= '1';
                            end if;
                            Data_Index <= Data_Index + 1;
                        else
                            LCD_EN <= '0';
                            Data_Index <= 0;
                            State <= WRITE_DATA;
                            --LCD_DATA <= Repeat_Sequence(Data_Index);
                        end if;
                    when WRITE_DATA =>
                        --iChar <= iHex(15 downto 12);   
                        LCD_DATA <= Repeat_Sequence(Data_Index);
                        if Repeat_Sequence(Data_Index) = x"C0" then
                            LCD_RS <= '0';
                        else
                            LCD_RS <= '1';
                        end if;
                        Data_Index <= (Data_Index + 1) mod 8;
                    when others =>
                        LCD_DATA <= (others => '0');
                        LCD_RS <= '0';
                end case;
            end if;
        end if;
    end process;
    
    with iChar select
        LCD_Char <= x"30" when "0000", --0
                    x"31" when "0001", --1
                    x"32" when "0010", --2
                    x"33" when "0011", --3
                    x"34" when "0100", --4
                    x"35" when "0101", --5
                    x"41" when "1010", --a
                    x"42" when "1011", --b
                    x"43" when "1100", --c
                    x"44" when "1101", --d
                    x"45" when "1110", --e
                    x"46" when "1111", --f
                    x"20" when others;
end rtl;
