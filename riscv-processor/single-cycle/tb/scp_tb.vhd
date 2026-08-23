-- **********************************************************************
-- Project :    RISC-V Single-cycle Processor
-- Filename:    scp_tb.vhd
-- Author  :    Jesse Rost
-- Date    :    08/08/26
-- Provides:
--   - A testbench for the single-cycle processor.
-- Origin  :    Written from scratch.
-- **********************************************************************

library ieee;
use ieee.std_logic_1164.all;

entity tb_riscv is
end entity tb_riscv;

architecture test of tb_riscv is
    signal CLK      : std_logic := '0';
    signal RST      : std_logic := '1';
    signal O_PC     : std_logic_vector(31 downto 0);
    signal O_INSTR  : std_logic_vector(31 downto 0);
    signal O_ALU    : std_logic_vector(31 downto 0);
    signal O_WBDATA : std_logic_vector(31 downto 0);
    signal O_REGWR  : std_logic;
begin

    dut : entity work.RISC_SCP
        port map (CLK => CLK, RST => RST,
                  O_PC => O_PC, O_INSTR => O_INSTR,
                  O_ALU => O_ALU, O_WBDATA => O_WBDATA,
                  O_REGWR => O_REGWR);

    clk_proc : process
    begin
        CLK <= '0'; wait for 5 ns;
        CLK <= '1'; wait for 5 ns;
    end process;

    stim : process
    begin
        RST <= '0';              -- assert reset
        wait for 20 ns;
        RST <= '1';              -- release
        wait for 2 ns;           -- let things settle

        -- instruction 1: addi x1, x0, 5
        report "PC=" & to_hstring(O_PC) & "  INSTR=" & to_hstring(O_INSTR) &
               "  ALU=" & to_hstring(O_ALU) & "  WB=" & to_hstring(O_WBDATA);
        wait for 10 ns;

        report "PC=" & to_hstring(O_PC) & "  INSTR=" & to_hstring(O_INSTR) &
               "  ALU=" & to_hstring(O_ALU) & "  WB=" & to_hstring(O_WBDATA);
        wait for 10 ns;

        report "PC=" & to_hstring(O_PC) & "  INSTR=" & to_hstring(O_INSTR) &
               "  ALU=" & to_hstring(O_ALU) & "  WB=" & to_hstring(O_WBDATA);
        wait for 10 ns;

        report "PC=" & to_hstring(O_PC) & "  INSTR=" & to_hstring(O_INSTR) &
               "  ALU=" & to_hstring(O_ALU) & "  WB=" & to_hstring(O_WBDATA);
        wait for 10 ns;

          report "PC=" & to_hstring(O_PC) & "  INSTR=" & to_hstring(O_INSTR) &
               "  ALU=" & to_hstring(O_ALU) & "  WB=" & to_hstring(O_WBDATA);
        wait for 10 ns;

          report "PC=" & to_hstring(O_PC) & "  INSTR=" & to_hstring(O_INSTR) &
               "  ALU=" & to_hstring(O_ALU) & "  WB=" & to_hstring(O_WBDATA);
        wait for 10 ns;

          report "PC=" & to_hstring(O_PC) & "  INSTR=" & to_hstring(O_INSTR) &
               "  ALU=" & to_hstring(O_ALU) & "  WB=" & to_hstring(O_WBDATA);
        wait for 10 ns;

        report "tb_riscv complete";
        wait;
    end process;

end architecture test;