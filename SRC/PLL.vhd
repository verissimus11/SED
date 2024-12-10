----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/11/2024 12:24:08 PM
-- Design Name: 
-- Module Name: PLL - Behavioral
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
-- arithmetic functions with Signed or Unsigned valuesuse IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
Library UNISIM;
use UNISIM.VComponents.all;


entity PLL is
    generic (
        CLKIN_PERIOD : real := 8.000; -- Periodo del reloj de entrada (8 ns para 125 MHz)
        CLK_MULTIPLY : integer := 8;  -- Multiplicador
        CLK_DIVIDE   : integer := 1;  -- Divisor
        CLKOUT0_DIV  : integer := 8;  -- Divisor de reloj de salida serial
        CLKOUT1_DIV  : integer := 40  -- Divisor de reloj de salida de píxeles (para 25 MHz)
    );
    port (
        clk_i   : in  std_logic;        -- Reloj de entrada
        rst     : in  std_logic;        -- Señal de reinicio
        clk0_o  : out std_logic;        -- Reloj de salida serial (125 MHz)
        clk1_o  : out std_logic         -- Reloj de salida de píxeles (25 MHz)
    );
end PLL;

architecture Behavioral of PLL is
    -- Señales internas para la generación y retroalimentación de los relojes
    signal pllclk0 : std_logic;  -- Señal interna para el reloj serial
    signal pllclk1 : std_logic;  -- Señal interna para el reloj de píxeles
    signal clkfbin : std_logic;  -- Señal de entrada de retroalimentación de la PLL
    signal clkfbout: std_logic;  -- Señal de entrada de retroalimentación de la PLL
begin
    -- Asignación de la señal de retroalimentación
    clkfbin <= clkfbout;

    -- Instancia del PLL para la generación de los relojes
        clock:PLLE2_BASE
        generic map (
            clkin1_period => CLKIN_PERIOD,
            clkfbout_mult => CLK_MULTIPLY, -- Multiplicador de la frecuencia
            clkout0_divide => CLKOUT0_DIV,
            clkout1_divide => CLKOUT1_DIV,
            divclk_divide  => CLK_DIVIDE
        )
        port map (
            rst    => '0',         -- Señal de reinicio
            pwrdwn => '0',     -- Señal de apagado
            clkin1  => clk_i,      -- Reloj de entrada
            clkfbin => clkfbout,    -- Retroalimentación del reloj conectada internamente
            clkfbout => clkfbout,    -- Salida de la retroalimentación
            clkout0 => pllclk0,    -- Salida del reloj serial (125 MHz)
            clkout1 => pllclk1     -- Salida del reloj de píxeles (25 MHz)
        );

    -- Buffer para las salidas de reloj
    clk0buf: BUFG port map (I => pllclk0, O => clk0_o);
    clk1buf: BUFG port map (I => pllclk1, O => clk1_o);

end Behavioral;

    