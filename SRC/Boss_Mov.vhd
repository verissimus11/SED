library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Boss_Mov is
  port (
    clk         : in  std_logic;            -- Señal de reloj
    rst         : in  std_logic;            -- Señal de reset
    Finn_alive  : in std_logic;
    cambio_map  : in std_logic;
    Finn_col    : in  unsigned(4 downto 0); -- Columna de Finn
    Finn_fil    : in  unsigned(4 downto 0); -- Fila de Finn
    Esp_fil     : in  unsigned(4 downto 0); -- Fila de la espada
    Esp_col     : in  unsigned(4 downto 0); -- Columna de la espada
    Boss_col    : out unsigned(4 downto 0); -- Columna del Boss
    Boss_fil    : out unsigned(4 downto 0);  -- Fila del Boss
    Boss_Alive  : out std_logic
    
  );
end Boss_Mov;

architecture Behavioral of Boss_Mov is

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
  

  -- Señales internas
  signal col_reg : unsigned(4 downto 0) ; -- Posición inicial columna
  signal fil_reg : unsigned(4 downto 0) ; -- Posición inicial fila
  signal boss_activado : std_logic ; -- Indica si el Boss está activado
  signal boss_move_pulse : std_logic ; -- Pulso para el movimiento
  
      -- CAMBIO DE MAPA
 
  signal cambio_map_s: std_logic;
  signal cuenta_cambio_map : unsigned(1 downto 0);
  
  ------------VIVO----------------
  
  signal Char_vivo_s : std_logic; 
  signal Esp_fil_s    :  unsigned(4 downto 0); -- Fila de la espada   
  signal Esp_col_s    :  unsigned(4 downto 0); -- Columna de la espada
  ----------------------------------
  signal f_cuenta_sig_25ms : std_logic; -- Pulso generado cada 25 ms
  signal collision_detected : std_logic;



begin
--            process(Esp_fil, Esp_col, fil_reg, col_reg)
--    begin
--        if (Esp_fil = fil_reg and Esp_col = col_reg) then
--            collision_detected <= '1';
--        else
--            collision_detected <= '0';
--        end if;
--    end process;
        
        
        C_25ms : Contador
  generic map(
    N_BITS => 25,
    MAX_VALOR => 2500000 -- Intervalo de 25 ms para un reloj de 25 MHz
  )
  port map(
    clk => clk,
    rst => rst,
    enable => '1', -- Siempre habilitado
    up_down => '0', -- Cuenta ascendente
    cuenta => open,
    f_cuenta => f_cuenta_sig_25ms
  );
  
      Health: Vida 
  generic map (
    MAX_LIFE => 5,
    DMG_BASE => 1
  )
  port map (
    clk        => clk ,            -- Señal de reloj
    rst        => rst,
    Atk_speed  =>  '1',
    f_cuenta   => f_cuenta_sig_25ms,    -- Señal de reset
    Esp_fil    => Esp_fil,
    Esp_col    => Esp_col,
    Char_fil   => col_reg,
    Char_col   => fil_reg,
    life       => open ,
    is_dead    => Char_vivo_s 
  );

  -- Instancia del Contador para generar el pulso
  C_Boss_Step : Contador
    generic map (
      N_BITS => 24,
      MAX_VALOR => 5000000 -- 500 ms a 25 MHz
    )
    port map (
      clk => clk,
      rst => rst,
      enable => '1', -- Siempre habilitado
      up_down => '0', -- Incremento
      cuenta => open, -- Salida no utilizada
      f_cuenta => boss_move_pulse -- Pulso de movimiento
    );

  -- Proceso principal para el comportamiento del Boss
  process(clk, rst)
  begin
    if rst = '1' then
      -- Reiniciar las señales
      col_reg <= to_unsigned(16, 5); -- Posición inicial columna
      fil_reg <= to_unsigned(15, 5); -- Posición inicial fila
      boss_activado <= '0';
      
    elsif rising_edge(clk) then
      -- Activar el Boss si Finn está en rango
      if cambio_map = '0' and Finn_alive='0' then
      if Char_vivo_s ='0' then 
          
          if abs(to_integer(Finn_col) - to_integer(col_reg)) <= 3 and 
             abs(to_integer(Finn_fil) - to_integer(fil_reg)) <= 3 then
            boss_activado <= '1';
          end if;
    
          -- Mover el Boss si está activado y hay pulso
          if boss_activado = '1' and boss_move_pulse = '1' then
            -- Movimiento hacia Finn
            if Finn_col > col_reg then
              col_reg <= col_reg + 1;
            elsif Finn_col < col_reg then
              col_reg <= col_reg - 1;
            end if;
    
            if Finn_fil > fil_reg then
              fil_reg <= fil_reg + 1;
            elsif Finn_fil < fil_reg then
              fil_reg <= fil_reg - 1;
            end if;
            end if;
            end if;
          end if;
        end if;
  end process;
  
        Cambio_Mapa :process(clk, rst)
    begin
      if rst = '1' then
            cambio_map_s <= '1';
            cuenta_cambio_map <=(others => '0');
      elsif rising_edge(clk) then
        if Finn_col = 0 and cuenta_cambio_map= 0 then
          cambio_map_s<= '0';
          cuenta_cambio_map <= cuenta_cambio_map + 1;
        end if;
      end if;
    end process;

  -- Asignación de salidas
  Boss_col <= col_reg;
  Boss_fil <= fil_reg;
  
  Boss_Alive <=Char_vivo_s;

end Behavioral;
