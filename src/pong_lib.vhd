package pong_lib is

    constant BALL_WIDTH : integer  := 8;
    constant BALL_HEIGHT : integer := 8;

    constant PADDLE_WIDTH : integer  := 10;
    constant PADDLE_HEIGHT : integer := 65;
    constant PADDLE_L_ADDR : integer := 0;
    constant PADDLE_R_ADDR : integer := 615;

    constant CENTER_X : integer := 320;
    constant CENTER_Y : integer := 240;
    
    constant LEFT : integer := -1;
    constant RIGHT : integer := 1;
    constant UP : integer := -1;
    constant DOWN : integer := 1;

end package pong_lib;
