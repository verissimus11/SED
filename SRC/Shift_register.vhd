

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Shift_register is
    Port ( 
           rst: in STD_LOGIC;
           clkReg : in STD_LOGIC;
           data_snes : in STD_LOGIC;
           pre_finish : in STD_LOGIC; -- pre_finish tiempo para cargar los datos de la snes
           -- antes de que se vuelvan a actualizar
           buttons_snes : out STD_LOGIC_VECTOR (11 downto 0) -- salida info boton pulsado
          );
end Shift_register;

architecture Behavioral of Shift_register is
   
   signal buttons_temp : STD_LOGIC_VECTOR(14 downto 0) := (others => '0');
   
   
begin

    

    process(pre_finish,rst) 
    begin
        if rst='1' then
       -- buttons_snes<=(others => '0');
       buttons_snes<=(others => '1'); --lógica inversa
        elsif rising_edge (pre_finish) then
            buttons_snes <= buttons_temp(11 downto 0);      
        end if;       
    end process;

    process (clkReg) -- obtener los datos de la SNES
    begin
      if falling_edge (clkReg) then
        buttons_temp(14 downto 0) <= data_snes & buttons_temp(14 downto 1);     
      end if;
    end process;
    
end Behavioral;
