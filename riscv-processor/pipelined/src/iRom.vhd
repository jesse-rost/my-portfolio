-- **********************************************************************
-- Project :    RISC-V Pipelined Processor
-- Filename:    iRom.vhd
-- Author  :    Jesse Rost
-- Date    :    08/22/26
-- Provides:
--   - An instruction ROM responding to addresses on its ADDR bus.
--   - A truth table built using with-select syntax.
-- Origin  :    Altered from ARM project.
-- **********************************************************************

-- NOTE: THIS FILE IS GIVEN IN COMPLETE FORM.
-- NOTE: THERE IS NO ADDITIONAL WORK FOR STUDENTS TO COMPLETE
-- NOTE: Review for reference.

-- use library packages
-- std_logic_1164: 9-valued logic signal voltages
library ieee;
use ieee.std_logic_1164.all;


-- function block symbol
-- inputs:
-- ADDR     : 32-bit address requesting instruction
-- outputs:
-- Q         : 32-bit output of machine code instruction
-- notes : ROMs do not reset on power-up so no reset signal
--         : ROMs do not load in user mode so no load signal
entity IROM is
port(ADDR : in std_logic_vector(31 downto 0);
          Q : out std_logic_vector(31 downto 0));

end entity IROM;


-- circuit description
architecture MULTIPLEXER of IROM is
begin

    -- use address to output correct binary machine code number
    with ADDR select
    Q <=
            X"00100113" when 32X"00000000",   -- addi x2, x0, 1
            X"00c000ef" when 32X"00000004",   -- jal x1, 12
            X"06300213" when 32X"00000008",   -- addi x4, x0, 99
            X"00c0006f" when 32X"0000000c",   -- jal x0, 12
            X"00700193" when 32X"00000010",   -- addi x3, x0, 7
            X"00008067" when 32X"00000014",   -- jalr x0, 0(x1)
            X"0000006f" when 32X"00000018",   -- jal x0, 0
            X"00000000" when others;          -- default to 0


end architecture MULTIPLEXER;
