library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.pong_lib.all;
use work.sprite_addr_lib.all;

entity pong is
    generic (
        INPUT_CLK_HZ  : integer := 50_000_000;
        PIXEL_CLK_HZ : integer := 25_000_000
    );
    port (
        -- DE10 LITE modules
        rst      : in  std_logic;
        clk      : in  std_logic;
        key0     : in  std_logic;
        key1     : in  std_logic;
        switches : in  std_logic_vector(9 downto 0);
        vga_hs   : out std_logic;
        vga_vs   : out std_logic;
        vga_r    : out std_logic_vector(3 downto 0);
        vga_g    : out std_logic_vector(3 downto 0);
        vga_b    : out std_logic_vector(3 downto 0)
    );
end entity pong;



architecture rtl of pong is

    type gamestate_t is (START, PLAYING, GAME_OVER);
    signal gamestate, next_gamestate : gamestate_t;

    signal pixel_clk  : std_logic := '0';
    signal pause_game : std_logic;
    signal reset, start_game, to_start : std_logic;
    signal p1_u, p1_d, p2_u, p2_d      : std_logic;
    
    -- VGA SIGNALS
    signal hsync_reg, vsync_reg, video_on : std_logic;
    signal hcount, vcount : std_logic_vector(9 downto 0);
    signal draw_game : std_logic;

    -- GRAPHICS & RGB
    signal rom_addr : std_logic_vector(13 downto 0);
    signal rgb      : std_logic_vector(11 downto 0);
    signal vga_r_reg: std_logic_vector(3 downto 0);
    signal vga_g_reg: std_logic_vector(3 downto 0);
    signal vga_b_reg: std_logic_vector(3 downto 0);
    signal draw_sprite : std_logic;

    -- GAME TICK
    signal slow_counter : integer range 0 to 1048575 := 0;
    signal game_tick : std_logic;

    -- GAME LOGIC
    signal p1_score, p2_score : integer range 0 to 9;
    signal ball_x, ball_y : unsigned(9 downto 0);
    signal p1_y : unsigned(9 downto 0) := to_unsigned(205, 10);
    signal p2_y : unsigned(9 downto 0) := to_unsigned(205, 10);
    signal dx, dy : integer;
    signal p2iswinner : std_logic;

    -- TEXT ROM ADDRESS SIGNALS
    signal pong_addr       : std_logic_vector(13 downto 0);
    signal start_press_addr: std_logic_vector(13 downto 0);
    signal game_over_addr  : std_logic_vector(13 downto 0);
    signal p1_win_addr     : std_logic_vector(13 downto 0);
    signal p2_win_addr     : std_logic_vector(13 downto 0);
    signal restart_addr    : std_logic_vector(13 downto 0);
    signal start_button_addr   : std_logic_vector(13 downto 0);
    signal restart_button_addr : std_logic_vector(13 downto 0);

    -- GRAPHICS RENDER ENABLE SIGNALS
    signal pong_draw        : std_logic;
    signal start_press_draw : std_logic;
    signal game_over_draw   : std_logic;
    signal p1_win_draw      : std_logic;
    signal p2_win_draw      : std_logic;
    signal restart_draw     : std_logic;
    signal playing_screen   : std_logic;

    -- GAME STATE ENABLES
    signal start_screen     : std_logic;
    signal game_over_screen : std_logic;
    signal p1_winner_screen : std_logic;
    signal p2_winner_screen : std_logic;

    signal start_button_draw   : std_logic;
    signal restart_button_draw : std_logic;

    -- SCORE RENDERING
    signal p1_score_addr, p2_score_addr : std_logic_vector(13 downto 0);
    signal p1_score_draw, p2_score_draw : std_logic;


