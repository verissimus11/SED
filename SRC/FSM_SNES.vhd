

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity FSM_SNES is
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
end FSM_SNES;

architecture Behavioral of FSM_SNES is

type estados_sec is (IDLE,STATE1,STATE2,STATE3,STATE4); -- Declarar un enumerado donde tendran los estados de nuestra FSM (en este ejemplo
 -- tenemos 3 estados diferentes). --El tipo enumerado que hemos declarado nos permite asignar los valores
--INT, DET0 y DET1 a las signals que se declaren del tipo "estados_sec".
 signal e_act, e_sig : estados_sec; --Se declaran 2 signals que indicaran el estado actual y el estado siguiente    

 constant ON_state : std_logic :='1';
 constant OFF_state : std_logic :='0';
 constant YES : std_logic :='1'; 
 constant NO : std_logic :='0';
 
    signal latch_snes_aux : STD_LOGIC; -- signal latch to indicate SNES pulse train
--    signal idle_out_aux   : STD_LOGIC; -- IDLE state comms protocol deactivated
--    signal finish_aux     : STD_LOGIC; -- finish state, succefully sended pulse train
    signal clkReg_aux     : STD_LOGIC; -- generation of pulse train to know which button pressed.

begin
 --********************* FSM DESING ARCHITECTURE START *********************--
  P_SEQ_FSM: Process (clk, rst) --PROCESO SECUENCIAL CON RELOJ
        begin
         if rst = '1' then
            e_act <= IDLE;
            elsif clk'event and clk='1' then --flipflop tipo D que carga el estado_sig al estado actual
            e_act <= e_sig;
         end if;
    end process;
     
    P_COMB_FSM: Process (e_act, fcuenta6us,fcuenta12us,START,finCnt) -- Proceso combinacional que obtiene el estado siguiente. 
 -- al ser un proceso combinacional NO depende del reloj ni el reset. EN la lista de sensibilidad solo tendremos
 -- todas las signals que se leen, que seran los estados actuales y las entradas.
        begin
        e_sig<=e_act; -- to avoid latches
        
        case e_act is --CON esta sentencia CASE seleccionamos el estado actual (e_act) y segun las entradas, obtendremos
 -- el estado siguiente (e_sig)   
      
      --******************** ESTADO INICIAL IDLE *******************************-- 
            when IDLE => -- EStado inicial
            if (START=OFF_state) then
                e_sig <= IDLE; -- se mantiene esperando
            elsif (START=ON_state and fcuenta12us=YES ) then
                e_sig <= STATE1; -- START=on empieza la comunicacion y el contador 12us empieza en 0.
                     
            end if;
    --********** ESTADO1 **********************--        
            when STATE1 => -- EStado ha detectado 0
            if ( fcuenta12us=NO) then --si no llega a 12us sigue contando
                e_sig <= STATE1; 
            elsif (fcuenta12us=YES) then -- ha llegado a 12us pasa siguiente estado
                e_sig<=STATE2;     
            end if;
        --********** ESTADO2 **********************--     
            when STATE2 => -- EStado a detectado 1
            if (fcuenta6us=NO) then
                e_sig <= STATE2; --si no llega a 6us sigue contando
            elsif (fcuenta6us=YES) then
                e_sig <= STATE3; --si llega a 6us pasa siguiente estado
            end if;  
           --********** ESTADO3  **********************--      
            when STATE3 => -- EStado a detectado 1
            if (fcuenta6us=NO ) then
                e_sig <= STATE3; --si no llega a 6us sigue contando
            elsif (fcuenta6us=YES AND finCnt=NO) then
                e_sig <= STATE2;--si llega a 6us y no ha terminado el tren de pulsos cambia estado 2
            elsif (fcuenta6us=YES AND finCnt=YES) then
                e_sig <= STATE4;-- llega 6us y llega el fin del tren de pulsos pasa estado 4
            end if;  
            
            --********** ESTADO4  **********************--      
            when STATE4 => -- EStado a detectado 1
            if (fcuenta12us=NO) then
                e_sig <= STATE4; -- si no llega a 12us sigue contando
            elsif (fcuenta12us=YES) then
                e_sig <= IDLE; --llega a 12us termina el protocolo de comunicacion
            end if;
                
         end case;
--********MUY IMPORTANTE!!!*****************
--Evitar "latches" es un proceso combinacional y NO queremos crear elementos de memoria. Para asegurarnos de NO CREAR LATCH
-- es necesario especificar TODOS los posibles casos en el "if", es decir, el if SIEMPRE debe ir con un else para que SIEMPRE
-- se le asigne un valor a la signal "e_sig".
--*******************************************************************
 end process;
 
  process (e_act) -- Es una Maquina de Moore solo depende del estado actual
    -- Maquina de Mealy tambien dependeria de las entradas.
        begin
            case e_act is 
            
                when IDLE=> 
                    latch_snes_aux<= NO;
                    clkReg_aux    <= YES;                                  
--                    idle_out_aux  <= YES;
--                    finish_aux    <= NO;
                   
                when  STATE1=>                
                    latch_snes_aux<= YES;                                 
                    clkReg_aux    <= YES;
--                    idle_out_aux  <= NO;
--                    finish_aux    <= NO;
       
                when  STATE2 =>
                    latch_snes_aux<= NO;                              
                    clkReg_aux    <= YES;
--                    idle_out_aux  <= NO;
--                    finish_aux    <= NO;
                              
                when  STATE3=>
                    latch_snes_aux<= NO; 
                    clkReg_aux    <= NO;                                   
--                    idle_out_aux  <= NO;
--                    finish_aux    <= NO;
                    
                when  STATE4=>
                    latch_snes_aux<= NO;                                    
                    clkReg_aux    <= YES; 
--                    idle_out_aux  <= NO; 
--                    finish_aux    <= YES; 
                     
             end case;  
   -- MUY IMPORTANTE!! Siempre que la salida este asignada en TODAS las condiciones posibles para evitar Latches             
    end process;
    
 --********************* END FSM ARCHITECTURE **************************--
 
    enCnt<= YES when e_act = STATE2 or e_act = STATE3 else NO;
    pre_finish <= YES when e_act=STATE4 else NO;
   
   latch_snes <= latch_snes_aux ;
--   idle_out   <= idle_out_aux   ;
--   finish     <= finish_aux     ;
   clkReg     <= clkReg_aux     ;
 
 
 

end Behavioral;
