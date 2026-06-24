-- **********************************************************************
-- Project:	CPE1510 Single-cycle Processor		
-- Filename:	alu.vhd
-- Author:	Jesse Rost 
-- Date:	04/10
-- Provides:	
-- - A 32-bit ALU responding to requests on function selection signal S.
-- - Function result flags C, V, N, and Z are produced.
-- - Uses IEEE library numeric_std to typecast between logic and numbers.
-- **********************************************************************
-- * S: 0=and, 1=eor, 2=sub, 3=rsb, 4=add, C=or, D=mov/shift, 
-- *    E=bic, F=mvn
-- **********************************************************************

-- library packages
--   std_logic_1164: 9-valued logic signal voltages 
--   numeric_std: unsigned, type conversions 

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
-- function block symbol
-- A, B, and F are 32-bit voltage vectors
-- S is a 4-bit voltage vector selecting a particular function
-- C, V, N, and Z are single output voltages
entity ALU is
    port (A:      in std_logic_vector(31 downto 0);
          B:      in std_logic_vector(31 downto 0);
          S:      in std_logic_vector(3 downto 0);
          F:      out std_logic_vector(31 downto 0);
          C, V, N, Z: out std_logic);
end entity ALU;

-- internal circuit  
architecture DATAFLOW of ALU is 

  -- 32-bit addition results in carry-out as bit 33 
  -- use 33-bit unsigned number to store that extra carry-out bit
  
  -- logic will be typecast to unsigned integers
  -- signed matters if using >, <, =, /= comparisons
  -- the ALU does not use these and thus unsigned is fine
  signal INTA: unsigned(32 downto 0);
  signal INTB: unsigned(32 downto 0);
  signal INTF: unsigned(32 downto 0);
  
  -- overflow occurs when two positives add to a negative 
  -- overflow occurs when two negatives add to a positive 
  -- overflow occurs when negative minus positive gives positive 
  -- overflow occurs when positive minus negative gives negative 
  -- use internal signal and create logic equation  
  signal INTV: std_logic;
  
begin

  -- connect INTA and INTB to the inputs 
  -- inputs are only 32-bits, from bits 31 downto 0
  -- set bit 32 of 33-bit number to 0
  INTA(32) <= '0';
  INTA(31 downto 0) <= unsigned(A);
  INTB(32) <= '0';
  INTB(31 downto 0) <= unsigned(B);
  
  -- complete the arithmetic and logic 
  -- numeric_std defines +, -, bitwise logic, etc. on unsigned type
  with S select 
  INTF <=  INTA and INTB when B"0000", 	   -- and
			  INTA xor INTB when B"0001",       -- eor
			  INTA - INTB when B"0010",         -- sub
			  INTB - INTA when B"0011",		   -- rsb
			  INTA + INTB when B"0100",         -- add
			  INTA + INTB when B"0101",  		   -- adc
			  INTA - INTB when B"0110", 			-- sbc
			  INTA - INTB when B"0111", 			-- rsc
			  INTA and INTB when B"1000", 		-- tst
			  INTA xor INTB when B"1001", 		-- teq
			  INTA - INTB when B"1010", 			-- cmp
			  INTA + INTB when B"1011", 			-- cmn
			  INTA or INTB when B"1100",        -- or 
			  INTB when B"1101", 				   -- mov, lsl, lsr, asr
			  INTA and (not INTB) when B"1110", -- bic 
			  (not INTB) when B"1111", 			-- mvn		  
			  33X"ABC" when others;			      -- error code for debugging
			 		 
  -- typecast the lower 32-bits of the unsigned to the
  -- output as a std_logic_vector: hint use 31 downto 0
  F <= std_logic_vector(INTF(31 downto 0));
  
  -- create the std_logic flag signals to announce arithmetic events
  C <= std_logic(INTF(32)); -- the carry out to column 32
   
  N <= std_logic(INTF(31)); -- negative is just MSB of 32-bit result 
  
  Z <= '1' when INTF(31 downto 0) = X"00000000" else '0';
  
  -- COMPLETE the truth table for signed overflow
  --   overflow occurs when two positives add to a negative 
  --   overflow occurs when two negatives add to a positive 
  --   overflow occurs when negative minus positive gives positive 
  --   overflow occurs when positive minus negative gives negative 
  --   remember that the sign bit of each number is is bit 31 
  --
  -- COMPLETE TRUTH TABLE BY FILLING IN VALUES FOR V 
  -- USING SELECT SIGNAL S(0) TO DIFFERENTIATE BETWEEN ADD AND SUBTRACT
  -- 
  -- S(0) INTA(31) INTB(31) INTF(31) | V   COMPLETE COMMENTS BEHIND V ALSO
  -- ------------------------------------
  -- 0    0        0        0        | 0   + plus + = +
  -- 0    0        0        1        | 1   + plus + = -
  -- 0    0        1        0        | 0   + plus - = + 
  -- 0    0        1        1        | 0   + plus - = -   
  -- 0    1        0        0        | 0  - plus + = +   
  -- 0    1        0        1        | 0   - plus + = -   
  -- 0    1        1        0        | 1   - plus - = +   
  -- 0    1        1        1        | 0   - plus - = -   
  -- 
  -- 1    0        0        0        | 0   + minus + = +
  -- 1    0        0        1        | 0   + minus + = -
  -- 1    0        1        0        | 0   + minus - = + 
  -- 1    0        1        1        | 1   + minus - = - 
  -- 1    1        0        0        | 1   - minus + = +
  -- 1    1        0        1        | 0   - minus + = -
  -- 1    1        1        0        | 0   - minus - = +
  -- 1    1        1        1        | 0   - minus - = -
  
  
  -- implement V as a canonical logic equation pulled from 
  -- your truth table. bits of unsigned work like logic bits so 
 -- Overflow logic for signed addition and subtraction
V <= (not S(0) and not INTA(31) and not INTB(31) and INTF(31)) or  -- minterm 2: + + = -
     (not S(0) and     INTA(31) and     INTB(31) and not INTF(31)) or  -- minterm 7: - - = +
     (    S(0) and not INTA(31) and     INTB(31) and     INTF(31)) or  -- minterm 12: + - = -
     (    S(0) and     INTA(31) and not INTB(31) and not INTF(31));    -- minterm 13: - + = +

end architecture DATAFLOW;
