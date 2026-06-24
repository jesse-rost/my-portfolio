
-- *********************************************************************
-- Project: CPE1510 Single-cycle Processor
-- Filename: reg32.vhd
-- Author: Jesse Rost
-- Date:
-- Provides:
-- - A 32-bit wide register used for registers not in the register file.
-- - Responds to an active-low (logic-0) asynchronous reset signal.
-- - Responds to an active-low (logic-0) synchronous load signal.
-- *********************************************************************
-- use library packages
-- std_logic_1164: 9-valued logic signal voltages
library ieee;
use ieee.std_logic_1164.all
-- function block symbol
-- inputs:
-- D is a 32-bit input number for storage
-- LD is an active-low sychronous load control signal
-- RST is an active-low asynchronous reset signal
-- CLK is a rising-edge triggered clock
-- outputs
-- Q is a 32-bit stored output number
-- HINT: This is just a register.
-- HINT: The design is a single process.
entity REG32 is
port(D: in std_logic_vector(31 downto 0);
LD: in std_logic;
RST: in std_logic;
CLK: in std_logic;
Q: out std_logic_vector(31 downto 0));
end entity REG32;
-- circuit description
architecture BEHAVIORAL of REG32 is
begin
reg: process(LD, RST, CLK)
begin
if RST = '0' then Q <= X"00000000";
elsif rising_edge(CLK) then
if LD = '0' then <<complete>>;
end if;
end if;
end process reg;
end architecture BEHAVIORAL;
