-- **************************************************************************
-- Project: CPE1510 Single-cycle Processor
-- Filename: dmem.vhd
-- Author: Jesse Rost
-- Date: 04/01
-- Provides:
-- - This is a 32-location RAM memory of 32-bit words.
-- - It has active-low memory write storing input data WD to address A.
-- - It provides one output port responding to address A on memory read.
-- **************************************************************************

-- NOTE: THIS FILE IS GIVEN IN COMPLETE FORM.
-- NOTE: THERE IS NO ADDITIONAL WORK FOR STUDENTS TO COMPLETE

--*********************************************************
--* LOAD IEEE LIBRARY AND SPECIFY LIBRARY PACKAGES
--* - std_logic_1164: provides 9-valued standard logic type
--* - std_logic_1164: provides rising and falling edge
--* - std_logic_unsigned: conv_integer function
--*********************************************************

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

--use ieee.std_logic_unsigned.all;

--*********************************************************
--* ENTITY DECLARATION
--* INPUT PORTS
--* - A: index into memory
--* - WD: 32-bit wide data to be written into memory
--* - MEMWR: active-high write control signal
--* - CLK: memory samples on falling-edge
--*
--* OUTPUT PORTS
--* - RD: memory output data
--*********************************************************
entity dmem is
port(A: in std_logic_vector(31 downto 0);
	 WD: in std_logic_vector(31 downto 0);
	 MEMWR, RST, CLK: in std_logic;
	 RD: out std_logic_vector(31 downto 0));
end entity dmem;

--*********************************************************
--* ARCHITECTURAL DESCRIPTION
--* - MEMARRAYTYPE: an abstract collection of 32-bit words
--* - MEMARRAY: an instance of MEMARRAYTYPE
--*********************************************************
architecture behavioral of dmem is
	type MEMARRAYTYPE is array(31 downto 0) of std_logic_vector(31 downto 0);
	signal MEMARRAY: MEMARRAYTYPE;
begin
	-- asynchronous read: does not depend on clock edge
	RD <= MEMARRAY(to_integer(unsigned(A)));
	-- synchronous write update process
	-- simulating large memory that does not have reset
	UPDATE: process(CLK,MEMWR)
	begin
		if rising_edge(CLK) then
			if MEMWR = '0' then
				MEMARRAY(to_integer(unsigned(A))) <= WD;
			end if;
		end if;
	end process;

end architecture behavioral;