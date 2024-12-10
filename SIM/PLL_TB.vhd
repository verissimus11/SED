----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/13/2024 03:09:12 PM
-- Design Name: 
-- Module Name: PLL_TB - Behavioral
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

entity PLL_TB is
--  Port ( );
end PLL_TB;

architecture Behavioral of PLL_TB is

component PLL is
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
end component;

                                        
    signal clk_s : std_logic := '0';    
    signal rst_s : std_logic := '0';         
    constant clock_period: time := 8ns;
    signal clk0_o_s : std_logic := '0';    
    signal clk1_o_s : std_logic := '0';   
    
    
begin
        
                     PLL_F: PLL
        port map(
            clk_i => clk_s,
            rst => rst_s,
            clk0_o => clk0_o_s,
            clk1_o => clk1_o_s
             );

         P_clk: process
        begin
            clk_s <= '0';
            wait for clock_period/2;
            clk_s <= '1';
            wait for clock_period/2;
        end process;

              P_init: process
        begin 
            rst_s <= '1';
            wait for 50ns;
            rst_s <= '0';
            wait;
         end process;  


end Behavioral;
