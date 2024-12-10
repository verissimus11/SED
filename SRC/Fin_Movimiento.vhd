library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use WORK.MAPATRACK_PKG.ALL;
use WORK.NOT_MAPATRACK_PKG.ALL;

entity Finn_Movimiento is
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
end Finn_Movimiento;


architecture Behavioral of Finn_Movimiento is

  -- Componente Contador
  component Contador
    generic (
      N_BITS    : integer := 27;
      MAX_VALOR : integer := 125_000_000
    );
    port (
      clk      : in std_logic;
      rst      : in std_logic;
      enable   : in std_logic;
      up_down  : in std_logic;
      cuenta   : out std_logic_vector(N_BITS - 1 downto 0);
      f_cuenta : out std_logic
    );
  end component;
  component Filtro_Mov is
    Port (          
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           f_cuenta : in STD_LOGIC;
           State_buttons : in STD_LOGIC_VECTOR (11 downto 0); -- entrada boton pulsado
           pulso_btn : out STD_LOGIC_VECTOR (3 downto 0)
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

  component Vida is
  generic (
    MAX_LIFE : integer := 10;  -- Valor máximo de vida
    DMG_BASE : integer := 1    -- Daño base por defecto
  );
  port (
    clk        : in  std_logic;            -- Señal de reloj
    rst        : in  std_logic; 
    f_cuenta   : in  std_logic;
    Atk_speed  : in  std_logic;           -- Señal de reset
    Esp_fil    : in  unsigned(4 downto 0); -- Fila de la espada
    Esp_col    : in  unsigned(4 downto 0); -- Columna de la espada
    Char_fil   : in  unsigned(4 downto 0); -- Fila del personaje
    Char_col   : in  unsigned(4 downto 0); -- Columna del personaje
    life       : out unsigned(7 downto 0); -- Vida actual (0-255)
    is_dead    : out std_logic             -- Indica si la vida es 0
  );
    end component;
    



  -- Definición de los estados
 type state_type is (
    IDLE, MOVE_UP1, MOVE_DOWN1, MOVE_LEFT1, MOVE_RIGHT1,
    MOVE_UP_LEFT1, MOVE_UP_RIGHT1, MOVE_DOWN_LEFT1, MOVE_DOWN_RIGHT1
);
signal e_act, e_sig : state_type;

  -- Señales internas para posición
  signal col_reg : unsigned(4 downto 0); -- Columna inicial
  signal fila_reg : unsigned(4 downto 0); -- Fila inicial
  signal mov_boton : std_logic_vector(3 downto 0);

  -- Señales del contador
  signal cuenta_sig : std_logic_vector(21 downto 0); -- Tamaño de 27 bits para N_BITS
  signal f_cuenta_sig : std_logic; -- Pulso generado cada 100 ms
  signal f_cuenta_sig_25ms : std_logic; -- Pulso generado cada 25 ms
  signal f_cuenta_sig_health : std_logic;
  
  
    -- Señales internas para filtrar el estado de los botones
  signal move_up_filtered     : std_logic := '1' ;
  signal move_down_filtered   : std_logic := '1' ;
  signal move_left_filtered   : std_logic := '1' ;
  signal move_right_filtered  : std_logic := '1' ;

  -- Límites del mapa
  signal limt_Mapa_up    : std_logic;
  signal limt_Mapa_down  : std_logic;
  signal limt_Mapa_left  : std_logic;
  signal limt_Mapa_right : std_logic;
  
  -- Complementos de los límites del mapa
  signal not_limit_Mapa_up    : std_logic;
  signal not_limit_Mapa_down  : std_logic;
  signal not_limit_Mapa_left  : std_logic;
  signal not_limit_Mapa_right : std_logic;
  
  --CAMBIAR MAPA
--  signal cambio_map : std_logic;
  signal cuenta_cambio_map : unsigned(1 downto 0);
  signal cuenta_cambio_map_c : integer := 2; -- Inicialización en 2

---------PAUSA----------------------
  signal Control_boton : std_logic_vector(3 downto 0);
  signal Control_boton_act : std_logic; 
  signal enable_pausa_s : std_logic; 
  signal Control_boton_prev : std_logic ;
  signal collision_detected : std_logic;

  



  
  --filtrado de la señal

begin

    process(Mon_fil, Mon_col, fila_reg, col_reg)
    begin
        if (Mon_fil = fila_reg and Mon_col = col_reg) then
            collision_detected <= '1';
        else
            collision_detected <= '0';
        end if;
    end process;
    
      Health: Vida 
  generic map (
    MAX_LIFE => 6,
    DMG_BASE => 1
  )
  port map (
    clk        => clk ,            -- Señal de reloj
    rst        => rst,
    Atk_speed  =>  collision_detected,
    f_cuenta  => f_cuenta_sig_health,       -- Señal de reset
    Esp_fil    => Mon_fil,
    Esp_col    => Mon_col ,
    Char_fil   => fila_reg,
    Char_col   => col_reg,
    life       => Finn_Health ,
    is_dead    => Alive 
  );
  
        C_250ms : Contador
  generic map(
    N_BITS => 23,
    MAX_VALOR => 5000000 -- Intervalo de 250 ms para un reloj de 25 MHz
  )
  port map(
    clk => clk,
    rst => rst,
    enable => '1', -- Siempre habilitado
    up_down => '0', -- Cuenta ascendente
    cuenta => open,
    f_cuenta => f_cuenta_sig_health
  );  
    
    Filtro_move :Filtro_Mov 
    Port map (          
           clk           =>clk,
           rst           =>rst,
           f_cuenta   => f_cuenta_sig_25ms,
           State_buttons => button_snes,
           pulso_btn     =>mov_boton
           );
           
       move_up_filtered   <=mov_boton(0);
       move_down_filtered <=mov_boton(1);
       move_left_filtered <=mov_boton(2);
       move_right_filtered<=mov_boton(3);
       
    Filtro_con :Filtro_Control 
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
    
  -- Contador de 100 ms
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
    cuenta => cuenta_sig,
    f_cuenta => f_cuenta_sig
  );
  
    C_25ms : Contador
  generic map(
    N_BITS => 20,
    MAX_VALOR => 625000 -- Intervalo de 25 ms para un reloj de 25 MHz
  )
  port map(
    clk => clk,
    rst => rst,
    enable => '1', -- Siempre habilitado
    up_down => '0', -- Cuenta ascendente
    cuenta => open,
    f_cuenta => f_cuenta_sig_25ms
  );
  
