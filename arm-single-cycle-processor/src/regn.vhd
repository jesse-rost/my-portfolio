-- *********************************************************************
-- Project:		CPE1510 Single-cycle Processor and Robot Computer System		
-- Filename:	regn.vhd
-- Author:		Dr. Russ Meier
-- Date:			4/15/2025
-- Provides:	
-- - An n-bit wide register.
-- - Responds to an active-low (logic-0) asynchronous reset signal. 
-- - Responds to an active-low (logic-0) synchronous load signal. 
-- *********************************************************************

-- use library packages
--  std_logic_1164: 9-valued logic signal voltages 
library ieee;
use ieee.std_logic_1164.all; 


-- function block symbol
-- inputs:
--   D is a n-bit input number for storage 
--   LD is an active-low sychronous load control signal 
--   RST is an active-low asynchronous reset signal 
--   CLK is a rising-edge triggered clock 
-- outputs
--   Q is a n-bit stored output number
-- generics: 
--	  WIDTH is an integer defaulting to 8


-- LEARN: VHDL allows generic component design. 
-- LEARN: Generics allows designers to specify parameters of the component
--        that change when the component is used in different places of a design. 

-- LEARN: In this component, the register width is a changeable parameter.
--			 The default width is set to the size of the byte, 8-bits. 

-- NOTE:	 This component is given to you in complete form. There are no changes to make. 

entity REGN is 
generic(WIDTH: integer := 8);
port(D: in std_logic_vector(WIDTH-1 downto 0);
     LD: in std_logic; 
     RST: in std_logic;
     CLK: in std_logic;
     Q: out std_logic_vector(WIDTH-1 downto 0));
end entity REGN;

-- circuit description 
architecture BEHAVIORAL of REGN is 
begin

  -- single process with asynchronous reset using the "all bits" or "all other bits" 
  -- syntax arrow to assign logic-0 to all bits 
  reg: process(LD, RST, CLK)
  begin
   if RST = '0' then Q <= (others => '0'); 
	elsif rising_edge(CLK) then 
	  if LD = '0' then Q <= D; 
	  end if; 
	end if;
  end process reg;
  
end architecture BEHAVIORAL;