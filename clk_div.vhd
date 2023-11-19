LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
ENTITY clk_div IS
	GENERIC(
		divider	: INTEGER := 12500000
	);
	PORT(
		CLK		: IN std_logic;
		RST		: IN std_logic;
		STROBE	: OUT std_logic
	);
END ENTITY;

ARCHITECTURE behave OF clk_div IS
	SIGNAL count	:INTEGER RANGE 0 TO (divider - 1) := 0;
BEGIN
	PROCESS(CLK,RST)
	BEGIN
		IF RST = '1' THEN
			count <= 0;
			STROBE <= '0';
		ELSE
			IF rising_edge(CLK) THEN
				IF count = divider - 1 THEN
					count <= 0;
					STROBE <= '1';
				ELSE
					count <= count + 1;
					STROBE <= '0';
				END IF;
			END IF;
		END IF;
	END PROCESS;
END behave;