--    process(clk, rst)
--    begin
--      if rst = '1' then
--        cambio_map <= '1';
--      elsif rising_edge(clk) then
--        if f_cuenta_sig = '1' then
--          if col_reg = 0 then
--            cambio_map <= '0';
--          end if;
--        end if;
--      end if;
--    end process;
    

--    -- Proceso separado para actualizar posición
--    process(clk, rst)
--    begin
--      if rst = '1' then
--            cuenta_cambio_map <= (others => '0');
--      elsif rising_edge(clk) then
--        if cambio_map = '0' and cuenta_cambio_map= 0 then
--         --col_reg <= to_unsigned(10, 5); -- Columna central
--         --fila_reg <= to_unsigned(16, 5); -- Fila central
--          cuenta_cambio_map <= cuenta_cambio_map + 1;
--        end if;
--      end if;
--    end process;
    
--     Filtrado de señales de movimiento (capturar estado limpio)


  -- Máquina de estados: lógica de transición
process(e_act, move_up_filtered, move_down_filtered, move_left_filtered, move_right_filtered)
begin
    e_sig <= e_act; -- Estado por defecto 
    case e_act is
    
        when IDLE =>
            if move_up_filtered = '0' and move_left_filtered = '0' then
                e_sig <= MOVE_UP_LEFT1;
            elsif move_up_filtered = '0' and move_right_filtered = '0' then
                e_sig <= MOVE_UP_RIGHT1;
            elsif move_down_filtered = '0' and move_left_filtered = '0' then
                e_sig <= MOVE_DOWN_LEFT1;
            elsif move_down_filtered = '0' and move_right_filtered = '0' then
                e_sig <= MOVE_DOWN_RIGHT1;
            elsif move_up_filtered = '0' then
                e_sig <= MOVE_UP1;
            elsif move_down_filtered = '0' then
                e_sig <= MOVE_DOWN1;
            elsif move_left_filtered = '0' then
                e_sig <= MOVE_LEFT1;
            elsif move_right_filtered = '0' then
                e_sig <= MOVE_RIGHT1;
            end if;

        when MOVE_UP1 =>
            if move_up_filtered = '0' then
                e_sig <= MOVE_UP1;
            else
                e_sig <= IDLE;
            end if;

        when MOVE_DOWN1 =>
            if move_down_filtered = '0' then
                e_sig <= MOVE_DOWN1;
            else
                e_sig <= IDLE;
            end if;

        when MOVE_LEFT1 =>
            if move_left_filtered = '0' then
                e_sig <= MOVE_LEFT1;
            else
                e_sig <= IDLE;
            end if;

        when MOVE_RIGHT1 =>
            if move_right_filtered = '0' then
                e_sig <= MOVE_RIGHT1;
            else
                e_sig <= IDLE;
            end if;

        when MOVE_UP_LEFT1 =>
            if move_up_filtered = '0' and move_left_filtered = '0' then
                e_sig <= MOVE_UP_LEFT1;
            else
                e_sig <= IDLE;
            end if;

        when MOVE_UP_RIGHT1 =>
            if move_up_filtered = '0' and move_right_filtered = '0' then
                e_sig <= MOVE_UP_RIGHT1;
            else
                e_sig <= IDLE;
            end if;

        when MOVE_DOWN_LEFT1 =>
            if move_down_filtered = '0' and move_left_filtered = '0' then
                e_sig <= MOVE_DOWN_LEFT1;
            else
                e_sig <= IDLE;
            end if;

        when MOVE_DOWN_RIGHT1 =>
            if move_down_filtered = '0' and move_right_filtered = '0' then
                e_sig <= MOVE_DOWN_RIGHT1;
            else
                e_sig <= IDLE;
            end if;

        when others =>
            e_sig <= IDLE;
    end case;
