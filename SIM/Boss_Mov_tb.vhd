library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Boss_Mov_tb is
end Boss_Mov_tb;

architecture Behavioral of Boss_Mov_tb is
  component Boss_Mov is
    port (
      clk         : in  std_logic;            -- Señal de reloj
      rst         : in  std_logic;            -- Señal de reset
      Finn_alive  : in  std_logic;
      cambio_map  : in  std_logic;
      Finn_col    : in  unsigned(4 downto 0); -- Columna de Finn
      Finn_fil    : in  unsigned(4 downto 0); -- Fila de Finn
      Esp_fil     : in  unsigned(4 downto 0); -- Fila de la espada
      Esp_col     : in  unsigned(4 downto 0); -- Columna de la espada
      Boss_col    : out unsigned(4 downto 0); -- Columna del Boss
      Boss_fil    : out unsigned(4 downto 0); -- Fila del Boss
      Boss_Alive  : out std_logic
    );
  end component;

  signal clk        : std_logic := '0';
  signal rst        : std_logic := '1';
  signal Finn_alive : std_logic := '1';
  signal cambio_map : std_logic := '0';
  signal Finn_col   : unsigned(4 downto 0) := to_unsigned(10, 5);
  signal Finn_fil   : unsigned(4 downto 0) := to_unsigned(10, 5);
  signal Esp_col    : unsigned(4 downto 0) := to_unsigned(0, 5);
  signal Esp_fil    : unsigned(4 downto 0) := to_unsigned(0, 5);
  signal Boss_col   : unsigned(4 downto 0);
  signal Boss_fil   : unsigned(4 downto 0);
  signal Boss_Alive : std_logic;

  constant clk_period : time := 40 ns;

begin
  -- Instancia de la entidad bajo prueba (DUT)
  DUT: Boss_Mov
    port map (
      clk => clk,
      rst => rst,
      Finn_alive => Finn_alive,
      cambio_map => cambio_map,
      Finn_col => Finn_col,
      Finn_fil => Finn_fil,
      Esp_col => Esp_col,
      Esp_fil => Esp_fil,
      Boss_col => Boss_col,
      Boss_fil => Boss_fil,
      Boss_Alive => Boss_Alive
    );

  -- Generador de reloj
  clk_process: process
  begin
    while true loop
      clk <= '0';
      wait for clk_period / 2;
      clk <= '1';
      wait for clk_period / 2;
    end loop;
  end process;

  -- Proceso de estímulos
  stim_proc: process
  begin
    -- Reset inicial
    rst <= '1';
    wait for clk_period * 5;
    rst <= '0';

    -- Caso 1: Boss no se mueve porque Finn está lejos
    Finn_col <= to_unsigned(20, 5);
    Finn_fil <= to_unsigned(20, 5);
    wait for clk_period * 100;
    assert (Boss_col = to_unsigned(16, 5) and Boss_fil = to_unsigned(15, 5))
      report "Error: Boss se movió incorrectamente cuando Finn estaba lejos" severity error;

    -- Caso 2: Finn entra en rango, Boss se activa y comienza a moverse
    Finn_col <= to_unsigned(17, 5);
    Finn_fil <= to_unsigned(15, 5);
    wait for clk_period * 100;
    assert (Boss_col = to_unsigned(17, 5) and Boss_fil = to_unsigned(15, 5))
      report "Error: Boss no se movió correctamente hacia Finn" severity error;

    -- Caso 3: Finn está muerto, Boss no debería moverse
    Finn_alive <= '0';
    wait for clk_period * 100;
    assert (Boss_col = to_unsigned(17, 5) and Boss_fil = to_unsigned(15, 5))
      report "Error: Boss se movió aunque Finn estaba muerto" severity error;

    -- Caso 4: Espada golpea al Boss y se reduce su vida
    Esp_col <= Boss_col;
    Esp_fil <= Boss_fil;
    wait for clk_period * 200;
    assert (Boss_Alive = '0')
      report "Error: Boss sigue vivo después de ser golpeado por la espada" severity error;

    -- Final de la simulación
    wait;
  end process;

end Behavioral;
