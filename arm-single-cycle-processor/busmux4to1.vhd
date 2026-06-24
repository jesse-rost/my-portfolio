-- *********************************************************************
-- Project:	CPE1510 Single-cycle Processor		
-- Filename:	busmux4to1.vhd
-- Author:	Jesse Rost 
-- Date:	04/08/25
-- Provides:	
-- - a multiplexer that passes one of the selected busses to the output
-- - uses with-select syntax to implement the multiplexer
-- *********************************************************************

library ieee;
use ieee.std_logic_1164.all;

entity busmux4to1 is 
port( D3, D2, D1, D0: in std_logic_vector(31 downto 0);
      S: in std_logic_vector(1 downto 0);
      Y: out std_logic_vector(31 downto 0));
end entity busmux4to1; 

architecture multiplexer of busmux4to1 is 
begin 

 with S select 
 Y <= D3 when B"11", 
      D2 when B"10", 
      D1 when B"01", 
      D0 when others;
		
end architecture multiplexer;
