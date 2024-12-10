----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 11/04/2024 
-- Design Name: VGA Sync Controller
-- Module Name: Sync_VGA - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: VGA Sync Controller with Contador component for horizontal and vertical sync
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
use IEEE.NUMERIC_STD.ALL;

entity SYNC_VGA is
    port(
        clk          : in  std_logic;                -- Pixel clock (typically 25 MHz for 640x480)
        rst          : in  std_logic;                -- rst signal
        hsync        : out std_logic;                -- Horizontal sync signal
        vsync        : out std_logic;                -- Vertical sync signal
        columnas     : out unsigned(9 downto 0);     -- Horizontal counter (unsigned output)
        filas        : out unsigned(9 downto 0);      -- Vertical counter (unsigned output)
               -- Line visible signal
        visible      : out std_logic                 -- Visible area (AND of pxl_visible and line_visible)
    );
end SYNC_VGA;

architecture Behavioral of Sync_VGA is

    component Contador is
    generic(
        N_BITS     : integer := 27;
        MAX_VALOR  : integer := 100 --125_000_000
    );
    port(
        clk       : in  std_logic;
        rst       : in  std_logic;
        enable    : in  std_logic;
        up_down   : in std_logic;
        cuenta    : out std_logic_vector(N_BITS-1 downto 0);
        f_cuenta  : out std_logic
            
    );
    end component;

    
    -- Timing parameters for 640x480 VGA resolution
    ------ Horizontal line
    constant H_VISIBLE     : integer := 640;    -- Number of visible columns (pixels)
    constant H_FRONT_PORCH : integer := 16;     -- Horizontal front porch
    constant H_SYNC_PULSE  : integer := 96;     -- Horizontal sync pulse width
    constant H_BACK_PORCH  : integer := 48;     -- Horizontal back porch
    constant H_MAX : integer := 800;
    
    
    ------  Vertical line
    constant V_VISIBLE     : integer := 480;    -- Number of visible rows (pixels)
    constant V_FRONT_PORCH : integer := 10;     -- Vertical front porch
    constant V_SYNC_PULSE  : integer := 2;      -- Vertical sync pulse width
    constant V_BACK_PORCH  : integer := 33;     -- Vertical back porch
    constant V_MAX : integer := 525;

    -- Signals for end-of-count flags and counters
    signal h_end          : std_logic;
    signal v_end          : std_logic;
    signal h_count        : std_logic_vector(9 downto 0);  -- 10-bit counter for horizontal timing
    signal v_count        : std_logic_vector(9 downto 0);  -- 10-bit counter for vertical timing

    -- Signals to enable vertical counting on horizontal counter completion
    
    signal h_enable       : std_logic;
    signal v_enable       : std_logic;
    
    -------- 
    
    signal pxl_visible  : std_logic; -- Internal signal for pixel visibility
    signal line_visible : std_logic; -- Internal signal for line visibility
    
    
    
begin

    -- Horizontal counter instantiation
    h_counter: Contador
        generic map(
            N_BITS    => 10,                      -- 10 bits for horizontal counting
            MAX_VALOR => H_MAX -- Total horizontal timing
        )
        port map(
            clk       => clk,
            rst       => rst,
            enable    => '1',                     -- Always enabled for horizontal counting
            up_down   => '0',                     -- Counting up
            cuenta    => h_count,
            f_cuenta  => h_end                    -- Horizontal end-of-count flag
        );

    -- Vertical counter instantiation
    v_counter: Contador 
        generic map(
            N_BITS    => 10,                      -- 10 bits for vertical counting
            MAX_VALOR => V_MAX     -- Total vertical timing
        )
        port map(
            clk       => clk,
            rst       => rst,
            enable    => h_end,                   -- Enable vertical counting on horizontal end
            up_down   => '0',                     -- Counting up
            cuenta    => v_count,
            f_cuenta  => v_end                    -- Vertical end-of-count flag
        );


 -- Señal de sincronización horizontal
    hsync <= '0' when (to_integer(unsigned(h_count)) >= 656 and 
                   to_integer(unsigned(h_count)) < 752) else '1';

-- Señal de sincronización vertical
    vsync <= '0' when (to_integer(unsigned(v_count)) >= 490 and 
                   to_integer(unsigned(v_count)) < 492) else '1';


    -- Pixel and line visible signals
    pxl_visible <= '1' when (to_integer(unsigned(h_count)) < H_VISIBLE) else '0';
    line_visible <= '1' when (to_integer(unsigned(v_count)) < V_VISIBLE) else '0';

    -- Combined visible area signal
    
    visible <= pxl_visible and line_visible;
    
    columnas <= unsigned(h_count);
    filas    <= unsigned(v_count);
    

end Behavioral;
