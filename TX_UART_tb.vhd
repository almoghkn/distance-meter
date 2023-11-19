library ieee;
use ieee.std_logic_1164.all;
--This tb simulates transmitting rotating data (147, 471, 714, 147...)
--EOM is generated every 5ms because transmission takes about 4.2ms
--(8 bits for ascii + 1 start bit + 1 stop bit) * (3 digits + newline) = 40 bits total
--Transmitting time: ((1/9600)*40) ~ 4.2 ms
--run this for 25 ms!
entity TX_UART_tb is
end entity;

architecture behave of TX_UART_tb is
	constant UART_DIV			: integer := 5208;
	constant C_CLK_PRD			: time := 20 ns;

	component TX_UART is
	generic(
		UART_Div	: integer
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
	end component;

	signal clk_sig			: std_logic := '0';
	signal rst_sig			: std_logic := '0';
	signal eom_sig			: std_logic := '0';
	signal ones_sig			: std_logic_vector(3 downto 0) := "0001"; --1
	signal tens_sig			: std_logic_vector(3 downto 0) := "0100"; --4
	signal hunds_sig		: std_logic_vector(3 downto 0) := "0111"; --7
	signal eom_time			: time := 5 ms; --Transmitting time: ((1/9600)*40) ~ 4.2 ms
	
begin

	dut: TX_UART
	generic map(
		UART_Div	=> UART_DIV
	)
	port map (
		clk		=> clk_sig,
		rst		=> rst_sig,
		EOM		=> eom_sig,
		Ones    => ones_sig,
		Tens    => tens_sig,
		Hunds   => hunds_sig,
		Tx      => open
	);
	
	rst_sig <= '1', '0' after 10 ns;
	clk_sig <= not clk_sig after C_CLK_PRD / 2;
	
	process --Generate EOM and rotating ones/tens/hunds signals
	begin
		wait for eom_time;
		eom_sig <= '1';
		ones_sig <= tens_sig;
		tens_sig <= hunds_sig;
		hunds_sig <= ones_sig;
		wait for C_CLK_PRD;
		eom_sig <= '0';
	end process;

end architecture;