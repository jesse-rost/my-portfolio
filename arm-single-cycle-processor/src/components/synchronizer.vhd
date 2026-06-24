-- Copyright (C) 2023  Intel Corporation. All rights reserved.
-- Your use of Intel Corporation's design tools, logic functions 
-- and other software and tools, and any partner logic 
-- functions, and any output files from any of the foregoing 
-- (including device programming or simulation files), and any 
-- associated documentation or information are expressly subject 
-- to the terms and conditions of the Intel Program License 
-- Subscription Agreement, the Intel Quartus Prime License Agreement,
-- the Intel FPGA IP License Agreement, or other applicable license
-- agreement, including, without limitation, that your use is for
-- the sole purpose of programming logic devices manufactured by
-- Intel and sold by Intel or its authorized distributors.  Please
-- refer to the applicable agreement for further details, at
-- https://fpgasoftware.intel.com/eula.

-- PROGRAM		"Quartus Prime"
-- VERSION		"Version 23.1std.0 Build 991 11/28/2023 SC Lite Edition"
-- CREATED		"Tue Jun 23 20:49:10 2026"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY synchronizer IS 
	PORT
	(
		SYSRST :  IN  STD_LOGIC;
		CLK :  IN  STD_LOGIC;
		RST :  OUT  STD_LOGIC
	);
END synchronizer;

ARCHITECTURE bdf_type OF synchronizer IS 

SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC;
SIGNAL	DFF_inst :  STD_LOGIC;


BEGIN 
SYNTHESIZED_WIRE_3 <= '1';



PROCESS(CLK,SYSRST,SYNTHESIZED_WIRE_3)
BEGIN
IF (SYSRST = '0') THEN
	DFF_inst <= '0';
ELSIF (SYNTHESIZED_WIRE_3 = '0') THEN
	DFF_inst <= '1';
ELSIF (RISING_EDGE(CLK)) THEN
	DFF_inst <= SYNTHESIZED_WIRE_3;
END IF;
END PROCESS;


PROCESS(CLK,SYSRST,SYNTHESIZED_WIRE_3)
BEGIN
IF (SYSRST = '0') THEN
	RST <= '0';
ELSIF (SYNTHESIZED_WIRE_3 = '0') THEN
	RST <= '1';
ELSIF (RISING_EDGE(CLK)) THEN
	RST <= DFF_inst;
END IF;
END PROCESS;



END bdf_type;