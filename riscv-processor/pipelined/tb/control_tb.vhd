-- **********************************************************************
-- Project :    RISC-V Pipelined Processor
-- Filename:    control_tb.vhd
-- Author  :    Jesse Rost
-- Date    :    08/22/26
-- Provides:
--   - A testbench for the control unit implementation.
-- Origin  :    Written from scratch.
-- **********************************************************************

library ieee;
use ieee.std_logic_1164.all;

entity tb_control is

end entity tb_control;


architecture DATAPATH of tb_control is

    signal OPCODE     : std_logic_vector(6 downto 0);
    signal FUNCT3     : std_logic_vector(2 downto 0);
    signal FUNCT7     : std_logic_vector(6 downto 0);
    signal REGWR      : std_logic;
    signal ALUSRC     : std_logic;
    signal ALUCONTROL : std_logic_vector(3 downto 0);
    signal MEMREAD    : std_logic;
    signal MEMWRITE   : std_logic;
    signal MEMTOREG   : std_logic_vector(1 downto 0);
    signal BRANCH     : std_logic;
    signal JUMP       : std_logic;
    signal JALRSRC    : std_logic;

begin
    dut : entity work.CONTROL
        port map(OPCODE => OPCODE, FUNCT3 => FUNCT3, FUNCT7 => FUNCT7,
                    REGWR => REGWR, ALUSRC => ALUSRC, ALUCONTROL => ALUCONTROL,
                    MEMREAD => MEMREAD, MEMWRITE => MEMWRITE, MEMTOREG => MEMTOREG,
                    BRANCH => BRANCH, JUMP => JUMP, JALRSRC => JALRSRC);

    process
    begin

        -- test 1 : ADD

        FUNCT3 <= B"000";
        FUNCT7 <= B"0000000";
        OPCODE <= B"0110011";

        wait for 10 ns;

        assert ALUCONTROL = B"0000"  and REGWRITE = '1' and
                 ALUSRC = '0' and MEMREAD = '0'and MEMREAD = '0' and
                 MEMWRITE = '0' and MEMTOREG = B"00"  and BRANCH = '0' and
                 JUMP = '0' and JALRSRC = '0'
            report("ADD instruction failed");


        wait for 10 ns;

        -- test 2 : lw

        FUNCT3 <= B"010";
        OPCODE <= B"0000011";

        wait for 10 ns;

        assert ALUCONTROL = B"0000"  and REGWRITE = '1' and
                 ALUSRC = '1' and MEMREAD = '1' and
                 MEMWRITE = '0' and MEMTOREG = B"01" and BRANCH = '0' and
                 JUMP = '0' and JALRSRC = '0'
            report("load instruction failed");

                wait for 10 ns;

        -- test 4 : sub

        FUNCT3 <= B"000";
        FUNCT7 <= B"0100000";
        OPCODE <= B"0110011";

        wait for 10 ns;

        assert ALUCONTROL = B"0001"  and REGWRITE = '1' and
                 ALUSRC = '0' and MEMREAD = '0' and
                 MEMWRITE = '0' and MEMTOREG = B"00" and BRANCH = '0' and
                 JUMP = '0' and JALRSRC = '0'
            report("sub instruction failed");

        wait for 10 ns;

        -- test 5 : addi

        FUNCT3 <= B"000";
        OPCODE <= B"0010011";

        wait for 10 ns;

        assert ALUCONTROL = B"0000"  and REGWRITE = '1' and
                 ALUSRC = '1' and MEMREAD = '0' and
                 MEMWRITE = '0' and MEMTOREG = B"00" and BRANCH = '0' and
                 JUMP = '0' and JALRSRC = '0'
            report("addi instruction failed");

        wait for 10 ns;

        -- test 6 : sw

        FUNCT3 <= B"010";
        OPCODE <= B"0100011";

        wait for 10 ns;

        assert ALUCONTROL = B"0000"  and REGWRITE = '0' and
                 ALUSRC = '1' and MEMREAD = '0' and
                 MEMWRITE = '1' and MEMTOREG = B"00" and BRANCH = '0' and
                 JUMP = '0' and JALRSRC = '0'
            report("store instruction failed");

        wait for 10 ns;

        -- test 7 : branch

        FUNCT3 <= B"000";
        OPCODE <= B"1100011";

        wait for 10 ns;

        assert ALUCONTROL = B"0001"  and REGWRITE = '0' and
                 ALUSRC = '0' and MEMREAD = '0' and
                 MEMWRITE = '0' and MEMTOREG = B"00" and BRANCH = '1' and
                 JUMP = '0' and JALRSRC = '0'
            report("branch instruction failed");


        -- test 8 : jump

        OPCODE <= B"1101111";

        wait for 10 ns;

        assert ALUCONTROL = B"0000"  and REGWRITE = '1' and
                 ALUSRC = '1' and MEMREAD = '0' and
                 MEMWRITE = '0' and MEMTOREG = B"10" and BRANCH = '0' and
                 JUMP = '1' and JALRSRC = '0'
            report("jump instruction failed");

        wait for 10 ns;

        -- test 9 : jalr

        FUNCT3 <= B"000";
        OPCODE <= B"1100111";

        wait for 10 ns;

        assert ALUCONTROL = B"0000"  and REGWRITE = '1' and
                 ALUSRC = '1' and MEMREAD = '0' and
                 MEMWRITE = '0' and MEMTOREG = B"10" and BRANCH = '0' and
                 JUMP = '1' and JALRSRC = '1'
            report("jalr instruction failed");


        wait for 10 ns;

        -- test 10 : lui

        OPCODE <= B"0110111";

        wait for 10 ns;

        assert ALUCONTROL = B"0000" and REGWRITE = '1' and
                 ALUSRC = '1' and MEMREAD = '0' and
                 MEMWRITE = '0' and MEMTOREG = B"00" and BRANCH = '0' and
                 JUMP = '0' and JALRSRC = '0'
            report("lui instruction failed");

        wait for 10 ns;

        -- test 11 : and

        FUNCT3 <= B"111";
        FUNCT7 <= B"0000000";
        OPCODE <= B"0110011";

        wait for 10 ns;

        assert ALUCONTROL = B"0010" and REGWRITE = '1' and
                 ALUSRC = '0' and MEMREAD = '0' and
                 MEMWRITE = '0' and MEMTOREG = B"00" and BRANCH = '0' and
                 JUMP = '0' and JALRSRC = '0'
            report("and instruction failed");

        wait for 10 ns;

        -- test 12 : or

        FUNCT3 <= B"110";
        FUNCT7 <= B"0000000";
        OPCODE <= B"0110011";

        wait for 10 ns;

        assert ALUCONTROL = B"0011" and REGWRITE = '1' and
                 ALUSRC = '0' and MEMREAD = '0' and
                 MEMWRITE = '0' and MEMTOREG = B"00" and BRANCH = '0' and
                 JUMP = '0' and JALRSRC = '0'
            report("or instruction failed");

        wait for 10 ns;

        -- test 13 : slt

        FUNCT3 <= B"010";
        FUNCT7 <= B"0000000";
        OPCODE <= B"0110011";

        wait for 10 ns;

        assert ALUCONTROL = B"0100" and REGWRITE = '1' and
                 ALUSRC = '0' and MEMREAD = '0' and
                 MEMWRITE = '0' and MEMTOREG = B"00" and BRANCH = '0' and
                 JUMP = '0' and JALRSRC = '0'
            report("slt instruction failed");

        report("tb_control complete");
        wait;

    end process;

end architecture DATAPATH;
