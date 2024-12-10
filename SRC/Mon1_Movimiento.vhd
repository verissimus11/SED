library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.MAPATRACK_PKG.ALL;

entity Mon1_Movimiento is
  Port (
    clk        : in std_logic; -- Reloj
    rst        : in std_logic; -- Reset
    Esp_fil    : in  unsigned(4 downto 0); -- Fila de la espada
    Esp_col    : in  unsigned(4 downto 0); -- Columna de la espada
    button_snes : in std_logic_vector(11 downto 0);
    Mon_col    : out unsigned(4 downto 0); -- Columna de Mon (0-31)
    Mon_fil    : out unsigned(4 downto 0); -- Fila de Mon (0-29)
    Alive      : out std_logic
  );
end Mon1_Movimiento;

architecture Behavioral of Mon1_Movimiento is

  -- Definición de estados
  type state_type is (RIGHT, DOWN, LEFT, UP);
  signal e_act, e_sig : state_type;

  -- Señales internas para posición
  signal col_reg : unsigned(4 downto 0);
  signal fila_reg : unsigned(4 downto 0);  

  -- Señales del contador
  signal cuenta_sig : std_logic_vector(22 downto 0); -- Señal del contador
  signal f_cuenta_sig : std_logic; -- Pulso cada 500 ms
  signal f_cuenta_sig_25ms : std_logic; -- Pulso generado cada 25 ms

---------PAUSA----------------------
  signal Control_boton : std_logic_vector(3 downto 0);
  signal Control_boton_act : std_logic; 
  signal enable_pausa_s : std_logic; 
  signal Control_boton_prev : std_logic ;
-------------------------------------
  signal limt_Mapa : std_logic;

  signal limt_Mapa_up : std_logic;
  signal limt_Mapa_down : std_logic;
  signal limt_Mapa_left : std_logic;
  signal limt_Mapa_right : std_logic;
  ------------VIVO----------------
  signal Char_vivo_s : std_logic; 
  signal Esp_fil_s    :  unsigned(4 downto 0); -- Fila de la espada   
  signal Esp_col_s    :  unsigned(4 downto 0); -- Columna de la espada
  signal collision_detected : std_logic;
  ----------------------------------
  component Vida is
  generic (
    MAX_LIFE : integer := 10;  -- Valor máximo de vida
    DMG_BASE : integer := 1    -- Daño base por defecto
  );
  port (
    clk        : in  std_logic;            -- Señal de reloj
    rst        : in  std_logic;            -- Señal de reset
    Atk_speed  : in  std_logic;
    f_cuenta   : in  std_logic;
    Esp_fil    : in  unsigned(4 downto 0); -- Fila de la espada
    Esp_col    : in  unsigned(4 downto 0); -- Columna de la espada
    Char_fil   : in  unsigned(4 downto 0); -- Fila del personaje
    Char_col   : in  unsigned(4 downto 0); -- Columna del personaje
    life       : out unsigned(7 downto 0); -- Vida actual (0-255)
    is_dead    : out std_logic             -- Indica si la vida es 0
  );
    end component;
  
  -- Componente del contador
  component Contador
    generic(
      N_BITS     : integer := 22;
      MAX_VALOR  : integer := 2500000 -- Para 100 ms con un reloj de 25 MHz
    );
    port(
      clk       : in  std_logic;
      rst       : in  std_logic;
      enable    : in  std_logic;
      up_down   : in  std_logic;
      cuenta    : out std_logic_vector(N_BITS-1 downto 0);
      f_cuenta  : out std_logic
    );
  end component;
  
component Filtro_Control is
    Port (          
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           f_cuenta : in STD_LOGIC;
           State_buttons : in STD_LOGIC_VECTOR (11 downto 0); -- Entrada de los botones del mando
           Control_out : out STD_LOGIC_VECTOR (3 downto 0) -- Salida filtrada (Select, Start, L, R)
           );
end component;

    

