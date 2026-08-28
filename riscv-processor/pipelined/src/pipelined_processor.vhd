-- **********************************************************************
-- Project :    RISC-V Pipelined Processor
-- Filename:    pipelined_processor.vhd
-- Author  :    Jesse Rost
-- Date    :    08/22/26
-- Provides:
--   - The structural top-level implementation of the pipelined processor.
-- Origin  :    Written from scratch.
-- **********************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity RISC_PIPELINED is
    port( CLK       : in std_logic;
          RST       : in std_logic;
		  O_PC     	: out std_logic_vector(31 downto 0);
          O_WBDATA 	: out std_logic_vector(31 downto 0));

end entity RISC_PIPELINED;

architecture STRUCTURAL of RISC_PIPELINED is
    signal RD              : std_logic_vector(31 downto 0);
    signal ALU_RESULT      : std_logic_vector(31 downto 0);
    signal WB_DATA         : std_logic_vector(31 downto 0);
    signal TARGET          : std_logic_vector(31 downto 0);
    signal BRANCH_TAR      : std_logic_vector(31 downto 0);
    signal JALR_TAR        : std_logic_vector(31 downto 0);
    signal PC_CURRENT      : std_logic_vector(31 downto 0);
    signal PC_NEXT         : std_logic_vector(31 downto 0);
    signal INSTR           : std_logic_vector(31 downto 0);
    signal PC_PLUS4        : std_logic_vector(31 downto 0);
    signal IMMR            : std_logic_vector(31 downto 0);
    signal RD1             : std_logic_vector(31 downto 0);
    signal RD2             : std_logic_vector(31 downto 0);
    signal ALU_A           : std_logic_vector(31 downto 0);
    signal ALU_B           : std_logic_vector(31 downto 0);
    signal OPCODE          : std_logic_vector(6 downto 0);
    signal FUNCT7          : std_logic_vector(6 downto 0);
    signal A1              : std_logic_vector(4 downto 0);
    signal A2              : std_logic_vector(4 downto 0);
    signal A3              : std_logic_vector(4 downto 0);
    signal FUNCT3          : std_logic_vector(2 downto 0);
    signal ALUCONTROL      : std_logic_vector(3 downto 0);
    signal MEMTOREG        : std_logic_vector(1 downto 0);
    signal REGWR           : std_logic;
    signal ALUSRC          : std_logic;
    signal MEMRD           : std_logic;
    signal MEMWR           : std_logic;
    signal BRANCH          : std_logic;
    signal JUMP            : std_logic;
    signal JALRSRC         : std_logic;
    signal ALU_FLAG        : std_logic;
    signal PCSRC           : std_logic;
    signal STALL           : std_logic;

    -- IF_ID
    signal IFID_INST       : std_logic_vector(31 downto 0);
    signal IFID_PC_PLUS4   : std_logic_vector(31 downto 0);
    signal IFID_PC_CURRENT : std_logic_vector(31 downto 0);

    -- ID_EX
    signal IDEX_PC_PLUS4   : std_logic_vector(31 downto 0);
    signal IDEX_RD1        : std_logic_vector(31 downto 0);
    signal IDEX_RD2        : std_logic_vector(31 downto 0);
    signal FWD_RD2         : std_logic_vector(31 downto 0);
    signal IDEX_IMMR       : std_logic_vector(31 downto 0);
    signal IDEX_BRANCH_TAR : std_logic_vector(31 downto 0);
    signal IDEX_INSTR      : std_logic_vector(31 downto 0);
    signal IDEX_RS1_ADDR   : std_logic_vector(4 downto 0);
    signal IDEX_RS2_ADDR   : std_logic_vector(4 downto 0);
    signal IDEX_RD_ADDR    : std_logic_vector(4 downto 0);
    signal IDEX_ALUCONTROL : std_logic_vector(3 downto 0);
    signal IDEX_MEMTOREG   : std_logic_vector(1 downto 0);
    signal IDEX_BRANCH     : std_logic;
    signal IDEX_JUMP       : std_logic;
    signal IDEX_JALRSRC    : std_logic;
    signal IDEX_ALUSRC     : std_logic;
    signal IDEX_MEMWR      : std_logic;
    signal IDEX_REGWR      : std_logic;
    signal IDEX_MEMRD      : std_logic;

    -- EX_MEM
    signal EXMEM_ALU_RESULT : std_logic_vector(31 downto 0);
    signal EXMEM_RD2        : std_logic_vector(31 downto 0);
    signal EXMEM_PC_PLUS4   : std_logic_vector(31 downto 0);
    signal EXMEM_RD_ADDR    : std_logic_vector(4 downto 0);
    signal EXMEM_MEMTOREG   : std_logic_vector(1 downto 0);
    signal EXMEM_MEMWR      : std_logic;
    signal EXMEM_REGWR      : std_logic;

    -- MEM_WB
    signal MEMWB_ALU_RESULT : std_logic_vector(31 downto 0);
    signal MEMWB_RD         : std_logic_vector(31 downto 0);
    signal MEMWB_PC_PLUS4   : std_logic_vector(31 downto 0);
    signal MEMWB_RD_ADDR    : std_logic_vector(4 downto 0);
    signal MEMWB_MEMTOREG   : std_logic_vector(1 downto 0);
    signal MEMWB_REGWR      : std_logic;

