----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/13/2024 11:23:08 AM
-- Design Name: 
-- Module Name: PLL_SYNC_PINTA_HDMI - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PLL_SYNC_PINTA_HDMI is
        Port ( 
        
        clk       : in std_logic;           -- 125 MHz clock input
        rst       : in std_logic;           -- rst signal
        sw        : in std_logic_vector(3 downto 0); -- Botones
        Pmodin    : in std_logic;
        Pmod      : out std_logic_vector(1 downto 0);
        Led       : out std_logic_vector(3 downto 0);
        clkP      : out std_logic;          -- TMDS clock positive output
        clkN      : out std_logic;          -- TMDS clock negative output
        dataP     : out std_logic_vector(2 downto 0); -- TMDS data positive output
        dataN     : out std_logic_vector(2 downto 0)  -- TMDS data negative output
        );
        
end PLL_SYNC_PINTA_HDMI;


architecture Behavioral of PLL_SYNC_PINTA_HDMI is



component SYNC_VGA is
    port(
        clk          : in  std_logic;                -- Pixel clock (typically 25 MHz for 640x480)
        rst          : in  std_logic;                -- rst signal
        hsync        : out std_logic;                -- Horizontal sync signal
        
        
        vsync        : out std_logic;                -- Vertical sync signal
        columnas     : out unsigned(9 downto 0);     -- Horizontal counter (unsigned output)
        filas        : out unsigned(9 downto 0);      -- Vertical counter (unsigned output)
               -- Line visible signal
        visible      : out std_logic 
    );
end component;

component PLL is
    generic (
        CLKIN_PERIOD : real := 8.000; -- Periodo del reloj de entrada (8 ns para 125 MHz)
        CLK_MULTIPLY : integer := 8;  -- Multiplicador
        CLK_DIVIDE   : integer := 1;  -- Divisor
        CLKOUT0_DIV  : integer := 8;  -- Divisor de reloj de salida serial
        CLKOUT1_DIV  : integer := 40  -- Divisor de reloj de salida de píxeles (para 25 MHz)
    );
    port (
        clk_i   : in  std_logic;        -- Reloj de entrada
        rst     : in  std_logic;        -- Señal de reinicio
        clk0_o  : out std_logic;        -- Reloj de salida serial (125 MHz)
        clk1_o  : out std_logic         -- Reloj de salida de píxeles (25 MHz)
    );
end component;


