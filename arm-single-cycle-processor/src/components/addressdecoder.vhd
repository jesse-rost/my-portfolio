-- ***********************************************************************
-- * Project:	   CPE1510 robot computer system
-- * Filename:	   addressdecoder.vhd
-- * Author:	   Jesse Rost
-- * Date:	   MSOE Spring Semester 2025
-- * Provides:	   a system level address decoder for the CPE1510 computer
-- ***********************************************************************

-- use library packages
--  std_logic_1164: 9-valued logic signal voltages 
--  numeric_std: allows arithmetic and comparison on std_logic_vectors 
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


-- function block symbol
-- inputs: 
--    ADDR  : 32-bit memory address output by the processor
--    MEMRD : control signal from processor controller 
--    MEMWR : control signal from processor controller
-- outputs: 
--    LD3   : active-low output requesting storage of data bus value to data memory (0x00 - 0x1F)
--    LD2   : active-low output requesting storage of data bus value to SEG7 register (0xE8)
--    LD1   : active-low output requesting storage of data bus value to MOTOR register (0xE4)
--    LD0   : active-low output requesting storage of data bus value to LED register. (0xE0)
--    DATAS : select signal for system level input data multiplexer 
entity ADDRESSDECODER is 
port(ADDR: in std_logic_vector(31 downto 0);
     MEMRD : in std_logic;
     MEMWR : in std_logic;
     LD3   : out std_logic;
     LD2   : out std_logic;
     LD1   : out std_logic;
     LD0   : out std_logic;
     DATASEL: out std_logic_vector(1 downto 0));
end entity ADDRESSDECODER;

-- circuit description 
-- hint: use truth table in Table 2 of lab assignment 
architecture DATAFLOW of ADDRESSDECODER is 
begin 

  LD3 <= '0' when ADDR < X"0000001F" and MEMRD = '1' and MEMWR = '0' else -- STR to MEM addresses
         '1'; -- all others
        
  LD2 <= '0' when ADDR = X"000000E8" and MEMRD = '1' and MEMWR = '0' else -- STR to SEG7 register 
			'1';
			
  LD1 <= '0' when ADDR = X"000000E4" and MEMRD  ='1' and MEMWR = '0' else -- STR to MOTOR register
         '1';
			
  LD0 <= '0' when ADDR = X"000000E0" and MEMRD = '1' and MEMWR = '0' else
			'1'; -- STR to LEDS
         
			
  DATASEL <= B"11" when ADDR < X"0000001F" and MEMRD = '0' and MEMWR = '1' else -- LDR from MEM addresses
             B"10" when ADDR = X"000000F0" and MEMRD = '0' and MEMWR = '1' else -- LDR from SLIDERS address
				 B"01" when ADDR = X"000000EC" and MEMRD = '0' and MEMWR = '1' else -- LDR from SENSOR input 
				 B"00"; -- not valid read 

end architecture DATAFLOW;
