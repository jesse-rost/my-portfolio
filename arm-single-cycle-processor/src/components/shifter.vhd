-- ******************************************************************
-- project: scp
-- filename: shifter.vhd
-- author: Jesse Rost
-- date: 04/01
-- provides: 32-bit shifter for CPE1510 single-cycle processor
-- ******************************************************************

-- NOTE: THIS FILE IS GIVEN IN COMPLETE FORM.
-- NOTE: THERE IS NO ADDITIONAL WORK FOR STUDENTS TO COMPLETE.
-- NOTE: Review for reference.

-- use library packages
-- std_logic_1164: 9-valued logic signal voltages
-- std_logic_numeric_std: allows arithmetic on std_logic_vectors
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity SHIFTER is
port(RD2: in std_logic_vector(31 downto 0);
	  SHAMT: in std_logic_vector(4 downto 0);
	  SHTYPE: in std_logic_vector(1 downto 0);
	  RD2SHIFTED: out std_logic_vector(31 downto 0));
end entity SHIFTER;

architecture DATAFLOW of SHIFTER is
		signal U_RD2VALUE: unsigned(31 downto 0);
		signal S_RD2VALUE: signed(31 downto 0);
		signal AMOUNT: integer range 0 to 31;
		signal U_RESULT: unsigned(31 downto 0);
		signal S_RESULT: signed(31 downto 0);

begin
		
		-- ASR is a signed operation
		-- LSL, LSR, ROR are unsigned operations
		-- the numeric_std library implements shift_right
		-- based on type passed to it. it is overloaded by type
		
		U_RD2VALUE <= unsigned(RD2);
		S_RD2VALUE <= signed(RD2);
		AMOUNT <= to_integer(unsigned(SHAMT));
		
		with SHTYPE select
		U_RESULT <= shift_left(U_RD2VALUE,AMOUNT) when B"00",
						shift_right(U_RD2VALUE,AMOUNT) when B"01",
						rotate_right(U_RD2VALUE,AMOUNT) when others;
		with SHTYPE select
		S_RESULT <= shift_right(S_RD2VALUE,AMOUNT) when B"10",
						32X"0" when others;
		with SHTYPE select
		RD2SHIFTED <= std_logic_vector(S_RESULT) when B"10",
						  std_logic_vector(U_RESULT) when others;

end architecture DATAFLOW;
