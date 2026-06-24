-- ***********************************************************************
-- Project:	CPE1510 Single-cycle Processor		
-- Filename:	extender.vhd
-- Author:	Jesse Rost
-- Date:	04/08/25
-- Provides:	
-- - A selection signal chooses among three immediate constant extensions.
-- - Extension of smaller immediates produces a 32-bit immediate for ALU.
-- - Only branch uses sign bit extension into the upper bits. 
-- ***********************************************************************

-- library packages 
--   std_logic_1164: 9-valued logic signal voltages 
 
library ieee;
use ieee.std_logic_1164.all;

-- function block symbol 
-- IMM8 is the 8-bit arithmetic immediate field input
-- IMM12 is the 12-bit load-store immediate field input
-- IMM24 is the 24-bit branch immediate field input
-- EXTS selects the size of extension based on instruction
-- IMM32 is the extended constant output for use by the ALU
entity EXTENDER is 
port(IMM8:  in std_logic_vector(7 downto 0);
     IMM12: in std_logic_vector(11 downto 0);
     IMM24: in std_logic_vector(23 downto 0);
     EXTS:  in std_logic_vector(1 downto 0);
     IMM32: out std_logic_vector(31 downto 0));
end entity EXTENDER;

-- circuit description 
architecture DATAFLOW of EXTENDER is 

   -- declare three internal 32-bit signals
   -- one signal per EXTS choice
   -- call them SIG_EXT8, SIG_EXT12, SIG_EXT24 
	signal SIG_EXT8:  std_logic_vector(31 downto 0);
	signal SIG_EXT12: std_logic_vector(31 downto 0);
	signal SIG_EXT24: std_logic_vector(31 downto 0);
	
begin

   -- truth table 
   -- EXTS  SELECTS THIS IMM32 OUTPUT BEHAVIOR   
   -- *****************************************                                  
   -- 0     put zeros into the upper 24 bits of SIG_EXT8, 
   --       IMM8 into the lower 8-bits of SIG_EXT8
   -- 
   -- 1     put zeros into the upper 20 bits of SIG_EXT12,
   --       IMM12 into the lower 12 bits of SIG_EXT12
   -- 
   -- 2     put IMM24(23) into the upper 6 bits of SIG_EXT24, 
   --       put IMM24 into the next bits of SIG_EXT24
   --       put 00 into bits 1 and 0 of SIG_EXT24 
   --
   -- 3     unused: output IMM32 = 0
	
   -- create internal signals 
	-- data processing extension is unsigned 
   SIG_EXT8(7 downto 0)  <= IMM8;
   SIG_EXT8(31 downto 8) <= X"000000";
	
	-- memory extention is unsigned
   SIG_EXT12(11 downto 0)  <= IMM12;
   SIG_EXT12(31 downto 12) <= X"00000";
	
	-- branch extension is signed, multiply by 4, copy number, add six sign bits
   SIG_EXT24(1 downto 0)   <= B"00"; -- shift left to multiply by 4
   SIG_EXT24(25 downto 2)  <= IMM24;
   SIG_EXT24(31 downto 26) <= IMM24(23)&IMM24(23)&IMM24(23)&IMM24(23)&IMM24(23)&IMM24(23);
	
   -- use a multiplexer to pass the correct internal signal
   -- to the output port 
   with EXTS select 
   IMM32 <= SIG_EXT8 when  B"00",  -- data processing
				SIG_EXT12 when B"01",  -- load-store
				SIG_EXT24 when B"10",  -- branch
            X"00000000" when others; -- reserved
   
 end architecture DATAFLOW;
