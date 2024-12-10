
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity CounterClks is
    Port ( 
          clk : in STD_LOGIC;
          rst : in STD_LOGIC;
          fcounter6us: in STD_LOGIC; -- fin de cuenta 6us
          fcounter12us: in STD_LOGIC;-- fin de cuenta 12us
          enCnt : in STD_LOGIC; -- entrada de FSM indicar contando pulsos en estado 2 o 3
         
          finCnt : out STD_LOGIC -- fin de la cuenta de pulsos llego al max
          );
end CounterClks;

architecture Behavioral of CounterClks is

    constant ON_state : std_logic :='1'; 
    constant OFF_state : std_logic :='0';
    constant YES : std_logic :='1';      
    constant NO : std_logic :='0';       

    signal num_clks : unsigned (3 downto 0); --4 bits cuenta hasta 16 pulsos
    signal fclks : STD_LOGIC;
begin

    process (fcounter6us)
    begin   
    if rising_edge(fcounter6us) then
        
            if num_clks = 14 then
                fclks <=ON_state; -- ha contado 16 pulsos activamos fclks
            else
                fclks <=OFF_state;
            end if;
        else
            null;
        end if;  
     
    end process;

    Counter_clocks : process (clk,rst)
    begin
      if rst=ON_state then 
        num_clks <= (others => '0');
      elsif rising_edge(clk) then
        if (fclks = YES and fcounter12us = YES) then
            num_clks <= (others => '0'); -- ha contado 14 pulsos y ha contado 12us resetea la cuenta
        else
            if (enCnt = ON_state and fcounter12us = YES) then
            num_clks <= num_clks +1; -- cuenta habilitada y han pasado 12us suma 1 pulso a la cuenta
            else
             null;
            end if;
        end if;
      end if;
           
    end process;
    
    finCnt <= YES when fclks= YES and fcounter12us = YES else NO;
    -- cuando haya contado 14 pulsos y 12 us enviara un fin de cuenta para pasar estado4
    
end Behavioral;
