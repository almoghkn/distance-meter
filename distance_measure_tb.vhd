library ieee;
use ieee.std_logic_1164.all;
--This tb simulates the system behavior for button presses or auto mode
--Simulates 2 long button presses (from 50 ns to 25 us, and from 6 ms to 6.001 ms)
--Simulates auto mode starting from 11 ms
--Simulated Echo width inreases by 15 us every measurement
--run this for 50 ms!
entity distance_measure_tb is
end entity;

architecture behave of distance_measure_tb is
	constant PULSE_WIDTH		: integer := 6;
	constant CNT_THR			: integer := 20;
	constant SOM_FREQ			: integer := 220;
	constant WIDTH_UNIT			: integer := 30;
	constant MAX_DISTANCE		: integer := 300;
	constant UART_CLK			: integer := 9600;
	constant C_CLK_PRD			: time := 20 ns;

	component distance_measure is
		generic(
			pulse_width		: integer ;
			cnt_thr			: integer;
			som_freq		: integer;
			width_unit		: integer;
			UART_Clk		: integer;
			max_distance	: integer
		);
		port(
			clk				: in std_logic;
			reset			: in std_logic;
			SOM_Button		: in std_logic;
			State_Button	: in std_logic;
			
			Echo			: in std_logic;
			Trigger			: out std_logic;
			
			Ones_7Seg		: out std_logic_Vector(6 downto 0);
			Tens_7Seg		: out std_logic_Vector(6 downto 0);
			Hunds_7Seg		: out std_logic_Vector(6 downto 0);
			
			Tx				: out std_logic
		);
	end component;

	signal clk_sig			: std_logic := '0';
	signal rst_sig			: std_logic := '0';
	signal som_button_sig	: std_logic := '0';
	signal state_button_sig	: std_logic := '0';
	signal echo_sig			: std_logic := '0';
	signal trigger_sig		: std_logic := '0';
	signal echo_time		: time := 15 us;
	
begin

	dut: distance_measure
	generic map(
		pulse_width		=> PULSE_WIDTH,
		cnt_thr			=> CNT_THR,
		som_freq		=> SOM_FREQ,
		width_unit		=> WIDTH_UNIT,
		UART_Clk		=> UART_CLK,
		max_distance 	=> MAX_DISTANCE
	)
	port map (
		clk				=> clk_sig,
		reset			=> rst_sig,
		SOM_Button		=> som_button_sig,
		State_Button	=> state_button_sig,

		Echo			=> echo_sig,
		Trigger		    => trigger_sig,

		Ones_7Seg	    => open,
		Tens_7Seg	    => open,
		Hunds_7Seg	    => open
	);
	
	rst_sig <= '1', '0' after 10 ns;
	clk_sig <= not clk_sig after C_CLK_PRD / 2;
	--Simulate 2 button presses
	som_button_sig <= '1', '0' after 50 ns, '1' after 25 us, '0' after 6 ms, '1' after 6 ms + 1 us;
	--Simulate auto mode
	state_button_sig <= '0', '1' after 11 ms;
	
	process --Simulate growing echo signal every measurement
	begin
		wait until rising_edge(trigger_sig);
		wait for 1 us;
		echo_sig <= '1';
		wait for echo_time;
		echo_time <= echo_time + 15 us;
		echo_sig <= '0';
	end process;

end architecture;