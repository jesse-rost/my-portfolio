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
     Q    : out std_logic_vector(31 downto 0));

end entity IROM;


-- circuit description
architecture MULTIPLEXER of IROM is
begin

    -- use address to output correct binary machine code number
    with ADDR select
    Q <=    X"00200513" when 32X"00000000",   -- addi x10, x0, 2
            X"00a00593" when 32X"00000004",   -- addi x11, x0, 10
            X"00600613" when 32X"00000008",   -- addi x12, x0, 6
            X"03700693" when 32X"0000000c",   -- addi x13, x0, 55
            X"02100713" when 32X"00000010",   -- addi x14, x0, 33
            X"000107b7" when 32X"00000014",   -- li x15, 0x00010000
            X"00a7a023" when 32X"00000018",   -- sw x10, 0(x15)
            X"00b7a223" when 32X"0000001c",   -- sw x11, 4(x15)
            X"00c7a423" when 32X"00000020",   -- sw x12, 8(x15)
            X"00d7a623" when 32X"00000024",   -- sw x13, 12(x15)
            X"00e7a823" when 32X"00000028",   -- sw x14, 16(x15)
            X"00400813" when 32X"0000002c",   -- addi x16, x0, 4
            X"00000a93" when 32X"00000030",   -- addi x21, x0, 0
            X"00010b37" when 32X"00000034",   -- li x22, 0x0001000c
            X"00cb0b13" when 32X"00000038",   -- addi x22, x22, 12
            X"0007a883" when 32X"0000003c",   -- lw x17, 0(x15)
            X"010789b3" when 32X"00000040",   -- add x19, x15, x16
            X"0009a903" when 32X"00000044",   -- lw x18, 0(x19)
            X"01288e63" when 32X"00000048",   -- beq x17, x18, check_end
            X"0128aa33" when 32X"0000004c",   -- slt x20, x17, x18
            X"000a0463" when 32X"00000050",   -- beq x20, x0, swap_location
            X"0100006f" when 32X"00000054",   -- j check_end
            X"001a8a93" when 32X"00000058",   -- addi x21, x21, 1
            X"0127a023" when 32X"0000005c",   -- sw x18, 0(x15)
            X"0119a023" when 32X"00000060",   -- sw x17, 0(x19)
            X"01678663" when 32X"00000064",   -- beq x15, x22, reset
            X"010787b3" when 32X"00000068",   -- add x15, x15, x16
            X"fd1ff06f" when 32X"0000006c",   -- j bubble_sort
            X"000107b7" when 32X"00000070",   -- li x15, 0x00010000
            X"000a8663" when 32X"00000074",   -- beq x21, x0, end
            X"00000a93" when 32X"00000078",   -- addi x21, x0, 0
            X"fc1ff06f" when 32X"0000007c",   -- j bubble_sort
            X"0007ac83" when 32X"00000080",   -- lw x25, 0(x15)
            X"0047ad03" when 32X"00000084",   -- lw x26, 4(x15)
            X"0087ad83" when 32X"00000088",   -- lw x27, 8(x15)
            X"00c7ae03" when 32X"0000008c",   -- lw x28, 12(x15)
            X"0107ae83" when 32X"00000090",   -- lw x29, 16(x15)
            X"0000006f" when 32X"00000094",   -- halt: j halt
            X"00000000" when others;          -- default to 0


end architecture MULTIPLEXER;
