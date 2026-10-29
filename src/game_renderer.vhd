library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pong_lib.all;

entity game_renderer is
    port (
        hcount : in std_logic_vector(9 downto 0);
        vcount : in std_logic_vector(9 downto 0);

        ball_x : in unsigned(9 downto 0);
        ball_y : in unsigned(9 downto 0);

        p1_y : in unsigned(9 downto 0);
        p2_y : in unsigned(9 downto 0);

        enable : in std_logic;


        draw_game : out std_logic
    );
end entity game_renderer;


architecture rtl of game_renderer is

begin

    process(all)

        variable x : integer;
        variable y : integer;

    begin

        x := to_integer(unsigned(hcount));
        y := to_integer(unsigned(vcount));

        rgb <= (others => '0');
        draw_game <= '0';

        if enable = '1' then

            -- BALL
            if x >= to_integer(ball_x) and
               x < to_integer(ball_x) + BALL_WIDTH and
               y >= to_integer(ball_y) and
               y < to_integer(ball_y) + BALL_HEIGHT then

                draw_game <= '1';

            -- P1 PADDLE
            elsif x >= PADDLE_L_ADDR and
                  x < PADDLE_L_ADDR + PADDLE_WIDTH and
                  y >= to_integer(p1_y) and
                  y < to_integer(p1_y) + PADDLE_HEIGHT then

                rgb <= (others => '1');
                draw_game <= '1';

            -- P2 PADDLE
            elsif x >= PADDLE_R_ADDR and
                  x < PADDLE_R_ADDR + PADDLE_WIDTH and
                  y >= to_integer(p2_y) and
                  y < to_integer(p2_y) + PADDLE_HEIGHT then

                rgb <= (others => '1');
                draw_game <= '1';

            end if;

        end if;

    end process;

end architecture rtl;