-- **********************************************************************
-- Project :    RISC-V Single-cycle Processor
-- Filename:    regfile.vhd
-- Author  :    Jesse Rost
-- Date    :    08/08/26
-- Provides:
--   - A 32-item register file with two simultaneous read ports.
--   - Addresses A1 and A2 select read values; A3 selects the write register.
-- Origin  :    Altered from ARM project.
-- **********************************************************************

library ieee;
use ieee.std_logic_1164.all;

-- function block symbol
-- inputs:
--     A1,A2 : 5-bit addresses specifying output registers RD1 and RD2
--     A3    : 5-bit address specifying register to write WD4 data into
--     WD4   : 32-bit data to be stored in register addressed by A3
--     REGWR : control signal to determine if input WD4 data gets stored
--     RST   : active-low synchronous reset signal
--     CLK   : clock for synchronized register behavior
-- outputs:
--     RD1   : 32-bit output from register specified by address A1
--     RD2   : 32-bit output from register specified by address A2

entity REGFILE is
port(WD4   : in std_logic_vector(31 downto 0);
     A1    : in std_logic_vector(4 downto 0);
     A2    : in std_logic_vector(4 downto 0);
     A3    : in std_logic_vector(4 downto 0);
     REGWR : in std_logic;
     RST   : in std_logic;
     CLK   : in std_logic;
     RD1   : out std_logic_vector(31 downto 0);
     RD2   : out std_logic_vector(31 downto 0));
end entity REGFILE;

-- circuit description
architecture BEHAVIORAL of REGFILE is
    -- declare 32 internal signals that will become register outputs
    signal X0  : std_logic_vector(31 downto 0);
    signal X1  : std_logic_vector(31 downto 0);
    signal X2  : std_logic_vector(31 downto 0);
    signal X3  : std_logic_vector(31 downto 0);
    signal X4  : std_logic_vector(31 downto 0);
    signal X5  : std_logic_vector(31 downto 0);
    signal X6  : std_logic_vector(31 downto 0);
    signal X7  : std_logic_vector(31 downto 0);
    signal X8  : std_logic_vector(31 downto 0);
    signal X9  : std_logic_vector(31 downto 0);
    signal X10 : std_logic_vector(31 downto 0);
    signal X11 : std_logic_vector(31 downto 0);
    signal X12 : std_logic_vector(31 downto 0);
    signal X13 : std_logic_vector(31 downto 0);
    signal X14 : std_logic_vector(31 downto 0);
    signal X15 : std_logic_vector(31 downto 0);
    signal X16 : std_logic_vector(31 downto 0);
    signal X17 : std_logic_vector(31 downto 0);
    signal X18 : std_logic_vector(31 downto 0);
    signal X19 : std_logic_vector(31 downto 0);
    signal X20 : std_logic_vector(31 downto 0);
    signal X21 : std_logic_vector(31 downto 0);
    signal X22 : std_logic_vector(31 downto 0);
    signal X23 : std_logic_vector(31 downto 0);
    signal X24 : std_logic_vector(31 downto 0);
    signal X25 : std_logic_vector(31 downto 0);
    signal X26 : std_logic_vector(31 downto 0);
    signal X27 : std_logic_vector(31 downto 0);
    signal X28 : std_logic_vector(31 downto 0);
    signal X29 : std_logic_vector(31 downto 0);
    signal X30 : std_logic_vector(31 downto 0);
    signal X31 : std_logic_vector(31 downto 0);


begin
    -- use A1 and A2 to control two multiplexers choosing outputs RD1 and RD2
    with A1 select
    RD1 <= X0  when B"00000",
           X1  when B"00001",
           X2  when B"00010",
           X3  when B"00011",
           X4  when B"00100",
           X5  when B"00101",
           X6  when B"00110",
           X7  when B"00111",
           X8  when B"01000",
           X9  when B"01001",
           X10 when B"01010",
           X11 when B"01011",
           X12 when B"01100",
           X13 when B"01101",
           X14 when B"01110",
           X15 when B"01111",
           x16 when B"10000",
           X17 when B"10001",
           X18 when B"10010",
           X19 when B"10011",
           X20 when B"10100",
           X21 when B"10101",
           X22 when B"10110",
           X23 when B"10111",
           X24 when B"11000",
           X25 when B"11001",
           X26 when B"11010",
           X27 when B"11011",
           X28 when B"11100",
           X29 when B"11101",
           X30 when B"11110",
           X31 when others;

    with A2 select
    RD2 <= X0  when B"00000",
           X1  when B"00001",
           X2  when B"00010",
           X3  when B"00011",
           X4  when B"00100",
           X5  when B"00101",
           X6  when B"00110",
           X7  when B"00111",
           X8  when B"01000",
           X9  when B"01001",
           X10 when B"01010",
           X11 when B"01011",
           X12 when B"01100",
           X13 when B"01101",
           X14 when B"01110",
           X15 when B"01111",
           x16 when B"10000",
           X17 when B"10001",
           X18 when B"10010",
           X19 when B"10011",
           X20 when B"10100",
           X21 when B"10101",
           X22 when B"10110",
           X23 when B"10111",
           X24 when B"11000",
           X25 when B"11001",
           X26 when B"11010",
           X27 when B"11011",
           X28 when B"11100",
           X29 when B"11101",
           X30 when B"11110",
           X31 when others;

