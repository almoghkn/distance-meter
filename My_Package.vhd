library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

package My_Package is
	
	function BCD27Seg (
		BCD_IN	: in std_logic_vector(3 downto 0))
		return std_logic_vector;
	function BCD2ASCII (
		BCD_IN	: in std_logic_vector(3 downto 0))
		return std_logic_vector;
		
end My_Package;

package body My_Package is
	function BCD27Seg (BCD_IN : in std_logic_vector(3 downto 0))
	return std_logic_vector is
		variable Seg: std_logic_vector (6 downto 0) := (others => '1');
	begin
		case BCD_IN is
			when "0000" => Seg := "1000000";
			when "0001" => Seg := "1111001";
			when "0010" => Seg := "0100100";
			when "0011" => Seg := "0110000";
			when "0100" => Seg := "0011001";
			when "0101" => Seg := "0010010";
			when "0110" => Seg := "0000010";
			when "0111" => Seg := "1111000";
			when "1000" => Seg := "0000000";
			when "1001" => Seg := "0010000";
			when others => null;
		end case;
		return (Seg);
	end BCD27Seg;
	
	function BCD2ASCII (BCD_IN : in std_logic_vector(3 downto 0))
	return std_logic_vector is
		variable Seg: std_logic_vector (7 downto 0) := (others => '1');
	begin
		case BCD_IN is
			when "0000" => Seg := "00110000";
			when "0001" => Seg := "00110001";
			when "0010" => Seg := "00110010";
			when "0011" => Seg := "00110011";
			when "0100" => Seg := "00110100";
			when "0101" => Seg := "00110101";
			when "0110" => Seg := "00110110";
			when "0111" => Seg := "00110111";
			when "1000" => Seg := "00111000";
			when "1001" => Seg := "00111001";
			when others => null;
		end case;
		return (Seg);
	end BCD2ASCII;
		
end My_Package;