----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 04.05.2021 11:28:49
-- Design Name: 
-- Module Name: main - Behavioral
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

entity main is
--    GENERIC(
--        h_pulse  : INTEGER := 96;    --horiztonal sync pulse width in pixels
--        h_bp     : INTEGER := 48;    --horiztonal back porch width in pixels
--        h_pixels : INTEGER := 640;   --horiztonal display width in pixels
--        h_fp     : INTEGER := 16;    --horiztonal front porch width in pixels
--        v_pulse  : INTEGER := 2;      --vertical sync pulse width in rows
--        v_bp     : INTEGER := 29;     --vertical back porch width in rows
--        v_pixels : INTEGER := 480;   --vertical display width in rows
--        v_fp     : INTEGER := 10      --vertical front porch width in rows
--        );
    Port (clk, reset, draw1, draw2: in std_logic;
        HS, VS: out std_logic;
        green, red, blue: out std_logic_vector(3 downto 0) := (OTHERS => '0'));
end main;


architecture Behavioral of main is
    component vga_driver is
        GENERIC(
            h_pulse  : INTEGER := 96;    --horiztonal sync pulse width in pixels
            h_bp     : INTEGER := 48;    --horiztonal back porch width in pixels
            h_pixels : INTEGER := 640;   --horiztonal display width in pixels
            h_fp     : INTEGER := 16;    --horiztonal front porch width in pixels
            v_pulse  : INTEGER := 2;      --vertical sync pulse width in rows
            v_bp     : INTEGER := 29;     --vertical back porch width in rows
            v_pixels : INTEGER := 480;   --vertical display width in rows
            v_fp     : INTEGER := 10      --vertical front porch width in rows
        );
        Port (clk, reset : in std_logic;
            HS, VS, video_on: out std_logic;
            column, row: out std_logic_vector(9 downto 0));
    end component;

signal column, row: integer:= 0;
signal enable: std_logic;
signal col, r: std_logic_vector(9 downto 0);
begin

column <=  to_integer(unsigned(col));
row <= to_integer(unsigned(r));

process(enable, column, row, draw1, draw2)
begin
    if(draw1 = '1' AND draw2 = '0') then 
        if(enable = '1') then
            if(row <= 48 OR (row >= 432 and row <= 480)) then 
                blue <= (OTHERS => '0');
                red <= (OTHERS => '1');
                green <= (OTHERS => '0');
            elsif(row > 48 AND row < 432) then 
                if(row >= 216 and row <= 264) then
                    blue <= (OTHERS => '0');
                    red <= (OTHERS => '1');
                    green <= (OTHERS => '0');
                else
                    if(column <= 48 OR (column >= 592 AND column <= 640)) then
                        blue <= (OTHERS => '0');
                        red <= (OTHERS => '1');
                        green <= (OTHERS => '0');
                    elsif(column >= 296 AND column <= 344) then
                        blue <= (OTHERS => '0');
                        red <= (OTHERS => '1');
                        green <= (OTHERS => '0');
                    else
                        blue <= (OTHERS => '1');
                        red <= (OTHERS => '0');
                        green <= (OTHERS => '0');
                    end if;
                end if;
            end if;    
       else
           blue <= (OTHERS => '0');
           red <= (OTHERS => '0');
           green <= (OTHERS => '0');
        end if;
        
    elsif(draw1='0' AND draw2='1') then
        if(enable = '1') then
            if(column <= 79) then
                blue <= (OTHERS => '1');
                red <= (OTHERS => '1');
                green <= (OTHERS => '1');
            elsif(column >= 80 AND column <= 159) then
                blue <= (OTHERS => '0');
                red <= (OTHERS => '1');
                green <= (OTHERS => '1'); 
            elsif(column >= 160 AND column <= 239) then
                blue <= (OTHERS => '1');
                red <= (OTHERS => '0');
                green <= (OTHERS => '1'); 
            elsif(column >= 240 AND column <= 319) then
                blue <= (OTHERS => '0');
                red <= (OTHERS => '0');
                green <= (OTHERS => '1'); 
            elsif(column >= 320 AND column <= 399) then
                blue <= (OTHERS => '1');
                red <= (OTHERS => '1');
                green <= (OTHERS => '0'); 
            elsif(column >= 400 AND column <= 479) then
                blue <= (OTHERS => '0');
                red <= (OTHERS => '1');
                green <= (OTHERS => '0'); 
            elsif(column >= 480 AND column <= 559) then
                blue <= (OTHERS => '1');
                red <= (OTHERS => '0');
                green <= (OTHERS => '0');  
            else
                blue <= (OTHERS => '0');
                red <= (OTHERS => '0');
                green <= (OTHERS => '0');                    
            end if;            
        end if;
    else
        blue <= (OTHERS => '0');
        red <= (OTHERS => '0');
        green <= (OTHERS => '0');      
    end if;    
end process;

driver: vga_driver port map(clk => clk, reset => reset, hs => hs, vs => vs, video_on => enable, column => col, row => r);
end Behavioral;
