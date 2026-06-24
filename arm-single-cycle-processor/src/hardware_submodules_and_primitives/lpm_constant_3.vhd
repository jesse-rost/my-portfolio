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
-- CREATED		"Tue Jun 23 20:57:54 2026"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 
-- use the following when compiling in Quartus Prime
--LIBRARY lpm;
--USE lpm.lpm_components.all; 

-- use the following when compiling in third party tools --
-- add lpm_pack.vhd from the Quartus Prime library
LIBRARY work;
USE work.lpm_components.all;

ENTITY lpm_constant_3 IS 
PORT 
( 
	result	:	OUT	 STD_LOGIC_VECTOR(3 DOWNTO 0)
); 
END lpm_constant_3;

ARCHITECTURE bdf_type OF lpm_constant_3 IS 
BEGIN 

-- instantiate LPM macrofunction 

b2v_inst3 : lpm_constant
GENERIC MAP(LPM_CVALUE => 14,
			LPM_WIDTH => 4)
PORT MAP(		 result => result);

END bdf_type; 