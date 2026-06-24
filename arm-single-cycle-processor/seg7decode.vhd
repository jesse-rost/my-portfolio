-- ******************************************************************
-- * Project:	   CPE1510 robot computer system
-- * Filename:	   seg7decode.vhd
-- * Author:	   Jesse Rost 
-- * Date:	   MSOE Spring Semester 2025
-- * Provides:	   A seven-segment decoder for the CPE 1510 computer
-- ******************************************************************

-- use library packages
--  std_logic_1164: 9-valued logic signal voltages 
library ieee;
use ieee.std_logic_1164.all;


-- function block symbol
-- inputs: 
--    A     : 32-bit value for hexadecimal display
-- outputs: 
--    DE10 Lite only has five (5) seven-segment displays 
--    and so the two most significant nibbles will not be displayed
-- 
--    SEG5  : 8-bit 7-segment display output for nibble A(23 downto 24) 
--    SEG4  : 8-bit 7-segment display output for nibble A(19 downto 16)
--    SEG3  : 8-bit 7-segment display output for nibble A(15 downto 12)
--    SEG2  : 8-bit 7-segment display output for nibble A(11 downto 8)
--    SEG1  : 8-bit 7-segment display output for nibble A(7 downto 4)
--    SEG0  : 8-bit 7-segment display output for nibble A(3 downto 0)
entity SEG7DECODE is 
port(A: in std_logic_vector(31 downto 0);
     SEG5: out std_logic_vector(7 downto 0);
     SEG4: out std_logic_vector(7 downto 0);
     SEG3: out std_logic_vector(7 downto 0);
     SEG2: out std_logic_vector(7 downto 0);
     SEG1: out std_logic_vector(7 downto 0);
     SEG0: out std_logic_vector(7 downto 0));
end entity SEG7DECODE;

-- circuit description 
architecture MULTIPLEXER of SEG7DECODE is 

  -- constants to help make corrections easier 
  constant HEX0 : std_logic_vector(7 downto 0) := 8X"C0"; -- DE10 Lite uses active-low LEDs, this is the pattern for 0
  constant HEX1 : std_logic_vector(7 downto 0) := 8X"F9"; -- DE10 Lite uses active-low LEDs, this is the pattern for 1
  constant HEX2 : std_logic_vector(7 downto 0) := 8X"A4"; -- DE10 Lite uses active-low LEDs, this is the pattern for 2
  constant HEX3 : std_logic_vector(7 downto 0) := 8X"B0"; -- DE10 Lite uses active-low LEDs, this is the pattern for 3
  constant HEX4 : std_logic_vector(7 downto 0) := 8X"99"; -- DE10 Lite uses active-low LEDs, this is the pattern for 4
  constant HEX5 : std_logic_vector(7 downto 0) := 8X"92"; -- DE10 Lite uses active-low LEDs, this is the pattern for 5
  constant HEX6 : std_logic_vector(7 downto 0) := 8X"82"; -- DE10 Lite uses active-low LEDs, this is the pattern for 6
  constant HEX7 : std_logic_vector(7 downto 0) := 8X"D8"; -- DE10 Lite uses active-low LEDs, this is the pattern for 7
  constant HEX8 : std_logic_vector(7 downto 0) := 8X"80"; -- DE10 Lite uses active-low LEDs, this is the pattern for 8
  constant HEX9 : std_logic_vector(7 downto 0) := 8X"90"; -- DE10 Lite uses active-low LEDs, this is the pattern for 9
  constant HEXA : std_logic_vector(7 downto 0) := 8X"88"; -- DE10 Lite uses active-low LEDs, this is the pattern for A
  constant HEXB : std_logic_vector(7 downto 0) := 8X"83"; -- DE10 Lite uses active-low LEDs, this is the pattern for B
  constant HEXC : std_logic_vector(7 downto 0) := 8X"A7"; -- DE10 Lite uses active-low LEDs, this is the pattern for C
  constant HEXD : std_logic_vector(7 downto 0) := 8X"A1"; -- DE10 Lite uses active-low LEDs, this is the pattern for D
  constant HEXE : std_logic_vector(7 downto 0) := 8X"86"; -- DE10 Lite uses active-low LEDs, this is the pattern for E
  constant HEXF : std_logic_vector(7 downto 0) := 8X"8E"; -- DE10 Lite uses active-low LEDs, this is the pattern for F
  
