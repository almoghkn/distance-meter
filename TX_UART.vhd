library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_arith.all;
use ieee.std_logic_unsigned.all;
library work;
use work.My_Package.all;

entity TX_UART is
	generic(
		UART_DIV	: integer := 5208
	);
	port(
		clk			: in std_logic;
		rst			: in std_logic;
		EOM			: in std_logic;
		
		Ones		: in std_logic_Vector(3 downto 0);
		Tens		: in std_logic_Vector(3 downto 0);
		Hunds		: in std_logic_Vector(3 downto 0);
		
		Tx			: out std_logic
	);
end entity;

architecture behave of TX_UART is
	
	constant START_BIT	: std_logic_vector(0 downto 0) := "1";
	constant STOP_BIT	: std_logic_vector(0 downto 0) := "0";
	constant MAX_BITS	: integer := 9;
	constant NEWLINE	: std_logic_vector(MAX_BITS downto 0) := "1000010100";
	type TX_SM is(
		Wait_EOM, 
		Tx_Ones,
		Tx_Tens,
		Tx_Hunds,
		Tx_NewLine,
		Tx_str_first
	);
	
	signal state				: TX_SM := Wait_EOM;
	signal tx_ones_ascii		: std_logic_vector(MAX_BITS downto 0) := (others=>'0');
	signal tx_tens_ascii		: std_logic_vector(MAX_BITS downto 0) := (others=>'0');
	signal tx_hunds_ascii		: std_logic_vector(MAX_BITS downto 0) := (others=>'0');
	signal tx_bit				: integer range 0 to MAX_BITS := 0;
	signal tx_counter			: integer range 0 to UART_DIV := 0;
	signal data_cnt				: integer range 0 to 12 := 0;
	signal tx_buf				: std_logic_vector(11 * 8-1+22 downto 0):= "10010000001001111010100100000010110010101011000110101101110010110000101011101000101110011010110100101010001000"; 
	
	
begin
	process(clk, rst)
	begin
		if rst = '1' then
			state <= WAIT_EOM;
			tx_ones_ascii <= (others => '0');
			tx_tens_ascii <= (others => '0');
			tx_hunds_ascii <= (others => '0');
			tx_bit <= 0;
			tx_counter <= 0;
			Tx <= '1';
		else
			if rising_edge(clk) then
				case state is
					when Wait_EOM =>
						Tx <= '1';--UART output is high when not transmitting
						if EOM = '1' then
							--Sample and hold data for transmission
							--This protects the very slow and asynchronous transmission
							--from possible changes in inputs
							--Also start&stop bits added for UART protocol
							tx_ones_ascii  <= START_BIT & BCD2ASCII(Ones) & STOP_BIT;
							tx_tens_ascii  <= START_BIT & BCD2ASCII(Tens) & STOP_BIT;
							tx_hunds_ascii <= START_BIT & BCD2ASCII(Hunds) & STOP_BIT;
							--state <= Tx_str_first;
							state <= Tx_Hunds;
						end if;
							
					when Tx_str_first =>
						Tx <= tx_buf(tx_bit+data_cnt*10);
						if tx_counter = UART_DIV-1 then
							tx_counter <= 0;
							--Count transmitted bits
							if tx_bit = MAX_BITS then
								tx_bit <= 0;
								data_cnt <= data_cnt + 1;
								if data_cnt = 12 then
									state <= Wait_EOM;
									data_cnt <= 0;
								end if;
							else
								--Go to next bit
								tx_bit <= tx_bit + 1;
							end if;
						else
							--Increase counter
							tx_counter <= tx_counter + 1;
						end if;
						
					when Tx_Hunds =>
						--Transmit selected bit
						Tx <= tx_hunds_ascii(tx_bit);
						--Count UART_DIV cycles to achieve UART frequency (9600)
						if tx_counter = UART_DIV-1 then
							tx_counter <= 0;
							--Count transmitted bits
							if tx_bit = MAX_BITS then
								tx_bit <= 0;
								state <= Tx_Tens;
							else
								--Go to next bit
								tx_bit <= tx_bit + 1;
							end if;
						else
							--Increase counter
							tx_counter <= tx_counter + 1;
						end if;
					
					--Rest of states work the same
					when Tx_Tens =>
						Tx <= tx_tens_ascii(tx_bit);
						if tx_counter = UART_DIV-1 then
							tx_counter <= 0;
							if tx_bit = MAX_BITS then
								tx_bit <= 0;
								state <= Tx_Ones;
							else
								tx_bit <= tx_bit + 1;
							end if;
						else
							tx_counter <= tx_counter + 1;
						end if;
						
					when Tx_Ones =>
						Tx <= tx_ones_ascii(tx_bit);
						if tx_counter = UART_DIV-1 then
							tx_counter <= 0;
							if tx_bit = MAX_BITS then
								tx_bit <= 0;
								state <= Tx_NewLine;
							else
								tx_bit <= tx_bit + 1;
							end if;
						else
							tx_counter <= tx_counter + 1;
						end if;
						
					when Tx_NewLine => --Sends a NewLine character
						Tx <= NEWLINE(tx_bit);
						if tx_counter = UART_DIV-1 then
							tx_counter <= 0;
							if tx_bit = MAX_BITS then
								tx_bit <= 0;
								state <= Tx_str_first;
							else
								tx_bit <= tx_bit + 1;
							end if;
						else
							tx_counter <= tx_counter + 1;
						end if;
				end case;
			end if;
		end if;
	end process;
end architecture;