component pinta_barras is
   Port (
-- In ports
    ---- ---- ---- --- ---- 
    visible      : in std_logic;
    col          : in unsigned(10-1 downto 0);
    fila         : in unsigned(10-1 downto 0);
    --- Personaje principal In ports
    Finn_dato    : in std_logic_vector( 15 downto 0);
    Finn_col     : in unsigned(4 downto 0); -- Posición columna de Finn
    Finn_fil     : in unsigned(4 downto 0); -- Posición fila de Finn
    Finn_Health  : in unsigned(7 downto 0);
    Finn_Alive        : in std_logic;
    --- ESPADA 
    Esp_col         : in unsigned(4 downto 0); -- Columna de la espada
    Esp_fil         : in unsigned(4 downto 0); -- Fila de la espada
    Esp_active      : in std_logic; -- Estado de la espada (1 si está en vuelo)
    Espada_dato    : in std_logic_vector( 15 downto 0);
    addr_Espada     : out std_logic_vector( 3 downto 0);
    
    --- Personaje Villano NPC
    
    Mon_dato     : in std_logic_vector( 15 downto 0);
    Mon_col      : in unsigned(4 downto 0); -- Posición columna de Finn
    Mon_fil      : in unsigned(4 downto 0); -- Posición fila de Finn
    Mon_Alive    : in std_logic; -- Posición fila de Finn
        --- Personaje Villano NPC 1
    
    Mon1_col      : in unsigned(4 downto 0); -- Posición columna de Finn
    Mon1_fil      : in unsigned(4 downto 0); -- Posición fila de Finn
    Mon1_Alive    : in std_logic; -- Posición fila de Finn
    ------------------------------------------------------------
    Mon2_col      : in unsigned(4 downto 0); -- Posición columna de Finn
    Mon2_fil      : in unsigned(4 downto 0); -- Posición fila de Finn
    Mon2_Alive    : in std_logic; -- Posición fila de Finn
    
    --- Personaje BOSS NPC
    
    Boss_col     : in unsigned(4 downto 0); -- Columna del Boss 
    Boss_fil     : in unsigned(4 downto 0);  -- Fila del Boss
    Boss_dato    : in std_logic_vector( 15 downto 0);
    Boss_Alive    : in std_logic;
    --- Fondo Mapa1
    Mapa1_dato   : in std_logic_vector( 32-1 downto 0);
    not_Mapa1_dato: in std_logic_vector( 32-1 downto 0);
    --- Fondo Mapa2
    Mapa2_dato   : in std_logic_vector( 32-1 downto 0);
    not_Mapa2_dato: in std_logic_vector( 32-1 downto 0);
    --- Fondo Mapa3
    Mapa3_dato   : in std_logic_vector( 32-1 downto 0);
    not_Mapa3_dato: in std_logic_vector( 32-1 downto 0);
    ---- Arboles del fondo 
    Arbol_dato     : in std_logic_vector( 15 downto 0);
    --- Out ports
    addr_Fin       : out std_logic_vector( 3 downto 0);
    addr_Boss       : out std_logic_vector( 3 downto 0);
    addr_Mon       : out std_logic_vector( 3 downto 0);
    addr_Mapa1     : out std_logic_vector( 5-1 downto 0);
    not_addr_Mapa1 : out std_logic_vector( 5-1 downto 0);
    addr_Mapa2     : out std_logic_vector( 5-1 downto 0);
    not_addr_Mapa2 : out std_logic_vector( 5-1 downto 0);
    addr_Mapa3   : out std_logic_vector( 5-1 downto 0);
    not_addr_Mapa3 : out std_logic_vector( 5-1 downto 0);
    addr_Arbol     : out std_logic_vector( 3 downto 0);
    --- RGB----
    cambio_mapa     : in std_logic;
    --- Cronometro----
    segundos      : in std_logic_vector(3 downto 0);
    dsegundos     : in std_logic_vector(3 downto 0);
    minutos       : in std_logic_vector(3 downto 0);
    colon         : in  std_logic_vector(3 downto 0); -- Salida de la ROM para ":"    
    
    addr_segundos    :out std_logic_vector(8 downto 0); 
    addr_dsegundos   :out std_logic_vector(8 downto 0); 
    addr_minutos     :out std_logic_vector(8 downto 0); 
    addr_colon       :out std_logic_vector(8 downto 0); 
                                                     
                                
    segundos_dato    :in std_logic_vector(15 downto 0);
    dsegundos_dato   :in std_logic_vector(15 downto 0);
    minutos_dato     :in std_logic_vector(15 downto 0);
    colon_dato       :in std_logic_vector(15 downto 0);
    --- RGB----
    rojo         : out std_logic_vector(8-1 downto 0);
    verde        : out std_logic_vector(8-1 downto 0);
    azul         : out std_logic_vector(8-1 downto 0)
  );
end component;

component ROM_Villano is
  port (
    clk  : in  std_logic;   -- reloj
    addr : in  std_logic_vector(4-1 downto 0);
    dout : out std_logic_vector(16-1 downto 0) 
  );
end component;

component ROM1b_1f_pacman_16x16_bn is
  port (
    clk  : in  std_logic;   -- reloj
    addr : in  std_logic_vector(4-1 downto 0);
    dout : out std_logic_vector(16-1 downto 0) 
  );
end component;

    component ROM1b_1f_red_num32_play_sprite16x16 is
        port (
            clk  : in  std_logic;   -- reloj
            addr : in  std_logic_vector(9-1 downto 0); -- Dirección de la ROM
            dout : out std_logic_vector(16-1 downto 0) -- Dato leído
        );
    end component;
    
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
    Alive         : out std_logic;
    finish_cont_s : out std_logic -- Señal de fin del contador
     );
end component;

component Espada is
  Port (
    clk             : in std_logic; -- Reloj
    rst             : in std_logic; -- Reset
    button_snes     : in std_logic_vector(11 downto 0);
    Finn_col        : in unsigned(4 downto 0); -- Columna de Finn
    Finn_fil        : in unsigned(4 downto 0); -- Fila de Finn
    Esp_col         : out unsigned(4 downto 0); -- Columna de la espada
    Esp_fil         : out unsigned(4 downto 0); -- Fila de la espada
    Esp_active      : out std_logic -- Estado de la espada (1 si está en vuelo)
  );
end component;

component ROM_Espada is
  port (
    clk  : in  std_logic;   -- reloj
    addr : in  std_logic_vector(4-1 downto 0);
    dout : out std_logic_vector(16-1 downto 0) 
  );
end component;


component ROM1b_1f_monster_16 is
  port (
    clk  : in  std_logic;   -- reloj
    addr : in  std_logic_vector(4-1 downto 0);
    dout : out std_logic_vector(16-1 downto 0) 
  );
end component;