-- implement thirty two registers with active-low synchronous reset
-- and active-high synchronous load
reg0: process(rst,clk)
begin
    if rising_edge(clk) then
        -- we don't write data to x0, its hardcoded to 0.
        X0 <= X"00000000";
    end if;
end process;

reg1: process(rst,clk)
begin
    if rising_edge(clk) then
        if RST = '0' then X1 <= X"00000000";
        elsif REGWR = '1' then
            if A3 = B"00001" then X1 <= WD4;
            end if;
        end if;
    end if;
end process;

reg2: process(rst,clk)
begin
    if rising_edge(clk) then
        if RST = '0' then X2 <= X"00000000";
        elsif REGWR = '1' then
            if A3 = B"00010" then X2 <= WD4;
            end if;
        end if;
    end if;
end process;

reg3: process(rst,clk)
begin
    if rising_edge(clk) then
        if RST = '0' then X3 <= X"00000000";
        elsif REGWR = '1' then
            if A3 = B"00011" then X3 <= WD4;
            end if;
        end if;
    end if;
end process;

reg4: process(rst,clk)
begin
    if rising_edge(clk) then
        if RST = '0' then X4 <= X"00000000";
        elsif REGWR = '1' then
            if A3 = B"00100" then X4 <= WD4;
            end if;
        end if;
    end if;
end process;

reg5: process(rst,clk)
begin
    if rising_edge(clk) then
        if RST = '0' then X5 <= X"00000000";
        elsif REGWR = '1' then
            if A3 = B"00101" then X5 <= WD4;
            end if;
        end if;
    end if;
end process;

reg6: process(rst,clk)
begin
    if rising_edge(clk) then
        if RST = '0' then X6 <= X"00000000";
        elsif REGWR = '1' then
            if A3 = B"00110" then X6 <= WD4;
            end if;
        end if;
    end if;
end process;

reg7: process(rst,clk)
begin
    if rising_edge(clk) then
        if RST = '0' then X7 <= X"00000000";
        elsif REGWR = '1' then
            if A3 = B"00111" then X7 <= WD4;
            end if;
        end if;
    end if;
end process;

reg8: process(rst,clk)
begin
    if rising_edge(clk) then
        if RST = '0' then X8 <= X"00000000";
        elsif REGWR = '1' then
            if A3 = B"01000" then X8 <= WD4;
            end if;
        end if;
    end if;
end process;

reg9: process(rst,clk)
begin
    if rising_edge(clk) then
        if RST = '0' then X9 <= X"00000000";
        elsif REGWR = '1' then
            if A3 = B"01001" then X9 <= WD4;
            end if;
        end if;
    end if;
end process;

reg10: process(rst,clk)
begin
    if rising_edge(clk) then
        if RST = '0' then X10 <= X"00000000";
        elsif REGWR = '1' then
            if A3 = B"01010" then X10 <= WD4;
            end if;
        end if;
    end if;
end process;

reg11: process(rst,clk)
begin
    if rising_edge(clk) then
        if RST = '0' then X11 <= X"00000000";
        elsif REGWR = '1' then
            if A3 = B"01011" then X11 <= WD4;
            end if;
        end if;
    end if;
end process;

reg12: process(rst,clk)
begin
    if rising_edge(clk) then
        if RST = '0' then X12 <= X"00000000";
        elsif REGWR = '1' then
            if A3 = B"01100" then X12 <= WD4;
            end if;
        end if;
    end if;
end process;

reg13: process(rst,clk)
begin
    if rising_edge(clk) then
        if RST = '0' then X13 <= X"00000000";
        elsif REGWR = '1' then
            if A3 = B"01101" then X13 <= WD4;
            end if;
        end if;
    end if;
end process;

reg14: process(rst,clk)
begin
    if rising_edge(clk) then
        if RST = '0' then X14 <= X"00000000";
        elsif REGWR = '1' then
            if A3 = B"01110" then X14 <= WD4;
            end if;
        end if;
    end if;
