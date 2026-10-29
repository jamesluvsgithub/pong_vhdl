library ieee;
use ieee.std_logic_1164.all;

entity rom is
    port (
        address : in std_logic_vector(13 downto 0);
        clock : in std_logic;
        q : out std_logic_vector(11 downto 0)
    );
end entity rom;

architecture black_box of rom is
begin
end architecture black_box;