component Mon_Movimiento is
  Port (
    clk        : in std_logic; -- Reloj
    rst        : in std_logic; -- Reset
    Esp_fil    : in  unsigned(4 downto 0); -- Fila de la espada
    Esp_col    : in  unsigned(4 downto 0); -- Columna de la espada
    button_snes : in std_logic_vector(11 downto 0);
    Mon_col    : out unsigned(4 downto 0); -- Columna de Mon (0-31)
    Alive      : out std_logic;
    Mon_fil    : out unsigned(4 downto 0) -- Fila de Mon (0-29)
 
  );
end component;

component Mon1_Movimiento is
  Port (
    clk        : in std_logic; -- Reloj
    rst        : in std_logic; -- Reset
    Esp_fil    : in  unsigned(4 downto 0); -- Fila de la espada
    Esp_col    : in  unsigned(4 downto 0); -- Columna de la espada
    button_snes: in std_logic_vector(11 downto 0);
    Mon_col    : out unsigned(4 downto 0); -- Columna de Mon (0-31)
    Alive      : out std_logic;
    Mon_fil    : out unsigned(4 downto 0) -- Fila de Mon (0-29)
 
  );
end component;

component Mon2_Movimiento is
  Port (
    clk        : in std_logic; -- Reloj
    rst        : in std_logic; -- Reset
    Esp_fil    : in  unsigned(4 downto 0); -- Fila de la espada
    Esp_col    : in  unsigned(4 downto 0); -- Columna de la espada
    button_snes: in std_logic_vector(11 downto 0);
    Mon_col    : out unsigned(4 downto 0); -- Columna de Mon (0-31)
    Alive      : out std_logic;
    Mon_fil    : out unsigned(4 downto 0) -- Fila de Mon (0-29)
 
  );
end component;


component Boss_Mov is
  port (
    clk         : in  std_logic;            -- Señal de reloj
    rst         : in  std_logic;            -- Señal de reset
    Finn_alive  : in std_logic;
    cambio_map  : in std_logic;
    Finn_col    : in  unsigned(4 downto 0); -- Columna de Finn
    Finn_fil    : in  unsigned(4 downto 0);
    Esp_fil     : in  unsigned(4 downto 0); -- Fila de la espada               
    Esp_col     : in  unsigned(4 downto 0); -- Columna de la espada            
    Boss_Alive  : out std_logic; -- Fila de Finn
    Boss_col    : out unsigned(4 downto 0); -- Columna del Boss
    Boss_fil    : out unsigned(4 downto 0)  -- Fila del Boss
  );
end component;

component Multiplex_DMG is
  Port (
    Finn_Col     : in  unsigned(4 downto 0);        -- Columna de Finn
    Finn_Fil     : in  unsigned(4 downto 0);        -- Fila de Finn
    Mon_Col      : in  unsigned(4 downto 0);        -- Columna del primer Monstruo
    Mon_Fil      : in  unsigned(4 downto 0);        -- Fila del primer Monstruo
    Boss_Col     : in  unsigned(4 downto 0);        -- Columna del Boss
    Boss_Fil     : in  unsigned(4 downto 0);        -- Fila del Boss
    Mon1_Col     : in  unsigned(4 downto 0);        -- Columna del segundo Monstruo
    Mon1_Fil     : in  unsigned(4 downto 0);        -- Fila del segundo Monstruo
    Mon2_Col     : in  unsigned(4 downto 0);        -- Columna del segundo Monstruo
    Mon2_Fil     : in  unsigned(4 downto 0); 
    Cambio_Mapa  : in  std_logic;                  -- Señal de cambio de mapa
    Dmg_Col_Out  : out unsigned(4 downto 0);       -- Columna seleccionada
    Dmg_Fil_Out  : out unsigned(4 downto 0)        -- Fila seleccionada
  );
end component;

component TIEMPO_contador is
    port (
        clk        : in std_logic;       -- Señal de reloj de 25 MHz
        rst        : in std_logic;       -- Señal de reset
        segundos   : out std_logic_vector(3 downto 0); -- Segundos (0 a 9)
        button_snes : in std_logic_vector(11 downto 0);
        dsegundos  : out std_logic_vector(3 downto 0); -- Decenas de segundos (0 a 5)
        minutos    : out std_logic_vector(3 downto 0);  -- Minutos (0 a 9)
        colon      : out std_logic_vector(3 downto 0)  -- Minutos (0 a 9) 
    );
end component;

component hdmi_rgb2tmds is
    generic (
        SERIES6 : boolean := false
    );
    port(
        -- rst and clocks
        rst : in std_logic;
        pixelclock : in std_logic;  -- slow pixel clock 1x
        serialclock : in std_logic; -- fast serial clock 5x

        -- video signals
        video_data : in std_logic_vector(23 downto 0);
        video_active  : in std_logic;
        hsync : in std_logic;
        vsync : in std_logic;

        -- tmds output ports
        clk_p : out std_logic;
        clk_n : out std_logic;
        data_p : out std_logic_vector(2 downto 0);
        data_n : out std_logic_vector(2 downto 0)
    );
