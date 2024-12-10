library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Multiplex_DMG is
  Port (
    Finn_Col     : in  unsigned(4 downto 0);        -- Columna de Finn
    Finn_Fil     : in  unsigned(4 downto 0);        -- Fila de Finn
    Mon_Col      : in  unsigned(4 downto 0);        -- Columna del primer Monstruo
    Mon_Fil      : in  unsigned(4 downto 0);        -- Fila del primer Monstruo
    Boss_Col     : in  unsigned(4 downto 0);        -- Columna del Boss
    Boss_Fil     : in  unsigned(4 downto 0);        -- Fila del Boss
    Mon1_Col     : in  unsigned(4 downto 0);        -- Columna del segundo Monstruo
    Mon1_Fil     : in  unsigned(4 downto 0);
    Mon2_Col     : in  unsigned(4 downto 0);        -- Columna del segundo Monstruo
    Mon2_Fil     : in  unsigned(4 downto 0);         -- Fila del segundo Monstruo
    Cambio_Mapa  : in  std_logic;                  -- Señal de cambio de mapa
    Dmg_Col_Out  : out unsigned(4 downto 0);       -- Columna seleccionada
    Dmg_Fil_Out  : out unsigned(4 downto 0)        -- Fila seleccionada
  );
end Multiplex_DMG;

architecture Behavioral of Multiplex_DMG is
  -- Señal interna para el select
  signal Select_Dmg : std_logic_vector(1 downto 0);
begin

  -- Generación del Select_Dmg basado en Cambio_Mapa y la proximidad a Finn
  process(Cambio_Mapa, Finn_Col, Finn_Fil, Mon_Col, Mon_Fil,Mon1_Col, Mon1_Fil,Mon2_Col, Mon2_Fil, Boss_Col, Boss_Fil)
    variable Dist_Mon  : integer;
    variable Dist_Mon1 : integer;
    variable Dist_Mon2 : integer;
  begin
    if Cambio_Mapa = '0' then
      -- Siempre seleccionar al Boss si Cambio_Mapa = '1'
      Select_Dmg <= "01";
    else
      -- Calcular distancias de Finn a los monstruos
        Dist_Mon  := abs(to_integer(Finn_Col) - to_integer(Mon_Col)) + abs(to_integer(Finn_Fil) - to_integer(Mon_Fil));
        Dist_Mon1 := abs(to_integer(Finn_Col) - to_integer(Mon1_Col)) + abs(to_integer(Finn_Fil) - to_integer(Mon1_Fil));
        Dist_Mon2 := abs(to_integer(Finn_Col) - to_integer(Mon2_Col)) + abs(to_integer(Finn_Fil) - to_integer(Mon2_Fil));

        -- Comparaciones para seleccionar al monstruo más cercano
        if Dist_Mon <= Dist_Mon1 and Dist_Mon <= Dist_Mon2 then
            Select_Dmg <= "00"; -- Selección del primer Monstruo
        elsif Dist_Mon1 < Dist_Mon and Dist_Mon1 <= Dist_Mon2 then
            Select_Dmg <= "11"; -- Selección del segundo Monstruo
        else
            Select_Dmg <= "10"; -- Selección del tercer Monstruo
        end if;
        
    end if;
  end process;

  -- Multiplexor para seleccionar las coordenadas
  process(Select_Dmg, Mon_Col, Mon_Fil, Boss_Col, Boss_Fil)
  begin
    case Select_Dmg is
      when "00" =>
        -- Selección del primer Monstruo
        Dmg_Col_Out <= Mon_Col;
        Dmg_Fil_Out <= Mon_Fil;
      when "01" =>
        -- Selección del Boss
        Dmg_Col_Out <= Boss_Col;
        Dmg_Fil_Out <= Boss_Fil;
      when "11" =>
        -- Selección del segundo Monstruo
        Dmg_Col_Out <= Mon1_Col;
        Dmg_Fil_Out <= Mon1_Fil;
      when "10" =>
        -- Selección del segundo Monstruo
        Dmg_Col_Out <= Mon2_Col;
        Dmg_Fil_Out <= Mon2_Fil;
      when others =>
        -- Valores por defecto (si el Select_Dmg no es válido)
        Dmg_Col_Out <= (others => '0');
        Dmg_Fil_Out <= (others => '0');
    end case;
  end process;

end Behavioral;
