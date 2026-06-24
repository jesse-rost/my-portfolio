
-- ************************************************************************
-- Project: CPE1510 Single-cycle Processor
-- Filename: cpsr.vhd
-- Author: Jesse Rost
-- Date: 04/01
-- Provides:
-- - The ARM current program status register.
-- - This register stores ALU flag signals C, V, N, Z.
-- - Input bus LD determines which bits are sampled and stored on clk edge.
-- ************************************************************************

-- use library packages
-- std_logic_1164: 9-valued logic signal voltages
library ieee;
use ieee.std_logic_1164.all;

-- function block symbol
-- inputs:
-- D3,D2,D1,D0 are input bits for storage
-- LD is a two-bit bus determining which inputs are sampled
-- RST is an active-low synchronous reset signal
-- CLK is a rising-edge triggered clock
-- outputs
-- Q3,Q2,Q1,Q0 are stored output bits
-- do not convert to bus! see reference diagrams
entity CPSR is
port(D3, D2, D1, D0: in std_logic;
	  LD: in std_logic_vector(1 downto 0);
	  RST: in std_logic;
	  CLK: in std_logic;
	  Q3, Q2, Q1, Q0: out std_logic);
end entity CPSR;


-- circuit description
architecture BEHAVIORAL of CPSR is
begin

	-- next state logic
	-- D3 = C, D2 = V, D1 = N, D0 = Z
	reg: process(LD, RST, CLK)
	begin
		if rising_edge(CLK) then				
			if RST='0' then Q3<='0'; Q2<='0'; Q1 <= '0'; Q0 <= '0';
				-- LD = 0: sample C, V, N, Z
				-- LD = 1: sample C, N, Z
				-- LD = 2: sample N, Z
				-- LD = 3: default - hold and don't change
			elsif LD=B"00" then Q3<=D3; Q2<=D2; Q1 <= D1; Q0 <= D0; -- CVNZ
			elsif LD=B"01" then Q3<=D3; Q1 <= D1; Q0 <= D0; 		  -- C, N, Z			
			elsif LD=B"10" then Q1 <= D1; Q0 <= D0; 					  -- N, Z
			else Q3 <= Q3; Q2 <= Q2; Q1 <= Q1; Q0 <= Q0; 			  -- hold
			end if ;
		end if;
	end process reg;

end architecture BEHAVIORAL;