end process;

-- Máquina de estados: lógica de salida
process(clk, rst)
begin
    if rst = '1' then
        e_act <= IDLE;
       col_reg <=  to_unsigned(10, 5); -- Columna central
       fila_reg <= to_unsigned(1, 5); -- Fila central

    elsif rising_edge(clk) then
        e_act <= e_sig;
       if enable_pausa_s= '0' then  
       if cambio_map = '1' then
    if f_cuenta_sig = '1' then
        case e_act is
            when MOVE_UP1 =>
                if fila_reg > 0 and limt_Mapa_up = '1' then
                    fila_reg <= fila_reg - 1;
                end if;

            when MOVE_DOWN1 =>
                if fila_reg < 29 and limt_Mapa_down = '1' then
                    fila_reg <= fila_reg + 1;
                end if;

            when MOVE_LEFT1 =>
                if col_reg > 0 and limt_Mapa_left = '1' then
                    col_reg <= col_reg - 1;
                end if;

            when MOVE_RIGHT1 =>
                if col_reg < 32 and limt_Mapa_right = '1' then
                    col_reg <= col_reg + 1;
                end if;

            when MOVE_UP_LEFT1 =>
                if fila_reg > 0 and col_reg > 0 and limt_Mapa_up = '1' and limt_Mapa_left = '1' then
                    fila_reg <= fila_reg - 1;
                    col_reg <= col_reg - 1;
                end if;

            when MOVE_UP_RIGHT1 =>
                if fila_reg > 0 and col_reg < 32 and limt_Mapa_up = '1' and limt_Mapa_right = '1' then
                    fila_reg <= fila_reg - 1;
                    col_reg <= col_reg + 1;
                end if;

            when MOVE_DOWN_LEFT1 =>
                if fila_reg < 29 and col_reg > 0 and limt_Mapa_down = '1' and limt_Mapa_left = '1' then
                    fila_reg <= fila_reg + 1;
                    col_reg <= col_reg - 1;
                end if;

            when MOVE_DOWN_RIGHT1 =>
                if fila_reg < 29 and col_reg < 32 and limt_Mapa_down = '1' and limt_Mapa_right = '1' then
                    fila_reg <= fila_reg + 1;
                    col_reg <= col_reg + 1;
                end if;

            when others =>
                fila_reg <= fila_reg;
                col_reg <= col_reg;
        end case;
    end if;