begin

    reset      <= not rst;
    start_game <= not key0;
    to_start   <= not key1;
    pause_game <= switches(5);
    p1_u <= switches(9);
    p1_d <= switches(8);
    p2_u <= switches(1);
    p2_d <= switches(0);

    -- PIXEL CLOCK
    pixel_clk_gen : entity work.clk_div
        generic map (
            INPUT_HZ  => INPUT_CLK_HZ,
            OUTPUT_HZ => PIXEL_CLK_HZ
        )
        port map (
            rst => reset, 
            input_clk => clk, 
            output_clk => pixel_clk
        );

    -- SPRITE ROM
    ROM : entity work.rom
        port map (
            address => rom_addr, 
            clock => pixel_clk, 
            q => rgb
        );

    -- VGA SYNC ENTITY
    syncgen : entity work.vga_sync_gen
        port map (
            clk => pixel_clk, 
            rst => reset,
            hsync => hsync_reg, 
            vsync => vsync_reg,
            video_on => video_on, 
            hcount => hcount, 
            vcount => vcount
        );

    vga_hs <= hsync_reg;
    vga_vs <= vsync_reg;


    -- SCORE RENDERERS

    p1_score_renderer : entity work.score_renderer
        generic map (
            X_POS => 240,
            Y_POS => 30
        )
        port map (
            hcount => hcount,
            vcount => vcount,
            score => p1_score,
            enable => playing_screen,
            rom_addr => p1_score_addr,
            draw_score => p1_score_draw
        );

    p2_score_renderer : entity work.score_renderer
        generic map (
            X_POS => 380,
            Y_POS => 30
        )
        port map (
            hcount => hcount,
            vcount => vcount,
            score => p2_score,
            enable => playing_screen,
            rom_addr => p2_score_addr,
            draw_score => p2_score_draw
        );



    -- GAME SPRITE RENDERER (BALL & PADDLES)

    game_renderer_inst : entity work.game_renderer
        port map (
            hcount => hcount,
            vcount => vcount,

            ball_x => ball_x,
            ball_y => ball_y,

            p1_y => p1_y,
            p2_y => p2_y,

            enable => playing_screen,

            draw_game => draw_game
        );


    -- GRAPHICS RENDERING ENABLE SIGNALS

    start_screen <= '1' when gamestate = START else '0';

    game_over_screen <= '1' when gamestate = GAME_OVER else '0';

    p1_winner_screen <= '1' when
        gamestate = GAME_OVER and p2iswinner = '0'
        else '0';

    p2_winner_screen <= '1' when
        gamestate = GAME_OVER and p2iswinner = '1'
        else '0';

    playing_screen <= '1' when gamestate = PLAYING else '0';



    -- TEXT RENDERERS

    pong_text : entity work.text_renderer
        generic map (
            TEXT  => "PONG",
            X_POS => START_GAME_XADDR1,
            Y_POS => START_GAME_YADDR1
        )
        port map (
            hcount    => hcount,
            vcount    => vcount,
            enable    => start_screen,
            rom_addr  => pong_addr,
            draw_text => pong_draw
        );

    start_press_text : entity work.text_renderer
        generic map (
            TEXT  => "PRESS",
            X_POS => START_GAME_XADDR2,
            Y_POS => START_GAME_YADDR2
        )
        port map (
            hcount    => hcount,
            vcount    => vcount,
            enable    => start_screen,
            rom_addr  => start_press_addr,
            draw_text => start_press_draw
        );

    start_button_text : entity work.text_renderer
        generic map (
            TEXT  => "B1",
            X_POS => START_GAME_XADDR2
                    + 5 * (SPRITE_WIDTH + GAP_BTWN_SPRITES)
                    + 3 * GAP_BTWN_SPRITES,
            Y_POS => START_GAME_YADDR2
        )
        port map (
            hcount    => hcount,
            vcount    => vcount,
            enable    => start_screen,
            rom_addr  => start_button_addr,
            draw_text => start_button_draw
        );

    game_over_text : entity work.text_renderer
        generic map (
            TEXT  => "GAME OVER",
            X_POS => GAME_OVER_XADDR1,
            Y_POS => GAME_OVER_YADDR1
        )
        port map (
            hcount    => hcount,
            vcount    => vcount,
            enable    => game_over_screen,
            rom_addr  => game_over_addr,
            draw_text => game_over_draw
        );

    p1_win_text : entity work.text_renderer
        generic map (
            TEXT  => "P1 WIN",
            X_POS => GAME_OVER_XADDR1
                    + 8 * (SPRITE_WIDTH + GAP_BTWN_SPRITES)
                    + 6 * GAP_BTWN_SPRITES,
            Y_POS => GAME_OVER_YADDR1
        )
        port map (
            hcount    => hcount,
            vcount    => vcount,
            enable    => p1_winner_screen,
            rom_addr  => p1_win_addr,
            draw_text => p1_win_draw
        );

    p2_win_text : entity work.text_renderer
        generic map (
            TEXT  => "P2 WIN",
            X_POS => GAME_OVER_XADDR1
                    + 8 * (SPRITE_WIDTH + GAP_BTWN_SPRITES)
                    + 6 * GAP_BTWN_SPRITES,
            Y_POS => GAME_OVER_YADDR1
        )
        port map (
            hcount    => hcount,
            vcount    => vcount,
            enable    => p2_winner_screen,
            rom_addr  => p2_win_addr,
            draw_text => p2_win_draw
        );

    restart_text : entity work.text_renderer
        generic map (
            TEXT  => "PRESS",
            X_POS => GAME_OVER_XADDR2,
            Y_POS => GAME_OVER_YADDR2
        )
        port map (
            hcount    => hcount,
            vcount    => vcount,
            enable    => game_over_screen,
            rom_addr  => restart_addr,
            draw_text => restart_draw
        );

    restart_button_text : entity work.text_renderer
        generic map (
            TEXT  => "B2",
            X_POS => GAME_OVER_XADDR2
                    + 5 * (SPRITE_WIDTH + GAP_BTWN_SPRITES)
                    + 3 * GAP_BTWN_SPRITES,
            Y_POS => GAME_OVER_YADDR2
        )
        port map (
            hcount    => hcount,
            vcount    => vcount,
            enable    => game_over_screen,
            rom_addr  => restart_button_addr,
            draw_text => restart_button_draw
        );

    rom_addr <=
            pong_addr when pong_draw = '1' else
            start_press_addr when start_press_draw = '1' else
            start_button_addr when start_button_draw = '1' else
            game_over_addr when game_over_draw = '1' else
            p1_win_addr when p1_win_draw = '1' else
            p2_win_addr when p2_win_draw = '1' else
            restart_addr when restart_draw = '1' else
            restart_button_addr when restart_button_draw = '1' else
            p1_score_addr when p1_score_draw = '1' else
            p2_score_addr when p2_score_draw = '1' else
            (others => '0');

    draw_sprite <=
            pong_draw or
            start_press_draw or
            start_button_draw or
            game_over_draw or
            p1_win_draw or
            p2_win_draw or
            restart_draw or
            restart_button_draw or
            p1_score_draw or
            p2_score_draw;


    -- GAME TICK

    process(pixel_clk)
    begin
        if rising_edge(pixel_clk) then
            if reset = '1' then
                slow_counter <= 0;
                game_tick <= '0';
            elsif slow_counter = 416666 then
                slow_counter <= 0;
                game_tick <= '1';
            else
                slow_counter <= slow_counter + 1;
                game_tick <= '0';
            end if;
        end if;
    end process;


    -- GAME STATE

    process(all)
    begin

        next_gamestate <= gamestate;

        case gamestate is
            when START =>
                if start_game = '1' then 
                    next_gamestate <= PLAYING; 
                end if;

            when PLAYING =>
                if p1_score = 9 or p2_score = 9 then
                    next_gamestate <= GAME_OVER;
                end if;

                if to_start = '1' then 
                    next_gamestate <= START; 
                end if;

            when GAME_OVER =>
                if to_start = '1' then 
                    next_gamestate <= START; 
                end if;

        end case;
    end process;


    -- GAME LOGIC

    process(pixel_clk)
    begin

        if rising_edge(pixel_clk) then

            if reset = '1' then
                gamestate <= START;
            else
                gamestate <= next_gamestate;

                if gamestate = START then
                    p1_score <= 0; 
                    p2_score <= 0;
                    p1_y <= to_unsigned(CENTER_Y, 10);
                    p2_y <= to_unsigned(CENTER_Y, 10);
                    ball_x <= to_unsigned(CENTER_X, 10);
                    ball_y <= to_unsigned(CENTER_Y, 10);
                    dx <= RIGHT; dy <= DOWN;

                elsif gamestate = PLAYING and game_tick = '1' and pause_game = '0' then
                    ball_x <= ball_x + to_unsigned(dx mod 1024, 10);
                    ball_y <= ball_y + to_unsigned(dy mod 1024, 10);

                    if to_integer(ball_x) <= PADDLE_L_ADDR + PADDLE_WIDTH and
                       to_integer(ball_y) + BALL_HEIGHT >= to_integer(p1_y) and
                       to_integer(ball_y) <= to_integer(p1_y) + PADDLE_HEIGHT then
                        dx <= RIGHT;
                    end if;

                    if to_integer(ball_x) + BALL_WIDTH >= PADDLE_R_ADDR and
                       to_integer(ball_y) + BALL_HEIGHT >= to_integer(p2_y) and
                       to_integer(ball_y) <= to_integer(p2_y) + PADDLE_HEIGHT then
                        dx <= LEFT;
                    end if;

                    if to_integer(ball_x) <= PADDLE_L_ADDR then
                        p2_score <= p2_score + 1;
                        ball_x <= to_unsigned(320, 10);
                        ball_y <= to_unsigned(240, 10);
                        dx <= RIGHT;

                        if p2_score = 9 then 
                            p2iswinner <= '1'; 
                        end if;
                    end if;

                    if to_integer(ball_x) >= PADDLE_R_ADDR + PADDLE_WIDTH then
                        p1_score <= p1_score + 1;
                        ball_x <= to_unsigned(320, 10);
                        ball_y <= to_unsigned(240, 10);
                        dx <= LEFT;

                        if p1_score = 9 then 
                            p2iswinner <= '0'; 
                        end if;
                    end if;

                    if to_integer(ball_y) <= 18 then
                        dy <= DOWN;
                    elsif to_integer(ball_y) >= 470 then
                        dy <= UP;
                    end if;
                    
                    if p1_u = '1' and p1_y > 0 then 
                        p1_y <= p1_y - 4; 
                    end if;

                    if p1_d = '1' and p1_y < 410 then 
                        p1_y <= p1_y + 4; 
                    end if;

                    if p2_u = '1' and p2_y > 0 then 
                        p2_y <= p2_y - 4; 
                    end if;

                    if p2_d = '1' and p2_y < 410 then 
                        p2_y <= p2_y + 4; 
                    end if;

                elsif gamestate = GAME_OVER then
                    p1_score <= 0; 
                    p2_score <= 0;
                    p1_y <= to_unsigned(240, 10);
                    p2_y <= to_unsigned(240, 10);
                    ball_x <= to_unsigned(320, 10);
                    ball_y <= to_unsigned(240, 10);
                    dx <= RIGHT; 
                    dy <= DOWN;
                end if;
            end if;
        end if;
    end process;

    -- If currently in text region, get RGB from ROM. If in ball or paddle region, RGB = white (others => '1').
    vga_r_reg <= rgb(11 downto 8) when (video_on = '1' and draw_sprite = '1') else
                (others => '1') when (video_on = '1' and draw_game = '1') else
                (others => '0');

    vga_g_reg <= rgb(7 downto 4) when (video_on = '1' and draw_sprite = '1') else
                (others => '1') when (video_on = '1' and draw_game = '1') else
                (others => '0');

    vga_b_reg <= rgb(3 downto 0) when (video_on = '1' and draw_sprite = '1') else
                (others => '1') when (video_on = '1' and draw_game = '1') else
                (others => '0');

    vga_r <= vga_r_reg;
    vga_g <= vga_g_reg;
    vga_b <= vga_b_reg;

    
end architecture rtl;