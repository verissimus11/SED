library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Filtro_Action is
    Port (          
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           f_cuenta : in STD_LOGIC;
           State_buttons : in STD_LOGIC_VECTOR (11 downto 0); -- Entrada de botones: B, Y, A, X
           Action_out : out STD_LOGIC_VECTOR (3 downto 0) -- Salida combinada filtrada
           );
end Filtro_Action;

---- Assignación de botones específicos
--Action_B <= State_buttons(0); -- Botón B
--Action_Y <= State_buttons(1); -- Botón Y
--Action_A <= State_buttons(8); -- Botón A
--Action_X <= State_buttons(9); -- Botón X


architecture Behavioral of Filtro_Action is

    signal Combined_Buttons : STD_LOGIC_VECTOR (3 downto 0); -- Botones combinados (BY y AX)
    signal Filtered_Buttons : STD_LOGIC_VECTOR (3 downto 0); -- Botones filtrados
begin
    -- Concatenar los botones B, Y, A, X en un solo vector
    Combined_Buttons <= State_buttons(1 downto 0) & State_buttons(9 downto 8);

    -- Proceso para filtrar los botones combinados
    process(rst, clk, f_cuenta, Combined_Buttons)
    begin
        if rst = '1' then
            -- Reinicio de Filtered_Buttons a un valor por defecto
            Filtered_Buttons <= (others => '1');
        elsif rising_edge(clk) then
            if f_cuenta = '1' then
                -- Filtrar los valores específicos de los botones combinados
                case Combined_Buttons is
                    when "1111" | "1110" | "1101" | "1011" | 
                         "0111" | "0110" | "1010" | "0101" | 
                         "1001" =>
                        Filtered_Buttons <= Combined_Buttons;
                    when others =>
                        -- Mantener el valor anterior si no se cumple la condición
                        Filtered_Buttons <= Filtered_Buttons;
                end case;
            end if;
        end if;
    end process;

    -- Asignar la salida de los botones filtrados
    Action_out <= Filtered_Buttons;
        --Action_out(3) -> Botón X
        --Action_out(2) -> Botón A
        --Action_out(1) -> Botón Y
        --Action_out(0) -> Botón B


end Behavioral;
