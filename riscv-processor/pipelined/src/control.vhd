-- **********************************************************************
-- Project :    RISC-V Pipelined Processor
-- Filename:    control.vhd
-- Author  :    Jesse Rost
-- Date    :    08/22/26
-- Provides:
--   - Control signal generation for RISC-V instruction decoding.
-- Origin  :    Written from scratch.
-- **********************************************************************

library ieee;
use ieee.std_logic_1164.all;

entity CONTROL is
    port (OPCODE     : in  std_logic_vector(6 downto 0);
          FUNCT7     : in  std_logic_vector(6 downto 0);
          FUNCT3     : in  std_logic_vector(2 downto 0);
          ALUCONTROL : out std_logic_vector(3 downto 0);
          MEMTOREG   : out std_logic_vector(1 downto 0);
          REGWR      : out std_logic;
          ALUSRC     : out std_logic;
          MEMREAD    : out std_logic;
          MEMWRITE   : out std_logic;
          BRANCH     : out std_logic;
          JUMP       : out std_logic;
          JALRSRC    : out std_logic);
end entity;

architecture DATAFLOW of CONTROL is

   constant ALU_ADD : std_logic_vector(3 downto 0) := B"0000";
   constant ALU_SUB : std_logic_vector(3 downto 0) := B"0001";
   constant ALU_AND : std_logic_vector(3 downto 0) := B"0010";
   constant ALU_OR  : std_logic_vector(3 downto 0) := B"0011";
   constant ALU_SLT : std_logic_vector(3 downto 0) := B"0100";

begin

    ALUCONTROL <= ALU_ADD when FUNCT3 = B"000" and FUNCT7 = B"0000000" and OPCODE = B"0110011" else -- add
                  ALU_SLT when FUNCT3 = B"010" and FUNCT7 = B"0000000" and OPCODE = B"0110011" else -- slt
                  ALU_AND when FUNCT3 = B"111" and FUNCT7 = B"0000000" and OPCODE = B"0110011" else -- and
                  ALU_OR  when FUNCT3 = B"110" and FUNCT7 = B"0000000" and OPCODE = B"0110011" else -- or
                  ALU_SUB when FUNCT3 = B"000" and FUNCT7 = B"0100000" and OPCODE = B"0110011" else -- sub
                  ALU_ADD when FUNCT3 = B"010" and OPCODE = B"0000011" else -- lw
                  ALU_ADD when FUNCT3 = B"000" and OPCODE = B"0010011" else -- addi
                  ALU_ADD when FUNCT3 = B"010" and OPCODE = B"0100011" else -- sw
                  ALU_SUB when FUNCT3 = B"000" and OPCODE = B"1100011" else -- beq
                  ALU_ADD when FUNCT3 = B"000" and OPCODE = B"1100111" else -- jalr
                  ALU_ADD when OPCODE = B"1101111" else -- jal
                  ALU_ADD when OPCODE = B"0110111" else -- lui
                  ALU_ADD;

    REGWR    <= '0' when OPCODE = B"0100011" else   -- sw (s-type)
                '0' when OPCODE = B"1100011" else   -- beq (b-type)
                '1';

    ALUSRC   <= '0' when OPCODE = B"0110011" else   -- add, slt, and, or, sub (r-type)
                '0' when OPCODE = B"1100011" else   -- beq (b-type)
                '1';

    MEMREAD  <= '1' when OPCODE = B"0000011" else   -- lw (I-type)
                '0';

    MEMWRITE <= '1' when OPCODE = B"0100011" else   -- sw (S-type)
                '0';

    MEMTOREG <= B"01" when OPCODE = B"0000011" else -- lw
                B"10" when OPCODE = B"1100111" else -- jalr
                B"10" when OPCODE = B"1101111" else -- jal
                B"00";
    BRANCH   <= '1' when OPCODE = B"1100011" else   -- beq
                '0';

    JUMP     <= '1' when OPCODE = B"1100111" else   -- jalr
                '1' when OPCODE = B"1101111" else   -- jal
                '0';

    JALRSRC  <= '1' when OPCODE = B"1100111" else   -- jalr, necessary to determine the jump source
                '0';

end architecture;





					  

	