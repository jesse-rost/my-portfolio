-- **********************************************************************
-- Project :    RISC-V Single-cycle Processor
-- Filename:    regn_tb.vhd
-- Author  :    Jesse Rost
-- Date    :    08/08/26
-- Provides:
--   - A testbench for the n-bit register implementation.
-- Origin  :    Written from scratch.
-- **********************************************************************

library ieee;
use ieee.std_logic_1164.all;

entity tb_regn is
end entity tb_regn;

architecture test of tb_regn is
    signal D   : std_logic_vector(31 downto 0) := (others => '0');
    signal LD  : std_logic := '1';   -- start disabled (active-low)
    signal RST : std_logic := '1';   -- start released (active-low)
    signal CLK : std_logic := '0';
    signal Q   : std_logic_vector(31 downto 0);
begin

    dut : entity work.REGN
        generic map (WIDTH => 32)
        port map (D => D, LD => LD, RST => RST, CLK => CLK, Q => Q);

    -- free-running clock, 10 ns period
    clk_proc : process
    begin
        CLK <= '0'; wait for 5 ns;
        CLK <= '1'; wait for 5 ns;
    end process;

    stim : process
    begin
        -- test 1: reset clears Q
        RST <= '0';
        wait for 12 ns;
        assert Q = x"00000000"
            report "FAIL: reset did not clear Q" severity error;
        RST <= '1';
        wait for 10 ns;

        -- test 2: load a value
        D  <= x"DEADBEEF";
        LD <= '0';                  -- active-low: enable load
        wait for 10 ns;             -- one clock edge passes
        assert Q = x"DEADBEEF"
            report "FAIL: load did not capture D" severity error;

        -- test 3: hold when LD is high
        LD <= '1';                  -- disable load
        D  <= x"12345678";
        wait for 20 ns;
        assert Q = x"DEADBEEF"
            report "FAIL: register changed while load disabled" severity error;

        -- test 4: async reset takes effect immediately
        RST <= '0';
        wait for 2 ns;              -- less than a clock period
        assert Q = x"00000000"
            report "FAIL: async reset did not clear immediately" severity error;

        report "tb_regn complete";
        wait;
    end process;

end architecture test;