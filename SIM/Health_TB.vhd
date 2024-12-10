library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Health_tb is
-- No puertos para el testbench
end Health_tb;

architecture Behavioral of Health_tb is
  -- Component under test
  component Vida
    generic (
      MAX_LIFE : integer := 10;
      DMG_BASE : integer := 2
    );
    port (
      clk        : in  std_logic;
      rst        : in  std_logic;
      Esp_fil    : in  unsigned(4 downto 0);
      Atk_speed  : in  std_logic;
          f_cuenta   : in  std_logic;

      Esp_col    : in  unsigned(4 downto 0);
      Char_fil   : in  unsigned(4 downto 0);
      Char_col   : in  unsigned(4 downto 0);
      life       : out unsigned(7 downto 0);
      is_dead    : out std_logic
    );
  end component;

  -- Señales para el DUT (Device Under Test)
  signal clk_tb       : std_logic := '0';
  signal rst_tb       : std_logic := '0';
  signal Esp_fil_tb   : unsigned(4 downto 0) := (others => '0');
  signal Esp_col_tb   : unsigned(4 downto 0) := (others => '0');
  signal Char_fil_tb  : unsigned(4 downto 0) := (others => '0');
  signal Char_col_tb  : unsigned(4 downto 0) := (others => '0');
  signal life_tb      : unsigned(7 downto 0);
  signal is_dead_tb   : std_logic;
  SIGNAL f_cuenta_tb   :  std_logic;


  -- Clock period for 40 ns
  constant clk_period : time := 40 ns;

begin
  -- Instantiate the DUT
  Vida_inst : Vida
    generic map (
      MAX_LIFE => 10,  -- Vida máxima inicial
      DMG_BASE => 2    -- Daño base
    )
    port map (
      clk        => clk_tb,
      rst        => rst_tb,
      Esp_fil    => Esp_fil_tb,
      Atk_speed  =>'1',
          f_cuenta   =>f_cuenta_tb, 

      Esp_col    => Esp_col_tb,
      Char_fil   => Char_fil_tb,
      Char_col   => Char_col_tb,
      life       => life_tb,
      is_dead    => is_dead_tb
    );

  -- Clock generation
  clk_process : process
  begin
    while true loop
      clk_tb <= '0';
      wait for clk_period / 2;
      clk_tb <= '1';
      wait for clk_period / 2;
    end loop;
  end process;

  -- Stimulus process
  stimulus_process : process
  begin
    -- Reset the system
    rst_tb <= '1';
    wait for 2 * clk_period;
    rst_tb <= '0';

    -- Tiempo 0 a 2 ciclos: Inicialización
    wait for 2 * clk_period;
    f_cuenta_tb<='1';
    Esp_fil_tb <= to_unsigned(5, 5);
    Esp_col_tb <= to_unsigned(5, 5);
    Char_fil_tb <= to_unsigned(5, 5);
    Char_col_tb <= to_unsigned(5, 5);    

    -- Tiempo 2 a 4 ciclos: Primera colisión
    wait for 2 * clk_period;
    f_cuenta_tb<='1';

    Esp_fil_tb <= to_unsigned(5, 5);
    Esp_col_tb <= to_unsigned(5, 5);

    -- Tiempo 4 a 6 ciclos: Segunda colisión (sin daño, posiciones diferentes)
    wait for 2 * clk_period;
        f_cuenta_tb<='1';

    Esp_fil_tb <= to_unsigned(3, 5);
    Esp_col_tb <= to_unsigned(3, 5);

    -- Tiempo 6 a 8 ciclos: Tercera colisión
        f_cuenta_tb<='1';

    wait for 2 * clk_period;
    Esp_fil_tb <= to_unsigned(5, 5);
    Esp_col_tb <= to_unsigned(5, 5);

    -- Tiempo 8 a 10 ciclos: Sin cambios
    wait for 2 * clk_period;

    -- Finalizar la simulación
    wait;
  end process;

end Behavioral;
