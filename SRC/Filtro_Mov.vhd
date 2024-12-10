----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/04/2024 08:38:30 PM
-- Design Name: 
-- Module Name: Filtro_Mov - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Filtro_Mov is
    Port (          
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           f_cuenta : in STD_LOGIC;
           State_buttons : in STD_LOGIC_VECTOR (11 downto 0); -- entrada boton pulsado
           pulso_btn : out STD_LOGIC_VECTOR (3 downto 0)
           );
end Filtro_Mov;
 
--        move_up_s    <= State_buttons(4); -- Flecha UP
--        move_down_s  <= State_buttons(5); -- Flecha DOWN
--        move_left_s  <= State_buttons(6); -- Flecha LEFT
--        move_right_s <= State_buttons(7); -- Flecha RIGHT

architecture Behavioral of Filtro_Mov is



    signal State_buttons_aux : STD_LOGIC_VECTOR (3 downto 0);

    
begin
        process(rst, clk, f_cuenta,State_buttons)
            begin
                if rst = '1' then
                    -- Reinicio de State_buttons_aux a un valor por defecto
                    State_buttons_aux <= (others => '1');
                elsif rising_edge(clk) then
                    -- Si se cumple la condición de sal100ms_internal
                    if f_cuenta = '1' then
                        -- Verificar los valores específicos de State_buttons
                        case State_buttons(7 downto 4) is
                            when "1111" | "1110" | "1101" | "1011" | "0111" |
                                 "0110" | "1010" | "0101" | "1001" =>
                                -- Cargar el valor de State_buttons en State_buttons_aux
                                State_buttons_aux <= State_buttons(7 downto 4);
                            when others =>
                                -- Mantener el valor anterior si no se cumple la condición
                                State_buttons_aux <= State_buttons_aux;
                        end case;
                    end if;
                end if;
            end process;

  pulso_btn<=State_buttons_aux;
  
end Behavioral;
