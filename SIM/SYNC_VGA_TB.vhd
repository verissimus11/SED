----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/11/2024 11:26:35 AM
-- Design Name: 
-- Module Name: Sync_VGA - Behavioral
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

entity SYNC_VGA_TB is
--  Port ( );
end SYNC_VGA_TB;

architecture Behavioral of SYNC_VGA_TB is
    component SYNC_VGA is
    port(
        clk          : in  std_logic;                -- Pixel clock (typically 25 MHz for 640x480)
        rst          : in  std_logic;                -- rst signal
        hsync        : out std_logic;                -- Horizontal sync signal
        vsync        : out std_logic;                -- Vertical sync signal
        
               -- Line visible signal
        visible      : out std_logic                 -- Visible area (AND of pxl_visible and line_visible)
    );
    end component;

    signal clk_s : std_logic := '0';
    signal rst_s : std_logic := '0';
    signal hsync_s : std_logic;
    signal vsync_s : std_logic;
    signal visible_s : std_logic;
    constant clock_period: time := 40ns;
begin
        
             SYNC: SYNC_VGA
        port map(
            clk => clk_s,
            rst => rst_s,
            hsync => hsync_S,
            vsync => vsync_s,
            visible => visible_s
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
