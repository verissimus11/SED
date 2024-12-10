library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Vida is
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
end Vida;

architecture Behavioral of Vida is
 
  signal life_reg : unsigned(7 downto 0) := to_unsigned(MAX_LIFE, 8); -- Registro de vida
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
  
  
  signal Esp_fil_s : unsigned(4 downto 0);
  signal Esp_col_s : unsigned(4 downto 0);
  signal Char_fil_s : unsigned(4 downto 0);
  signal Char_col_s : unsigned(4 downto 0);

  
  
begin
  
    
    
    
  process(clk, rst)
  begin
    if rst = '1' then
      life_reg <= to_unsigned(MAX_LIFE, 8); -- Reinicia la vida al máximo
    elsif rising_edge(clk) then
       if Atk_speed = '1' and  f_cuenta= '1' then
        
      -- Detectar colisión entre la espada y el personaje
      if Esp_fil_s = Char_fil_s and Esp_col_s = Char_fil_s then
        -- Reducir la vida según el daño base, asegurándose de que no sea menor a 0
        if life_reg > to_unsigned(DMG_BASE, 8) then
          life_reg <= life_reg - to_unsigned(DMG_BASE, 8);
        else
          life_reg <= to_unsigned(0, 8); -- Vida no puede ser negativa
        end if;
        end if;
      end if;
    end if;
  end process;

Esp_fil_s  <=Esp_fil;
Esp_col_s  <=Esp_col;
Char_fil_s <=Char_fil;
Char_col_s <=Char_fil_s;    
    

  -- Asignación de salidas
  life <= life_reg;                      -- Vida actual
  is_dead <= '1' when signed(life_reg) <= 0 else '0'; -- Indicador de muerte

end Behavioral;
