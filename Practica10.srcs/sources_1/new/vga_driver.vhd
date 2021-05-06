----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.05.2021 14:57:14
-- Design Name: 
-- Module Name: vga_driver - Behavioral
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
use ieee.Numeric_Std.all;

entity vga_driver is
    GENERIC(
        h_pulse  : integer := 96;    --horiztonal sync pulse width in pixels
        h_bp     : integer := 48;    --horiztonal back porch width in pixels
        h_pixels : integer := 640;   --horiztonal display width in pixels
        h_fp     : integer := 16;    --horiztonal front porch width in pixels
        v_pulse  : integer := 2;      --vertical sync pulse width in rows
        v_bp     : integer := 33;     --vertical back porch width in rows
        v_pixels : integer := 480;   --vertical display width in rows
        v_fp     : integer := 10      --vertical front porch width in rows
        );
    Port (clk, reset : in std_logic;
        HS, VS, video_on: out std_logic;
        column, row: out std_logic_vector(9 downto 0));
end vga_driver;

architecture Behavioral of vga_driver is
signal clk25: std_logic := '0';
CONSTANT h_period : integer := h_pulse + h_bp + h_pixels + h_fp; --total number of pixel clocks in a row
CONSTANT v_period : integer := v_pulse + v_bp + v_pixels + v_fp; --total number of rows in column
signal hcount_reg,vcount_reg : integer range 0 to 799;

begin
clk_divider: process(clk)
    variable cnt: integer range 0 to 3;
    variable tmp: std_logic := '0';
    begin
        if(clk'event and clk = '1') then
            if(cnt = 3) then
                tmp := not(tmp);
                cnt := 0;
            else 
                cnt := cnt + 1;
            end if;
            clk25 <= tmp;
        end if;
    end process;

vs_and_hs_generator: process(clk25, reset)
    variable h_count : integer range 0 to h_period - 1 := 0;  --horizontal counter (counts the columns)
    variable v_count : integer range 0 to v_period - 1 := 0;  --vertical counter (counts the rows)
    begin
        if(reset= '1') then    --reset asserted
          h_count := 0;             --reset horizontal counter
          v_count := 0;             --reset vertical counter
          hs <= '1';      --deassert horizontal sync
          vs <= '1';      --deassert vertical sync
          video_on <= '0';          --disable display
          column <= (others => '0');              --reset column pixel coordinate
          row <= (others => '0');                 --reset row pixel coordinate
        
        elsif(clk25'event and clk25 = '1') then
            if(h_count < h_period - 1) then
                h_count := h_count + 1;
            else
                h_count := 0;
                if(v_count < v_period - 1) then
                    v_count := v_count + 1;
                else
                    v_count := 0;
                end if;    
            end if;
           
            if(h_count >= h_pulse AND h_count <= h_period - 1) then
                HS <= '1';
            else
                HS <= '0';
            end if;
            
            if(v_count >= v_pulse AND v_count <= v_period-1) then
                VS <= '1';
            else
                VS <= '0';
            end if;                
            
            --if(h_count < h_pixels) then
                column <= std_logic_vector(to_unsigned(h_count, 10));
            --end if;
            
            --if(v_count < v_pixels) then
                row <= std_logic_vector(to_unsigned(v_count, 10));
            --end if;

            if(h_count < h_pixels AND v_count < v_pixels) then
                video_on <= '1';
            else            
                video_on <= '0';
            end if;
        end if; 
    end process;

end Behavioral;
