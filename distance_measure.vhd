library ieee;
use ieee.std_logic_1164.all;
entity distance_measure is
	generic(
		pulse_width		: integer := 600;		--Width of trigger pulse to Ultrasonic Sensor in clock cycles
		cnt_thr			: integer := 2500000;	--Num of cycles to wait between measurements
		som_freq		: integer := 4;			--Frequency of measurements when in auto mode
		width_unit		: integer := 2915; 		--Num of cycles in 1cm of Echo signal for 50MHz clock
		UART_Clk		: integer := 9600; 		
		max_distance	: integer := 300		--Maximum distance of Ultrasonic Sensor in cm
	);
	port(
		clk				: in std_logic;
		reset			: in std_logic;
		SOM_Button		: in std_logic;
		State_Button	: in std_logic;
		
		Echo			: in std_logic;
		Trigger			: out std_logic;
		
		Ones_7Seg		: out std_logic_vector(6 downto 0);
		Tens_7Seg		: out std_logic_vector(6 downto 0);
		Hunds_7Seg		: out std_logic_vector(6 downto 0);
		Thous_7Seg		: out std_logic_vector(6 downto 0);
		
		Tx				: out std_logic	
	);
end entity;

architecture behave of distance_measure is
	constant TURNOFF_7SEG	: std_logic_vector(6 downto 0) := (others=>'1'); --Turns off 4th 7Seg
	constant UART_Div		: integer := 50000000/UART_Clk; --System_clk/UART_clk
	component sensor_driver is
		generic(
			pulse_width		: integer;
			cnt_thr			: integer;
			width_unit		: integer;
			max_distance	: integer
		);
		port(
			clk				: in  std_logic;
			reset			: in  std_logic;
			SOM				: in  std_logic;
			EOM				: out std_logic;
			Echo			: in std_logic;
			Trigger			: out std_logic;
			Dist			: out integer range 0 to max_distance
		);
	end component;
	
	component logic is
		generic(
			pulse_width		: integer;
			som_freq		: integer
		);
		port(
			clk				: in std_logic;
			reset			: in std_logic;
			SOM_Button		: in std_logic;
			State_Button	: in std_logic;
			Dist_in			: in integer range 0 to max_distance;
				
			SOM				: out std_logic;
			Ones			: out std_logic_vector(3 downto 0);
			Tens			: out std_logic_vector(3 downto 0);
			Hunds			: out std_logic_vector(3 downto 0)
		);
	end component;
	
	component to_7seg_converter is
		port(
			Ones_BCD		: in std_logic_vector(3 downto 0);
			Tens_BCD		: in std_logic_vector(3 downto 0);
			Hunds_BCD		: in std_logic_vector(3 downto 0);
			
			Ones_7Seg		: out std_logic_vector(6 downto 0);
			Tens_7Seg		: out std_logic_vector(6 downto 0);
			Hunds_7Seg		: out std_logic_vector(6 downto 0)
		);
	end component;
	
	component synchronizer is
		port(
			async_in		: in std_logic;
			reset			: in std_logic;
			clk				: in std_logic;
			sync_out		: out std_logic
		);
	end component;
	
	component TX_UART is
		generic(
			UART_Div	: integer
		);
		port(
			clk			: in std_logic;
			rst			: in std_logic;
			EOM			: in std_logic;
			
			Ones		: in std_logic_vector(3 downto 0);
			Tens		: in std_logic_vector(3 downto 0);
			Hunds		: in std_logic_vector(3 downto 0);
			
			Tx			: out std_logic
		);
	end component;

	--Signals for synchronized inputs
	signal som_button_synchronized		: std_logic := '0';
	signal state_button_synchronized	: std_logic := '0';
	signal echo_stabilyzed				: std_logic := '0';
	--Signals for interconnecting components
	signal som_sig						: std_logic;
	signal eom_sig						: std_logic;
	signal eom_sig_delayed				: std_logic;
	signal dist_sig						: integer range 0 to max_distance;
	signal ones_sig						: std_logic_vector(3 downto 0);
	signal tens_sig						: std_logic_vector(3 downto 0);
	signal hunds_sig					: std_logic_vector(3 downto 0);
	
begin
	--Turn off 4th 7seg by outputting all high
	Thous_7Seg <= TURNOFF_7SEG;
	--Synchronize signals coming from outside sources
	som_synchronizer: synchronizer
	port map(
		async_in		=> SOM_Button,
		reset           => reset,
		clk             => clk,
		sync_out        => som_button_synchronized
	);
	state_synchronizer: synchronizer
	port map(
		async_in		=> State_Button,
		reset           => reset,
		clk             => clk,
		sync_out        => state_button_synchronized
	);
	echo_synchronizer: synchronizer
	port map(
		async_in		=> Echo,
		reset           => reset,
		clk             => clk,
		sync_out        => echo_stabilyzed
	);
	--EOM from driver arrives at TX_UART 2 cycles earlier than Data
	--Fix this by delaying EOM by 2 cycles, exactly what synchronizer does
	EOM_Delay_2cycles: synchronizer
	port map(
		async_in		=> eom_sig,
		reset           => reset,
		clk             => clk,
		sync_out        => eom_sig_delayed
	);
	--Connect the rest of the components
	driver: sensor_driver
	generic map(
		pulse_width		=> pulse_width,
		cnt_thr			=> cnt_thr,
		width_unit		=> width_unit,
		max_distance		=> max_distance
	)
	port map(
		clk				=> clk,
		reset			=> reset,
		SOM				=> som_sig,
		EOM				=> eom_sig,
		Echo			=> echo_stabilyzed,
		Trigger			=> Trigger,
		Dist			=> dist_sig
	);
	logic_unit: logic
	generic map(
		pulse_width		=> pulse_width,
		som_freq		=> som_freq
	)
	port map(
		clk				=> clk,
		reset			=> reset,
		SOM_Button		=> som_button_synchronized,
		State_Button	=> state_button_synchronized,
		Dist_in			=> dist_sig,
		SOM				=> som_sig,
		Ones			=> ones_sig,
		Tens			=> tens_sig,
		Hunds			=> hunds_sig
	);
	
	display: to_7seg_converter
	port map(
		Ones_BCD		=> ones_sig,
		Tens_BCD		=> tens_sig,
		Hunds_BCD		=> hunds_sig,
		Ones_7Seg		=> Ones_7Seg,
		Tens_7Seg		=> Tens_7Seg,
		Hunds_7Seg		=> Hunds_7Seg
	);
	UART: TX_UART
	generic map(
		UART_Div		=> UART_Div
	)
	port map(
		clk             => clk,
		rst             => reset,
		EOM             => eom_sig_delayed,
		Ones            => ones_sig,
		Tens            => tens_sig,
		Hunds           => hunds_sig,
		Tx              => Tx
		);
	
end architecture;