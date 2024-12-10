library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Espada is
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
end Espada;

architecture Behavioral of Espada is
  -- Componente del contador
  component Contador
    generic(
      N_BITS     : integer := 22;
      MAX_VALOR  : integer := 1250000 -- Para 50 ms con un reloj de 25 MHz
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
    component Filtro_Mov is
    Port (          
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           f_cuenta : in STD_LOGIC;
           State_buttons : in STD_LOGIC_VECTOR (11 downto 0); -- entrada boton pulsado
           pulso_btn : out STD_LOGIC_VECTOR (3 downto 0)
           );
  end component;  
  component Filtro_Action is
    Port (          
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           f_cuenta : in STD_LOGIC;
           State_buttons : in STD_LOGIC_VECTOR (11 downto 0); -- Entrada de botones: B, Y, A, X
           Action_out : out STD_LOGIC_VECTOR (3 downto 0) -- Salida combinada filtrada
           );
 end component;
  



-- Definición de estado
  type espada_state_type is (INACTIVE, ACTIVE);
  signal e_act, e_sig : espada_state_type;

  -- Señales internas para posición
  signal esp_col_reg : unsigned(4 downto 0);
  signal esp_fil_reg : unsigned(4 downto 0);  

  -- Señales del contador
 
  signal f_cuenta_sig : std_logic; -- Pulso cada 50 ms

  
  -- Dirección del movimiento
  signal throw_direction : std_logic_vector(1 downto 0); -- Última dirección del movimiento

  -- Señales de botones filtrados
  signal mov_boton : std_logic_vector(3 downto 0);
  signal Act_boton : std_logic_vector(3 downto 0);
  signal Act_boton_s : std_logic ; -- Estado previo del botón
  signal Act_boton_prev : std_logic ; -- Estado previo del botón
  signal Act_boton_act  : std_logic ; -- Estado actual del botón
  
  signal move_up_filtered     : std_logic := '0';
  signal move_down_filtered   : std_logic := '0';
  signal move_left_filtered   : std_logic := '0';
  signal move_right_filtered  : std_logic := '0';
  
  signal Esp_active_s : std_logic; 
  


  
   -- Señal combinada para activar la transición a INACTIVE
  signal deactivate_signal : std_logic;

begin
      -- Instancia del filtro de botones
  Filtro_A : Filtro_Action
    Port map (
      clk           => clk,
      rst           => rst,
      f_cuenta      => f_cuenta_sig,
      State_buttons => button_snes,
      Action_out     => Act_boton
    );
    
        --Action_out(3) -> Botón X
        --Action_out(2) -> Botón A
        --Action_out(1) -> Botón Y
        --Action_out(0) -> Botón B
        
    process(clk, rst)
    begin
        if rst = '1' then
            Act_boton_act <= '1'; -- Estado inicial
            Act_boton_prev <= '1'; -- Reset del estado previo
        elsif rising_edge(clk) then
            -- Detectar flanco de bajada
            if Act_boton_prev = '1' and Act_boton(0) = '0' then
                Act_boton_act <= not Act_boton_act; -- Cambiar estado
            end if;
            -- Actualizar el estado previo del botón
            Act_boton_prev <= Act_boton(0);
        end if;
    end process;
      
      Act_boton_s <= Act_boton_act;
    
  -- Instancia del filtro de botones
  Filtro_M : Filtro_Mov
    Port map (
      clk           => clk,
      rst           => rst,
      f_cuenta      => f_cuenta_sig,
      State_buttons => button_snes,
      pulso_btn     => mov_boton
    );

  -- Asignación de botones filtrados
  move_up_filtered    <= mov_boton(0);
  move_down_filtered  <= mov_boton(1);
  move_left_filtered  <= mov_boton(2);
  move_right_filtered <= mov_boton(3);

  -- Instancia del contador para generar un pulso cada 50 ms
  C_50ms : Contador
    generic map(
      N_BITS => 22,
      MAX_VALOR => 2500000
    )
    port map(
      clk => clk,
      rst => rst,
      enable => '1',         -- Siempre habilitado
      up_down => '0',        -- Cuenta ascendente
      cuenta => open,  -- Conexión de cuenta (opcional)
      f_cuenta => f_cuenta_sig -- Pulso cada 50 ms
    );

  -- Máquina de estados
process(clk, rst)
begin
    if rst = '1' then
        e_act <= INACTIVE; -- Estado inicial

    elsif rising_edge(clk) then
       if f_cuenta_sig = '1' then -- Cambiar cada 50 ms
        e_act <= e_sig;
      end if;
    end if;
end process;

-- Proceso para la lógica de transición de estados
process(e_act, Act_boton_s)  -- Act_boton(0) es el botón para activar/desactivar la espada
begin
    case e_act is
        when INACTIVE =>
            if Act_boton_s = '0' then -- Pulsar botón activa la espada
                e_sig <= ACTIVE;
            end if;

        when ACTIVE =>
            if Act_boton_s = '0' then -- Pulsar botón desactiva la espada
                e_sig <= INACTIVE;
            end if;

--        when others =>
--            e_sig <= INACTIVE; -- Estado por defecto
    end case;
end process;

-- Proceso para determinar la dirección de la espada según los botones filtrados
process(clk, rst,move_up_filtered,move_down_filtered,move_left_filtered,move_right_filtered)
begin
    if rst = '1' then
        throw_direction <= "00"; -- Dirección inicial (Derecha)
    elsif rising_edge(clk) then
        if move_up_filtered = '0' then
            throw_direction <= "10"; -- Arriba
        elsif move_down_filtered = '0' then
            throw_direction <= "11"; -- Abajo
        elsif move_left_filtered = '0' then
            throw_direction <= "01"; -- Izquierda
        elsif move_right_filtered = '0' then
            throw_direction <= "00"; -- Derecha
        end if;
        
    end if;
end process;


-- Lógica de salida y movimiento de la espada
process(e_act, throw_direction, Finn_col, Finn_fil)
begin
    -- Señal para indicar si la espada está activa

    if Esp_active_s = '1' then
        -- Posicionar la espada un bloque adelante de Finn según la dirección
        if throw_direction = "00" then  -- Derecha
            esp_col_reg <= Finn_col + 1;
            esp_fil_reg <= Finn_fil;
        elsif throw_direction = "01" then  -- Izquierda
            esp_col_reg <= Finn_col - 1;
            esp_fil_reg <= Finn_fil;
        elsif throw_direction = "10" then  -- Arriba
            esp_col_reg <= Finn_col;
            esp_fil_reg <= Finn_fil - 1;
        elsif throw_direction = "11" then  -- Abajo
            esp_col_reg <= Finn_col;
            esp_fil_reg <= Finn_fil + 1;
        else
            -- Default: mantener la espada en la posición actual de Finn
            esp_col_reg <= Finn_col;
            esp_fil_reg <= Finn_fil;
        end if;
 
    end if;
end process;

Esp_col <= esp_col_reg;
Esp_fil <= esp_fil_reg;
Esp_active_s <= '1' when e_act = ACTIVE else '0';
Esp_active<= Esp_active_s;

end Behavioral;


