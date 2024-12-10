library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Filtro_Control is
    Port (          
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           f_cuenta : in STD_LOGIC;
           State_buttons : in STD_LOGIC_VECTOR (11 downto 0); -- Entrada de los botones del mando
           Control_out : out STD_LOGIC_VECTOR (3 downto 0) -- Salida filtrada (Select, Start, L, R)
           );
end Filtro_Control;

--BTN_Select_s <= button_snes_s(2); -- Botón Select
--BTN_Start_s  <= button_snes_s(3); -- Botón Start

architecture Behavioral of Filtro_Control is

    -- Vector combinado para Select, Start, L y R
    signal Combined_Control : STD_LOGIC_VECTOR (3 downto 0);
    signal Filtered_Control : STD_LOGIC_VECTOR (3 downto 0);

begin
    -- Concatenar los botones Select, Start, L, R en un solo vector
   
        Combined_Control <= State_buttons(3 downto 2) & State_buttons(11 downto 10);
    

    -- Proceso para filtrar los botones combinados
    process(rst, clk, f_cuenta, Combined_Control)
    begin
        if rst = '1' then
            -- Reinicio de Filtered_Control a un valor por defecto
            Filtered_Control <= (others => '1');
        elsif rising_edge(clk) then
            if f_cuenta = '1' then
                -- Filtrar los valores específicos de los botones combinados
                case Combined_Control is
                    when "1111" | "1110" | "1101" | "1011" | 
                         "0111" | "0110" | "1010" | "0101" | 
                         "1001" =>
                        Filtered_Control <= Combined_Control;
                    when others =>
                        -- Mantener el valor anterior si no se cumple la condición
                        Filtered_Control <= Filtered_Control;
                end case;
            end if;
        end if;
    end process;

    -- Asignar la salida de los botones filtrados
    Control_out <= Filtered_Control;
    
--        Combined_Control(1) -> R
--        Combined_Control(0) -> L
--        Combined_Control(3) -> Start (St)
--        Combined_Control(2) -> Select (S)

end Behavioral;
