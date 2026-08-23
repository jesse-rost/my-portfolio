-- **********************************************************************
-- Project :    RISC-V Single-cycle Processor
-- Filename:    scp.vhd
-- Author  :    Jesse Rost
-- Date    :    08/08/26
-- Provides:
--   - The structural top-level implementation of the single-cycle processor.
-- About   :
--   - Instantiates the PC, instruction ROM, immediate generator, control unit,
--     register file, ALU, and data memory used by the processor datapath.
--   - Decodes each instruction and routes operands through the ALU and memory
--     in one clock cycle, with support for arithmetic, loads, and stores.
--   - Selects sequential, branch, and jump addresses and routes ALU, memory,
--     or PC+4 results back to the register file for writeback.
-- Origin  :    Written from scratch.
-- **********************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RISC_SCP is
    port(CLK       : in std_logic;
          RST      : in std_logic;
          O_PC     : out std_logic_vector(31 downto 0);
          O_INSTR  : out std_logic_vector(31 downto 0);
          O_ALU    : out std_logic_vector(31 downto 0);
          O_WBDATA : out std_logic_vector(31 downto 0);
          O_REGWR  : out std_logic);
end entity RISC_SCP;

architecture STRUCTURAL of RISC_SCP is
    signal RD         : std_logic_vector(31 downto 0);
    signal ALU_RESULT : std_logic_vector(31 downto 0);
    signal INPUT_2    : std_logic_vector(31 downto 0);
    signal WB_DATA    : std_logic_vector(31 downto 0);
    signal TARGET     : std_logic_vector(31 downto 0);
    signal BRANCH_TAR : std_logic_vector(31 downto 0);
    signal JALR_TAR   : std_logic_vector(31 downto 0);
    signal PC_CURRENT : std_logic_vector(31 downto 0);
    signal PC_NEXT    : std_logic_vector(31 downto 0);
    signal INSTR      : std_logic_vector(31 downto 0);
    signal PC_PLUS4   : std_logic_vector(31 downto 0);
    signal IMMR       : std_logic_vector(31 downto 0);
    signal WD4        : std_logic_vector(31 downto 0);
    signal RD1        : std_logic_vector(31 downto 0);
    signal RD2        : std_logic_vector(31 downto 0);

    signal OPCODE     : std_logic_vector(6 downto 0);
    signal FUNCT7     : std_logic_vector(6 downto 0);

    signal A1         : std_logic_vector(4 downto 0);
    signal A2         : std_logic_vector(4 downto 0);
    signal A3         : std_logic_vector(4 downto 0);

    signal FUNCT3     : std_logic_vector(2 downto 0);
    signal ALUCONTROL : std_logic_vector(3 downto 0);
    signal MEMTOREG   : std_logic_vector(1 downto 0);

    signal REGWR      : std_logic;
    signal ALUSRC     : std_logic;
    signal MEMRD      : std_logic;
    signal MEMWR      : std_logic;
    signal BRANCH     : std_logic;
    signal JUMP       : std_logic;
    signal JALRSRC    : std_logic;
    signal ALU_FLAG   : std_logic;
    signal PCSRC      : std_logic;

begin

    O_PC     <= PC_CURRENT;
    O_INSTR  <= INSTR;
    O_ALU    <= ALU_RESULT;
    O_WBDATA <= WB_DATA;
    O_REGWR  <= REGWR;

    /***
    *** FETCH stage
    ***/
    PC_REG : entity work.REGN
        generic map (WIDTH => 32)
        port map(D => PC_NEXT, LD => '0', RST => RST, CLK => CLK, Q => PC_CURRENT);


    IMEM_INSTR : entity work.IROM -- goes to DECODE
        port map(ADDR => PC_CURRENT, Q => INSTR);

    PC_PLUS4 <= std_logic_vector(unsigned(PC_CURRENT) + 4);

    -- PC mux logic

    -- two possible targets
    JALR_TAR <= ALU_RESULT;
    BRANCH_TAR <= std_logic_vector(unsigned(PC_CURRENT) + unsigned(IMMR));

    -- pick which target (jalr uses the ALU, everything else uses PC+imm)
    TARGET <= JALR_TAR when JALRSRC = '1' else BRANCH_TAR;

    -- deide whether to use the target at all
    PCSRC <= JUMP or (BRANCH and ALU_FLAG);

    -- final PC mux
    PC_NEXT <= TARGET when PCSRC = '1' else PC_PLUS4;


-- decode stage

    IMM : entity work.IMM -- next use case within EXECUTE
        port map(INSTR => INSTR, IMMR => IMMR);

    -- assign variables to their corresponding bits within the instruction
    OPCODE <= INSTR(6 downto 0);
    FUNCT3 <= INSTR(14 downto 12);
    FUNCT7 <= INSTR(31 downto 25);

    CONTROL : entity work.CONTROL
        port map(OPCODE => OPCODE, FUNCT3 => FUNCT3, FUNCT7 => FUNCT7,
                 REGWR => REGWR, ALUSRC => ALUSRC, ALUCONTROL => ALUCONTROL,
                 MEMREAD => MEMRD, MEMWRITE => MEMWR, MEMTOREG => MEMTOREG,
                 BRANCH => BRANCH, JUMP => JUMP, JALRSRC => JALRSRC);

    -- assign variables to their corresponding bits within the instruction
    -- A1 = RS1
    -- A2 = RS2
    -- A3 = RD
    A1 <= INSTR(19 downto 15);
    A2 <= INSTR(24 downto 20);
    A3 <= INSTR(11 downto 7);

    REG_FILE : entity work.REGFILE -- RD1 : straight to ALU, RD2 : into mux with imm
        port map(A1 => A1, A2 => A2, A3 => A3, WD4 => WB_DATA, RST => RST,
                 RD1 => RD1, RD2 => RD2, CLK => CLK, REGWR => REGWR);

-- execute stage

    -- RD2 / imm mux
    INPUT_2 <= RD2 when ALUSRC = '0' else IMMR;

    ALU : entity work.ALU
        port map(S => ALUCONTROL, A => RD1, B => INPUT_2, F => ALU_RESULT, Z => ALU_FLAG);

-- memory / wb stage

    DMEM : entity work.DMEM
        port map(MEMWR => MEMWR, CLK => CLK, RST => RST, WD => RD2, A => ALU_RESULT, RD => RD);

    -- wb mux
    with MEMTOREG select -- goes into the regfile
        WB_DATA <= RD when B"01",
                   ALU_RESULT when B"00",
                   PC_PLUS4 when others;

end architecture STRUCTURAL;



