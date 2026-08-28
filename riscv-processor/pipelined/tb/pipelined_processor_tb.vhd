-- **********************************************************************
-- Project :    RISC-V Pipelined Processor
-- Filename:    pipelined_processor_tb.vhd
-- Author  :    Jesse Rost
-- Date    :    08/22/26
-- Provides:
--   - A testbench for the pipelined processor.
--   - Traces the execute-stage forwarding path with instruction identity.
-- Origin  :    Written from scratch.
-- **********************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

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
    signal O_STALL           : std_logic;
    signal O_IDEX_MEMRD      : std_logic;
    signal O_IDEX_RD_ADDR    : std_logic_vector(4 downto 0);
    signal O_A1              : std_logic_vector(4 downto 0);
    signal O_A2              : std_logic_vector(4 downto 0);

    signal O_IDEX_ALUSRC   : std_logic;
    signal O_IDEX_RS1_ADDR : std_logic_vector(4 downto 0);
    signal O_IDEX_RS2_ADDR : std_logic_vector(4 downto 0);
    signal O_IDEX_RD1      : std_logic_vector(31 downto 0);
    signal O_IDEX_RD2      : std_logic_vector(31 downto 0);
    signal O_IDEX_IMMR     : std_logic_vector(31 downto 0);
    signal O_FWD_RD2       : std_logic_vector(31 downto 0);
    signal O_ALU_A         : std_logic_vector(31 downto 0);
    signal O_ALU_B         : std_logic_vector(31 downto 0);

    signal O_EXMEM_REGWR   : std_logic;
    signal O_EXMEM_RD_ADDR : std_logic_vector(4 downto 0);
    signal O_MEMWB_REGWR   : std_logic;

    signal O_IDEX_INSTR    : std_logic_vector(31 downto 0);
    signal O_PCSRC         : std_logic;

begin

    dut : entity work.RISC_PIPELINED
        port map (CLK => CLK, RST => RST,
                  O_PC => O_PC, O_INSTR => O_INSTR, O_ALU => O_ALU,
                  O_WBDATA => O_WBDATA, O_REGWR => O_REGWR,
                  O_MEMWB_RD_ADDR => O_MEMWB_RD_ADDR,
                  O_IDEX_ALUCONTROL => O_IDEX_ALUCONTROL,
                  O_STALL => O_STALL,
                  O_IDEX_MEMRD => O_IDEX_MEMRD,
                  O_IDEX_RD_ADDR => O_IDEX_RD_ADDR,
                  O_A1 => O_A1, O_A2 => O_A2,
                  O_IDEX_ALUSRC => O_IDEX_ALUSRC,
                  O_IDEX_RS1_ADDR => O_IDEX_RS1_ADDR,
                  O_IDEX_RS2_ADDR => O_IDEX_RS2_ADDR,
                  O_IDEX_RD1 => O_IDEX_RD1,
                  O_IDEX_RD2 => O_IDEX_RD2,
                  O_IDEX_IMMR => O_IDEX_IMMR,
                  O_FWD_RD2 => O_FWD_RD2,
                  O_ALU_A => O_ALU_A,
                  O_ALU_B => O_ALU_B,
                  O_EXMEM_REGWR => O_EXMEM_REGWR,
                  O_EXMEM_RD_ADDR => O_EXMEM_RD_ADDR,
                  O_MEMWB_REGWR => O_MEMWB_REGWR,
                  O_IDEX_INSTR => O_IDEX_INSTR,
                  O_PCSRC => O_PCSRC);

    clk_proc : process
    begin
        CLK <= '0'; wait for 5 ns;
        CLK <= '1'; wait for 5 ns;
    end process;

    stim : process
    begin
        RST <= '0';
        wait for 20 ns;
        RST <= '1';
        wait for 2 ns;

        for i in 0 to 154 loop

            report "cyc " & integer'image(i) &
                   "  PC=" & to_hstring(O_PC) &
                   "  IF_INSTR=" & to_hstring(O_INSTR) &
                   "  STALL=" & std_logic'image(O_STALL) &
                   "  PCSRC=" & std_logic'image(O_PCSRC);

            report "   EX_INSTR=" & to_hstring(O_IDEX_INSTR) &
                   "  rs1=" & integer'image(to_integer(unsigned(O_IDEX_RS1_ADDR))) &
                   " rs2=" & integer'image(to_integer(unsigned(O_IDEX_RS2_ADDR))) &
                   " rd=" & integer'image(to_integer(unsigned(O_IDEX_RD_ADDR))) &
                   "  ALUSRC=" & std_logic'image(O_IDEX_ALUSRC) &
                   " ALUCTRL=" & to_hstring(O_IDEX_ALUCONTROL);

            report "   VALS: RD1=" & to_hstring(O_IDEX_RD1) &
                   " RD2=" & to_hstring(O_IDEX_RD2) &
                   " IMM=" & to_hstring(O_IDEX_IMMR) &
                   "  ALU_A=" & to_hstring(O_ALU_A) &
                   " ALU_B=" & to_hstring(O_ALU_B) &
                   " => " & to_hstring(O_ALU);

            report "   FWD: EXMEM(wr=" & std_logic'image(O_EXMEM_REGWR) &
                   " rd=" & integer'image(to_integer(unsigned(O_EXMEM_RD_ADDR))) &
                   ")  MEMWB(wr=" & std_logic'image(O_MEMWB_REGWR) &
                   " rd=" & integer'image(to_integer(unsigned(O_MEMWB_RD_ADDR))) &
                   ")  WB_DATA=" & to_hstring(O_WBDATA);

            if O_REGWR = '1' and O_MEMWB_RD_ADDR /= "00000" then
                report "   >>> WRITE x" &
                       integer'image(to_integer(unsigned(O_MEMWB_RD_ADDR))) &
                       " <= " & to_hstring(O_WBDATA);
            end if;

            wait for 10 ns;
        end loop;

        report "tb_riscv complete";
        wait;
    end process;

end architecture test;