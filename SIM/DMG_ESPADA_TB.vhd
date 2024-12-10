library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Espada_tb is
-- No ports for the testbench
end Espada_tb;

architecture Behavioral of Espada_tb is

    -- Component under test
    component Espada
        Port (
            clk             : in std_logic;
            rst             : in std_logic;
            button_snes     : in std_logic_vector(11 downto 0);
            Finn_col        : in unsigned(4 downto 0);
            Finn_fil        : in unsigned(4 downto 0);
            Esp_col         : out unsigned(4 downto 0);
            Esp_fil         : out unsigned(4 downto 0);
            Esp_active      : out std_logic
        );
    end component;

    -- Test signals
    signal clk_tb          : std_logic := '0';
    signal rst_tb          : std_logic := '0';
    signal button_snes_tb  : std_logic_vector(11 downto 0) ; -- No button pressed
    signal Finn_col_tb     : unsigned(4 downto 0) := to_unsigned(10, 5);
    signal Finn_fil_tb     : unsigned(4 downto 0) := to_unsigned(10, 5);
    signal Esp_col_tb      : unsigned(4 downto 0);
    signal Esp_fil_tb      : unsigned(4 downto 0);
    signal Esp_active_tb   : std_logic;

    -- Clock period
    constant clk_period : time := 40 ns;

begin

    -- Instantiate the Unit Under Test (UUT)
    UUT: Espada
        Port map (
            clk             => clk_tb,
            rst             => rst_tb,
            button_snes     => button_snes_tb,
            Finn_col        => Finn_col_tb,
            Finn_fil        => Finn_fil_tb,
            Esp_col         => Esp_col_tb,
            Esp_fil         => Esp_fil_tb,
            Esp_active      => Esp_active_tb
        );

    -- Clock generation
    clk_process : process
    begin
        clk_tb <= '0';
        wait for clk_period / 2;
        clk_tb <= '1';
        wait for clk_period / 2;
    end process;

    -- Stimulus process
    stimulus_process : process
begin
    -- Reset the system
    rst_tb <= '1';
    wait for 2 * clk_period;
    rst_tb <= '0';

    

    -- Activate the sword (simulate button press for Act_boton(0))
    
    button_snes_tb<=(others => '0');
     button_snes_tb<="011000100110";
    
    wait for 5 * clk_period;


    -- Move Finn to the right, check sword position
    button_snes_tb<="011000100110";
    Finn_col_tb <= to_unsigned(12, 5);
    Finn_fil_tb <= to_unsigned(10, 5); -- Finn moves to the right
    
    wait for 5 * clk_period;

    -- Move Finn to the left, check sword position
     -- Activate the sword
      button_snes_tb<="011001000110";

    Finn_col_tb <= to_unsigned(10, 5);
    Finn_fil_tb <= to_unsigned(10, 5); -- Finn moves to the left
    wait for 5 * clk_period;

    -- Move Finn up, check sword position
     -- Activate the sword
    Finn_col_tb <= to_unsigned(12, 5);
    Finn_fil_tb <= to_unsigned(8, 5); -- Finn moves up
    wait for 5 * clk_period;

    -- Move Finn down, check sword position
     -- Activate the sword
    Finn_col_tb <= to_unsigned(12, 5);
    Finn_fil_tb <= to_unsigned(12, 5); -- Finn moves down
    wait for 5 * clk_period;

    -- Deactivate the sword
     -- Activate the sword
    



    -- Test complete
    wait;
end process;

end Behavioral;
