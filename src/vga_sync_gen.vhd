library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.vgalib_640x480_60hz.all;

entity vga_sync_gen is
    port (
        clk : in std_logic; -- should be 25 MHz
        rst : in std_logic;
        hsync : out std_logic; -- active low
        vsync : out std_logic; -- active low
        video_on : out std_logic;
        hcount : out std_logic_vector(9 downto 0); -- 0-799
        vcount : out std_logic_vector(9 downto 0) -- 0-524
    );
end entity vga_sync_gen;

architecture rtl of vga_sync_gen is
    signal hcount_reg : unsigned(9 downto 0);
    signal vcount_reg : unsigned(9 downto 0);
begin
    hcount <= std_logic_vector(hcount_reg);
    vcount <= std_logic_vector(vcount_reg);

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                hcount_reg <= (others => '0');
                vcount_reg <= (others => '0');
            else
                if hcount_reg = H_TOTAL - 1 then
                    hcount_reg <= (others => '0');
                    if vcount_reg = V_TOTAL - 1 then
                        vcount_reg <= (others => '0');
                    else
                        vcount_reg <= vcount_reg + 1;
                    end if;
                else
                    hcount_reg <= hcount_reg + 1;
                end if;
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                hsync <= '1';
            else
                if hcount_reg >= (H_VISIBLE + H_FRONT) and
                   hcount_reg < (H_VISIBLE + H_FRONT + H_SYNC) then
                    hsync <= '0';
                else
                    hsync <= '1';
                end if;
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                vsync <= '1';
            else
                if vcount_reg >= (V_VISIBLE + V_FRONT) and
                   vcount_reg < (V_VISIBLE + V_FRONT + V_SYNC) then
                    vsync <= '0';
                else
                    vsync <= '1';
                end if;
            end if;
        end if;
    end process;

    process(clk)
    begin
        if rising_edge(clk) then
            if rst = '1' then
                video_on <= '0';
            else
                if hcount_reg < H_VISIBLE and vcount_reg < V_VISIBLE then
                    video_on <= '1';
                else
                    video_on <= '0';
                end if;
            end if;
        end if;
    end process;
end architecture rtl;
