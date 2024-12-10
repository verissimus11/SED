
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Counter12us is
    Port ( 
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           fcuenta6us : out STD_LOGIC;
           fcuenta12us : out STD_LOGIC;
           START : out STD_LOGIC
          );
end Counter12us;

architecture Behavioral of Counter12us is
     signal cuenta24us : natural range 0 to 2**12-1; -- RELOJ DE LA PLACA 125MHz no se puede modificar
     constant cfin24us : natural := 3000; -- uncomment for synthesis
     signal cuenta12us : natural range 0 to 2**11-1; -- RELOJ DE LA PLACA 125MHz no se puede modificar
     constant cfin12us : natural := 1500; -- uncomment for synthesis
     --constant cfin12us : natural := 625; --just for simulation comment for synthesis
     signal ledaux12us : std_logic;
     
     signal cuenta6us : natural range 0 to 2**10-1; -- RELOJ DE LA PLACA 125MHz no se puede modificar
     constant cfin6us : natural := 750; -- uncomment for synthesis
     --constant cfin12us : natural := 625; --just for simulation comment for synthesis
     signal ledaux6us : std_logic;
     
begin
   
   P_contaSTART : Process (rst, clk)
begin
    if rst = '1' then
        cuenta24us <= 0; -- Reinicia el contador
        START <= '0';    -- Inicializa la señal START en 0
    elsif rising_edge(clk) then
        if cuenta24us = 2249 then
            cuenta24us <= 0;     -- Reinicia el contador después de 2250 ciclos
        else
            cuenta24us <= cuenta24us + 1; -- Incrementa el contador
        end if;

        -- Cambia el estado de START según el valor del contador
        if cuenta24us < 750 then
            START <= '1'; -- START en 1 durante los primeros 750 ciclos (6 µs)
        else
            START <= '0'; -- START en 0 durante los siguientes 1500 ciclos (12 µs)
        end if;
    end if;
end process;


    P_conta12us: Process (rst, clk)
    begin
       if rst = '1' then
           cuenta12us <= 0; --pone la cuenta a 0
           
       elsif clk'event and clk = '1' then --Se activa cuando hay un flanco de subida de reloj
      
       if ledaux12us = '1' then  
              cuenta12us <= 0;
              
       else
               cuenta12us <= cuenta12us + 1; 
               
           end if;      
       end if;
    end process;
    
    P_conta6us: Process (rst, clk)
    begin
       if rst = '1' then
           cuenta6us <= 0; --pone la cuenta a 0
           --START<='0' ;
       elsif clk'event and clk = '1' then --Se activa cuando hay un flanco de subida de reloj
      
       if ledaux6us = '1' then  
              cuenta6us <= 0;
             -- START<='1' ;
       else
               cuenta6us <= cuenta6us + 1; 
               
           end if;      
       end if;
    end process;
    
    ledaux12us<= '1' when cuenta12us=cfin12us-1 else '0';
    ledaux6us<= '1' when cuenta6us=cfin6us-1 else '0';     
    
    fcuenta6us <=ledaux6us;
    fcuenta12us<=ledaux12us;
    --START<='1' when ;
    
end Behavioral;
