library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Finn_Movimiento_tb is
end Finn_Movimiento_tb;

architecture Behavioral of Finn_Movimiento_tb is

component Finn_Movimiento is
  Port (
    clk        : in std_logic; -- Reloj
    rst        : in std_logic; -- Reset
    finish_nes : in std_logic;
    button_snes : in std_logic_vector(11 downto 0);
    cambio_map  : in std_logic;
    Mon_col    : in unsigned(4 downto 0); -- Columna de Mon (0-31)
    Mon_fil    : in unsigned(4 downto 0); -- Fila de Mon (0-29)
    Finn_col   : out unsigned(4 downto 0); -- Columna de Finn (0-32)
    Finn_fil   : out unsigned(4 downto 0); -- Fila de Finn (0-30)
    Finn_Health   : out unsigned(7 downto 0);
    Alive      : out std_logic;
    finish_cont_s : out std_logic -- Señal de fin del contador
  );
end component;


  -- Declaración de señales internas
  signal clk        : std_logic := '0';
  signal rst        : std_logic := '1';
  signal finish_nes : std_logic := '0';
  signal button_snes : std_logic_vector(11 downto 0) := (others => '1');
  signal cambio_map  : std_logic := '0';
  signal Mon_col    : unsigned(4 downto 0) := to_unsigned(15, 5);
  signal Mon_fil    : unsigned(4 downto 0) := to_unsigned(15, 5);
  signal Finn_col   : unsigned(4 downto 0);
  signal Finn_fil   : unsigned(4 downto 0);
  signal Finn_Health : unsigned(7 downto 0);
  signal Alive      : std_logic;
  signal finish_cont_s : std_logic;

  -- Reloj de 25 MHz
  constant clk_period : time := 40 ns;

begin
  -- Instancia del diseño a probar
  DUT: Finn_Movimiento
    port map (
      clk => clk,
      rst => rst,
      finish_nes => finish_nes,
      button_snes => button_snes,
      cambio_map => cambio_map,
      Mon_col => Mon_col,
      Mon_fil => Mon_fil,
      Finn_col => Finn_col,
      Finn_fil => Finn_fil,
      Finn_Health => Finn_Health,
      Alive => Alive,
      finish_cont_s => finish_cont_s
    );

  -- Generador de reloj
  clk_process: process
  begin
    clk <= '0';
    wait for clk_period / 2;
    clk <= '1';
    wait for clk_period / 2;
  end process;

  -- Proceso de prueba
  stim_proc: process
  begin
    -- Reset inicial
    rst <= '1';
    wait for clk_period * 2;
    rst <= '0';

    -- Prueba de movimiento hacia arriba
    button_snes<="011000100110";
    wait for clk_period *20;

    -- Prueba de movimiento hacia abajo
    button_snes<="011000100110";
    wait for clk_period * 20;
    button_snes(5) <= '1';

    -- Prueba de movimiento hacia la izquierda
    wait for clk_period * 20;
    button_snes(6) <= '1';

    -- Prueba de movimiento hacia la derecha
    button_snes(7) <= '0'; -- Simula presionar el botón de movimiento hacia la derecha
    wait for clk_period * 20;
    button_snes(7) <= '1';

    -- Prueba de colisión con Mon
    Mon_col <= to_unsigned(10, 5);
    Mon_fil <= to_unsigned(10, 5);
    wait for clk_period * 2;
   -- Prueba de colisión con Mon
    Mon_col <= to_unsigned(10, 5);
    Mon_fil <= to_unsigned(10, 5);
    wait for clk_period * 2;
       -- Prueba de colisión con Mon
    Mon_col <= to_unsigned(10, 5);
    Mon_fil <= to_unsigned(10, 5);
    wait for clk_period * 2;
       -- Prueba de colisión con Mon
    Mon_col <= to_unsigned(10, 5);
    Mon_fil <= to_unsigned(10, 5);
    wait for clk_period * 2;
    -- Final de simulación
    wait;
  end process;

end Behavioral;