begin 

  with A(23 downto 20) select 
  SEG5 <= HEX0 when X"0", 
          HEX1 when X"1", 
          HEX2 when X"2", 
          HEX3 when X"3", 
	       HEX4 when X"4",
	       HEX5 when X"5", 
			 HEX6 when X"6", 
			 HEX7 when X"7",
			 HEX8 when X"8",
			 HEX9 when X"9",
			 HEXA when X"A",
			 HEXB when X"B",
			 HEXC when X"C",
			 HEXD when X"D",
			 HEXE when X"E",
          HEXF when others; 
          
  with A(19 downto 16) select 
  SEG4 <= HEX0 when X"0", 
          HEX1 when X"1", 
          HEX2 when X"2", 
          HEX3 when X"3", 
	       HEX4 when X"4",
	       HEX5 when X"5", 
			 HEX6 when X"6", 
			 HEX7 when X"7",
			 HEX8 when X"8",
			 HEX9 when X"9",
			 HEXA when X"A",
			 HEXB when X"B",
			 HEXC when X"C",
			 HEXD when X"D",
			 HEXE when X"E",
          HEXF when others; 
          
  with A(15 downto 12) select 
  SEG3 <= HEX0 when X"0", 
          HEX1 when X"1", 
          HEX2 when X"2", 
          HEX3 when X"3", 
	       HEX4 when X"4",
	       HEX5 when X"5", 
			 HEX6 when X"6", 
			 HEX7 when X"7",
			 HEX8 when X"8",
			 HEX9 when X"9",
			 HEXA when X"A",
			 HEXB when X"B",
			 HEXC when X"C",
			 HEXD when X"D",
			 HEXE when X"E",
          HEXF when others;                     
 
  with A(11 downto 8) select 
  SEG2 <= HEX0 when X"0", 
          HEX1 when X"1", 
          HEX2 when X"2", 
          HEX3 when X"3", 
	       HEX4 when X"4",
	       HEX5 when X"5", 
			 HEX6 when X"6", 
			 HEX7 when X"7",
			 HEX8 when X"8",
			 HEX9 when X"9",
			 HEXA when X"A",
			 HEXB when X"B",
			 HEXC when X"C",
			 HEXD when X"D",
			 HEXE when X"E",
          HEXF when others; 
 
  with A(7 downto 4) select
  SEG1 <= HEX0 when X"0", 
          HEX1 when X"1", 
          HEX2 when X"2", 
          HEX3 when X"3", 
	       HEX4 when X"4",
	       HEX5 when X"5", 
			 HEX6 when X"6", 
			 HEX7 when X"7",
			 HEX8 when X"8",
			 HEX9 when X"9",
			 HEXA when X"A",
			 HEXB when X"B",
			 HEXC when X"C",
			 HEXD when X"D",
			 HEXE when X"E",
          HEXF when others; 
  
  with A(3 downto 0) select 
  SEG0 <= HEX0 when X"0", 
          HEX1 when X"1", 
          HEX2 when X"2", 
          HEX3 when X"3", 
	       HEX4 when X"4",
	       HEX5 when X"5", 
			 HEX6 when X"6", 
			 HEX7 when X"7",
			 HEX8 when X"8",
			 HEX9 when X"9",
			 HEXA when X"A",
			 HEXB when X"B",
			 HEXC when X"C",
			 HEXD when X"D",
			 HEXE when X"E",
          HEXF when others; 
end architecture MULTIPLEXER; 
