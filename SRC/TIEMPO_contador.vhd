library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity TIEMPO_contador is
    port (
        clk        : in std_logic;       -- Señal de reloj de 25 MHz
        rst        : in std_logic;       -- Señal de reset
        button_snes : in std_logic_vector(11 downto 0);
        segundos   : out std_logic_vector(3 downto 0); -- Segundos (0 a 9)
        dsegundos  : out std_logic_vector(3 downto 0); -- Decenas de segundos (0 a 5)
        minutos    : out std_logic_vector(3 downto 0);  -- Minutos (0 a 9)
        colon      : out std_logic_vector(3 downto 0)  -- Minutos (0 a 9) 
    );
end TIEMPO_contador;

architecture Behavioral of TIEMPO_contador is
    -- Declaración del componente Contador
    component Contador is
        generic (
            N_BITS    : integer := 27;
            MAX_VALOR : integer := 100
        );
        port (
            clk      : in  std_logic;
            rst      : in  std_logic;
            enable   : in  std_logic;
            up_down  : in  std_logic;
            cuenta   : out std_logic_vector(N_BITS-1 downto 0);
            f_cuenta : out std_logic
        );
    end component;

   -- Declaración del componente ROM

    
     component Filtro_Control is
    Port (          
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           f_cuenta : in STD_LOGIC;
           State_buttons : in STD_LOGIC_VECTOR (11 downto 0); -- Entrada de los botones del mando
           Control_out : out STD_LOGIC_VECTOR (3 downto 0) -- Salida filtrada (Select, Start, L, R)
           );
end component;

    -- Señales internas
    signal f_cuenta_sig : std_logic; -- Pulso generado cada 25 ms
    
    signal cuenta_1s      : std_logic_vector(24 downto 0);         -- Contador para 1 segundo
    signal f_1s           : std_logic;                             -- Pulso de 1 segundo

    signal cuenta_0a9s    : std_logic_vector(3 downto 0);          -- Contador de segundos (0 a 9)
    signal f_10s          : std_logic;                             -- Pulso cada 10 segundos

    signal cuenta_0a5ds   : std_logic_vector(2 downto 0);-- Contador de decenas de segundos (0 a 5)
    signal f_60s          : std_logic;                             -- Pulso cada 60 segundos

    signal cuenta_0a9min  : std_logic_vector(3 downto 0);          -- Contador de minutos (0 a 9)
    
    ---------PAUSA----------------------
      signal Control_boton : std_logic_vector(3 downto 0);
      signal Control_boton_act : std_logic; 
      signal enable_pausa_s : std_logic; 
      signal Control_boton_prev : std_logic ;

    -- Señales combinadas para habilitación
    signal enable_seg     : std_logic;                    -- Habilitación de segundos
    signal enable_dseg    : std_logic;                    -- Habilitación de decenas de segundos
    signal enable_min     : std_logic;                    -- Habilitación de minutos
    
     -- Señales para las direcciones de la ROM

    signal addr_colon       : std_logic_vector(3 downto 0); -- Dirección para ":"




begin


    addr_colon     <= "1111"; -- Dirección fija para ":"


    Filtro_con :Filtro_Control 
    Port map (          
           clk           =>clk,
           rst           =>rst,
           f_cuenta   => f_cuenta_sig,
           State_buttons => button_snes,
           Control_out     =>Control_boton
           );
    
--        Combined_Control(1) -> R
--        Combined_Control(0) -> L
--        Combined_Control(3) -> Start (St)
--        Combined_Control(2) -> Select (S)
           ---- START BUTTON
         process(clk, rst)
        begin
            if rst = '1' then
                Control_boton_act <= '1'; -- Estado inicial
                Control_boton_prev <= '1'; -- Reset del estado previo
            elsif rising_edge(clk) then
                -- Detectar flanco de bajada
                if Control_boton_prev = '1' and Control_boton(3) = '0' then
                    Control_boton_act <= not Control_boton_act; -- Cambiar estado
                end if;
                -- Actualizar el estado previo del botón
                Control_boton_prev <= Control_boton(3);
            end if;
        end process;

    enable_pausa_s <= not(Control_boton_act); -- Asignar el valor del registro a la salida
    -- Generación de señal combinada para habilitar segundos
    enable_seg <= f_1s AND enable_pausa_s;

    -- Generación de señal combinada para habilitar decenas de segundos
    enable_dseg <= f_10s AND f_1s;
    
    -- Generación de señal combinada para habilitar minutos
    enable_min <= f_60s and enable_dseg ;
    
    
    C_100ms : Contador
  generic map(
    N_BITS => 22,
    MAX_VALOR => 2500000 -- Intervalo de 100 ms para un reloj de 25 MHz
  )
  port map(
    clk => clk,
    rst => rst,
    enable => '1', -- Siempre habilitado
    up_down => '0', -- Cuenta ascendente
    cuenta => open,
    f_cuenta => f_cuenta_sig
  );

    -- Instancia para generar un pulso cada 1 segundo
    haceun1s : Contador
        generic map (
            N_BITS => 25,
            MAX_VALOR => 25000000 -- Intervalo de 1 segundo (25 MHz)
        )
        port map (
            clk      => clk,
            rst      => rst,
            enable   => enable_pausa_s,
            up_down  => '0',         -- Cuenta ascendente
            cuenta   => cuenta_1s,   -- Conexión de cuenta
            f_cuenta => f_1s         -- Pulso de 1 segundo
        );

    -- Contador para segundos (0 a 9)
    Un0a9s : Contador
        generic map (
            N_BITS => 4,
            MAX_VALOR => 9 -- Cuenta de 0 a 9
        )
        port map (
            clk      => clk,
            rst      => rst,
            enable   => enable_seg,   -- Habilitado por pulso de 1 segundo
            up_down  => '0',          -- Cuenta ascendente
            cuenta   => cuenta_0a9s,  -- Segundos (0 a 9)
            f_cuenta => f_10s         -- Pulso cada 10 segundos
        );

    -- Contador para decenas de segundos (0 a 5)
    Un1a5ds : Contador
        generic map (
            N_BITS => 3,
            MAX_VALOR => 5 -- Cuenta de 0 a 5
        )
        port map (
            clk      => clk,
            rst      => rst,
            enable   => enable_dseg,  -- Habilitado por pulso de 10 segundos
            up_down  => '0',          -- Cuenta ascendente
            cuenta   => cuenta_0a5ds, -- Decenas de segundos (0 a 5)
            f_cuenta => f_60s         -- Pulso cada 60 segundos
        );

    -- Contador para minutos (0 a 9)
    Un0a9min : Contador
        generic map (
            N_BITS => 4,
            MAX_VALOR => 9 -- Cuenta de 0 a 9 minutos
        )
        port map (
            clk      => clk,
            rst      => rst,
            enable   => enable_min,   -- Habilitado por pulso de 60 segundos
            up_down  => '0',          -- Cuenta ascendente
            cuenta   => cuenta_0a9min,-- Minutos (0 a 9)
            f_cuenta => open          -- No se requiere usar el pulso
        );
        
      


    -- Salidas
    segundos <= cuenta_0a9s;
    dsegundos <= '0' & cuenta_0a5ds;
    minutos <= cuenta_0a9min;
    colon <=addr_colon;

end Behavioral;
