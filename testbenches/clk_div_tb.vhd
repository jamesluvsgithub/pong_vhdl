library ieee;
use ieee.std_logic_1164.all;
use std.env.all;

-- visually confirm the clock divider with waveforms

entity clk_div_tb is
    generic (
        NUM_OUT_POSEDGES : integer := 200; -- 100 full cycles
        INPUT_MHZ       : integer := 50;
        OUTPUT_MHZ      : integer := 25
    );
end entity clk_div_tb;

architecture behavioral of clk_div_tb is
    signal rst        : std_logic := '0';
    signal input_clk  : std_logic := '0';
    signal output_clk : std_logic;
begin

    DUT : entity work.clk_div
        generic map (
            INPUT_MHZ  => INPUT_MHZ,
            OUTPUT_MHZ => OUTPUT_MHZ
        )
        port map (
            rst        => rst,
            input_clk  => input_clk,
            output_clk => output_clk
        );

    generate_clock : process
    begin
        -- period of 20 ns -> 50 MHz
        loop
            wait for 10 ns;
            input_clk <= not input_clk;
        end loop;
    end process generate_clock;

    stimulus : process
    begin
        rst <= '1';
        for i in 1 to 5 loop
            wait until rising_edge(input_clk);
        end loop;
        rst <= '0';

        for i in 1 to NUM_OUT_POSEDGES loop
            wait until rising_edge(output_clk);
        end loop;

        finish;
        wait;
    end process stimulus;

end architecture behavioral;
