library ieee;
use ieee.std_logic_1164.all;
use work.My_Package.all;
entity to_7seg_converter is
	port(
		Ones_BCD		: in std_logic_Vector(3 downto 0);
		Tens_BCD		: in std_logic_Vector(3 downto 0);
		Hunds_BCD		: in std_logic_Vector(3 downto 0);
		
		Ones_7Seg		: out std_logic_Vector(6 downto 0);
		Tens_7Seg		: out std_logic_Vector(6 downto 0);
		Hunds_7Seg		: out std_logic_Vector(6 downto 0)
	);
end entity;

architecture behave of to_7seg_converter is

begin
	Ones_7Seg	  <= BCD27Seg(Ones_BCD);
	Tens_7Seg	  <= BCD27Seg(Tens_BCD);
	Hunds_7Seg	  <= BCD27Seg(Hunds_BCD);
end architecture;
