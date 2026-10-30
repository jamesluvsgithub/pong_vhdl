library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.sprite_addr_lib.all;

entity score_renderer is
    generic (
        X_POS : natural;
        Y_POS : natural
    );
    port (
        hcount : in std_logic_vector(9 downto 0);
        vcount : in std_logic_vector(9 downto 0);

        score  : in integer range 0 to 15;
        enable : in std_logic;

        rom_addr   : out std_logic_vector(13 downto 0);
        draw_score : out std_logic
    );
end entity score_renderer;



architecture rtl of score_renderer is
begin

    process(all)

        variable x_local   : integer;
        variable y_local   : integer;
        variable base_addr : natural;
        variable addr      : natural;

    begin

        rom_addr   <= (others => '0');
        draw_score <= '0';

        x_local := to_integer(unsigned(hcount)) - X_POS;
        y_local := to_integer(unsigned(vcount)) - Y_POS;

        case score is
            when 0 => base_addr := ADDR_0;
            when 1 => base_addr := ADDR_1;
            when 2 => base_addr := ADDR_2;
            when 3 => base_addr := ADDR_3;
            when 4 => base_addr := ADDR_4;
            when 5 => base_addr := ADDR_5;
            when 6 => base_addr := ADDR_6;
            when 7 => base_addr := ADDR_7;
            when 8 => base_addr := ADDR_8;
            when 9 => base_addr := ADDR_9;
            when others => base_addr := ADDR_0;
        end case;

        -- Check whether current pixel is inside the digit
        if enable = '1' and
           x_local >= 0 and x_local < SPRITE_WIDTH and
           y_local >= 0 and y_local < SPRITE_HEIGHT then

            addr := base_addr
                    + y_local * 16
                    + x_local
                    + 1;

            rom_addr <= std_logic_vector(
                to_unsigned(addr, rom_addr'length)
            );

            draw_score <= '1';
        end if;

    end process;

end architecture rtl;