library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FSM_SNES_MAIN_tb is
end FSM_SNES_MAIN_tb;

architecture Behavioral of FSM_SNES_MAIN_tb is
  -- Declaración de señales
  
  component FSM_SNES_MAIN is
    Port ( 
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           --START : in STD_LOGIC; -- para iniciar el protocolo de coms
           data_snes : in STD_LOGIC; -- entrada del tren de pulsos de la SNES envia 16 simbolos
           
           --idle_out : out STD_LOGIC;
           --finish : out STD_LOGIC;
           LATCH : out STD_LOGIC; -- envia flag para iniciar la comunicacion con mando SNES
           clk_snes : out STD_LOGIC; -- envia reloj protocolo coms con mando SNES
           State_buttons : out STD_LOGIC_VECTOR (11 downto 0) -- envia la info de los botones
          ); 
end component;
  signal clk          : std_logic := '0';
  signal rst          : std_logic := '1';
  signal data_snes    : std_logic := '0';
  signal LATCH        : std_logic;
  signal clk_snes     : std_logic;
  signal State_buttons: std_logic_vector(11 downto 0);

  -- Parámetros del reloj
  constant clk_period : time := 8 ns;

begin
  -- Instancia de la entidad bajo prueba (DUT)
  DUT: FSM_SNES_MAIN
    port map (
      clk => clk,
      rst => rst,
      data_snes => data_snes,
      LATCH => LATCH,
      clk_snes => clk_snes,
      State_buttons => State_buttons
    );

  -- Generador de reloj
  clk_process: process
  begin
    clk <= '0';
    wait for clk_period / 2;
    clk <= '1';
    wait for clk_period / 2;
  end process;

  -- Proceso de estímulos
  stim_proc: process
  begin
    -- Reset inicial
    rst <= '1';
    wait for clk_period * 5;
    rst <= '0';

    -- Simulación de datos del SNES
    wait for clk_period * 10;
    data_snes <= '1';
    wait for clk_period * 5;
    data_snes <= '0';

    wait for clk_period * 10;
    data_snes <= '1';
    wait for clk_period * 5;
    data_snes <= '0';

    -- Repetir patrones para simular datos de los botones
    for i in 0 to 15 loop
      data_snes <= not data_snes;
      wait for clk_period * 10;
    end loop;

    -- Esperar un poco más y finalizar simulación
    wait for clk_period * 100;

    -- Fin de simulación
    wait;
  end process;

end Behavioral;
