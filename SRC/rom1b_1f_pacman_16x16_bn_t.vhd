------- ROM creada automaticamente por ppm2rom -----------
------- Felipe Machado -----------------------------------
------- Departamento de Tecnologia Electronica -----------
------- Universidad Rey Juan Carlos ----------------------
------- http://gtebim.es ---------------------------------
----------------------------------------------------------
--------Datos de la imagen -------------------------------
--- Fichero original    : pacman_16x16_bn.pbm 
--- Filas    : 16 
--- Columnas : 16 
--- Color    :  Blanco y negro. 2 niveles (1 bit)



------ Puertos -------------------------------------------
-- Entradas ----------------------------------------------
--    clk  :  senal de reloj
--    addr :  direccion de la memoria
-- Salidas  ----------------------------------------------
--    dout :  dato de 16 bits de la direccion addr (un ciclo despues)


library IEEE;
  use IEEE.STD_LOGIC_1164.ALL;
  use IEEE.NUMERIC_STD.ALL;


entity ROM1b_1f_pacman_16x16_bn is
  port (
    clk  : in  std_logic;   -- reloj
    addr : in  std_logic_vector(4-1 downto 0);
    dout : out std_logic_vector(16-1 downto 0) 
  );
end ROM1b_1f_pacman_16x16_bn;


architecture BEHAVIORAL of ROM1b_1f_pacman_16x16_bn is
 signal addr_int  : natural range 0 to 2**4-1;
  type memostruct is array (natural range<>) of std_logic_vector(16-1 downto 0);
  constant filaimg : memostruct := (
       "1100111111110011",
       "1100000000000011",
       "1100000000000011",
       "1100110001100011",
       "1100110001100011",
       "1100000000000011",
       "1100001111000011",
       "1100000000000011",
       "1110000000000111",
       "1000000000000001",
       "1010000000000101",
       "1010000000000101",
       "1111000000001111",
       "1100000100000011",
       "1100001110000011",
       "1100011111100011"
        );

begin

  addr_int <= TO_INTEGER(unsigned(addr));

  P_ROM: process (clk)
  begin
    if clk'event and clk='1' then
      dout <= filaimg(addr_int);
    end if;
  end process;

end BEHAVIORAL;

