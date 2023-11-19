library ieee;
use ieee.std_logic_1164.all;

entity derivative is
port(
	CLK		:	in std_logic;
	RST		: 	in std_logic;
	SIG_IN	:	in std_logic;
	SIG_OUT	:	out	std_logic
);
end entity;

architecture behave of derivative is
	signal x_d1	:	std_logic;
	signal x_d2	:	std_logic;
begin
	process(CLK,RST)
	begin
		if RST = '1' then
		x_d1 	<= '0';
		x_d2 	<= '0';
		SIG_OUT <= '0';
		elsif rising_edge(CLK) then
			x_d1<=SIG_IN;
			x_d2<=x_d1;
			if x_d1 = '0' and x_d2 = '1' then
				SIG_OUT <= '1';
			else
				SIG_OUT <= '0';
			end if;
		end if;
	end process;
end architecture;