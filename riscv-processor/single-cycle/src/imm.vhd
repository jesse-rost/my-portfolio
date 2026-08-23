-- **********************************************************************
-- Project :    RISC-V Single-cycle Processor
-- Filename:    imm.vhd
-- Author  :    Jesse Rost
-- Date    :    08/08/26
-- Provides:
--   - Immediate value generation from RISC-V instruction encodings.
-- Origin  :    Written from scratch.
-- **********************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- functional block symbol
entity IMM is
port(INSTR : in std_logic_vector(31 downto 0);
     IMMR  : out std_logic_vector(31 downto 0));

end entity IMM;

-- block description
architecture DATAFLOW of IMM is
    signal OPCODE : std_logic_vector(6 downto 0);
begin
    OPCODE <= INSTR(6 downto 0);

    with OPCODE select
    IMMR <= X"00000000" when B"0110011",                                                                               -- R-type
            (31 downto 11 => INSTR(31)) & INSTR(30 downto 20) when B"0000011" | B"0010011" | B"1100111",               -- I-type : arithmetic & loads & jalr
            (31 downto 12 => INSTR(31)) & INSTR(31 downto 25) & INSTR(11 downto 7) when B"0100011",                    -- S-type
            (31 downto 12 => INSTR(31)) & INSTR(7) & INSTR(30 downto 25) & INSTR(11 downto 8) & '0' when B"1100011",   -- B-type
            INSTR(31 downto 12) & (11 downto 0 => X"000") when B"0110111" ,                                            -- U-type-lui
            (31 downto 20 => INSTR(31)) & INSTR(19 downto 12) & INSTR(20) & INSTR(30 downto 21) & '0' when B"1101111", -- J-type
            X"DEADC0DE" when others;

end architecture;