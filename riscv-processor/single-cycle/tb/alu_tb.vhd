-- **********************************************************************
-- Project :    RISC-V Single-cycle Processor
-- Filename:    alu_tb.vhd
-- Author  :    Jesse Rost
-- Date    :    08/08/26
-- Provides:
--   - A testbench for the ALU implementation.
-- Origin  :    Written from scratch.
-- **********************************************************************

library ieee;
use ieee.std_logic_1164.all;


-- function block symbol
entity tb_alu is

end entity tb_alu;


-- action block symbol
architecture test of tb_alu is
    signal A : std_logic_vector(31 downto 0);
    signal B : std_logic_vector(31 downto 0);
    signal F : std_logic_vector(31 downto 0);
    signal S : std_logic_vector(3 downto 0);
    signal Z : std_logic := '0';
begin
    dut : entity work.ALU
        port map (A => A, B => B, F => F, S => S, Z => Z);

    process
    begin
        -- test 1 : basic arithmetic
        
        A <= X"0000000A";
        B <= X"00000005";
        S <= B"0000";        -- add
        wait for 10 ns;
        assert F = X"0000000F"
            report "ADD test failed" severity error;

        wait for 10 ns;

        A <= X"0000000A";
        B <= X"00000005";
        S <= B"0001";        -- sub
        wait for 10 ns;
        assert F = X"00000005"
            report "SUB test failed" severity error;

        wait for 10 ns;


        -- test 2 : logic operators
        A <= X"FF00FF00";
        B <= X"0F0F0F0F";
        S <= B"0010";        -- and
        wait for 10 ns;
        assert F = X"0F000F00"
            report "AND test failed" severity error;

        wait for 10 ns;

        A <= X"FF00FF00";
        B <= X"0F0F0F0F";
        S <= B"0011";        -- or
        wait for 10 ns;
        assert F = X"FF0FFF0F"
            report "OR test failed" severity error;

        wait for 10 ns;

        A <= X"00000001";
        B <= X"00000000";
        S <= B"0100";        -- slt
        wait for 10 ns;
        assert F = X"00000000"
            report "SLT test failed" severity error;


        report "tb_alu complete";
        wait;

    end process;
end architecture test;