end component;

component ROM_Mapa1 is
  port (
    clk  : in  std_logic;   -- reloj
    addr : in  std_logic_vector(5-1 downto 0);
    dout : out std_logic_vector(32-1 downto 0); 
    not_addr : in  std_logic_vector(5-1 downto 0);
    not_dout : out std_logic_vector(32-1 downto 0) 
  );
end component;

component ROM_Mapa2 is
  port (
    clk  : in  std_logic;   -- reloj
    addr : in  std_logic_vector(5-1 downto 0);
    dout : out std_logic_vector(32-1 downto 0); 
    not_addr : in  std_logic_vector(5-1 downto 0);
    not_dout : out std_logic_vector(32-1 downto 0) 
  );
end component;

component ROM_Mapa3 is
  port (
    clk  : in  std_logic;   -- reloj
    addr : in  std_logic_vector(5-1 downto 0);
    dout : out std_logic_vector(32-1 downto 0); 
    not_addr : in  std_logic_vector(5-1 downto 0);
    not_dout : out std_logic_vector(32-1 downto 0) 
  );
end component;

component ROM_Arbol is
  port (
    clk  : in  std_logic;   -- reloj
    addr : in  std_logic_vector(4-1 downto 0);
    dout : out std_logic_vector(16-1 downto 0) 
  );