elsif cambio_map = '0' then
    if f_cuenta_sig = '1' then
        case e_act is
            when MOVE_UP1 =>
                if fila_reg > 0 and not_limit_Mapa_up = '1' then
                    fila_reg <= fila_reg - 1;
                end if;

            when MOVE_DOWN1 =>
                if fila_reg < 29 and not_limit_Mapa_down = '1' then
                    fila_reg <= fila_reg + 1;
                end if;

            when MOVE_LEFT1 =>
                if col_reg > 0 and not_limit_Mapa_left = '1' then
                    col_reg <= col_reg - 1;
                end if;

            when MOVE_RIGHT1 =>
                if col_reg < 32 and not_limit_Mapa_right = '1' then
                    col_reg <= col_reg + 1;
                end if;

            when MOVE_UP_LEFT1 =>
                if fila_reg > 0 and col_reg > 0 and not_limit_Mapa_up = '1' and not_limit_Mapa_left = '1' then
                    fila_reg <= fila_reg - 1;
                    col_reg <= col_reg - 1;
                end if;

            when MOVE_UP_RIGHT1 =>
                if fila_reg > 0 and col_reg < 32 and not_limit_Mapa_up = '1' and not_limit_Mapa_right = '1' then
                    fila_reg <= fila_reg - 1;
                    col_reg <= col_reg + 1;
                end if;

            when MOVE_DOWN_LEFT1 =>
                if fila_reg < 29 and col_reg > 0 and not_limit_Mapa_down = '1' and not_limit_Mapa_left = '1' then
                    fila_reg <= fila_reg + 1;
                    col_reg <= col_reg - 1;
                end if;

            when MOVE_DOWN_RIGHT1 =>
                if fila_reg < 29 and col_reg < 32 and not_limit_Mapa_down = '1' and not_limit_Mapa_right = '1' then
                    fila_reg <= fila_reg + 1;
                    col_reg <= col_reg + 1;
                end if;

            when others =>
                fila_reg <= fila_reg;
                col_reg <= col_reg;
            end case;
            end if;
        end if;
    end if;
end if;
end process;


    



  -- Límites del mapa
  limt_Mapa_up    <= pista(to_integer(fila_reg - 1))(to_integer(col_reg));
  limt_Mapa_down  <= pista(to_integer(fila_reg + 1))(to_integer(col_reg));
  limt_Mapa_left  <= pista(to_integer(fila_reg))(to_integer(col_reg - 1));
  limt_Mapa_right <= pista(to_integer(fila_reg))(to_integer(col_reg + 1));
  
    -- Complementos de los límites del mapa
    not_limit_Mapa_up    <= not_pista(to_integer(fila_reg - 1))(to_integer(col_reg));
    not_limit_Mapa_down  <= not_pista(to_integer(fila_reg + 1))(to_integer(col_reg));
    not_limit_Mapa_left  <= not_pista(to_integer(fila_reg))(to_integer(col_reg - 1));
    not_limit_Mapa_right <= not_pista(to_integer(fila_reg))(to_integer(col_reg + 1));

  -- Asignación de las posiciones a las salidas
  Finn_col <= col_reg;
  Finn_fil <= fila_reg;
  finish_cont_s <= f_cuenta_sig;

  

end Behavioral;