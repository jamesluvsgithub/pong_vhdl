package sprite_addr_lib is

    constant SPRITE_WIDTH : integer := 16;
    constant SPRITE_HEIGHT : integer := 16;
    constant SPRITE_SIZE : integer := SPRITE_WIDTH * SPRITE_HEIGHT;
    constant GAP_BTWN_SPRITES : integer := 2;


    -- ROM ADDRESSES
    constant ADDR_0 : integer := 0;
    constant ADDR_1 : integer := ADDR_0 + SPRITE_SIZE;
    constant ADDR_2 : integer := ADDR_1 + SPRITE_SIZE;
    constant ADDR_3 : integer := ADDR_2 + SPRITE_SIZE;
    constant ADDR_4 : integer := ADDR_3 + SPRITE_SIZE;
    constant ADDR_5 : integer := ADDR_4 + SPRITE_SIZE;
    constant ADDR_6 : integer := ADDR_5 + SPRITE_SIZE;
    constant ADDR_7 : integer := ADDR_6 + SPRITE_SIZE;
    constant ADDR_8 : integer := ADDR_7 + SPRITE_SIZE;
    constant ADDR_9 : integer := ADDR_8 + SPRITE_SIZE;
    constant ADDR_A : integer := ADDR_9 + SPRITE_SIZE;
    constant ADDR_B : integer := ADDR_A + SPRITE_SIZE;
    constant ADDR_E : integer := ADDR_B + SPRITE_SIZE;
    constant ADDR_G : integer := ADDR_E + SPRITE_SIZE;
    constant ADDR_I : integer := ADDR_G + SPRITE_SIZE;
    constant ADDR_L : integer := ADDR_I + SPRITE_SIZE;
    constant ADDR_M : integer := ADDR_L + SPRITE_SIZE;
    constant ADDR_N : integer := ADDR_M + SPRITE_SIZE;
    constant ADDR_O : integer := ADDR_N + SPRITE_SIZE;
    constant ADDR_P : integer := ADDR_O + SPRITE_SIZE;
    constant ADDR_R : integer := ADDR_P + SPRITE_SIZE;
    constant ADDR_S : integer := ADDR_R + SPRITE_SIZE;
    constant ADDR_T : integer := ADDR_S + SPRITE_SIZE;
    constant ADDR_V : integer := ADDR_T + SPRITE_SIZE;
    constant ADDR_W : integer := ADDR_V + SPRITE_SIZE;
    constant ADDR_Y : integer := ADDR_W + SPRITE_SIZE;


    -- SCREEN ADDRESSES - 640x480
    constant START_GAME_XADDR1 : integer := 240;
    constant START_GAME_YADDR1 : integer := 210;
    constant START_GAME_XADDR2 : integer := 220;
    constant START_GAME_YADDR2 : integer := 280;

    constant GAME_OVER_XADDR1 : integer := 180;
    constant GAME_OVER_YADDR1 : integer := 210;
    constant GAME_OVER_XADDR2 : integer := 220;
    constant GAME_OVER_YADDR2 : integer := 280;

    constant P1_SCORE_XADDR : integer := 220;
    constant P1_SCORE_YADDR : integer := 80;

    constant P2_SCORE_XADDR : integer := 370;
    constant P2_SCORE_YADDR : integer := 80;

end package sprite_addr_lib;
