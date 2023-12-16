library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity state_machine is
    Port (
        CLK_S     : in STD_LOGIC;
        RST       : in STD_LOGIC;
        GPIO      : out STD_LOGIC_VECTOR(15 downto 0);
        ostate : out std_logic_vector(3 downto 0)
    );
end state_machine;

architecture Behavioral of state_machine is
    signal state     : std_logic_vector(3 downto 0) := "0000";  -- State register
    signal direction : std_logic := '0';  -- Direction flag (0 = forward, 1 = backward)

begin
    process(CLK_S)
    begin
        ostate <= state;
        if rising_edge(CLK_S) then
            if RST = '0' then
                -- Initialize the state machine to its lowest state
                state <= "0000";
                ostate <= state;
                direction <= '0';  -- Reset direction to forward
            else
                -- State transition logic with boundary checks
                if direction = '0' then
                    -- Forward direction with upper boundary check
                    if state < "1001" then
                        state <= state + 1;
                        ostate <= state;
                    else 
                        state <= "0000";
                        ostate <= state;
                    end if;
                else
                    -- Backward direction with lower boundary check
                    if state > "0000" then
                        state <= state - 1;
                        ostate <= state;
                    end if;
                end if;
            end if;
        end if;
    end process;

    -- Map states to GPIO outputs (16 bits)
    with state select
        GPIO <= "0000000000000000" when "0000",  -- State 0
                "1111101011011110" when "0001",  -- State 1
                "1100101011111110" when "0010",  -- State 2
                "0100101100011101" when "0011",  -- State 3
                "1111111011101101" when "0100",  -- State 4
                "0001101110101101" when "0101",  -- State 5
                "1101000000001101" when "0110",  -- State 6
                "1101111010101101" when "0111",  -- State 7
                "1011111011101111" when "1000",  -- State 8
                "1111000000001101" when "1001",  -- State 9
                "XXXXXXXXXXXXXXXX" when others;     -- Undefined states
end Behavioral;
