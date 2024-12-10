------- ROM creada automaticamente por ppm2rom -----------
------- Felipe Machado -----------------------------------
------- Departamento de Tecnologia Electronica -----------
------- Universidad Rey Juan Carlos ----------------------
------- http://gtebim.es ---------------------------------
----------------------------------------------------------
--------Datos de la imagen -------------------------------
--- Fichero original    : racetrack_1_bn.pbm 
--- Filas    : 30 
--- Columnas : 32 
--- Color    :  Blanco y negro. 2 niveles (1 bit)



------ Puertos -------------------------------------------
-- Entradas ----------------------------------------------
--    clk  :  senal de reloj
--    addr :  direccion de la memoria
-- Salidas  ----------------------------------------------
--    dout :  dato de 32 bits de la direccion addr (un ciclo despues)


library IEEE;
  use IEEE.STD_LOGIC_1164.ALL;
  use IEEE.NUMERIC_STD.ALL;


entity ROM_Mapa1 is
  port (
    clk  : in  std_logic;   -- reloj
    addr : in  std_logic_vector(5-1 downto 0);
    dout : out std_logic_vector(32-1 downto 0); 
    not_addr : in  std_logic_vector(5-1 downto 0);
    not_dout : out std_logic_vector(32-1 downto 0) 
  );
end ROM_Mapa1;


architecture BEHAVIORAL of ROM_Mapa1 is
  signal addr_int  : natural range 0 to 2**5-1;
  signal not_addr_int  : natural range 0 to 2**5-1;
  type memostruct is array (natural range<>) of std_logic_vector(32-1 downto 0);
  constant filaimg : memostruct := (
        "00000000000000000001111100000000",
        "00000000000000000001111100000000",
        "00000000000000000001111100000000",
        "00011111111111111111111111111000",
        "00011111111111111111111111111000",
        "00011111111111111111111111110000",
        "00011111111111111111111111100000",
        "00011111111111111111111110000000",
        "00011111111111111111111111100000",
        "00011111111111111111111111110000",
        "00011111111111111111111111111000",
        "00011111111111111111111111111000",
        "00011111111111111111111111111000",
        "00011111111111111111111111111111",
        "00011111111111111111111111111111",
        "00011111111111111111111111111111",
        "00011111111111111111111111111111",
        "00011111111111111111111111111111",
        "00011111111111111111111111111000",
        "00001111111111111111111111111000",
        "00000011111111111111111111111000",
        "00000001111111111111111111111000",
        "00000011111111111111111111111000",
        "00000011111111111111111111111000",
        "00001111111111111111111111111000",
        "00011111111111111111111111111000",
        "00011111111111111111111111111000",
        "00000000000000000000000000000000",
        "00000000000000000000000000000000",
        "00000000000000000000000000000000" 
        );

begin

  addr_int <= TO_INTEGER(unsigned(addr));

  P_ROM: process (clk)
  begin
    if clk'event and clk='1' then
      dout <= filaimg(addr_int);
    end if;
  end process;
  
  not_addr_int <= TO_INTEGER(unsigned(not_addr));

  P_ROM_NOT: process (clk)
  begin
    if clk'event and clk='1' then
      not_dout <= filaimg(not_addr_int);
    end if;
  end process;

end BEHAVIORAL;
