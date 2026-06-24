-- *********************************************************************
-- Project: CPE1510 Single-cycle Processor
-- Filename: reg32.vhd
-- Author: Jesse Rost
-- Date: 04/01
-- Provides:
-- - A 32-bit wide register used for registers not in the register file.
-- - Responds to an active-low (logic-0) asynchronous reset signal.
-- - Responds to an active-low (logic-0) synchronous load signal.
-- *********************************************************************

-- use library packages
-- std_logic_1164: 9-valued logic signal voltages
library ieee;
use ieee.std_logic_1164.all;

-- function block symbol
-- inputs:
-- 	D is a 32-bit input number for storage
-- 	LD is an active-low sychronous load control signal
-- 	RST is an active-low asynchronous reset signal
-- 	CLK is a rising-edge triggered clock
-- outputs
-- 	Q is a 32-bit stored output number

-- HINT: This is just a register.
-- HINT: The design is a single process.

entity REG32 is
port(
    D   : in std_logic_vector(31 downto 0);  -- 32-bit input data
    LD  : in std_logic;                      -- active-low load signal
    RST : in std_logic;                      -- active-low reset signal
    CLK : in std_logic;                      -- clock input
    Q   : out std_logic_vector(31 downto 0)  -- 32-bit output data
);
end entity REG32;

-- circuit description
architecture BEHAVIORAL of REG32 is
begin
    reg: process(LD, RST, CLK)
    begin
        if RST = '0' then  		  	-- Asynchronous reset (active-low)
            Q <= (others => '0');  	-- Reset to 0 (32-bits)
        elsif rising_edge(CLK) then	-- Rising edge of the clock
            if LD = '0' then  		-- Active-low load signal
                Q <= D;  				-- Load input data D into the register Q
            end if;
        end if;
    end process reg;

end architecture BEHAVIORAL;
