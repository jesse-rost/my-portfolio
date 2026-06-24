-- *********************************************************************
-- Project: CPE1510 Single-cycle Processor
-- Filename: iRom.vhd
-- Author: Jesse Rost
-- Date: 04/01
-- Provides:
-- - An instruction ROM responding to addresses on its ADDR bus.
-- - This ROM is a truth table built using with-select syntax.
-- *********************************************************************

-- NOTE: THIS FILE IS GIVEN IN COMPLETE FORM.
-- NOTE: THERE IS NO ADDITIONAL WORK FOR STUDENTS TO COMPLETE
-- NOTE: Review for reference.

-- use library packages
-- std_logic_1164: 9-valued logic signal voltages
library ieee;
use ieee.std_logic_1164.all;


-- function block symbol
-- inputs:
-- ADDR 	: 32-bit address requesting instruction
-- outputs:
-- Q 		: 32-bit output of machine code instruction
-- notes : ROMs do not reset on power-up so no reset signal
-- 		: ROMs do not load in user mode so no load signal
entity IROM is
port(ADDR : in std_logic_vector(31 downto 0);
		  Q : out std_logic_vector(31 downto 0));

end entity IROM;


-- circuit description
architecture MULTIPLEXER of IROM is
begin

	-- use address to output correct binary machine code number
	with ADDR select
	Q <= 
X"e3a04000"	when	32X"00000000",
X"e3a05000"	when	32X"00000004",
X"e3a060e4"	when	32X"00000008",
X"e3a070ec"	when	32X"0000000C",
X"e3a080f0"	when	32X"00000010",
X"e3a090e0"	when	32X"00000014",
X"e3a0a0e8"	when	32X"00000018",
X"eb000014"	when	32X"0000001C",
X"e1a04000"	when	32X"00000020",
X"eb000020"	when	32X"00000024",
X"e1a05000"	when	32X"00000028",
X"e1a00004"	when	32X"0000002C",
X"e1a01005"	when	32X"00000030",
X"eb00002e"	when	32X"00000034",
X"e3a08005"	when	32X"00000038",
X"e3a010ff"	when	32X"0000003C",
X"e2811c03"	when	32X"00000040",
X"e5891000"	when	32X"00000044",
X"e3a01010"	when	32X"00000048",
X"e5861000"	when	32X"0000004C",
X"eb000043"	when	32X"00000050",
X"e3a01000"	when	32X"00000054",
X"e5891000"	when	32X"00000058",
X"e5861000"	when	32X"0000005C",
X"eb00003f"	when	32X"00000060",
X"e2488001"	when	32X"00000064",
X"e3580000"	when	32X"00000068",
X"1afffff2"	when	32X"0000006C",
X"eafffffe"	when	32X"00000070",
X"e3a02000"	when	32X"00000074",
X"e3a0100f"	when	32X"00000078",
X"e5861000"	when	32X"0000007C",
X"e5973000"	when	32X"00000080",
X"e2033004"	when	32X"00000084",
X"e3530000"	when	32X"00000088",
X"e2822001"	when	32X"0000008C",
X"1a000000"	when	32X"00000090",
X"eafffff9"	when	32X"00000094",
X"e3a01000"	when	32X"00000098",
X"e5861000"	when	32X"0000009C",
X"e58a2000"	when	32X"000000A0",
X"e1a00002"	when	32X"000000A4",
X"e1a0f00e"	when	32X"000000A8",
X"e3a02000"	when	32X"000000AC",
X"e5973000"	when	32X"000000B0",
X"e2033004"	when	32X"000000B4",
X"e3530004"	when	32X"000000B8",
X"0afffffb"	when	32X"000000BC",
X"e3a01003"	when	32X"000000C0",
X"e5861000"	when	32X"000000C4",
X"e5973000"	when	32X"000000C8",
X"e2033004"	when	32X"000000CC",
X"e3530000"	when	32X"000000D0",
X"e2822001"	when	32X"000000D4",
X"1a000000"	when	32X"000000D8",
X"eafffff9"	when	32X"000000DC",
X"e3a01000"	when	32X"000000E0",
X"e5861000"	when	32X"000000E4",
X"e58a2000"	when	32X"000000E8",
X"e1a00002"	when	32X"000000EC",
X"e1a0f00e"	when	32X"000000F0",
X"e5982000"	when	32X"000000F4",
X"e3a030ff"	when	32X"000000F8",
X"e2833c03"	when	32X"000000FC",
X"e1520003"	when	32X"00000100",
X"1afffffa"	when	32X"00000104",
X"e1a04000"	when	32X"00000108",
X"e1a05001"	when	32X"0000010C",
X"e3a0c004"	when	32X"00000110",
X"e3a0100f"	when	32X"00000114",
X"e5861000"	when	32X"00000118",
X"e1a02004"	when	32X"0000011C",
X"e3520000"	when	32X"00000120",
X"0a000002"	when	32X"00000124",
X"e0000000"	when	32X"00000128",
X"e2422001"	when	32X"0000012C",
X"eafffffa"	when	32X"00000130",
X"e3a01003"	when	32X"00000134",
X"e5861000"	when	32X"00000138",
X"e1a02005"	when	32X"0000013C",
X"e3520000"	when	32X"00000140",
X"0a000002"	when	32X"00000144",
X"e0000000"	when	32X"00000148",
X"e2422001"	when	32X"0000014C",
X"eafffffa"	when	32X"00000150",
X"e24cc001"	when	32X"00000154",
X"e35c0000"	when	32X"00000158",
X"1affffec"	when	32X"0000015C",
X"e1a0f00e"	when	32X"00000160",
X"e3a0303f"	when	32X"00000164",
X"e3a0c0ff"	when	32X"00000168",
X"e3a020ff"	when	32X"0000016C",
X"e2422001"	when	32X"00000170",
X"e3520000"	when	32X"00000174",
X"e0000000"	when	32X"00000178",
X"e0000000"	when	32X"0000017C",
X"1afffffa"	when	32X"00000180",
X"e24cc001"	when	32X"00000184",
X"e35c0000"	when	32X"00000188",
X"1afffff6"	when	32X"0000018C",
X"e2433001"	when	32X"00000190",
X"e3530000"	when	32X"00000194",
X"1afffff2"	when	32X"00000198",
X"e1a0f00e"	when	32X"0000019C",
X"ff200000"	when	32X"000001A0",
X"ff200050"	when	32X"000001A4",
X"ff200040"	when	32X"000001A8",
X"ff200020"	when	32X"000001AC",
X"ff200030"	when	32X"000001B0",
X"00000000"	when	32X"000001B4",
X"e8bd9c00"	when	32X"000001B8",
X"00000000"	when	32X"000001BC",
X"40000000"	when	32X"000001C0",
X"10000000"	when	32X"000001C4",
X"80000000"	when	32X"000001C8",
X"0000ffff"	when	32X"000001CC",
X"0000000c"	when	32X"000001D0",
X"00000000"	when	others;


end architecture MULTIPLEXER;
