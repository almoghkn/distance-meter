library ieee;
use ieee.std_logic_1164.all;
--This tb simulates a growing distance every time a measurement happens
--A single asynchronous button press is simulated at 107 to 133 ns
--Auto mode is activated at 500 ns with som frequency of 4Hz
--run this for 10 ms!
entity logic_tb is
end entity;

architecture behave of logic_tb is
	constant PULSE_WIDTH	: integer := 6;
	constant SOM_FREQ		: integer := 4000;
	constant C_CLK_PRD		: time := 20 ns;
	constant C_PULSE_WIDTH	: time := 200 ns;

	component logic is
		generic(
			pulse_width		: integer := 6;
			som_freq		: integer := 4
		);
		port(
			clk				: in std_logic;
			reset			: in std_logic;
			SOM_Button		: in std_logic;
			State_Button	: in std_logic;
			Dist_in			: in integer range 0 to 300;
				
			SOM				: out std_logic;
			Ones			: out std_logic_Vector(3 downto 0);
			Tens			: out std_logic_Vector(3 downto 0);
			Hunds			: out std_logic_Vector(3 downto 0)
		);
	end component;

	signal clk_sig			: std_logic := '0';
	signal rst_sig			: std_logic := '0';
	signal som_button_sig	: std_logic := '1';
	signal state_button_sig	: std_logic := '0';
	signal dist_in_sig		: integer range 0 to 300 := 0;
	signal som_sig			: std_logic;
	
begin

	dut: logic
	generic map(
		pulse_width		=> PULSE_WIDTH,
		som_freq		=> SOM_FREQ
	)
	port map (
		clk				=> clk_sig,
		reset			=> rst_sig,
		SOM_Button		=> som_button_sig,
		State_Button	=> state_button_sig,
		Dist_in			=> dist_in_sig,
		SOM				=> som_sig,
		Ones			=> open,
		Tens			=> open,
		Hunds			=> open
	);
	process(som_sig)
	begin
		if rising_edge(som_sig) then
			dist_in_sig <= dist_in_sig + 7;
		end if;
	end process;
	clk_sig <= not clk_sig after C_CLK_PRD / 2;
	rst_sig <= '1', '0' after 10 ns;
	som_button_sig <= '1', '0' after 107 ns, '1' after 133 ns;
	state_button_sig <= '0', '1' after 500 ns;

end architecture;