-- **********************************************************************
-- Project :	RISC-V Pipelined Processor		
-- Filename:	regfile_tb.vhd
-- Author  :	Jesse Rost 
-- Date    :	08/22/26
-- Provides:	
--   - A testbench for the register file implementation.
-- Origin  :	Written from scratch.
-- **********************************************************************

library ieee;
use ieee.std_logic_1164.all;

entity tb_regfile is

-- no new definitions for a tb file

end entity tb_regfile;

architecture test of tb_regfile is 
	signal A1   : std_logic_vector(4 downto 0);
	signal A2   : std_logic_vector(4 downto 0);
	signal A3   : std_logic_vector(4 downto 0);
	signal WD4  : std_logic_vector(31 downto 0);
	signal REGWR: std_logic := '0';	-- default to 0
	signal RST  : std_logic := '0';	-- default to 0
	signal CLK  : std_logic := '0';	-- default to 0
	signal RD1  : std_logic_vector(31 downto 0);
	signal RD2  : std_logic_vector(31 downto 0);
	
begin
	dut : entity work.REGFILE
	port map (A1 => A1, A2 => A2, A3 => A3,
				 WD4 => WD4, REGWR => REGWR, RST => RST,
				 CLK => CLK, RD1 => RD1, RD2 => RD2);
				 
	-- free-running clock, 10 ns period
	clk_proc : process
	begin
		clk <= '1';
		wait for 5 ns;
		clk <= '0';
		wait for 5 ns;
	end process;
	
	-- test simulation run for regfile 
	sim : process
	begin
	
		-- test 1 : write to and read from a register
		
		-- write 0xDEADBEEF to register 21
		RST <= '1';
		wait for 10 ns;
		A3 <= "10101";
		WD4 <= X"DEADBEEF";
		REGWR <= '1';        -- active-high enable
		wait for 10 ns;      -- clock edge captures it

		-- now read it back
		REGWR <= '0';        -- disable writes
		A1 <= "10101";
		wait for 10 ns;
		assert RD1 = X"DEADBEEF"
			report "RD1 = 0x" & to_hstring(RD1);
		
		-- test 2 : set reset to 0 and read the value of the register 
		
		RST <= '0';
		wait for 10 ns;
		REGWR <= '1';
		A1 <= "00101";
		wait for 10 ns;
		assert RD1 = X"00000000" 
			report "FAIL to reset register value" severity error;
					
		-- test 3 : confirm that x0 is working as intended
		
		-- write 0xDEADBEEF to register 1
		RST <= '1';
		wait for 10 ns;
		A3 <= "00000";
		WD4 <= X"DEADBEEF";
		REGWR <= '1';        -- active-high enable
		wait for 10 ns;      -- clock edge captures it

		-- now read it back
		REGWR <= '0';        -- disable writes
		A1 <= "00000";
		wait for 10 ns;
		assert RD1 = X"00000000"
			report "FAIL: x0 has been written to" severity error;

		report "tb_regfile is complete";
		wait;
		
	end process;
end architecture test;
	
	