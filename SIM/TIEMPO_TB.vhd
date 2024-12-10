library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity TIEMPO_contador_tb is
-- No se declaran puertos en el testbench
end TIEMPO_contador_tb;

architecture Behavioral of TIEMPO_contador_tb is
    -- Declaración de señales para el testbench
    signal clk        : std_logic := '0'; -- Señal de reloj
    signal rst        : std_logic := '1'; -- Señal de reset inicial en alto
    signal enable     : std_logic := '0'; -- Señal de habilitación
    signal segundos   : std_logic_vector(3 downto 0);
    signal dsegundos  : std_logic_vector(2 downto 0);
    signal minutos    : std_logic_vector(3 downto 0);

    -- Constante para el periodo del reloj (25 MHz = 40 ns)
    constant clk_period : time := 40 ns;
component TIEMPO_contador is
    port (
        clk        : in std_logic;       -- Señal de reloj de 25 MHz
        rst        : in std_logic;       -- Señal de reset
        enable     : in std_logic;       -- Habilitar el conteo
        segundos   : out std_logic_vector(3 downto 0); -- Segundos (0 a 9)
        dsegundos  : out std_logic_vector(2 downto 0); -- Decenas de segundos (0 a 5)
        minutos    : out std_logic_vector(3 downto 0)  -- Minutos (0 a 9)
    );
end component;
begin

    -- Instancia del DUT (Device Under Test)
    DUT: TIEMPO_contador
        port map (
            clk        => clk,
            rst        => rst,
            enable     => enable,
            segundos   => segundos,
            dsegundos  => dsegundos,
            minutos    => minutos
        );

    -- Generador de reloj
    clk_process: process
    begin
        while true loop
            clk <= '0';
            wait for clk_period / 2;
            clk <= '1';
            wait for clk_period / 2;
        end loop;
    end process;

    -- Proceso de estímulos
    stim_proc: process
    begin
        -- Inicialización
        rst <= '1';
        enable <= '0';
        wait for 100 ns;

        -- Liberar reset
        rst <= '0';
        wait for 100 ns;

        -- Activar habilitación
        enable <= '1';
        wait for 500000 ns; -- Simular durante 1 segundo




        -- Finalización de la simulación
        wait;
    end process;

end Behavioral;