end process;

reg15: process(rst,clk)
begin
    if rising_edge(clk) then
        if RST = '0' then X15 <= X"00000000";
        elsif REGWR = '1' then
            if A3 = B"01111" then X15 <= WD4;
            end if;
        end if;
    end if;
end process;


reg16: process(rst,clk)
begin
    if rising_edge(clk) then
        if RST = '0' then X16 <= X"00000000";
        elsif REGWR = '1' then
            if A3 = B"10000" then X16 <= WD4;
            end if;
        end if;
    end if;
end process;

reg17: process(rst,clk)
begin
    if rising_edge(clk) then
        if RST = '0' then X17 <= X"00000000";
        elsif REGWR = '1' then
            if A3 = B"10001" then X17 <= WD4;
            end if;
        end if;
    end if;
end process;

reg18: process(rst,clk)
begin
    if rising_edge(clk) then
        if RST = '0' then X18 <= X"00000000";
        elsif REGWR = '1' then
            if A3 = B"10010" then X18 <= WD4;
            end if;
        end if;
    end if;
end process;

reg19: process(rst,clk)
begin
    if rising_edge(clk) then
        if RST = '0' then X19 <= X"00000000";
        elsif REGWR = '1' then
            if A3 = B"10011" then X19 <= WD4;
            end if;
        end if;
    end if;
end process;

reg20: process(rst,clk)
begin
    if rising_edge(clk) then
        if RST = '0' then X20 <= X"00000000";
        elsif REGWR = '1' then
            if A3 = B"10100" then X20 <= WD4;
            end if;
        end if;
    end if;
end process;

reg21: process(rst,clk)
begin
    if rising_edge(clk) then
        if RST = '0' then X21 <= X"00000000";
        elsif REGWR = '1' then
            if A3 = B"10101" then X21 <= WD4;
            end if;
        end if;
    end if;
end process;

reg22: process(rst,clk)
begin
    if rising_edge(clk) then
        if RST = '0' then X22 <= X"00000000";
        elsif REGWR = '1' then
            if A3 = B"10110" then X22 <= WD4;
            end if;
        end if;
    end if;
end process;

reg23: process(rst,clk)
begin
    if rising_edge(clk) then
        if RST = '0' then X23 <= X"00000000";
        elsif REGWR = '1' then
            if A3 = B"10111" then X23 <= WD4;
            end if;
        end if;
    end if;
end process;

reg24: process(rst,clk)
begin
    if rising_edge(clk) then
        if RST = '0' then X24 <= X"00000000";
        elsif REGWR = '1' then
            if A3 = B"11000" then X24 <= WD4;
            end if;
        end if;
    end if;
end process;

reg25: process(rst,clk)
begin
    if rising_edge(clk) then
        if RST = '0' then X25 <= X"00000000";
        elsif REGWR = '1' then
            if A3 = B"11001" then X25 <= WD4;
            end if;
        end if;
    end if;
end process;

reg26: process(rst,clk)
begin
    if rising_edge(clk) then
        if RST = '0' then X26 <= X"00000000";
        elsif REGWR = '1' then
            if A3 = B"11010" then X26 <= WD4;
            end if;
        end if;
    end if;
end process;

reg27: process(rst,clk)
begin
    if rising_edge(clk) then
        if RST = '0' then X27 <= X"00000000";
        elsif REGWR = '1' then
            if A3 = B"11011" then X27 <= WD4;
            end if;
        end if;
    end if;
end process;

reg28: process(rst,clk)
begin
    if rising_edge(clk) then
        if RST = '0' then X28 <= X"00000000";
        elsif REGWR = '1' then
            if A3 = B"11100" then X28 <= WD4;
            end if;
        end if;
    end if;
end process;

reg29: process(rst,clk)
begin
    if rising_edge(clk) then
        if RST = '0' then X29 <= X"00000000";
        elsif REGWR = '1' then
            if A3 = B"11101" then X29 <= WD4;
            end if;
        end if;
    end if;
end process;

reg30: process(rst,clk)
begin
    if rising_edge(clk) then
        if RST = '0' then X30 <= X"00000000";
        elsif REGWR = '1' then
            if A3 = B"11110" then X30 <= WD4;
            end if;
        end if;
    end if;
end process;

reg31: process(rst,clk)
begin
    if rising_edge(clk) then
        if RST = '0' then X31 <= X"00000000";
        elsif REGWR = '1' then
            if A3 = B"11111" then X31 <= WD4;
            end if;
        end if;
    end if;
end process;

end architecture BEHAVIORAL;