end component;
    


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





    signal clk0, clk1       : std_logic;              -- Clocks from PLL
    signal hsync, vsync     : std_logic;              -- Sync signals from SYNC_VGA
    signal visible          : std_logic;              -- Visible signal
    signal h_count_s, v_count_s  : unsigned(9 downto 0);   -- Column and row signals
    signal vdata_rgb        : std_logic_vector(23 downto 0); -- RGB data
    signal vactive          : std_logic;              -- Video active signal
    -- DATOS MOVIMIENTO PERSONAJE  PRINCIPAL
    signal finn_col_s         :  unsigned(4 downto 0); -- Columna de fin
    signal finn_fil_s         :  unsigned(4 downto 0);  -- Fila de fin
    signal    Finn_Health_s   : unsigned(7 downto 0);
    signal    Finn_Alive_s    :  std_logic;
    
    -- DATOS MOVIMIENTO ESPADA  
    signal Esp_col_s :  unsigned(4 downto 0);
    signal Esp_fil_s :  unsigned(4 downto 0);
    signal Esp_active_s  :  std_logic;
    
    -- DATOS MOVIMIENTO PERSONAJE SECUNDARIO
    signal Mon_col_s    :  unsigned(4 downto 0); -- Columna de fin
    signal Mon_fil_s   :  unsigned(4 downto 0);  -- Fila de fin
    signal Mon_Alive_s  :  std_logic;
    
        -- DATOS MOVIMIENTO PERSONAJE SECUNDARIO
    signal Mon1_col_s    :  unsigned(4 downto 0); -- Columna de fin
    signal Mon1_fil_s   :  unsigned(4 downto 0);  -- Fila de fin
    signal Mon1_Alive_s  :  std_logic;
    
        -- DATOS MOVIMIENTO PERSONAJE SECUNDARIO
    signal Mon2_col_s    :  unsigned(4 downto 0); -- Columna de fin
    signal Mon2_fil_s   :  unsigned(4 downto 0);  -- Fila de fin
    signal Mon2_Alive_s  :  std_logic;
    
        -- DATOS MOVIMIENTO PERSONAJE SECUNDARIO
    signal Boss_col_s    :  unsigned(4 downto 0); -- Columna de fin
    signal Boss_fil_s   :  unsigned(4 downto 0);  -- Fila de fin
    signal Boss_Alive_s  :  std_logic;
    
    -- DATOS PARA LEER PERSONAJE PRINCIPAL
    signal address_Finn_s : std_logic_vector(3 downto 0);
    signal dato_Finn_s : std_logic_vector(15 downto 0);
    
        -- DATOS PARA LEER Espada
    signal address_Espada_s : std_logic_vector(3 downto 0);
    signal dato_Espada_s : std_logic_vector(15 downto 0);
    
    -- VIDA 
    signal Dmg_select_col :  unsigned(4 downto 0);
    signal Dmg_select_fil :  unsigned(4 downto 0);
    
    -- DATOS PARA LEER PERSONAJE NPC
    signal address_Mon_s : std_logic_vector(3 downto 0);
    signal dato_Mon_s : std_logic_vector(15 downto 0);
    
        -- DATOS PARA LEER PERSONAJE BOSS
    signal address_Boss_s : std_logic_vector(3 downto 0);
    signal dato_Boss_s : std_logic_vector(15 downto 0);
    
    
    -- DATOS PARA LEER MAPA 1
    signal address_Mapa1_s : std_logic_vector(4 downto 0);
    signal not_addr_Mapa1_s : std_logic_vector(4 downto 0);
    signal dato_Mapa1_s : std_logic_vector(32-1 downto 0);
    signal not_dato_Mapa1_s : std_logic_vector(32-1 downto 0);
    
        -- DATOS PARA LEER MAPA 2
    signal address_Mapa2_s     : std_logic_vector(4 downto 0);  -- Dirección del Mapa 2
    signal not_addr_Mapa2_s    : std_logic_vector(4 downto 0);  -- Dirección NOT del Mapa 2
    signal dato_Mapa2_s        : std_logic_vector(32-1 downto 0); -- Datos del Mapa 2
    signal not_dato_Mapa2_s    : std_logic_vector(32-1 downto 0); -- Datos NOT del Mapa 2
    
    -- DATOS PARA LEER MAPA 3
    signal address_Mapa3_s     : std_logic_vector(4 downto 0);  -- Dirección del Mapa 3
    signal not_addr_Mapa3_s    : std_logic_vector(4 downto 0);  -- Dirección NOT del Mapa 3
    signal dato_Mapa3_s        : std_logic_vector(32-1 downto 0); -- Datos del Mapa 3
    signal not_dato_Mapa3_s    : std_logic_vector(32-1 downto 0); -- Datos NOT del Mapa 3
    
    
    
        -- DATOS PARA LEER Arbol
    signal address_Arbol_s : std_logic_vector(3 downto 0);
    signal dato_Arbol_s : std_logic_vector(15 downto 0);
    
    -- BOTONES SNES
    signal finish_cont_s1 : std_logic;
    
    
    signal button_snes_s: std_logic_vector (11 downto 0);
    
    signal finish_s : std_logic;
    
    signal BTN_B_s   : std_logic ;
    signal BTN_Y_s    : std_logic ;
    signal BTN_A_s  : std_logic ;
    signal BTN_x_s  : std_logic ;
    signal BTN_Start_s  : std_logic ;
    signal BTN_Select_s : std_logic ;
    
    signal move_up_s    : std_logic ;
    signal move_down_s  : std_logic ;
    signal move_left_s  : std_logic ;
    signal move_right_s : std_logic ;
    
    -- CAMBIO DE MAPA
 
     signal cambio_map_s: std_logic;
     signal cambio_map_habilitador: std_logic;
    signal cuenta_cambio_map : unsigned(1 downto 0);
   --- Cronometro
    signal segundos_s   : std_logic_vector(3 downto 0);
    signal dsegundos_s   : std_logic_vector(3 downto 0);
    signal minutos_s   : std_logic_vector(3 downto 0);
    signal colon_s   : std_logic_vector(3 downto 0); -- Salida de la ROM para ":"
   
   signal addr_segundos_s    : std_logic_vector(8 downto 0);
   signal addr_dsegundos_s   : std_logic_vector(8 downto 0);
   signal addr_minutos_s     : std_logic_vector(8 downto 0);
   signal addr_colon_s       : std_logic_vector(8 downto 0); -- Dirección para ":"
   
   -- Salidas de la ROM
   signal dout_segundos_s    : std_logic_vector(15 downto 0);
   signal dout_dsegundos_s   : std_logic_vector(15 downto 0);
   signal dout_minutos_s     : std_logic_vector(15 downto 0);
   signal dout_colon_s      : std_logic_vector(15 downto 0); -- Salida de la ROM para ":"begin   
   
