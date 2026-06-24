-- ***************************************************************************
-- Project:		CPE1510 Single-cycle Processor
-- Filename:	control.vhd
-- Author:		Jesse Rost
-- Date:			04/08/25
-- Provides:
-- - A control circuit for the ARMv4 ISA single-cycle processor.
-- - Use when-else to create equations for each signal.
-- ***************************************************************************
-- The following instructions must be implemented in all appropriate modes:
-- - Arithmetic: add, adds, cmp, cmn, rsb, rsbs, sub, subs
-- - Bitwise logic: and, ands, asl, asls, asr, asrs, bic, bics,
--                   eor, eors, lsl, lsls, lsr, lsrs, orr, ors
-- - Moves: mov, movs, mvn, mvns
-- - Load-store: ldr, str (offset indexing, + or - offset)
-- - Conditional branch: beq, bne
-- - Unconditional branch:bal, bl
-- ***************************************************************************
-- The following instructions are optional but make a more complete uproc
-- - Conditional branch: 		bge: pc <- braddr if 	not (N xor V)
-- - Conditional branch: 		blt: pc <- braddr if 	N xor V
-- - Conditional branch: 		bgt: pc <- braddr if 	not Z and not (N xor V)
-- - Conditional branch: 		ble: pc <- braddr if 	Z or (N xor V)
-- ***************************************************************************

-- use library packages
-- std_logic_1164: 9-valued logic signal voltages
library ieee;
use ieee.std_logic_1164.all;

-- functional block symbol
-- inputs
--    IBUS:	 	the 32-bit machine code instruction
--    C,V,N,Z:	the condition code flag signals from the CPSR
-- outputs
--    PCSEL:    0 = ground				1 = WD4 (for mov PC, LR)
--					2 = BRADDR				3 = PC+4
--    A3SEL:    0 = Rs					1 = Rd
--    ROTSEL:   0 = ROTATE field		1 = constant 0
--    SHAMTSEL:0 = SHAMT field		1 = R[RS] - lower five bits
--    SRC2SEL: 0 = SHIFTED RM	     	1 = immediate
--    REGWR:    0 = Regfile Write     1 = Regfile does not write
--    ALUSEL:   0 = AND             1 = EOR
--              2 = SUB             3 = RSB
--              4 = ADD             C = ORR
--              D = MOV/SHIFTS      E = BIC
--	            F = MVN
--    CSPRWR:   0 = sample CVNZ       1 = sample CNZ
--	            2 = sample NZ	     3 = hold, do not sample
--    MEMWR:    0 = Mem Write (STR)   1 = not an STR
--    MEMRD:    0 = Mem Read (LDR)    1 = not an LDR
--    WD4SEL:   0 = Data Mem Value    1 = ALU Value
--	            2 = PC+4 (BL)	     3 = ground
--    A4SEL:    0 = rd		         1 = constant 14: LR

entity CONTROL is
port(IBUS:      in  std_logic_vector(31 downto 0);
    C,V,N,Z:   in  std_logic;
    PCSEL:     out std_logic_vector(1 downto 0);
    A3SEL:     out std_logic;
    ROTSEL:    out std_logic;
    SHAMTSEL:  out std_logic;
    SRC2SEL:   out std_logic;
    REGWR:     out std_logic;
    ALUSEL:    out std_logic_vector(3 downto 0);
    CPSRWR:    out std_logic_vector(1 downto 0);
    MEMWR:     out std_logic;
    MEMRD:     out std_logic;
    WD4SEL:    out std_logic_vector(1 downto 0);
    A4SEL:		out std_logic);
end entity CONTROL;

-- circuit description
architecture DATAFLOW of CONTROL is
    -- declare signals for the IBUS bit fields
    -- data processing: fields used for implementing arithmetic
    signal COND : std_logic_vector(3 downto 0);
    signal OPCODE: std_logic_vector(1 downto 0);
    signal I: std_logic;
    signal CMD: std_logic_vector(3 downto 0);
    signal S: std_logic;
    -- load-store: fields used to implement load-store
    signal IBAR: std_logic;
    signal PUBWL: std_logic_vector(4 downto 0);
    signal L: std_logic;
    -- branch: fields used to help implement branches and MOV PC,LR
    signal BL: std_logic; -- the branch L bit is a different bit than memory L
    signal RD: std_logic_vector(3 downto 0); -- destination register
	signal RM: std_logic_vector(3 downto 0);
	signal BIT4: std_logic; -- convenience for writing equations

