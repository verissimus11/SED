----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 12/04/2024 09:17:51 PM
-- Design Name: 
-- Module Name: FILTRO_MOV_TB - Behavioral
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

entity FILTRO_MOV_TB is
--  Port ( );
end FILTRO_MOV_TB;

architecture Behavioral of FILTRO_MOV_TB is

    component Filtro_Mov is
    Port (          
           clk : in STD_LOGIC;
           rst : in STD_LOGIC;
           f_cuenta : in STD_LOGIC;
           State_buttons : in STD_LOGIC_VECTOR (11 downto 0); -- entrada boton pulsado
           pulso_btn : out STD_LOGIC_VECTOR (3 downto 0)
           );
           
    end component;
 -- Señales para conectar al DUT (Device Under Test)
    
   signal clk_s : STD_LOGIC := '0'; -- Señal de reloj
    signal rst_s : STD_LOGIC := '0'; -- Señal de reset
    signal f_cuenta_s : STD_LOGIC := '0'; -- Pulso de cuenta
    signal State_buttons_s : STD_LOGIC_VECTOR(11 downto 0) := (others => '0'); -- Botones presionados
    signal pulso_btn_s : STD_LOGIC_VECTOR(3 downto 0); -- Salida filtrada

    -- Periodo del reloj
    constant clk_period : time := 40 ns;

begin

    -- Instancia del módulo Filtro_Mov
    uut: Filtro_Mov
        port map (
            clk => clk_s,
            rst => rst_s,
            f_cuenta => f_cuenta_s,
            State_buttons => State_buttons_s,
            pulso_btn => pulso_btn_s
        );

    -- Generador de reloj
    clk_process: process
    begin
        while True loop
            clk_s <= '0';
            wait for clk_period / 2;
            clk_s <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Proceso de estimulación
    stimulus: process
    begin
        -- Reseteo del sistema
        rst_s <= '1';
        wait for clk_period;
        rst_s <= '0';
        wait for clk_period;

        -- Escenario 1: Botón válido en los bits 7 downto 4
        f_cuenta_s <= '1';
        State_buttons_s <= "000010111111"; -- Bits 7 downto 4 = "1011" (válido)
        wait for clk_period;

        f_cuenta_s <= '0'; -- Desactiva el pulso
        wait for clk_period * 3;

        -- Escenario 2: Botón no válido
        f_cuenta_s <= '1';
        State_buttons_s <= "000011000000"; -- Bits 7 downto 4 = "1100" (no válido)
        wait for clk_period;

        f_cuenta_s <= '0';
        wait for clk_period * 3;

        -- Escenario 3: Otro botón válido
        f_cuenta_s <= '1';
        State_buttons_s <= "000001011111"; -- Bits 7 downto 4 = "1011" (válido)
        wait for clk_period;

        f_cuenta_s <= '0';
        wait for clk_period * 3;

        -- Escenario 4: Reseteo en medio de una operación
        rst_s <= '1';
        wait for clk_period;
        rst_s <= '0';
        wait for clk_period * 5;

        -- Escenario 5: Combinación mixta
        f_cuenta_s <= '1';
        State_buttons_s <= "111100101111"; -- Bits 7 downto 4 = "1011" (válido)
        wait for clk_period;

        f_cuenta_s <= '0';
        wait for clk_period * 3;

        -- Finalización de la simulación
        wait;
    end process;

end Behavioral;
