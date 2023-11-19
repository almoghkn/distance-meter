library ieee;
use ieee.std_logic_1164.all;
entity synchronizer is
	port(
		async_in	: in std_logic;
		reset		: in std_logic;
		clk			: in std_logic;
		sync_out	: out std_logic
	);
end entity;

architecture behave of synchronizer is
	signal q1, q2	: std_logic := '0';
begin
	process(clk,reset)
	begin
		if reset = '1' then
			sync_out 	<= '0';
			q1			<= '0';
			q2			<= '0';
		else
			if rising_edge(clk) then
				q1 <= async_in;
				q2 <= q1;
				sync_out <= q2;
			end if;
		end if;
	end process;
end architecture;