begin

    -- assign IBUS bits to internal signals
    COND <= IBUS(31 downto 28);
    OPCODE <= IBUS(27 downto 26);
    I <= IBUS(25);
    CMD <= IBUS(24 downto 21);
    S <= IBUS(20);
    IBAR <= IBUS(25);
    PUBWL <= IBUS(24 downto 20);
    L <= IBUS(20); -- memory instruction L bit
    BL <= IBUS(24); -- branch instruction L bit
    RD <= IBUS(15 downto 12); -- destination register
	 RM <= IBUS(3 downto 0);
	 BIT4 <= IBUS(4); -- convenience for writing equations

    -- write output equations using when-else syntax
	-- include rows from data processing, load-store, and branch truth tables
PCSEL <= B"10" when COND=X"1" and OPCODE=B"10" and BL='0' and Z='0' else -- bne taking branch
         B"10" when COND=X"0" and OPCODE=B"10" and BL='0' and Z='1' else -- beq taking branch
         B"10" when COND=X"E" and OPCODE=B"10" else -- branch always (bal)
         B"10" when COND=X"E" and OPCODE=B"10" and BL='1' else -- branch link (bl)
         B"01" when COND=X"E" and OPCODE=B"00" and CMD=X"D" and RD=X"F" else -- mov pc,lr
         B"11"; -- PC+4 for all other instructions
			
-- double checked

A3SEL <= '1' when OPCODE=B"01" else -- ldr/str
         '0'; -- all other instructions
			
-- double checked

ROTSEL <= '1' when OPCODE=B"00" and I = '0' and BIT4 = '0' else -- data processing immediate
			 '1' when OPCODE=B"00" and I = '0' and BIT4 = '1' else -- data processing shifted register
          '0'; -- all other instructions (no rotation for register or immediate without rotate)
			 
--double checked

SHAMTSEL <= '0' when OPCODE=B"00" and I = '0' else -- data processing immediate has shift amount in instruction
            '1' when OPCODE=B"00" and I = '0' and BIT4 = '1' else -- data processing register shift uses Rm
            '0'; -- default
				
-- double checked

SRC2SEL <= '1' when OPCODE=B"00" and I = '1' else -- data processing immediate
           '0' when OPCODE=B"00" and I = '0' else -- data processing register
           '0' when OPCODE=B"01" and IBAR = '1' else -- ldr/str 
           '1'; -- default, branch instructions are all dc
			  
-- double checked 

REGWR <= '0' when OPCODE=B"00" and S = '0' and CMD /= X"A" and CMD /= X"B" else -- data processing without setting flags (not cmp/cmn)
         '0' when OPCODE=B"01" and L = '1' else -- ldr
			'0' when OPCODE=B"10" and BL = '1' else
         '1'; -- all others (str, branches, cmp/cmn, etc.)
			
-- double checked

ALUSEL <= CMD when OPCODE=B"00" else -- data processing uses CMD field for ALU operation
          X"4" when OPCODE=B"01" and PUBWL(2) = '1' else -- ldr (add offset to base)
          X"2" when OPCODE=B"01" and PUBWL(2) = '0' else -- str (add offset to base)
          X"D"; -- default (rest dont matter)
			 
-- double checked

CPSRWR <= B"00" when OPCODE=B"00" and S = '1' and CMD = X"2" else 
			 B"00" when OPCODE=B"00" and S = '1' and CMD = X"4" else
			 B"00" when OPCODE=B"00" and S = '1' and CMD = X"A" else 
			 B"00" when OPCODE=B"00" and S = '1' and CMD = X"B" else
		    B"01" when OPCODE=B"00" and S = '1' and CMD = X"0" else -- data processing setting flags (not cmp/cmn)
			 B"01" when OPCODE=B"00" and S = '1' and CMD = X"D" else -- data processing setting flags (not cmp/cmn)
		    B"01" when OPCODE=B"00" and S = '1' and CMD = X"E" else -- data processing setting flags (not cmp/cmn)
		    B"01" when OPCODE=B"00" and S = '1' and CMD = X"1" else -- data processing setting flags (not cmp/cmn)
		    B"01" when OPCODE=B"00" and S = '1' and CMD = X"C" else -- data processing setting flags (not cmp/cmn)
          B"11"; -- hold for all other instructions

MEMWR <= '0' when OPCODE=B"01" and L = '0' else -- str
         '1'; -- all other instructions
			
-- double checked

MEMRD <= '0' when OPCODE=B"01" and L = '1' else -- ldr
         '1'; -- all other instructions
			
-- double checked

WD4SEL <= B"01" when OPCODE=B"00" else -- data processing result
			 B"10" when OPCODE=B"10" and BL = '1' else -- branch only cares when linking
          B"00"; -- default
			 
-- double checked

A4SEL <= '1' when OPCODE=B"10" and BL = '1' else -- branch needs 1 when linking
			'0'; -- default

-- good unless, we need to do bl

end architecture DATAFLOW;