begin
    
    
    process(Esp_fil, Esp_col, fila_reg, col_reg)
    begin
        if (Esp_fil = fila_reg and Esp_col = col_reg) then
            collision_detected <= '1';
        else
            collision_detected <= '0';
        end if;
    end process;

  
  -- Instancia del contador para generar un pulso cada 500 ms
    C_500ms : Contador
    generic map(
      N_BITS => 23,
      MAX_VALOR => 7500000 -- Intervalo de 500 ms
    )
    port map(
      clk => clk,
      rst => rst,
      enable => '1',         -- Siempre habilitado
      up_down => '0',        -- Cuenta ascendente
      cuenta => cuenta_sig,  -- Conexión de cuenta (opcional)
      f_cuenta => f_cuenta_sig -- Pulso cada 500 ms
    );
    
    C_25ms : Contador
  generic map(
    N_BITS => 25,
    MAX_VALOR => 2500000 -- Intervalo de 100 ms para un reloj de 25 MHz
  )
  port map(
    clk => clk,
    rst => rst,
    enable => '1', -- Siempre habilitado
    up_down => '0', -- Cuenta ascendente
    cuenta => open,
    f_cuenta => f_cuenta_sig_25ms
  );
    
    Filtro_Con :Filtro_Control 
    Port map (          
           clk           =>clk,
           rst           =>rst,
           f_cuenta   => f_cuenta_sig_25ms,
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

    enable_pausa_s <= Control_boton_act; -- Asignar el valor del registro a la salida


  Health: Vida 
  generic map (
    MAX_LIFE => 1,
    DMG_BASE => 1
  )
  port map (
    clk        => clk ,            -- Señal de reloj
    rst        => rst,             -- Señal de reset
    Atk_speed  => collision_detected, 
    f_cuenta   => f_cuenta_sig_25ms, 
    Esp_fil    => Esp_fil,
    Esp_col    => Esp_col ,
    Char_fil   => fila_reg,
    Char_col   => col_reg,
    life       => open ,
    is_dead    => Char_vivo_s 
  );

    
  -- Máquina de estados
  process(clk, rst)
  begin
    if rst = '1' then
      -- Reset a la posición inicial y estado inicial
      e_act <= RIGHT;

    elsif rising_edge(clk) then
      if f_cuenta_sig = '1' then -- Cambiar cada 500 ms
        e_act <= e_sig;
      end if;
    end if;
  end process;
  
    

    
  -- Lógica de transición de estados
  process(e_act, col_reg, fila_reg)
  begin
    -- Estado por defecto
    e_sig <= e_act;

            case e_act is
              when RIGHT =>
            -- Cambiar a DOWN si se alcanza la columna 22
            if col_reg = 23 then
                e_sig <= DOWN;
            end if;
        
        when DOWN =>
            -- Cambiar a RIGHT si se alcanza la fila 16
            if fila_reg = 7 then
                e_sig <= LEFT;
            end if;
        
        when LEFT =>
            -- Cambiar a UP si se alcanza la columna 29
            if col_reg = 8 then
                e_sig <= UP;
            end if;
        
        when UP =>
            -- Cambiar a LEFT si se alcanza la fila 5
            if fila_reg = 3 then
                e_sig <= RIGHT;
            end if;

      when others =>
        e_sig <= RIGHT; -- Estado por defecto
    end case;
  end process;

  -- Lógica de salida y movimiento
  process(clk, rst)
  begin
    if rst = '1' then
      col_reg <= to_unsigned(3, 5); -- Centro
      fila_reg <= to_unsigned(3, 5); -- Centro

    elsif rising_edge(clk) then
    if enable_pausa_s = '0' then
      if f_cuenta_sig = '1' then -- Mover cada 500 ms
        if Char_vivo_s = '0' then 
                case e_act is
                  when RIGHT =>
                    -- Movimiento hacia la derecha
                    if limt_Mapa_right = '1' then 
                        col_reg <= col_reg + 1;
                    end if;
        
                  when DOWN =>
                    -- Movimiento hacia abajo
                    
                    if limt_Mapa_down = '1' then 
                        fila_reg <= fila_reg + 1;
                    end if;
        
                  when LEFT =>
                    -- Movimiento hacia la izquierda
          
                    if limt_Mapa_left = '1' then 
                        col_reg <= col_reg - 1;
                    end if;
        
                  when UP =>
                    -- Movimiento hacia arriba
                    
                    if limt_Mapa_up = '1' then 
                        fila_reg <= fila_reg - 1;
                    end if;
        
                  when others =>
                    null; -- Sin movimiento
                end case;
             end if;
      end if;
    end if;
    end if;
  end process;


    
 limt_Mapa_up    <=pista(to_integer(fila_reg-1))(to_integer(col_reg));
 limt_Mapa_down  <=pista(to_integer(fila_reg+1))(to_integer(col_reg));
 limt_Mapa_left  <=pista(to_integer(fila_reg))(to_integer(col_reg-1));
 limt_Mapa_right <= pista(to_integer(fila_reg))(to_integer(col_reg+1));
 
  -- Asignación de las posiciones a las salidas
  Mon_col <= col_reg;
  Mon_fil <= fila_reg;
  
  Esp_fil_s <= Esp_fil;
  Esp_col_s <= Esp_col;
  
  Alive<= Char_vivo_s ;

end Behavioral;