begin

	 O_PC     <= PC_CURRENT;
	 O_WBDATA <= WB_DATA;

    -- ================= FETCH =================

    PC_REG : entity work.REGN
        generic map (WIDTH => 32)
        port map(D => PC_NEXT, LD => STALL, RST => RST, CLK => CLK, Q => PC_CURRENT);

    IMEM_INSTR : entity work.IROM
        port map(ADDR => PC_CURRENT, Q => INSTR);

    PC_PLUS4 <= std_logic_vector(unsigned(PC_CURRENT) + 4);

    IF_ID : process(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '0' or PCSRC = '1' then
                IFID_INST       <= (others => '0');
                IFID_PC_PLUS4   <= (others => '0');
                IFID_PC_CURRENT <= (others => '0');
            elsif STALL = '0' then
                IFID_INST       <= INSTR;
                IFID_PC_PLUS4   <= PC_PLUS4;
                IFID_PC_CURRENT <= PC_CURRENT;
            end if;
        end if;
    end process;

    -- ================= DECODE =================

    IMM : entity work.IMM
        port map(INSTR => IFID_INST, IMMR => IMMR);

    OPCODE <= IFID_INST(6 downto 0);
    FUNCT3 <= IFID_INST(14 downto 12);
    FUNCT7 <= IFID_INST(31 downto 25);

    CONTROL : entity work.CONTROL
        port map(OPCODE => OPCODE, FUNCT3 => FUNCT3, FUNCT7 => FUNCT7,
                 REGWR => REGWR, ALUSRC => ALUSRC, ALUCONTROL => ALUCONTROL,
                 MEMREAD => MEMRD, MEMWRITE => MEMWR, MEMTOREG => MEMTOREG,
                 BRANCH => BRANCH, JUMP => JUMP, JALRSRC => JALRSRC);

    BRANCH_TAR <= std_logic_vector(unsigned(IFID_PC_CURRENT) + unsigned(IMMR));

    A1 <= IFID_INST(19 downto 15);
    A2 <= IFID_INST(24 downto 20);
    A3 <= IFID_INST(11 downto 7);

    STALL <= '1' when (IDEX_MEMRD = '1' and IDEX_RD_ADDR /= B"00000"
                 and (IDEX_RD_ADDR = A1 or IDEX_RD_ADDR = A2)) else '0';

    REG_FILE : entity work.REGFILE
        port map(A1 => A1, A2 => A2, A3 => MEMWB_RD_ADDR, WD4 => WB_DATA, RST => RST,
                 RD1 => RD1, RD2 => RD2, CLK => CLK, REGWR => MEMWB_REGWR);

    ID_EX : process(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '0' or STALL = '1' or PCSRC = '1' then
                IDEX_RS1_ADDR   <= (others => '0');
                IDEX_RS2_ADDR   <= (others => '0');
                IDEX_BRANCH_TAR <= (others => '0');
                IDEX_IMMR       <= (others => '0');
                IDEX_ALUCONTROL <= (others => '0');
                IDEX_RD1        <= (others => '0');
                IDEX_RD2        <= (others => '0');
                IDEX_MEMTOREG   <= (others => '0');
                IDEX_PC_PLUS4   <= (others => '0');
                IDEX_RD_ADDR    <= (others => '0');
                IDEX_INSTR      <= (others => '0');
                IDEX_BRANCH     <= '0';
                IDEX_JUMP       <= '0';
                IDEX_JALRSRC    <= '0';
                IDEX_ALUSRC     <= '0';
                IDEX_MEMWR      <= '0';
                IDEX_REGWR      <= '0';
                IDEX_MEMRD      <= '0';
            else
                IDEX_BRANCH     <= BRANCH;
                IDEX_JUMP       <= JUMP;
                IDEX_JALRSRC    <= JALRSRC;
                IDEX_BRANCH_TAR <= BRANCH_TAR;
                IDEX_ALUSRC     <= ALUSRC;
                IDEX_IMMR       <= IMMR;
                IDEX_ALUCONTROL <= ALUCONTROL;
                IDEX_RD1        <= RD1;
                IDEX_RD2        <= RD2;
                IDEX_MEMWR      <= MEMWR;
                IDEX_MEMTOREG   <= MEMTOREG;
                IDEX_PC_PLUS4   <= IFID_PC_PLUS4;
                IDEX_RD_ADDR    <= A3;
                IDEX_REGWR      <= REGWR;
                IDEX_RS1_ADDR   <= A1;
                IDEX_RS2_ADDR   <= A2;
                IDEX_MEMRD      <= MEMRD;
                IDEX_INSTR      <= IFID_INST;
            end if;
        end if;
    end process;

    -- ================= EXECUTE =================

    ALU_A <= EXMEM_ALU_RESULT when (EXMEM_REGWR = '1'
                              and EXMEM_RD_ADDR /= "00000"
                              and EXMEM_RD_ADDR = IDEX_RS1_ADDR) else
             WB_DATA when (MEMWB_REGWR = '1'
                     and MEMWB_RD_ADDR /= "00000"
                     and MEMWB_RD_ADDR = IDEX_RS1_ADDR) else
             IDEX_RD1;

    FWD_RD2 <= EXMEM_ALU_RESULT when (EXMEM_REGWR = '1'
                                and EXMEM_RD_ADDR /= "00000"
                                and EXMEM_RD_ADDR = IDEX_RS2_ADDR) else
               WB_DATA when (MEMWB_REGWR = '1'
                       and MEMWB_RD_ADDR /= "00000"
                       and MEMWB_RD_ADDR = IDEX_RS2_ADDR) else
               IDEX_RD2;

    ALU_B <= FWD_RD2 when IDEX_ALUSRC = '0' else IDEX_IMMR;

    ALU : entity work.ALU
        port map(S => IDEX_ALUCONTROL, A => ALU_A, B => ALU_B,
                 F => ALU_RESULT, Z => ALU_FLAG);

    JALR_TAR <= ALU_RESULT;
    TARGET   <= JALR_TAR when IDEX_JALRSRC = '1' else IDEX_BRANCH_TAR;
    PCSRC    <= IDEX_JUMP or (IDEX_BRANCH and ALU_FLAG);
    PC_NEXT  <= TARGET when PCSRC = '1' else PC_PLUS4;

    EX_MEM : process(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '0' then
                EXMEM_MEMTOREG   <= (others => '0');
                EXMEM_ALU_RESULT <= (others => '0');
                EXMEM_RD2        <= (others => '0');
                EXMEM_PC_PLUS4   <= (others => '0');
                EXMEM_RD_ADDR    <= (others => '0');
                EXMEM_MEMWR      <= '0';
                EXMEM_REGWR      <= '0';
            else
                EXMEM_MEMTOREG   <= IDEX_MEMTOREG;
                EXMEM_ALU_RESULT <= ALU_RESULT;
                EXMEM_RD2        <= FWD_RD2;
                EXMEM_PC_PLUS4   <= IDEX_PC_PLUS4;
                EXMEM_RD_ADDR    <= IDEX_RD_ADDR;
                EXMEM_MEMWR      <= IDEX_MEMWR;
                EXMEM_REGWR      <= IDEX_REGWR;
            end if;
        end if;
    end process;

    -- ================= MEMORY =================

    DMEM : entity work.DMEM
        port map(MEMWR => EXMEM_MEMWR, CLK => CLK, RST => RST,
                 WD => EXMEM_RD2, A => EXMEM_ALU_RESULT, RD => RD);

    MEM_WB : process(CLK)
    begin
        if rising_edge(CLK) then
            if RST = '0' then
                MEMWB_MEMTOREG   <= (others => '0');
                MEMWB_ALU_RESULT <= (others => '0');
                MEMWB_RD         <= (others => '0');
                MEMWB_PC_PLUS4   <= (others => '0');
                MEMWB_RD_ADDR    <= (others => '0');
                MEMWB_REGWR      <= '0';
            else
                MEMWB_MEMTOREG   <= EXMEM_MEMTOREG;
                MEMWB_ALU_RESULT <= EXMEM_ALU_RESULT;
                MEMWB_RD         <= RD;
                MEMWB_PC_PLUS4   <= EXMEM_PC_PLUS4;
                MEMWB_RD_ADDR    <= EXMEM_RD_ADDR;
                MEMWB_REGWR      <= EXMEM_REGWR;
            end if;
        end if;
    end process;

    -- ================= WRITEBACK =================

    with MEMWB_MEMTOREG select
        WB_DATA <= MEMWB_ALU_RESULT when B"00",
                   MEMWB_RD         when B"01",
                   MEMWB_PC_PLUS4   when others;

end architecture STRUCTURAL;