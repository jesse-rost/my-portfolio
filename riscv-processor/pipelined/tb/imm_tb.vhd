-- **********************************************************************
-- Project :    RISC-V Pipelined Processor
-- Filename:    imm_tb.vhd
-- Author  :    Jesse Rost
-- Date    :    08/22/26
-- Provides:
--   - A testbench for immediate value generation.
-- Origin  :    Written from scratch.
-- **********************************************************************

library ieee;
use ieee.std_logic_1164.all;

entity tb_imm is
end entity tb_imm;

architecture test of tb_imm is
    signal INSTR : std_logic_vector(31 downto 0);
    signal IMM   : std_logic_vector(31 downto 0);
begin

    dut : entity work.IMM
        port map (INSTR => INSTR, IMMR => IMM);

    process
    begin

        -- test 1: R-type (add x1, x2, x3) -- no immediate, expect zeros
        INSTR <= X"003100B3";
        wait for 10 ns;
        assert IMM = X"00000000"
            report "R-type failed" severity error;

        -- test 2: I-type positive (addi x1, x0, 5)
        INSTR <= X"00500093";
        wait for 10 ns;
        assert IMM = X"00000005"
            report "I-type positive failed" severity error;

        -- test 3: I-type negative (addi x1, x0, -1)
        INSTR <= X"FFF00093";
        wait for 10 ns;
        assert IMM = X"FFFFFFFF"
            report "I-type negative failed" severity error;

        -- test 4: I-type load (lw x5, 12(x10))
        INSTR <= X"00C52283";
        wait for 10 ns;
        assert IMM = X"0000000C"
            report "I-type load failed" severity error;

        -- test 5: S-type (sw x5, 8(x10))
        INSTR <= X"00552423";
        wait for 10 ns;
        assert IMM = X"00000008"
            report "S-type failed" severity error;

        -- test 6: B-type (beq x1, x2, +16)
        INSTR <= X"00208863";
        wait for 10 ns;
        assert IMM = X"00000010"
            report "B-type failed" severity error;

        -- test 7: U-type (lui x5, 0x12345)
        INSTR <= X"123452B7";
        wait for 10 ns;
        assert IMM = X"12345000"
            report "U-type failed" severity error;

        -- test 8: J-type (jal x1, +32)
        INSTR <= X"020000EF";
        wait for 10 ns;
        assert IMM = X"00000020"
            report "J-type failed" severity error;

        report "tb_imm has completed";
        wait;

    end process;

end architecture test;