begin
     -- PLL instantiation
    PLL_comp : PLL
        generic map (
            CLKIN_PERIOD => 8.000, -- Input clock period (8 ns for 125 MHz)
            CLK_MULTIPLY => 8,     -- Multiplier
            CLK_DIVIDE   => 1,     -- Divider
            CLKOUT0_DIV  => 8,     -- Serial clock divider
            CLKOUT1_DIV  => 40     -- Pixel clock divider (for 25 MHz)
        )
        port map (
            clk_i   => clk,        -- Input clock (125 MHz)
            rst     => rst,        -- rst
            clk0_o  => clk0,       -- Serial clock output (125 MHz)
            clk1_o  => clk1        -- Pixel clock output (25 MHz)
        );

    -- SYNC_VGA instantiation
    SYNC_VGA_comp : SYNC_VGA
        port map (
            clk       => clk1,     -- Pixel clock (25 MHz)
            rst       => rst,      -- rst signal
            hsync     => hsync,    -- Horizontal sync
            vsync     => vsync,    -- Vertical sync
            visible   => visible,  -- Visible signal
            columnas  => h_count_s, -- Column address
            filas     => v_count_s     -- Row address
        );


    -- PINTA_BARRAS instantiation
    PINTA_BARRAS_comp : pinta_barras
        port map (
            visible   => visible,       -- Visible signal
            col       => h_count_s,      -- Column address
            fila      => v_count_s,
            -----------------
            Finn_dato   => dato_Finn_s,
            Finn_col    =>finn_col_s,
            Finn_fil    =>finn_fil_s,
            Finn_Health =>Finn_Health_s, 
            Finn_Alive  =>Finn_Alive_s, 
            
            ------------------
            Esp_col       => Esp_col_s,
            Esp_fil       => Esp_fil_s,
            Esp_active    => Esp_active_s,
            Espada_dato   => dato_Espada_s,
            addr_Espada   => address_Espada_s, 
            -------------------
            Mon_dato  =>dato_Mon_s,
            Mon_col   =>Mon_col_s,
            Mon_fil   =>Mon_fil_s,
            Mon_Alive => Mon_Alive_s,
            
            ---------------------
            Mon1_col   =>Mon1_col_s,
            Mon1_fil   =>Mon1_fil_s,
            Mon1_Alive => Mon1_Alive_s,
            ---------------------
            Mon2_col   =>Mon2_col_s,
            Mon2_fil   =>Mon2_fil_s,
            Mon2_Alive => Mon2_Alive_s,
            ---------------------
            
            Boss_dato  => dato_Boss_s  ,
            Boss_col   =>Boss_col_s    ,
            Boss_fil   =>Boss_fil_s    ,
            Boss_Alive => Boss_Alive_s,
            
            ------------------
            Mapa1_dato => dato_Mapa1_s,
            not_Mapa1_dato => not_dato_Mapa1_s,
            -------------------
            Mapa2_dato => dato_Mapa2_s,
            not_Mapa2_dato => not_dato_Mapa2_s,
            -------------------
            Mapa3_dato => dato_Mapa3_s,
            not_Mapa3_dato => not_dato_Mapa3_s,
            -------------------
            Arbol_dato=>dato_Arbol_s,
            -------------------
            addr_Boss  =>address_Boss_s , 
            addr_Fin      => address_Finn_s,  -- Row address
            addr_Mon      => address_Mon_s,  -- Row address
            addr_Mapa1 => address_Mapa1_s,
            not_addr_Mapa1 => not_addr_Mapa1_s,
            addr_Mapa2 => address_Mapa2_s,
            not_addr_Mapa2 => not_addr_Mapa2_s,
            addr_Mapa3 => address_Mapa3_s,
            not_addr_Mapa3 => not_addr_Mapa3_s,
            addr_Arbol      => address_Arbol_s,
            cambio_mapa  =>cambio_map_s,  
            ----------------------------
            segundos  =>segundos_s   ,
            dsegundos =>dsegundos_s  ,
            minutos   =>minutos_s    ,
            colon     =>colon_s      ,
            
            ---
            addr_segundos  => addr_segundos_s,
            addr_dsegundos => addr_dsegundos_s,
            addr_minutos  =>  addr_minutos_s,
            addr_colon    =>  addr_colon_s,                           
            ---
            segundos_dato   => dout_segundos_s,
            dsegundos_dato  =>dout_dsegundos_s,
            minutos_dato    =>dout_minutos_s,
            colon_dato      =>dout_colon_s,                         
           -----------------------------
            rojo      => vdata_rgb(23 downto 16), -- Red component
            verde     => vdata_rgb(15 downto 8),  -- Green component
            azul      => vdata_rgb(7 downto 0)    -- Blue component
        );
        
        
      -- MAPA 1
         MAPA1 : ROM_Mapa1
         port  map(
            clk    => clk1, -- reloj
            not_addr => not_addr_Mapa1_s,
            not_dout => not_dato_Mapa1_s,
            addr  =>address_Mapa1_s ,
            dout  => dato_Mapa1_s 
        );
        -- MAPA 2
         MAPA2 : ROM_Mapa2
         port  map(
            clk    => clk1, -- reloj
            not_addr => not_addr_Mapa2_s,
            not_dout => not_dato_Mapa2_s,
            addr  =>address_Mapa2_s ,
            dout  => dato_Mapa2_s 
        );
        
        -- MAPA 2
         MAPA3 : ROM_Mapa3
         port  map(
            clk    => clk1, -- reloj
            not_addr => not_addr_Mapa2_s,
            not_dout => not_dato_Mapa2_s,
            addr  =>address_Mapa2_s ,
            dout  => dato_Mapa2_s 
        );
     -- PERSONAJE Principal
        PACMAN : ROM1b_1f_pacman_16x16_bn 
        port map (
            clk    => clk1, -- reloj
            addr  =>address_Finn_s ,
            dout  => dato_Finn_s 
        );
                BOSS : ROM_Villano 
        port map (
            clk    => clk1, -- reloj
            addr  =>address_Boss_s ,
            dout  => dato_Boss_s 
        );
        
             -- PERSONAJE ESPADA
        SWORD : ROM_Espada 
        port map (
            clk    => clk1, -- reloj
            addr  =>address_Espada_s ,
            dout  => dato_Espada_s 
        );
      

     -- MOVIMIENTO PERSONAJE  Principal 
         FIN_MOV : Finn_Movimiento 
        port map (
            clk    => clk1, -- reloj
            rst => rst,
            finish_nes =>finish_s ,
            cambio_map =>  cambio_map_s,
            button_snes  =>button_snes_s,
            Mon_col   =>Dmg_select_col, 
            Mon_fil    =>Dmg_select_fil,  
            Finn_Health=>Finn_Health_s, 
            Alive      =>Finn_Alive_s, 
            Finn_col   =>finn_col_s,
            Finn_fil   =>finn_fil_s,
            finish_cont_s  => finish_cont_s1 
        );
        -- ESPADA PARA ATACAR 
         ATK_ESPA : Espada  
        port map (
            clk          =>clk1,
            rst          =>rst,
            button_snes    => button_snes_s,
            Finn_col      =>finn_col_s,
            Finn_fil      =>finn_fil_s,
            Esp_col       => Esp_col_s,
            Esp_fil       => Esp_fil_s,
            Esp_active    =>Esp_active_s
        );              
          -- PERSONAJE Villano
        MON :ROM1b_1f_monster_16 
         port  map(
            clk    => clk1, -- reloj
            addr  =>address_Mon_s ,
            dout  => dato_Mon_s 
        );
        -- MOVIMIENTO Monstruo
        
        MON_MOV : Mon_Movimiento 
        port map (
            clk    => clk1, -- reloj
            rst => rst,
            Esp_col       => Esp_col_s,
            Esp_fil       => Esp_fil_s,
            button_snes => button_snes_s,
            Alive => Mon_Alive_s,
            Mon_col   =>Mon_col_s,
            Mon_fil   =>Mon_fil_s
        ); 
                MON1_MOV : Mon1_Movimiento 
        port map (
            clk    => clk1, -- reloj
            rst => rst,
            Esp_col       => Esp_col_s,
            Esp_fil       => Esp_fil_s,
            button_snes => button_snes_s,
            Alive => Mon1_Alive_s,
            Mon_col   =>Mon1_col_s,
            Mon_fil   =>Mon1_fil_s
        ); 
        
                MON2_MOV : Mon2_Movimiento 
        port map (
            clk    => clk1, -- reloj
            rst => rst,
            Esp_col       => Esp_col_s,
            Esp_fil       => Esp_fil_s,
            button_snes => button_snes_s,
            Alive => Mon2_Alive_s,
            Mon_col   =>Mon2_col_s,
            Mon_fil   =>Mon2_fil_s
        ); 
        
        
        
         -- MOVIMIENTO Boss
        BOSS_MOVE : Boss_Mov 
        port map (
            clk    => clk1, -- reloj
            rst => rst,
            Finn_alive  =>Finn_Alive_s,
            Esp_col       => Esp_col_s,
            cambio_map =>  cambio_map_s,
            Esp_fil       => Esp_fil_s,
            Finn_col      =>finn_col_s,
            Finn_fil      =>finn_fil_s,
            Boss_Alive => Boss_Alive_s,
            Boss_col   =>Boss_col_s,
            Boss_fil   =>Boss_fil_s
        );
        
           Select_dmg: Multiplex_DMG
      Port map (
        Finn_Col     =>Finn_col_s,
        Finn_Fil     => Finn_fil_s,      -- Fila de Finn
        Mon_Col      =>Mon_col_s,      -- Columna del primer Monstruo
        Mon_Fil      =>Mon_fil_s,      -- Fila del primer Monstruo
        Boss_Col     =>Boss_col_s,    -- Columna del Boss
        Boss_Fil     =>Boss_fil_s,        -- Fila del Boss
        Mon1_Col    =>Mon1_Col_s,        -- Columna del segundo Monstruo
        Mon1_Fil     =>Mon1_Fil_s,
        Mon2_Col    =>Mon2_Col_s,        -- Columna del segundo Monstruo
        Mon2_Fil     =>Mon2_Fil_s,         -- Fila del segundo Monstruo
        Cambio_Mapa  =>cambio_map_s,               -- Señal de cambio de mapa
        Dmg_Col_Out  =>Dmg_select_col,       -- Columna seleccionada
        Dmg_Fil_Out  =>Dmg_select_fil       -- Fila seleccionada
      );
   
        
        ARBOLES :ROM_Arbol 
         port  map(
            clk    => clk1, -- reloj
            addr  =>address_Arbol_s ,
            dout  => dato_Arbol_s 
        );
        
        cronometro :TIEMPO_contador 
          port map(
        clk        =>clk1,       -- Señal de reloj de 25 MHz
        rst        =>rst,      -- Señal de reset
        button_snes => button_snes_s,
        segundos   =>segundos_s, -- Segundos (0 a 9)
        dsegundos  =>dsegundos_s, -- Decenas de segundos (0 a 5)
        minutos    =>minutos_s,  -- Minutos (0 a 9)
        colon      => colon_s -- Minutos (0 a 9) 
        );
        
        
    SNESS_FUNCIONA:FSM_SNES_MAIN   
    port map(
    
    
    clk  =>clk0, -- Reloj principal
	rst   =>rst,
    --START => finish_cont_s1,-- para iniciar el protocolo de coms
    data_snes => Pmodin,-- entrada del tren de pulsos de la SNES envia 16 simbolos
   
   --idle_out : out STD_LOGIC;
    --finish : out STD_LOGIC;
    LATCH =>Pmod(0),-- envia flag para iniciar la comunicacion con mando SNES
    clk_snes => Pmod(1),-- envia reloj protocolo coms con mando SNES
    State_buttons => button_snes_s-- envia la info de los botones
    
    );
    
    ROM_segundos: ROM1b_1f_red_num32_play_sprite16x16
        port map (
            clk  => clk1,
            addr => addr_segundos_s,
            dout => dout_segundos_s
        );
    
    ROM_dsegundos: ROM1b_1f_red_num32_play_sprite16x16
        port map (
            clk  => clk1,
            addr => addr_dsegundos_s,
            dout => dout_dsegundos_s
        );
    
    ROM_minutos: ROM1b_1f_red_num32_play_sprite16x16
        port map (
            clk  => clk1,
            addr => addr_minutos_s,
            dout => dout_minutos_s
        );
    
    ROM_colon: ROM1b_1f_red_num32_play_sprite16x16
        port map (
            clk  => clk1,
            addr => addr_colon_s,
            dout => dout_colon_s
        );

    -- HDMI_RGB2TMDS instantiation
    HDMI_RGB2TMDS_inst : hdmi_rgb2tmds
        generic map (
            SERIES6 => false           -- Configuration for FPGA series
        )
        port map (
            rst         => rst,         -- rst signal
            pixelclock  => clk1,        -- Pixel clock (25 MHz)
            serialclock => clk0,        -- Serial clock (125 MHz)
            video_data  => vdata_rgb,   -- Video data (RGB)
            video_active => visible,    -- Video active signal
            hsync       => hsync,       -- Horizontal sync
            vsync       => vsync,       -- Vertical sync
            clk_p       => clkP,        -- TMDS clock positive
            clk_n       => clkN,        -- TMDS clock negative
            data_p      => dataP,       -- TMDS data positive
            data_n      => dataN        -- TMDS data negative
        );
        
      cambio_map_habilitador <= '1' when (Mon_Alive_s='1') and (Mon1_Alive_s='1') and (Mon2_Alive_s='1') else '0'; 
      Cambio_Mapa :process(clk, rst)
    begin
      if rst = '1' then
            cambio_map_s <= '1';
            cuenta_cambio_map <=(others => '0');
      elsif rising_edge(clk) then
        if finn_col_s = 0 and cuenta_cambio_map= 0 and cambio_map_habilitador ='1' then
          cambio_map_s<= '0';
          cuenta_cambio_map <= cuenta_cambio_map + 1;
        end if;
      end if;
    end process;
        
        
BTN_B_s      <= button_snes_s(0); -- Botón B
BTN_Y_s      <= button_snes_s(1); -- Botón Y
BTN_Select_s <= button_snes_s(2); -- Botón Select
BTN_Start_s  <= button_snes_s(3); -- Botón Start
move_up_s    <= button_snes_s(4); -- Flecha UP
move_down_s  <= button_snes_s(5); -- Flecha DOWN
move_left_s  <= button_snes_s(6); -- Flecha LEFT
move_right_s <= button_snes_s(7); -- Flecha RIGHT
BTN_A_s      <= button_snes_s(8); -- Botón A
BTN_X_s      <= button_snes_s(9); -- Botón X
        
    Led(0) <= move_up_s   ;
    Led(1) <= move_down_s ;
    Led(2) <= move_left_s ;
    Led(3) <= move_right_s;

end Behavioral;
