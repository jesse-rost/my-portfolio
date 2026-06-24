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
-- CREATED		"Tue Jun 23 20:39:13 2026"

LIBRARY ieee;
USE ieee.std_logic_1164.all; 

LIBRARY work;

ENTITY fetch IS 
	PORT
	(
		PCWR :  IN  STD_LOGIC;
		RST :  IN  STD_LOGIC;
		CLK :  IN  STD_LOGIC;
		PCD :  IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		IBUS :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
		PC4 :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
		PC8 :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END fetch;

ARCHITECTURE bdf_type OF fetch IS 

ATTRIBUTE black_box : BOOLEAN;
ATTRIBUTE noopt : BOOLEAN;

COMPONENT lpm_constant_0
	PORT(		 result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
END COMPONENT;
ATTRIBUTE black_box OF lpm_constant_0: COMPONENT IS true;
ATTRIBUTE noopt OF lpm_constant_0: COMPONENT IS true;

COMPONENT lpm_constant_1
	PORT(		 result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
END COMPONENT;
ATTRIBUTE black_box OF lpm_constant_1: COMPONENT IS true;
ATTRIBUTE noopt OF lpm_constant_1: COMPONENT IS true;

COMPONENT adder
	PORT(A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 S : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT irom
	PORT(ADDR : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 Q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT regn
GENERIC (WIDTH : INTEGER
			);
	PORT(LD : IN STD_LOGIC;
		 RST : IN STD_LOGIC;
		 CLK : IN STD_LOGIC;
		 D : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 Q : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	SYNTHESIZED_WIRE_0 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_5 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC_VECTOR(31 DOWNTO 0);


BEGIN 



b2v_ADDER_P4 : adder
PORT MAP(A => SYNTHESIZED_WIRE_0,
		 B => SYNTHESIZED_WIRE_5,
		 S => PC4);


b2v_ADDER_P8 : adder
PORT MAP(A => SYNTHESIZED_WIRE_2,
		 B => SYNTHESIZED_WIRE_5,
		 S => PC8);


b2v_const4 : lpm_constant_0
PORT MAP(		 result => SYNTHESIZED_WIRE_0);


b2v_const8 : lpm_constant_1
PORT MAP(		 result => SYNTHESIZED_WIRE_2);


b2v_IROM : irom
PORT MAP(ADDR => SYNTHESIZED_WIRE_5,
		 Q => IBUS);


b2v_PC : regn
GENERIC MAP(WIDTH => 32
			)
PORT MAP(LD => PCWR,
		 RST => RST,
		 CLK => CLK,
		 D => PCD,
		 Q => SYNTHESIZED_WIRE_5);


END bdf_type;