library ieee;
use ieee.std_logic_1164.all;
--This tb simulates a single measurement of C_DISTANCE
--The final output of the simulation should have output Dist = C_DISTANCE
--run this for 20 ms to cover max distance of 300 cm
entity sensor_driver_tb is
end entity;

architecture behave of sensor_driver_tb is
	constant C_DISTANCE			: integer := 222; 	--Simulated distance in cm
													--Change this value to try different distances
	
	constant C_PULSE_WIDTH		: integer := 6;
	constant C_CNT_THR			: integer := 20;
	constant C_WIDTH_UNIT		: integer := 2915;
	constant C_MAX_LENGTH		: integer := 300;
	constant C_CLK_PRD			: time := 20 ns;
	constant C_ECHO_WIDTH		: time := C_DISTANCE * C_WIDTH_UNIT * C_CLK_PRD;

	component sensor_driver is
		generic(
			pulse_width		: integer;
			cnt_thr			: integer;
			width_unit		: integer;
			max_distance		: integer
		);
		port(
			clk			: in std_logic;
			reset		: in std_logic;
			SOM			: in std_logic;
			EOM			: out std_logic;
			Echo		: in std_logic;
			Trigger		: out std_logic;
			Dist		: out integer range 0 to max_distance
		);
	end component;

	signal clk_sig			: std_logic := '0';
	signal rst_sig			: std_logic := '0';
	signal som_sig			: std_logic := '0';
	signal echo_sig			: std_logic := '0';
	
begin

	dut: sensor_driver
	generic map(
		pulse_width	=> C_PULSE_WIDTH,
		cnt_thr		=> C_CNT_THR,
		width_unit	=> C_WIDTH_UNIT,
		max_distance	=> C_MAX_LENGTH
	)
	port map (
		clk			=> clk_sig,
		reset		=> rst_sig,
		SOM			=> som_sig,
		Echo		=> echo_sig,
		EOM			=> open,
		Trigger		=> open,
		Dist		=> open
	);
	
	rst_sig <= '1', '0' after 10 ns;
	clk_sig <= not clk_sig after C_CLK_PRD / 2;
	--som signal is raised and lowered in the middle of conversion to see that it doesn't affect the process
	som_sig <= '0', '1' after 50 ns, '0' after 70 ns, '1' after C_ECHO_WIDTH/3, '0' after 2*C_ECHO_WIDTH/3;
	--echo signal is simulated with the calculated width
	echo_sig <= '1' after 500 ns, '0' after C_ECHO_WIDTH + 500 ns;

end architecture;