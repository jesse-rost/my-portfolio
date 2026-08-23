-- **********************************************************************
-- Project :    RISC-V Pipelined Processor
-- Filename:    pipelined_processor_tb.vhd
-- Author  :    Jesse Rost
-- Date    :    08/22/26
-- Provides:
--   - A testbench for the pipelined processor.
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
    signal O_MEMWB_RD_ADDR : std_logic_vector(4 downto 0);
    signal O_IDEX_ALUCONTROL : std_logic_vector(3 downto 0);
    signal O_STALL : std_logic;
    signal O_IDEX_MEMRD : std_logic;
    signal O_IDEX_RD_ADDR : std_logic_vector(4 downto 0);
    signal O_A1 : std_logic_vector(4 downto 0);
    signal O_A2 : std_logic_vector(4 downto 0);

begin

    dut : entity work.RISC_PIPELINED
        port map (CLK => CLK, RST => RST,
                  O_PC => O_PC, O_INSTR => O_INSTR,
                  O_ALU => O_ALU, O_WBDATA => O_WBDATA,
                  O_REGWR => O_REGWR, O_MEMWB_RD_ADDR => O_MEMWB_RD_ADDR,
                  O_IDEX_ALUCONTROL => O_IDEX_ALUCONTROL, O_STALL => O_STALL,
                  O_IDEX_MEMRD => O_IDEX_MEMRD,
                  O_IDEX_RD_ADDR => O_IDEX_RD_ADDR,
                  O_A1 => O_A1, O_A2 => O_A2);

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

       -- instruction 1: addi x2, x0, 1
        report "PC=" & to_hstring(O_PC) & "  INSTR=" & to_hstring(O_INSTR) &
               "  ALU=" & to_hstring(O_ALU) & "  WB=" & to_hstring(O_WBDATA) &
               "  MEMWB_RD_ADDR=" & to_hstring(O_MEMWB_RD_ADDR) &
               "  IDEX_ALUCONTROL=" & to_hstring(O_IDEX_ALUCONTROL) & "  STALL=" & std_logic'image(O_STALL) &
               "  IDEX_RD_ADDR=" & to_hstring(O_IDEX_RD_ADDR) &
               "  A1=" & to_hstring(O_A1) & "  A2=" & to_hstring(O_A2);
        wait for 10 ns;

        report "PC=" & to_hstring(O_PC) & "  INSTR=" & to_hstring(O_INSTR) &
               "  ALU=" & to_hstring(O_ALU) & "  WB=" & to_hstring(O_WBDATA) &
               "  MEMWB_RD_ADDR=" & to_hstring(O_MEMWB_RD_ADDR) &
               "  IDEX_ALUCONTROL=" & to_hstring(O_IDEX_ALUCONTROL) & "  STALL=" & std_logic'image(O_STALL) &
               "  IDEX_RD_ADDR=" & to_hstring(O_IDEX_RD_ADDR) &
               "  A1=" & to_hstring(O_A1) & "  A2=" & to_hstring(O_A2);
        wait for 10 ns;

        report "PC=" & to_hstring(O_PC) & "  INSTR=" & to_hstring(O_INSTR) &
               "  ALU=" & to_hstring(O_ALU) & "  WB=" & to_hstring(O_WBDATA) &
               "  MEMWB_RD_ADDR=" & to_hstring(O_MEMWB_RD_ADDR) &
               "  IDEX_ALUCONTROL=" & to_hstring(O_IDEX_ALUCONTROL) & "  STALL=" & std_logic'image(O_STALL) &
               "  IDEX_RD_ADDR=" & to_hstring(O_IDEX_RD_ADDR) &
               "  A1=" & to_hstring(O_A1) & "  A2=" & to_hstring(O_A2);
        wait for 10 ns;

        report "PC=" & to_hstring(O_PC) & "  INSTR=" & to_hstring(O_INSTR) &
               "  ALU=" & to_hstring(O_ALU) & "  WB=" & to_hstring(O_WBDATA) &
               "  MEMWB_RD_ADDR=" & to_hstring(O_MEMWB_RD_ADDR) &
               "  IDEX_ALUCONTROL=" & to_hstring(O_IDEX_ALUCONTROL) & "  STALL=" & std_logic'image(O_STALL) &
               "  IDEX_RD_ADDR=" & to_hstring(O_IDEX_RD_ADDR) &
               "  A1=" & to_hstring(O_A1) & "  A2=" & to_hstring(O_A2);
        wait for 10 ns;

        report "PC=" & to_hstring(O_PC) & "  INSTR=" & to_hstring(O_INSTR) &
               "  ALU=" & to_hstring(O_ALU) & "  WB=" & to_hstring(O_WBDATA) &
               "  MEMWB_RD_ADDR=" & to_hstring(O_MEMWB_RD_ADDR) &
               "  IDEX_ALUCONTROL=" & to_hstring(O_IDEX_ALUCONTROL) & "  STALL=" & std_logic'image(O_STALL) &
               "  IDEX_RD_ADDR=" & to_hstring(O_IDEX_RD_ADDR) &
               "  A1=" & to_hstring(O_A1) & "  A2=" & to_hstring(O_A2);
        wait for 10 ns;

        report "PC=" & to_hstring(O_PC) & "  INSTR=" & to_hstring(O_INSTR) &
               "  ALU=" & to_hstring(O_ALU) & "  WB=" & to_hstring(O_WBDATA) &
               "  MEMWB_RD_ADDR=" & to_hstring(O_MEMWB_RD_ADDR) &
               "  IDEX_ALUCONTROL=" & to_hstring(O_IDEX_ALUCONTROL) & "  STALL=" & std_logic'image(O_STALL) &
               "  IDEX_RD_ADDR=" & to_hstring(O_IDEX_RD_ADDR) &
               "  A1=" & to_hstring(O_A1) & "  A2=" & to_hstring(O_A2);
        wait for 10 ns;

        report "PC=" & to_hstring(O_PC) & "  INSTR=" & to_hstring(O_INSTR) &
               "  ALU=" & to_hstring(O_ALU) & "  WB=" & to_hstring(O_WBDATA) &
               "  MEMWB_RD_ADDR=" & to_hstring(O_MEMWB_RD_ADDR) &
               "  IDEX_ALUCONTROL=" & to_hstring(O_IDEX_ALUCONTROL) & "  STALL=" & std_logic'image(O_STALL) &
               "  IDEX_RD_ADDR=" & to_hstring(O_IDEX_RD_ADDR) &
               "  A1=" & to_hstring(O_A1) & "  A2=" & to_hstring(O_A2);
        wait for 10 ns;

        report "PC=" & to_hstring(O_PC) & "  INSTR=" & to_hstring(O_INSTR) &
               "  ALU=" & to_hstring(O_ALU) & "  WB=" & to_hstring(O_WBDATA) &
               "  MEMWB_RD_ADDR=" & to_hstring(O_MEMWB_RD_ADDR) &
               "  IDEX_ALUCONTROL=" & to_hstring(O_IDEX_ALUCONTROL) & "  STALL=" & std_logic'image(O_STALL) &
               "  IDEX_RD_ADDR=" & to_hstring(O_IDEX_RD_ADDR) &
               "  A1=" & to_hstring(O_A1) & "  A2=" & to_hstring(O_A2);
        wait for 10 ns;

        report "PC=" & to_hstring(O_PC) & "  INSTR=" & to_hstring(O_INSTR) &
               "  ALU=" & to_hstring(O_ALU) & "  WB=" & to_hstring(O_WBDATA) &
               "  MEMWB_RD_ADDR=" & to_hstring(O_MEMWB_RD_ADDR) &
               "  IDEX_ALUCONTROL=" & to_hstring(O_IDEX_ALUCONTROL) & "  STALL=" & std_logic'image(O_STALL) &
               "  IDEX_RD_ADDR=" & to_hstring(O_IDEX_RD_ADDR) &
               "  A1=" & to_hstring(O_A1) & "  A2=" & to_hstring(O_A2);
        wait for 10 ns;

        report "PC=" & to_hstring(O_PC) & "  INSTR=" & to_hstring(O_INSTR) &
               "  ALU=" & to_hstring(O_ALU) & "  WB=" & to_hstring(O_WBDATA) &
               "  MEMWB_RD_ADDR=" & to_hstring(O_MEMWB_RD_ADDR) &
               "  IDEX_ALUCONTROL=" & to_hstring(O_IDEX_ALUCONTROL) & "  STALL=" & std_logic'image(O_STALL) &
               "  IDEX_RD_ADDR=" & to_hstring(O_IDEX_RD_ADDR) &
               "  A1=" & to_hstring(O_A1) & "  A2=" & to_hstring(O_A2);
        wait for 10 ns;

        report "PC=" & to_hstring(O_PC) & "  INSTR=" & to_hstring(O_INSTR) &
               "  ALU=" & to_hstring(O_ALU) & "  WB=" & to_hstring(O_WBDATA) &
               "  MEMWB_RD_ADDR=" & to_hstring(O_MEMWB_RD_ADDR) &
               "  IDEX_ALUCONTROL=" & to_hstring(O_IDEX_ALUCONTROL) & "  STALL=" & std_logic'image(O_STALL) &
               "  IDEX_RD_ADDR=" & to_hstring(O_IDEX_RD_ADDR) &
               "  A1=" & to_hstring(O_A1) & "  A2=" & to_hstring(O_A2);
        wait for 10 ns;

        report "PC=" & to_hstring(O_PC) & "  INSTR=" & to_hstring(O_INSTR) &
               "  ALU=" & to_hstring(O_ALU) & "  WB=" & to_hstring(O_WBDATA) &
               "  MEMWB_RD_ADDR=" & to_hstring(O_MEMWB_RD_ADDR) &
               "  IDEX_ALUCONTROL=" & to_hstring(O_IDEX_ALUCONTROL) & "  STALL=" & std_logic'image(O_STALL) &
               "  IDEX_RD_ADDR=" & to_hstring(O_IDEX_RD_ADDR) &
               "  A1=" & to_hstring(O_A1) & "  A2=" & to_hstring(O_A2);
        wait for 10 ns;

        report "PC=" & to_hstring(O_PC) & "  INSTR=" & to_hstring(O_INSTR) &
               "  ALU=" & to_hstring(O_ALU) & "  WB=" & to_hstring(O_WBDATA) &
               "  MEMWB_RD_ADDR=" & to_hstring(O_MEMWB_RD_ADDR) &
               "  IDEX_ALUCONTROL=" & to_hstring(O_IDEX_ALUCONTROL) & "  STALL=" & std_logic'image(O_STALL) &
               "  IDEX_RD_ADDR=" & to_hstring(O_IDEX_RD_ADDR) &
               "  A1=" & to_hstring(O_A1) & "  A2=" & to_hstring(O_A2);
        wait for 10 ns;

        report "PC=" & to_hstring(O_PC) & "  INSTR=" & to_hstring(O_INSTR) &
               "  ALU=" & to_hstring(O_ALU) & "  WB=" & to_hstring(O_WBDATA) &
               "  MEMWB_RD_ADDR=" & to_hstring(O_MEMWB_RD_ADDR) &
               "  IDEX_ALUCONTROL=" & to_hstring(O_IDEX_ALUCONTROL) & "  STALL=" & std_logic'image(O_STALL) &
               "  IDEX_RD_ADDR=" & to_hstring(O_IDEX_RD_ADDR) &
               "  A1=" & to_hstring(O_A1) & "  A2=" & to_hstring(O_A2);
        wait for 10 ns;

        report "PC=" & to_hstring(O_PC) & "  INSTR=" & to_hstring(O_INSTR) &
               "  ALU=" & to_hstring(O_ALU) & "  WB=" & to_hstring(O_WBDATA) &
               "  MEMWB_RD_ADDR=" & to_hstring(O_MEMWB_RD_ADDR) &
               "  IDEX_ALUCONTROL=" & to_hstring(O_IDEX_ALUCONTROL) & "  STALL=" & std_logic'image(O_STALL) &
               "  IDEX_RD_ADDR=" & to_hstring(O_IDEX_RD_ADDR) &
               "  A1=" & to_hstring(O_A1) & "  A2=" & to_hstring(O_A2);
        wait for 10 ns;

        report "PC=" & to_hstring(O_PC) & "  INSTR=" & to_hstring(O_INSTR) &
               "  ALU=" & to_hstring(O_ALU) & "  WB=" & to_hstring(O_WBDATA) &
               "  MEMWB_RD_ADDR=" & to_hstring(O_MEMWB_RD_ADDR) &
               "  IDEX_ALUCONTROL=" & to_hstring(O_IDEX_ALUCONTROL) & "  STALL=" & std_logic'image(O_STALL) &
               "  IDEX_RD_ADDR=" & to_hstring(O_IDEX_RD_ADDR) &
               "  A1=" & to_hstring(O_A1) & "  A2=" & to_hstring(O_A2);
        wait for 10 ns;

        report "PC=" & to_hstring(O_PC) & "  INSTR=" & to_hstring(O_INSTR) &
               "  ALU=" & to_hstring(O_ALU) & "  WB=" & to_hstring(O_WBDATA) &
               "  MEMWB_RD_ADDR=" & to_hstring(O_MEMWB_RD_ADDR) &
               "  IDEX_ALUCONTROL=" & to_hstring(O_IDEX_ALUCONTROL) & "  STALL=" & std_logic'image(O_STALL) &
               "  IDEX_RD_ADDR=" & to_hstring(O_IDEX_RD_ADDR) &
               "  A1=" & to_hstring(O_A1) & "  A2=" & to_hstring(O_A2);
        wait for 10 ns;
        report "tb_riscv complete";
        wait;
    end process;

end architecture test;