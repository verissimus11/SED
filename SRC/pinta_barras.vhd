--------------------------------------------------------------------------------
-- Felipe Machado Sanchez
-- Departameto de Tecnologia Electronica
-- Universidad Rey Juan Carlos
-- http://gtebim.es/~fmachado
--
-- Pinta barras para la XUPV2P

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pinta_barras is
  Port (
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
end pinta_barras;

architecture behavioral of pinta_barras is

  signal int_col : unsigned (3 downto 0);
  signal int_fil : unsigned (3 downto 0);
  
  signal cuad_col : unsigned (5 downto 0);
  signal cuad_fil : unsigned (5 downto 0);
  
  signal sel_Boss_pixel : std_logic;
  signal sel_Espada_pixel : std_logic;
  signal sel_Finn_pixel : std_logic;
  signal sel_Mon_pixel : std_logic;
  signal sel_Mapa1_pixel : std_logic;
  signal not_sel_Mapa1_pixel : std_logic;
  -- Señales para Mapa 2
  signal sel_Mapa2_pixel      : std_logic; -- Selección de pixel para Mapa2
  signal not_sel_Mapa2_pixel  : std_logic; -- Selección de pixel complementario (NOT) para Mapa2
  
  -- Señales para Mapa 3
  signal sel_Mapa3_pixel      : std_logic; -- Selección de pixel para Mapa3
  signal not_sel_Mapa3_pixel  : std_logic; -- Selección de pixel complementario (NOT) para Mapa3

  
  
  signal sel_Arbol_pixel : std_logic; 
  
  --MUX RGB
  signal not_color_Mapa1 : std_logic_vector(11 downto 0);
  signal color_Mapa1 : std_logic_vector(11 downto 0);
  signal color_Finn : std_logic_vector(11 downto 0);
  signal color_Mon : std_logic_vector(11 downto 0);
  signal select_Mux : std_logic_vector(1 downto 0);
  
  signal Mon_fil_mux : std_logic;
  signal Mon_col_mux : std_logic;
  signal Finn_fil_mux : std_logic;
  signal Finn_col_mux : std_logic;
  signal Finn_Vida_s :unsigned (7 downto 0);
  
  signal pinta_Mon : std_logic;
  signal pinta_Finn : std_logic;
  
  constant c_bar_width : natural := 64;
  
 -- CAMBIO DE MAPA
 
 signal cambio_map_s: std_logic;
  
  
  -- ESPADA 
  
  signal Esp_col_s   :  unsigned(5 downto 0); -- Columna de la espada
  signal Esp_fil_s   :  unsigned(5 downto 0); -- Fila de la espada
  
  ---Cronometro 
    signal segundos_s   : unsigned (8 downto 0);
    signal dsegundos_s   : unsigned (8 downto 0);
    signal minutos_s   : unsigned (8 downto 0);
    signal colon_s   : unsigned (8 downto 0); -- Salida de la ROM para ":"
    
    signal sel_segundos_pixel    : std_logic;
    signal sel_dsegundos_pixel   : std_logic;
    signal sel_minutos_pixel     : std_logic;
    signal sel_colon_pixel       : std_logic; -- Salida de la ROM para ":"

begin
    
  Finn_Vida_s <= Finn_Health; 
  
  cuad_col <= col (9 downto 4);
  cuad_fil <= fila (9 downto 4);
  
  int_col <=  col (3 downto 0);
  int_fil <=  fila (3 downto 0);
  
  -- PERSONAJE PRINCIPAL 
  addr_Fin <= std_logic_vector(int_fil(3 downto 0));
  
  sel_Finn_pixel  <= Finn_dato(to_integer (int_col(3 downto 0)));
  
  -- Espada
  addr_Espada <= std_logic_vector(int_fil(3 downto 0));
  
  sel_Espada_pixel  <= Espada_dato(to_integer (int_col(3 downto 0)));
  
--  Esp_fil_s <= to_unsigned(6, 6) when Esp_active = '0' else ('0' & Esp_fil);
--  Esp_col_s <= to_unsigned(35, 6) when Esp_active = '0' else ('0' & Esp_col);

  
  -- PERSONAJE PRINCIPAL VILLANO
  addr_Mon <= std_logic_vector(int_fil(3 downto 0));
  
  sel_Mon_pixel  <= Mon_dato(to_integer (int_col(3 downto 0)));
  
    -- PERSONAJE PRINCIPAL BOSS
  addr_Boss <= std_logic_vector(int_fil(3 downto 0));
  
  sel_Boss_pixel  <= Boss_dato(to_integer (int_col(3 downto 0)));
  
  -- ARBOLES DEL FONDO                               
  addr_Arbol <= std_logic_vector(int_fil(3 downto 0));           
                                                               
  sel_Arbol_pixel  <= Arbol_dato(to_integer (int_col(3 downto 0)));  
  
  
  -- MAPA1   

  addr_Mapa1      <= std_logic_vector(cuad_fil(4 downto 0));
  sel_Mapa1_pixel <= Mapa1_dato(to_integer (cuad_Col(4 downto 0)));
  
   -- MAPA_NOT
  not_addr_Mapa1 <= not(std_logic_vector(cuad_fil(4 downto 0)));
  not_sel_Mapa1_pixel <= not_Mapa1_dato(to_integer (cuad_Col(4 downto 0)));
  
  -- MAPA2
  addr_Mapa2      <= std_logic_vector(cuad_fil(4 downto 0));
  sel_Mapa2_pixel <= Mapa2_dato(to_integer(cuad_col(4 downto 0)));
  
  -- MAPA_NOT 2
  not_addr_Mapa2      <= not(std_logic_vector(cuad_fil(4 downto 0)));
  not_sel_Mapa2_pixel <= not_Mapa2_dato(to_integer(cuad_col(4 downto 0)));
  
  -- MAPA3
  addr_Mapa3      <= std_logic_vector(cuad_fil(4 downto 0));
  sel_Mapa3_pixel <= Mapa3_dato(to_integer(cuad_col(4 downto 0)));
  
  -- MAPA_NOT 3
  not_addr_Mapa3      <= not(std_logic_vector(cuad_fil(4 downto 0)));
  not_sel_Mapa3_pixel <= not_Mapa3_dato(to_integer(cuad_col(4 downto 0)));
    
  
  -- MUX
  color_Mapa1 <= (others=> sel_Mapa1_pixel); --cambiar a este modo
  color_Finn <= (others=>'1') when sel_Finn_pixel = '1';
  color_Mon <= (others=>'1') when sel_Mon_pixel = '1';
  
  Mon_fil_mux <= '1' when (Mon2_fil = fila(8 downto 4))  or (Mon1_fil = fila(8 downto 4))  or (Mon_fil = fila(8 downto 4))  or  (Boss_fil = fila(8 downto 4)) else '0';
  Mon_col_mux <= '1' when (Mon2_col = col(8 downto 4))   or (Mon1_col = col(8 downto 4))   or (Mon_col = col(8 downto 4))   or  (Boss_col = col(8 downto 4))  else '0';
  
  Finn_fil_mux <= '1' when (Finn_fil = fila(8 downto 4)) else '0' ;
  Finn_col_mux <= '1' when (Finn_col = col(8 downto 4))  else '0';
  
  pinta_Mon <= '1' when Mon_fil_mux = '1' and Mon_col_mux = '1' else '0';
  pinta_Finn <= '1' when Finn_fil_mux = '1' and Finn_col_mux = '1' else '0';
  
  select_mux <= pinta_Finn & pinta_Mon;
  
 
 
     cambio_map_s <= cambio_mapa;
  

  ------CRONOMETRO--------------
  
     segundos_s <=  unsigned('0' & segundos) & (int_fil);
     dsegundos_s<=unsigned('0' & dsegundos) & (int_fil);
     minutos_s  <= unsigned('0' & minutos) & (int_fil);
     colon_s    <= "10101" & (int_fil);
        
     addr_segundos <= std_logic_vector(segundos_s(9-1 downto 0));
     addr_dsegundos<= std_logic_vector(dsegundos_s(9-1 downto 0));
     addr_minutos  <= std_logic_vector(minutos_s (9-1 downto 0));
     addr_colon    <= std_logic_vector(colon_s(9-1 downto 0));

     sel_segundos_pixel <= segundos_dato(15 - to_integer(int_col(3 downto 0)));
     sel_dsegundos_pixel <= dsegundos_dato(15 - to_integer(int_col(3 downto 0)));
     sel_minutos_pixel <= minutos_dato(15 - to_integer(int_col(3 downto 0)));
     sel_colon_pixel <= colon_dato(to_integer(int_col(3 downto 0)));

  
  
      P_pinta: Process (visible, col, fila)
      begin
        rojo   <= (others=>'0');
        verde  <= (others=>'0');
        azul   <= (others=>'0');
        -- PRUEBA 
if visible = '1' then
    
    
    if cuad_col >= 32 and cuad_col <= 39 then
        if (cuad_fil = 3 ) then
            -- Minutos: columnas 34 a 36
            if (cuad_col = 34 ) then
                if sel_minutos_pixel = '0' then
                    rojo   <= std_logic_vector(to_unsigned(239, 8)); -- Rojo brillante
                    verde  <= std_logic_vector(to_unsigned(184, 8)); -- Verde brillante
                    azul   <= std_logic_vector(to_unsigned(16, 8)); -- Azul brillante
                else
                    rojo   <= std_logic_vector(to_unsigned(0, 8)); -- Fondo negro
                    verde  <= std_logic_vector(to_unsigned(0, 8));
                    azul   <= std_logic_vector(to_unsigned(0, 8));
                end if;
                
            -- Dos puntos (:): columna 37
            elsif (cuad_col = 35) then
                if sel_colon_pixel = '0' then
                    rojo   <= std_logic_vector(to_unsigned(239, 8)); -- Rojo brillante
                    verde  <= std_logic_vector(to_unsigned(184, 8)); -- Verde brillante
                    azul   <= std_logic_vector(to_unsigned(16, 8)); -- Azul brillante
                else
                    rojo   <= std_logic_vector(to_unsigned(0, 8)); -- Fondo negro
                    verde  <= std_logic_vector(to_unsigned(0, 8));
                    azul   <= std_logic_vector(to_unsigned(0, 8));
                end if;
        
            -- Decenas de segundos: columnas 38 a 39
            elsif (cuad_col = 36 ) then
                if sel_dsegundos_pixel = '0' then
                    rojo   <= std_logic_vector(to_unsigned(239, 8)); -- Rojo brillante
                    verde  <= std_logic_vector(to_unsigned(184, 8)); -- Verde brillante
                    azul   <= std_logic_vector(to_unsigned(16, 8)); -- Azul brillante
                else
                    rojo   <= std_logic_vector(to_unsigned(0, 8)); -- Fondo negro
                    verde  <= std_logic_vector(to_unsigned(0, 8));
                    azul   <= std_logic_vector(to_unsigned(0, 8));
                end if;
                
                
        
            -- Segundos: columnas 40 a 41
            elsif (cuad_col = 37) then
                if sel_segundos_pixel = '0' then
                    rojo   <= std_logic_vector(to_unsigned(239, 8)); -- Rojo brillante
                    verde  <= std_logic_vector(to_unsigned(184, 8)); -- Verde brillante
                    azul   <= std_logic_vector(to_unsigned(16, 8)); -- Azul brillante
                else
                    rojo   <= std_logic_vector(to_unsigned(0, 8)); -- Fondo negro
                    verde  <= std_logic_vector(to_unsigned(0, 8));
                    azul   <= std_logic_vector(to_unsigned(0, 8));
                end if;
            
            else
                -- Fondo
                rojo   <= std_logic_vector(to_unsigned(0, 8));
                verde  <= std_logic_vector(to_unsigned(0, 8));
                azul   <= std_logic_vector(to_unsigned(0, 8));
            end if;
    
        elsif (cuad_fil = 5 ) then
            if (cuad_col = 34 ) then
                if (Finn_Vida_s > 0) then 
                if sel_Finn_pixel = '0' then
                    rojo   <= std_logic_vector(to_unsigned(210, 8)); -- Rojo brillante
                    verde  <= std_logic_vector(to_unsigned(40, 8)); -- Verde brillante
                    azul   <= std_logic_vector(to_unsigned(9, 8)); -- Azul brillante
                else
                    rojo   <= std_logic_vector(to_unsigned(0, 8)); -- Fondo negro
                    verde  <= std_logic_vector(to_unsigned(0, 8));
                    azul   <= std_logic_vector(to_unsigned(0, 8));
                end if;
                end if;
                
            -- Dos puntos (:): columna 37
            elsif (cuad_col = 35) then
            if (Finn_Vida_s >= 1) then 
                if sel_Finn_pixel = '0' then
                    rojo   <= std_logic_vector(to_unsigned(210, 8)); -- Rojo brillante
                    verde  <= std_logic_vector(to_unsigned(40, 8)); -- Verde brillante
                    azul   <= std_logic_vector(to_unsigned(9, 8)); -- Azul brillante
                else
                    rojo   <= std_logic_vector(to_unsigned(0, 8)); -- Fondo negro
                    verde  <= std_logic_vector(to_unsigned(0, 8));
                    azul   <= std_logic_vector(to_unsigned(0, 8));
                end if;
                end if;
            -- Decenas de segundos: columnas 38 a 39
            elsif (cuad_col = 36 ) then
                if (Finn_Vida_s >= 2) then 
                if sel_Finn_pixel = '0' then
                    rojo   <= std_logic_vector(to_unsigned(210, 8)); -- Rojo brillante
                    verde  <= std_logic_vector(to_unsigned(40, 8)); -- Verde brillante
                    azul   <= std_logic_vector(to_unsigned(9, 8)); -- Azul brillante
                else
                    rojo   <= std_logic_vector(to_unsigned(0, 8)); -- Fondo negro
                    verde  <= std_logic_vector(to_unsigned(0, 8));
                    azul   <= std_logic_vector(to_unsigned(0, 8));
                end if;
                end if;
        
            -- Segundos: columnas 40 a 41
            elsif (cuad_col = 37) then
                if (Finn_Vida_s >= 3) then 
                if sel_Finn_pixel = '0' then
                    rojo   <= std_logic_vector(to_unsigned(210, 8)); -- Rojo brillante
                    verde  <= std_logic_vector(to_unsigned(40, 8)); -- Verde brillante
                    azul   <= std_logic_vector(to_unsigned(9, 8)); -- Azul brillante
                else
                    rojo   <= std_logic_vector(to_unsigned(0, 8)); -- Fondo negro
                    verde  <= std_logic_vector(to_unsigned(0, 8));
                    azul   <= std_logic_vector(to_unsigned(0, 8));
                end if;
                end if;
            end if;
        elsif (cuad_fil = 6 ) then
            if (cuad_col = 36 ) then
            if (Finn_Vida_s >= 5) then 
                if sel_Finn_pixel = '0' then
                    rojo   <= std_logic_vector(to_unsigned(210, 8)); -- Rojo brillante
                    verde  <= std_logic_vector(to_unsigned(40, 8)); -- Verde brillante
                    azul   <= std_logic_vector(to_unsigned(9, 8)); -- Azul brillante
                else
                    rojo   <= std_logic_vector(to_unsigned(0, 8)); -- Fondo negro
                    verde  <= std_logic_vector(to_unsigned(0, 8));
                    azul   <= std_logic_vector(to_unsigned(0, 8));
                end if;
                end if;
                
            -- Dos puntos (:): columna 37
            elsif (cuad_col = 35) then
               if (Finn_Vida_s >= 4) then 
                if sel_Finn_pixel = '0' then
                    rojo   <= std_logic_vector(to_unsigned(210, 8)); -- Rojo brillante
                    verde  <= std_logic_vector(to_unsigned(40, 8)); -- Verde brillante
                    azul   <= std_logic_vector(to_unsigned(9, 8)); -- Azul brillante
                else
                    rojo   <= std_logic_vector(to_unsigned(0, 8)); -- Fondo negro
                    verde  <= std_logic_vector(to_unsigned(0, 8));
                    azul   <= std_logic_vector(to_unsigned(0, 8));
                end if;
                end if ;
           end if;
        end if;
      
----    Líneas de la cuadrícula
--    elsif int_col = "0000" or int_fil = "0000" then
--      rojo   <= (others=>'0');
--      verde  <= (others=>'0');
--      azul   <= (others=>'0');
-----------------------------------------------------------------------------------------
     elsif Esp_active = '1' and (cuad_fil = Esp_fil and cuad_col = Esp_col) then
    --Esp_active = '1' and
    -- Dibujar Espada
        if sel_Espada_pixel = '0' then
            rojo   <= (std_logic_vector(TO_UNSIGNED(41, 8))); -- Rojo brillante
            verde  <= (std_logic_vector(TO_UNSIGNED(49, 8)));   -- Verde apagado
            azul   <= (std_logic_vector(TO_UNSIGNED(51, 8)));   -- Azul apagado
        else
            rojo   <= (std_logic_vector(TO_UNSIGNED(220, 8)));
            verde  <= (std_logic_vector(TO_UNSIGNED(168, 8)));
            azul   <= (std_logic_vector(TO_UNSIGNED(92, 8)));
        
        end if;
-------------------------------------------------------------    
    elsif ( cuad_col < 32 ) then
       if select_mux= "00" then
        
        if cambio_map_s = '1' then 
             if sel_Mapa2_pixel = '0' then

                if sel_Arbol_pixel = '0' then
                    -- Color de Arbol  (Verde oscuro)
                    rojo   <= (std_logic_vector(TO_UNSIGNED(138, 8)));
                    verde  <= (std_logic_vector(TO_UNSIGNED(149, 8))); 
                    azul   <= (std_logic_vector(TO_UNSIGNED(151, 8)));
                else    
                    rojo   <= (std_logic_vector(TO_UNSIGNED(220, 8)));
                    verde  <= (std_logic_vector(TO_UNSIGNED(168, 8)));
                    azul   <= (std_logic_vector(TO_UNSIGNED(92, 8)));
                end if;
          elsif sel_Mapa1_pixel = '0' then
            -- Color de Fondo delimititado (Verde)
            rojo   <= (std_logic_vector(TO_UNSIGNED(0, 8)));
            verde  <= (std_logic_vector(TO_UNSIGNED(177, 8)));
            azul   <= (std_logic_vector(TO_UNSIGNED(64, 8)));
                if sel_Arbol_pixel = '0' then
                    -- Color de Arbol  (Verde oscuro)
                    rojo   <= (std_logic_vector(TO_UNSIGNED(0, 8)));
                    verde  <= (std_logic_vector(TO_UNSIGNED(128, 8))); 
                    azul   <= (std_logic_vector(TO_UNSIGNED(0, 8)));
                else    
                    rojo   <= (std_logic_vector(TO_UNSIGNED(0, 8)));
                    verde  <= (std_logic_vector(TO_UNSIGNED(177, 8)));
                    azul   <= (std_logic_vector(TO_UNSIGNED(64, 8)));
                end if;
          else
            -- Fondo  (Marron)
            rojo   <= (std_logic_vector(TO_UNSIGNED(220, 8)));
            verde  <= (std_logic_vector(TO_UNSIGNED(168, 8)));
            azul   <= (std_logic_vector(TO_UNSIGNED(92, 8)));
          end if;
          else 
             if not_sel_Mapa2_pixel = '0' then

                if sel_Arbol_pixel = '0' then
                    -- Color de Arbol  (Verde oscuro)
                    rojo   <= (std_logic_vector(TO_UNSIGNED(138, 8)));
                    verde  <= (std_logic_vector(TO_UNSIGNED(149, 8))); 
                    azul   <= (std_logic_vector(TO_UNSIGNED(151, 8)));
                else    
                    rojo   <= (std_logic_vector(TO_UNSIGNED(220, 8)));
                    verde  <= (std_logic_vector(TO_UNSIGNED(168, 8)));
                    azul   <= (std_logic_vector(TO_UNSIGNED(92, 8)));
                end if;
          elsif not_sel_Mapa1_pixel = '0' then
            -- Color de Fondo delimititado (Verde)
            rojo   <= (std_logic_vector(TO_UNSIGNED(0, 8)));
            verde  <= (std_logic_vector(TO_UNSIGNED(177, 8)));
            azul   <= (std_logic_vector(TO_UNSIGNED(64, 8)));
                if sel_Arbol_pixel = '0' then
                    -- Color de Arbol  (Verde oscuro)
                    rojo   <= (std_logic_vector(TO_UNSIGNED(87, 8)));
                    verde  <= (std_logic_vector(TO_UNSIGNED(35, 8))); 
                    azul   <= (std_logic_vector(TO_UNSIGNED(100, 8)));
                else    
                    rojo   <= (std_logic_vector(TO_UNSIGNED(0, 8)));
                    verde  <= (std_logic_vector(TO_UNSIGNED(68, 8)));
                    azul   <= (std_logic_vector(TO_UNSIGNED(106, 8)));
                end if;
          else
            -- Fondo  (Marron)
            rojo   <= (std_logic_vector(TO_UNSIGNED(220, 8)));
            verde  <= (std_logic_vector(TO_UNSIGNED(168, 8)));
            azul   <= (std_logic_vector(TO_UNSIGNED(92, 8)));
          end if;
        end if;
          
        elsif select_mux= "01" then 
            if cambio_map_s = '1' then 
              if Mon_Alive= '0' and (cuad_fil = Mon_fil and cuad_col = Mon_col) then
                  if sel_Mon_pixel = '0' then
                    -- Color de Monstruo (Verde)
                    rojo   <= (std_logic_vector(TO_UNSIGNED(47, 8)));
                    verde  <= (std_logic_vector(TO_UNSIGNED(69, 8)));
                    azul   <= (std_logic_vector(TO_UNSIGNED(56, 8)));
                  else
                    -- Fondo para Monstrulo (marron)
                    rojo   <= (std_logic_vector(TO_UNSIGNED(220, 8)));
                    verde  <= (std_logic_vector(TO_UNSIGNED(168, 8)));
                    azul   <= (std_logic_vector(TO_UNSIGNED(92, 8)));
                  end if;
                elsif Mon1_Alive= '0' and (cuad_fil = Mon1_fil and cuad_col = Mon1_col) then
                  if sel_Mon_pixel = '0' then
                    -- Color de Monstruo (Verde)
                    rojo   <= (std_logic_vector(TO_UNSIGNED(47, 8)));
                    verde  <= (std_logic_vector(TO_UNSIGNED(69, 8)));
                    azul   <= (std_logic_vector(TO_UNSIGNED(56, 8)));
                  else
                    -- Fondo para Monstrulo (marron)
                    rojo   <= (std_logic_vector(TO_UNSIGNED(220, 8)));
                    verde  <= (std_logic_vector(TO_UNSIGNED(168, 8)));
                    azul   <= (std_logic_vector(TO_UNSIGNED(92, 8)));
                  end if;
                  
                 elsif Mon2_Alive= '0' and (cuad_fil = Mon2_fil and cuad_col = Mon2_col) then
                  if sel_Mon_pixel = '0' then
                    -- Color de Monstruo (Verde)
                    rojo   <= (std_logic_vector(TO_UNSIGNED(47, 8)));
                    verde  <= (std_logic_vector(TO_UNSIGNED(69, 8)));
                    azul   <= (std_logic_vector(TO_UNSIGNED(56, 8)));
                  else
                    -- Fondo para Monstrulo (marron)
                    rojo   <= (std_logic_vector(TO_UNSIGNED(220, 8)));
                    verde  <= (std_logic_vector(TO_UNSIGNED(168, 8)));
                    azul   <= (std_logic_vector(TO_UNSIGNED(92, 8)));
                  end if;
                  
              else 
               -- Fondo para Monstrulo (marron)
                    rojo   <= (std_logic_vector(TO_UNSIGNED(220, 8)));
                    verde  <= (std_logic_vector(TO_UNSIGNED(168, 8)));
                    azul   <= (std_logic_vector(TO_UNSIGNED(92, 8)));
                 end if;
                 
             else
               
               if Boss_Alive='0' and (cuad_fil = Boss_fil and cuad_col = Boss_col) then
               
                  if sel_Boss_pixel = '0' then
                    -- Color de Boss (Verde)
                    rojo   <= (std_logic_vector(TO_UNSIGNED(47, 8)));
                    verde  <= (std_logic_vector(TO_UNSIGNED(69, 8)));
                    azul   <= (std_logic_vector(TO_UNSIGNED(56, 8)));
                  else
                    -- Fondo para Boss (marron)
                    rojo   <= (std_logic_vector(TO_UNSIGNED(220, 8)));
                    verde  <= (std_logic_vector(TO_UNSIGNED(168, 8)));
                    azul   <= (std_logic_vector(TO_UNSIGNED(92, 8)));
                  end if;
              else 
              
                 if sel_Arbol_pixel = '0' then
                    -- Color de Arbol  (Verde oscuro)
                    rojo   <= (std_logic_vector(TO_UNSIGNED(45, 8)));
                    verde  <= (std_logic_vector(TO_UNSIGNED(87, 8)));
                    azul   <= (std_logic_vector(TO_UNSIGNED(44, 8)));
                else    
                    rojo   <= (std_logic_vector(TO_UNSIGNED(138, 8)));
                    verde  <= (std_logic_vector(TO_UNSIGNED(149, 8))); 
                    azul   <= (std_logic_vector(TO_UNSIGNED(151, 8)));
                end if;

                 end if;
                 
             end if;
             
            elsif select_mux = "10" then
                if(cuad_fil = Finn_fil and cuad_col = Finn_col) then
                    if Finn_Alive= '0'  then
                        if sel_Finn_pixel = '0' then
                            -- Color de Finn (Azul)
                            rojo   <= (std_logic_vector(TO_UNSIGNED(0, 8)));
                            verde  <= (std_logic_vector(TO_UNSIGNED(170, 8)));
                            azul   <= (std_logic_vector(TO_UNSIGNED(228, 8)));
                        else
                            -- Fondo para Fin (Marron)
                            rojo   <= (std_logic_vector(TO_UNSIGNED(220, 8)));
                            verde  <= (std_logic_vector(TO_UNSIGNED(168, 8)));
                            azul   <= (std_logic_vector(TO_UNSIGNED(92, 8)));
                        end if;
                        
                     else
                     
                             if sel_Arbol_pixel = '0' then
                                    -- Color de Arbol  (Verde oscuro)
                                rojo   <= std_logic_vector(to_unsigned(210, 8)); -- Rojo brillante
                                verde  <= std_logic_vector(to_unsigned(40, 8)); -- Verde brillante
                                azul   <= std_logic_vector(to_unsigned(9, 8)); -- Azul brillante
                        else    
                                              -- Fondo para Fin (Marron)
                            rojo   <= (std_logic_vector(TO_UNSIGNED(220, 8)));
                            verde  <= (std_logic_vector(TO_UNSIGNED(168, 8)));
                            azul   <= (std_logic_vector(TO_UNSIGNED(92, 8)));
                        end if;
     
                     end if;
                     
                  else 
                                         -- Fondo para Fin (Marron)
                        rojo   <= (std_logic_vector(TO_UNSIGNED(220, 8)));
                        verde  <= (std_logic_vector(TO_UNSIGNED(168, 8)));
                        azul   <= (std_logic_vector(TO_UNSIGNED(92, 8)));
                end if;
            end if;
           end if; 
                       
    end if;

end process;
  
  
end Behavioral;

