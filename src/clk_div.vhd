library ieee;
use ieee.std_logic_1164.all;

entity clk_div is
    generic (
        INPUT_MHZ : integer := 50;
        OUTPUT_MHZ : integer := 25
    );
    port (
        rst : in std_logic;
        input_clk : in std_logic;
        output_clk : out std_logic := '0'
    );
end entity clk_div;

architecture rtl of clk_div is
    constant TOGGLE_COUNT : integer := INPUT_MHZ / (2 * OUTPUT_MHZ);
    signal counter : integer := 0;
    signal output_clk_reg : std_logic := '0';
begin
    output_clk <= output_clk_reg;
    process(input_clk)
    begin
        if rising_edge(input_clk) then
            if rst = '1' then
                output_clk_reg <= '0';
                counter <= 0;
            elsif counter = TOGGLE_COUNT - 1 then
                output_clk_reg <= not output_clk_reg;
                counter <= 0;
            else
                counter <= counter + 1;
            end if;
        end if;
    end process;
end architecture rtl;
