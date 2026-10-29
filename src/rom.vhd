library ieee;
use ieee.std_logic_1164.all;
library altera_mf;
use altera_mf.altera_mf_components.all;

entity rom is
    port (
        address : in std_logic_vector(13 downto 0);
        clock : in std_logic;
        q : out std_logic_vector(11 downto 0)
    );
end entity rom;

architecture rtl of rom is
    signal sub_wire0 : std_logic_vector(11 downto 0);
begin
    q <= sub_wire0;
    altsyncram_component : altsyncram
        generic map (
            address_aclr_a => "NONE",
            clock_enable_input_a => "BYPASS",
            clock_enable_output_a => "BYPASS",
            init_file => "/src/image/mem_init.mif",
            intended_device_family => "MAX 10",
            lpm_hint => "ENABLE_RUNTIME_MOD=NO",
            lpm_type => "altsyncram",
            numwords_a => 10240,
            operation_mode => "ROM",
            outdata_aclr_a => "NONE",
            outdata_reg_a => "UNREGISTERED",
            widthad_a => 14,
            width_a => 12,
            width_byteena_a => 1
        )
        port map (
            address_a => address,
            clock0 => clock,
            q_a => sub_wire0,
            aclr0 => '0',
            aclr1 => '0',
            address_b => (others => '1'),
            addressstall_a => '0',
            addressstall_b => '0',
            byteena_a => (others => '1'),
            byteena_b => (others => '1'),
            clock1 => '1',
            clocken0 => '1',
            clocken1 => '1',
            clocken2 => '1',
            clocken3 => '1',
            data_a => (others => '1'),
            data_b => (others => '1'),
            eccstatus => open,
            q_b => open,
            rden_a => '1',
            rden_b => '1',
            wren_a => '0',
            wren_b => '0'
        );
end architecture rtl;
