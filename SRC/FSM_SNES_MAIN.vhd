

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FSM_SNES_MAIN is
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
end FSM_SNES_MAIN;

architecture Behavioral of FSM_SNES_MAIN is

    signal fcuenta6us_int  : STD_LOGIC;
    signal fcuenta12us_int : STD_LOGIC;
    signal enCnt_int : STD_LOGIC;
    signal finCnt_int : STD_LOGIC;
    signal pre_finish_int : STD_LOGIC;
    signal clkReg_int : STD_LOGIC;
    signal start_aux : std_logic;
    
    component FSM_SNES
     Port ( 
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           START : in STD_LOGIC; -- signal to indicate comunication start
           fCuenta6us : in STD_LOGIC; -- fin de la cuenta 6us
           fCuenta12us : in STD_LOGIC; -- fin de la cuenta 12us ha llegado a 12us
           finCnt : in STD_LOGIC; -- fin cuenta pulsos,  ha enviado con exito el tren de pulsos
           
           latch_snes : out STD_LOGIC; -- flag signal para activar la comunicacion 
--           idle_out : out STD_LOGIC; -- estado de espera para recibir orden de comunicacion
--           finish : out STD_LOGIC; -- indica fin de la comunicacion con mando SNES
           clkReg : out STD_LOGIC; -- reloj comunicacion con mando SNES
           enCnt : out STD_LOGIC; -- habilitar la cuenta del tren de pulsos
           pre_finish : out STD_LOGIC -- para guardar y enviar los botones pulsados SNES 
         );
    end component;

    component Shift_register
    Port ( 
           rst: in STD_LOGIC;          
           clkReg : in STD_LOGIC;
           data_snes : in STD_LOGIC;
           pre_finish : in STD_LOGIC; -- pre_finish tiempo para cargar los datos de la snes
           -- antes de que se vuelvan a actualizar
           buttons_snes : out STD_LOGIC_VECTOR (11 downto 0) -- salida info boton pulsado
          );
    end component;
    
    component CounterClks
    Port ( 
          clk : in STD_LOGIC;
          rst : in STD_LOGIC;
          fcounter6us: in STD_LOGIC; -- fin de cuenta 6us
          fcounter12us: in STD_LOGIC;-- fin de cuenta 12us
          enCnt : in STD_LOGIC; -- entrada de FSM indicar contando pulsos en estado 2 o 3
         
          finCnt : out STD_LOGIC -- fin de la cuenta de pulsos llego al max
          );
    end component;
    
    component Counter12us
     Port ( 
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           fcuenta6us : out STD_LOGIC;
           fcuenta12us : out STD_LOGIC;
           START : out STD_LOGIC
          );
    end component;
    
begin

    SNES1:FSM_SNES
    port map
    (
    clk         => clk,
    rst         => rst,
    START       => start_aux, -- start signal para comenzar el protocolo de coms
    fCuenta6us  => fcuenta6us_int, --pulso 6us
    fCuenta12us => fcuenta12us_int, --pulso 12us
    finCnt      => finCnt_int, --entrada de fin de pulsos SNES
    -- out ports          
    latch_snes  => LATCH, -- envia latch para iniciar el protocolo de comunicacion
--    idle_out    => idle_out,
--    finish      => finish,
    clkReg      => clkReg_int,
    enCnt       => enCnt_int,
    pre_finish  => pre_finish_int
    );

    SNES2: CounterClks
    port map
    (
      clk          => clk,
      rst          => rst,
      fcounter6us  => fcuenta6us_int, 
      fcounter12us => fcuenta12us_int,
      enCnt        => enCnt_int,
                      
      finCnt       => finCnt_int
    );
    
    SNES3:Counter12us
    port map
    (
     clk         => clk,
     rst         => rst,
     fcuenta6us  => fcuenta6us_int,
     fcuenta12us => fcuenta12us_int,
     START       => start_aux
    );

    SNES4: Shift_register
    port map
    (
    rst          => rst,
    clkReg       => clkReg_int,
    data_snes    => data_snes, -- datos enviados por el mando SNES
    pre_finish   => pre_finish_int, -- flag carga datos botones pulsados
                 
    buttons_snes => State_buttons -- botones que han sido pulsados
    );
    
    clk_snes<=clkReg_int;
    
end Behavioral;
