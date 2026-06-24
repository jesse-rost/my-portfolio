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
-- CREATED		"Tue Jun 23 20:41:00 2026"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY execute IS 
	PORT
	(
		RST :  IN  STD_LOGIC;
		CLK :  IN  STD_LOGIC;
		ALUSEL :  IN  STD_LOGIC_VECTOR(3 DOWNTO 0);
		CPSRWR :  IN  STD_LOGIC_VECTOR(1 DOWNTO 0);
		SRC1 :  IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		SRC2 :  IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		C :  OUT  STD_LOGIC;
		V :  OUT  STD_LOGIC;
		N :  OUT  STD_LOGIC;
		Z :  OUT  STD_LOGIC;
		F :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END execute;

ARCHITECTURE bdf_type OF execute IS 

COMPONENT alu
	PORT(A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 S : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 C : OUT STD_LOGIC;
		 V : OUT STD_LOGIC;
		 N : OUT STD_LOGIC;
		 Z : OUT STD_LOGIC;
		 F : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT cpsr
	PORT(D3 : IN STD_LOGIC;
		 D2 : IN STD_LOGIC;
		 D1 : IN STD_LOGIC;
		 D0 : IN STD_LOGIC;
		 RST : IN STD_LOGIC;
		 CLK : IN STD_LOGIC;
		 LD : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 Q3 : OUT STD_LOGIC;
		 Q2 : OUT STD_LOGIC;
		 Q1 : OUT STD_LOGIC;
		 Q0 : OUT STD_LOGIC
	);
END COMPONENT;

SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC;
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC;


BEGIN 



b2v_ALU : alu
PORT MAP(A => SRC1,
		 B => SRC2,
		 S => ALUSEL,
		 C => SYNTHESIZED_WIRE_0,
		 V => SYNTHESIZED_WIRE_1,
		 N => SYNTHESIZED_WIRE_2,
		 Z => SYNTHESIZED_WIRE_3,
		 F => F);


b2v_CPSR : cpsr
PORT MAP(D3 => SYNTHESIZED_WIRE_0,
		 D2 => SYNTHESIZED_WIRE_1,
		 D1 => SYNTHESIZED_WIRE_2,
		 D0 => SYNTHESIZED_WIRE_3,
		 RST => RST,
		 CLK => CLK,
		 LD => CPSRWR,
		 Q3 => C,
		 Q2 => V,
		 Q1 => N,
		 Q0 => Z);


END bdf_type;