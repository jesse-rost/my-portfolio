-- *********************************************************************
-- Project:	CPE1510 Single-cycle Processor		
-- Filename:	adder.vhd
-- Author:	Jesse Rost 
-- Date:	04/08/25
-- Provides:	
-- - A 32-bit adder that drops the carry out. 
-- - This component uses the ieee library called numeric_std. 
-- - The numeric_std library allows type-casting logic and numbers.
-- *********************************************************************

-- use library packages
--  std_logic_1164: 9-valued logic signal voltages 
--  numeric_std: allows arithmetic on std_logic_vectors using typecasts
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- function block symbol
-- inputs:
--   A is the first 32-bit number for addition
--   B is the second 32-bit number for addition 
-- outputs
--   S is the 32-bit output result
entity ADDER is 
port(A, B: in std_logic_vector(31 downto 0);
     S: out std_logic_vector(31 downto 0));
end entity ADDER;

-- circuit description 
architecture DATAFLOW of ADDER is 
begin

  -- program counter addition is unsigned 
  -- it is okay to do inline typecasting 
  S <= std_logic_vector(unsigned(A) + unsigned(B));

end architecture DATAFLOW;