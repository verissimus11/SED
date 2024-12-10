library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Multiplex_DMG_tb is
end Multiplex_DMG_tb;

architecture Behavioral of Multiplex_DMG_tb is

component Multiplex_DMG is
  Port (
    Finn_Col     : in  unsigned(4 downto 0);        -- Columna de Finn
    Finn_Fil     : in  unsigned(4 downto 0);        -- Fila de Finn
    Mon_Col      : in  unsigned(4 downto 0);        -- Columna del primer Monstruo
    Mon_Fil      : in  unsigned(4 downto 0);        -- Fila del primer Monstruo
    Boss_Col     : in  unsigned(4 downto 0);        -- Columna del Boss
    Boss_Fil     : in  unsigned(4 downto 0);        -- Fila del Boss
    Mon1_Col     : in  unsigned(4 downto 0);        -- Columna del segundo Monstruo
    Mon1_Fil     : in  unsigned(4 downto 0);
    Mon2_Col     : in  unsigned(4 downto 0);        -- Columna del segundo Monstruo
    Mon2_Fil     : in  unsigned(4 downto 0);         -- Fila del segundo Monstruo
    Cambio_Mapa  : in  std_logic;                  -- Señal de cambio de mapa
    Dmg_Col_Out  : out unsigned(4 downto 0);       -- Columna seleccionada
    Dmg_Fil_Out  : out unsigned(4 downto 0)        -- Fila seleccionada
  );
end component;

  -- Señales para conectar a la entidad bajo prueba (DUT)
  signal Finn_Col    : unsigned(4 downto 0) := to_unsigned(10, 5);
  signal Finn_Fil    : unsigned(4 downto 0) := to_unsigned(10, 5);
  signal Mon_Col     : unsigned(4 downto 0) := to_unsigned(5, 5);
  signal Mon_Fil     : unsigned(4 downto 0) := to_unsigned(5, 5);
  signal Mon1_Col    : unsigned(4 downto 0) := to_unsigned(8, 5);
  signal Mon1_Fil    : unsigned(4 downto 0) := to_unsigned(8, 5);
  signal Mon2_Col    : unsigned(4 downto 0) := to_unsigned(12, 5);
  signal Mon2_Fil    : unsigned(4 downto 0) := to_unsigned(12, 5);
  signal Boss_Col    : unsigned(4 downto 0) := to_unsigned(15, 5);
  signal Boss_Fil    : unsigned(4 downto 0) := to_unsigned(15, 5);
  signal Cambio_Mapa : std_logic := '0';
  signal Dmg_Col_Out : unsigned(4 downto 0);
  signal Dmg_Fil_Out : unsigned(4 downto 0);

  -- Reloj para posibles modificaciones futuras
  constant clk_period : time := 40 ns;

begin
  -- Instancia de la entidad bajo prueba (DUT)
  DUT: Multiplex_DMG
    port map (
      Finn_Col => Finn_Col,
      Finn_Fil => Finn_Fil,
      Mon_Col => Mon_Col,
      Mon_Fil => Mon_Fil,
      Boss_Col => Boss_Col,
      Boss_Fil => Boss_Fil,
      Mon1_Col => Mon1_Col,
      Mon1_Fil => Mon1_Fil,
      Mon2_Col => Mon2_Col,
      Mon2_Fil => Mon2_Fil,
      Cambio_Mapa => Cambio_Mapa,
      Dmg_Col_Out => Dmg_Col_Out,
      Dmg_Fil_Out => Dmg_Fil_Out
    );

  -- Proceso de estímulos
  stim_proc: process
  begin
    -- Caso 1: Cambio_Mapa = '0', debe seleccionar al Boss
    Cambio_Mapa <= '0';
    wait for clk_period * 5;
    

    -- Caso 2: Cambio_Mapa = '1', seleccionar al Monstruo más cercano (Mon)
    Cambio_Mapa <= '1';
    Mon_Col <= to_unsigned(6, 5);
    Mon_Fil <= to_unsigned(6, 5);
    Mon1_Col <= to_unsigned(20, 5);
    Mon1_Fil <= to_unsigned(20, 5);
    Mon2_Col <= to_unsigned(25, 5);
    Mon2_Fil <= to_unsigned(25, 5);
    wait for clk_period * 5;
   

    -- Caso 3: Selección del segundo Monstruo (Mon1)
    Mon_Col <= to_unsigned(30, 5);
    Mon_Fil <= to_unsigned(30, 5);
    Mon1_Col <= to_unsigned(9, 5);
    Mon1_Fil <= to_unsigned(9, 5);
    Mon2_Col <= to_unsigned(20, 5);
    Mon2_Fil <= to_unsigned(20, 5);
    wait for clk_period * 5;
    

    -- Caso 4: Selección del tercer Monstruo (Mon2)
    Mon1_Col <= to_unsigned(30, 5);
    Mon1_Fil <= to_unsigned(30, 5);
    Mon2_Col <= to_unsigned(11, 5);
    Mon2_Fil <= to_unsigned(11, 5);
    wait for clk_period * 5;
    

    -- Fin de la simulación
    wait;
  end process;

end Behavioral;
