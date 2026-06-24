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

LIBRARY work;

ENTITY decode IS 
	PORT
	(
		A3SEL :  IN  STD_LOGIC;
		ROTSEL :  IN  STD_LOGIC;
		SHAMTSEL :  IN  STD_LOGIC;
		SRC2SEL :  IN  STD_LOGIC;
		REGWR :  IN  STD_LOGIC;
		A4SEL :  IN  STD_LOGIC;
		RST :  IN  STD_LOGIC;
		CLK :  IN  STD_LOGIC;
		IBUS :  IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		PC8 :  IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		WD4 :  IN  STD_LOGIC_VECTOR(31 DOWNTO 0);
		BRADDR :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
		RD3 :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
		SRC1 :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0);
		SRC2 :  OUT  STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END decode;

ARCHITECTURE bdf_type OF decode IS 

ATTRIBUTE black_box : BOOLEAN;
ATTRIBUTE noopt : BOOLEAN;

COMPONENT lpm_constant_3
	PORT(		 result : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
END COMPONENT;
ATTRIBUTE black_box OF lpm_constant_3: COMPONENT IS true;
ATTRIBUTE noopt OF lpm_constant_3: COMPONENT IS true;

COMPONENT lpm_constant_4
	PORT(		 result : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
END COMPONENT;
ATTRIBUTE black_box OF lpm_constant_4: COMPONENT IS true;
ATTRIBUTE noopt OF lpm_constant_4: COMPONENT IS true;

COMPONENT busmux_0
	PORT(sel : IN STD_LOGIC;
		 dataa : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 datab : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 result : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
END COMPONENT;
ATTRIBUTE black_box OF busmux_0: COMPONENT IS true;
ATTRIBUTE noopt OF busmux_0: COMPONENT IS true;

COMPONENT busmux_1
	PORT(sel : IN STD_LOGIC;
		 dataa : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 datab : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 result : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
END COMPONENT;
ATTRIBUTE black_box OF busmux_1: COMPONENT IS true;
ATTRIBUTE noopt OF busmux_1: COMPONENT IS true;

COMPONENT busmux_2
	PORT(sel : IN STD_LOGIC;
		 dataa : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 datab : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 result : OUT STD_LOGIC_VECTOR(3 DOWNTO 0));
END COMPONENT;
ATTRIBUTE black_box OF busmux_2: COMPONENT IS true;
ATTRIBUTE noopt OF busmux_2: COMPONENT IS true;

COMPONENT busmux_5
	PORT(sel : IN STD_LOGIC;
		 dataa : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 datab : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 result : OUT STD_LOGIC_VECTOR(4 DOWNTO 0));
END COMPONENT;
ATTRIBUTE black_box OF busmux_5: COMPONENT IS true;
ATTRIBUTE noopt OF busmux_5: COMPONENT IS true;

COMPONENT busmux_6
	PORT(sel : IN STD_LOGIC;
		 dataa : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 datab : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 result : OUT STD_LOGIC_VECTOR(31 DOWNTO 0));
END COMPONENT;
ATTRIBUTE black_box OF busmux_6: COMPONENT IS true;
ATTRIBUTE noopt OF busmux_6: COMPONENT IS true;

COMPONENT adder
	PORT(A : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 B : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 S : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT extender
	PORT(EXTS : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 IMM12 : IN STD_LOGIC_VECTOR(11 DOWNTO 0);
		 IMM24 : IN STD_LOGIC_VECTOR(23 DOWNTO 0);
		 IMM8 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
		 IMM32 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT regfile
	PORT(REGWR : IN STD_LOGIC;
		 RST : IN STD_LOGIC;
		 CLK : IN STD_LOGIC;
		 A1 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 A2 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 A3 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 A4 : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 WD4 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 RD1 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 RD2 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0);
		 RD3 : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT rotator
	PORT(NUM : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 ROT : IN STD_LOGIC_VECTOR(3 DOWNTO 0);
		 B : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

COMPONENT shifter
	PORT(RD2 : IN STD_LOGIC_VECTOR(31 DOWNTO 0);
		 SHAMT : IN STD_LOGIC_VECTOR(4 DOWNTO 0);
		 SHTYPE : IN STD_LOGIC_VECTOR(1 DOWNTO 0);
		 RD2SHIFTED : OUT STD_LOGIC_VECTOR(31 DOWNTO 0)
	);
END COMPONENT;

SIGNAL	RD_ALTERA_SYNTHESIZED3 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_11 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_1 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_2 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_3 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_4 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_5 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_6 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_8 :  STD_LOGIC_VECTOR(3 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_9 :  STD_LOGIC_VECTOR(31 DOWNTO 0);
SIGNAL	SYNTHESIZED_WIRE_10 :  STD_LOGIC_VECTOR(4 DOWNTO 0);


BEGIN 



b2v_ADDER_BRADDR : adder
PORT MAP(A => PC8,
		 B => SYNTHESIZED_WIRE_11,
		 S => BRADDR);


b2v_EXTENDER : extender
PORT MAP(EXTS => IBUS(27 DOWNTO 26),
		 IMM12 => IBUS(11 DOWNTO 0),
		 IMM24 => IBUS(23 DOWNTO 0),
		 IMM8 => IBUS(7 DOWNTO 0),
		 IMM32 => SYNTHESIZED_WIRE_11);


b2v_inst : busmux_0
PORT MAP(sel => A4SEL,
		 dataa => IBUS(15 DOWNTO 12),
		 datab => SYNTHESIZED_WIRE_1,
		 result => SYNTHESIZED_WIRE_6);


b2v_inst1 : busmux_1
PORT MAP(sel => A3SEL,
		 dataa => IBUS(11 DOWNTO 8),
		 datab => IBUS(15 DOWNTO 12),
		 result => SYNTHESIZED_WIRE_5);


b2v_inst2 : busmux_2
PORT MAP(sel => ROTSEL,
		 dataa => IBUS(11 DOWNTO 8),
		 datab => SYNTHESIZED_WIRE_2,
		 result => SYNTHESIZED_WIRE_8);


b2v_inst3 : lpm_constant_3
PORT MAP(		 result => SYNTHESIZED_WIRE_1);


b2v_inst4 : lpm_constant_4
PORT MAP(		 result => SYNTHESIZED_WIRE_2);


b2v_inst7 : busmux_5
PORT MAP(sel => SHAMTSEL,
		 dataa => IBUS(11 DOWNTO 7),
		 datab => RD_ALTERA_SYNTHESIZED3(4 DOWNTO 0),
		 result => SYNTHESIZED_WIRE_10);


b2v_inst9 : busmux_6
PORT MAP(sel => SRC2SEL,
		 dataa => SYNTHESIZED_WIRE_3,
		 datab => SYNTHESIZED_WIRE_4,
		 result => SRC2);


b2v_REGFILE : regfile
PORT MAP(REGWR => REGWR,
		 RST => RST,
		 CLK => CLK,
		 A1 => IBUS(19 DOWNTO 16),
		 A2 => IBUS(3 DOWNTO 0),
		 A3 => SYNTHESIZED_WIRE_5,
		 A4 => SYNTHESIZED_WIRE_6,
		 WD4 => WD4,
		 RD1 => SRC1,
		 RD2 => SYNTHESIZED_WIRE_9,
		 RD3 => RD_ALTERA_SYNTHESIZED3);


b2v_ROTATOR : rotator
PORT MAP(NUM => SYNTHESIZED_WIRE_11,
		 ROT => SYNTHESIZED_WIRE_8,
		 B => SYNTHESIZED_WIRE_4);


b2v_SHIFTER : shifter
PORT MAP(RD2 => SYNTHESIZED_WIRE_9,
		 SHAMT => SYNTHESIZED_WIRE_10,
		 SHTYPE => IBUS(6 DOWNTO 5),
		 RD2SHIFTED => SYNTHESIZED_WIRE_3);

RD3 <= RD_ALTERA_SYNTHESIZED3;

END bdf_type;