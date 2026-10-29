package vgalib_640x480_60hz is

    constant H_VISIBLE : integer := 640;
    constant H_FRONT : integer := 16;
    constant H_SYNC : integer := 96;
    constant H_BACK : integer := 48;
    constant H_TOTAL : integer := H_VISIBLE + H_FRONT + H_SYNC + H_BACK; -- 800

    constant V_VISIBLE : integer := 480;
    constant V_FRONT : integer := 10;
    constant V_SYNC : integer := 2;
    constant V_BACK : integer := 33;
    constant V_TOTAL : integer := V_VISIBLE + V_FRONT + V_SYNC + V_BACK; -- 525

end package vgalib_640x480_60hz;
