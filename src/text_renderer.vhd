library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pong_lib.all;
use work.sprite_addr_lib.all;


entity text_renderer is
    generic (
        TEXT : string;
        X_POS : natural;
        Y_POS : natural
    );
    port (
        hcount    : in  std_logic_vector(9 downto 0);
        vcount    : in  std_logic_vector(9 downto 0);
        enable    : in  std_logic;
        rom_addr  : out std_logic_vector(13 downto 0);
        draw_text : out std_logic
    );
end entity text_renderer;


architecture rtl of text_renderer is

    constant CHAR_PITCH : positive := SPRITE_WIDTH + GAP_BTWN_SPRITES;


    function char_base_addr(c : character) return natural is
    begin

        case c is
            when 'A' | 'a' => return ADDR_A;
            when 'B' | 'b' => return ADDR_B;
            when 'C' | 'c' => return ADDR_C;
            when 'D' | 'd' => return ADDR_D;
            when 'E' | 'e' => return ADDR_E;
            when 'F' | 'f' => return ADDR_F;
            when 'G' | 'g' => return ADDR_G;
            when 'H' | 'h' => return ADDR_H;
            when 'I' | 'i' => return ADDR_I;
            when 'J' | 'j' => return ADDR_J;
            when 'K' | 'k' => return ADDR_K;
            when 'L' | 'l' => return ADDR_L;
            when 'M' | 'm' => return ADDR_M;
            when 'N' | 'n' => return ADDR_N;
            when 'O' | 'o' => return ADDR_O;
            when 'P' | 'p' => return ADDR_P;
            when 'Q' | 'q' => return ADDR_Q;
            when 'R' | 'r' => return ADDR_R;
            when 'S' | 's' => return ADDR_S;
            when 'T' | 't' => return ADDR_T;
            when 'U' | 'u' => return ADDR_U;
            when 'V' | 'v' => return ADDR_V;
            when 'W' | 'w' => return ADDR_W;
            when 'X' | 'x' => return ADDR_X;
            when 'Y' | 'y' => return ADDR_Y;
            when 'Z' | 'z' => return ADDR_Z;
            when '0' => return ADDR_0;
            when '1' => return ADDR_1;
            when '2' => return ADDR_2;
            when '3' => return ADDR_3;
            when '4' => return ADDR_4;
            when '5' => return ADDR_5;
            when '6' => return ADDR_6;
            when '7' => return ADDR_7;
            when '8' => return ADDR_8;
            when '9' => return ADDR_9;
            when others => return 0;

        end case;

    end function;


begin


    process(all)

        variable x_local    : integer;
        variable y_local    : integer;
        variable char_index : integer;
        variable x_offset   : integer;
        variable base_addr  : natural;
        variable addr       : integer;

    begin

        rom_addr  <= (others => '0');
        draw_text <= '0';

        x_local := to_integer(unsigned(hcount)) - X_POS;
        y_local := to_integer(unsigned(vcount)) - Y_POS;

        if enable = '1' and
           x_local >= 0 and x_local < TEXT'length * CHAR_PITCH and
           y_local >= 0 and y_local < SPRITE_HEIGHT then

            char_index := x_local / CHAR_PITCH;
            x_offset   := x_local mod CHAR_PITCH;

            if x_offset < SPRITE_WIDTH then

                if TEXT(TEXT'low + char_index) /= ' ' then

                    base_addr := char_base_addr(TEXT(TEXT'low + char_index));

                    if base_addr /= 0 then

                        addr := base_addr + y_local * 16 + x_offset + 1;
                        rom_addr  <= std_logic_vector(to_unsigned(addr, rom_addr'length));
                        draw_text <= '1';

                    end if;
                end if;
            end if;
        end if;
    end process;
end architecture rtl;
