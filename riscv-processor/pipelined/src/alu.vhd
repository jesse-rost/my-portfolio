-- **********************************************************************
-- Project :    RISC-V Pipelined Processor
-- Filename:    alu.vhd
-- Author  :    Jesse Rost
-- Date    :    08/22/26
-- Provides:
--   - A 32-bit ALU responding to requests on function selection signal S.
--   - The zero flag Z is produced from the 32-bit function result.
--   - Uses IEEE library numeric_std to typecast between logic and numbers.
-- Origin  :    Altered from ARM project.
-- **********************************************************************
-- * S: 0=add, 1=sub, 2=and, 3=or, 4=slt
-- **********************************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- function block symbol
-- A, B, and F are 32-bit voltage vectors
-- S is a 4-bit voltage vector selecting a particular function
entity ALU is
    port (A : in std_logic_vector(31 downto 0);
          B : in std_logic_vector(31 downto 0);
          S : in std_logic_vector(3 downto 0);
          F : out std_logic_vector(31 downto 0);
          Z : out std_logic);
end entity ALU;

-- internal circuit
architecture DATAFLOW of ALU is

  signal INTF: std_logic_vector(31 downto 0);
  signal SLT_RESULT: std_logic_vector(31 downto 0);

begin

    SLT_RESULT <= X"00000001" when signed(A) < signed(B) else 
                  X"00000000";

  -- complete the arithmetic and logic
  with S select
    INTF <= std_logic_vector(unsigned(A) + unsigned(B)) when B"0000", -- add
            std_logic_vector(unsigned(A) - unsigned(B)) when B"0001", -- sub
            A and B when B"0010",                                     -- and
            A or B when B"0011",                                      -- or
            SLT_RESULT when B"0100",                                  -- slt
            X"DEADC0DE" when others;                                  -- error code for debugging

  -- typecast the lower 32-bits to the output as a std_logic_vector
  F <= INTF;

  -- create the std_logic flag signals to announce arithmetic events
  Z <= '1' when INTF = X"00000000" else '0';

end architecture DATAFLOW;
