-- **********************************************************************
-- Project :    RISC-V Single-cycle Processor
-- Filename:    iRom.vhd
-- Author  :    Jesse Rost
-- Date    :    08/08/26
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
    Q <=
                    X"00500093" when 32X"00000000",
                    X"00300113" when 32X"00000004",
                    X"00102023" when 32X"00000008",
                    X"00002183" when 32X"0000000C",
                    X"00108463" when 32x"00000010",
                    X"06300213" when  32x"00000014",
                    X"00700293" when  32x"00000018",
                    x"00000000" when     others;


end architecture MULTIPLEXER;
