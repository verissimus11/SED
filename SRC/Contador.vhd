----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 10/14/2024 05:12:09 PM
-- Design Name: 
-- Module Name: Contador - Behavioral
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
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Contador is
    generic(
        N_BITS     : integer := 27;
        MAX_VALOR  : integer := 100 --125_000_000
    );
    port(
        clk       : in  std_logic;
        rst       : in  std_logic;
        enable    : in  std_logic;
        up_down : in std_logic;
        cuenta    : out std_logic_vector(N_BITS-1 downto 0);
        f_cuenta  : out std_logic
        
        
    );
end Contador;

architecture Behavioral of Contador is
    signal counter_reg : unsigned(N_BITS-1 downto 0) := (others => '0');
begin
    process(clk, rst)
    begin
        if rst = '1' then
            if up_down ='0' then -- En 0 la cuenta es ascendente
                counter_reg <= (others => '0');   -- Reiniciar el contador
            else
                 counter_reg <= TO_UNSIGNED(MAX_VALOR-1,N_BITS);
            end if;  
        elsif rising_edge(clk) then
            if enable = '1' then 
                if up_down ='0' then -- En 0 la cuenta es ascendente
                    if counter_reg = (MAX_VALOR-1) then
                        counter_reg <= (others => '0');  -- Reiniciar al alcanzar el valor máximo
                    else
                        counter_reg <= counter_reg + 1;  -- Incrementar el contador
                    end if;
                 else -- En 1 la cuenta es descendente
                    if counter_reg = 0 then 
                        counter_reg <= TO_UNSIGNED(MAX_VALOR-1,N_BITS);
                    else
                        counter_reg <= counter_reg - 1; 
                    end if;
                end if;
           end if;
        end if;
    end process;

    cuenta <= std_logic_vector(counter_reg);  -- Asignar el valor del contador a la salida
    f_cuenta <= '1' when ((up_down = '0' and counter_reg = (MAX_VALOR - 1)) or 
                          (up_down = '1' and counter_reg = 0)) else '0';  -- Activa solo en los límites alcanzados

  
end Behavioral;



