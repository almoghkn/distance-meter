library ieee;
use ieee.std_logic_1164.all;
use ieee.Numeric_Std.all;
entity logic is
	generic(
		pulse_width		: integer := 6;
		som_freq		: integer := 4;
		max_distance	: integer := 300
	);
	port(
		clk			: in std_logic;
		reset		: in std_logic;
		SOM_Button	: in std_logic;
		State_Button: in std_logic;
		Dist_in		: in integer range 0 to max_distance;
		
		SOM			: out std_logic;
		Ones		: out std_logic_Vector(3 downto 0);
		Tens		: out std_logic_Vector(3 downto 0);
		Hunds		: out std_logic_Vector(3 downto 0)
	);
end entity;

architecture behave of logic is
	constant C_AUTO_SOM_DIV	: integer := 50e6/som_freq; --Counter for SOM generator
	component clk_div IS
	GENERIC(
			divider	: INTEGER := 12500000
		);
		PORT(
			CLK		: IN std_logic;
			RST		: IN std_logic;
			STROBE	: OUT std_logic
		);
	END component;
	
	component bin2bcd_12bit_sync is
		port ( 
			binIN       : in    STD_LOGIC_VECTOR (11 downto 0);     -- this is the binary number
			ones        : out   STD_LOGIC_VECTOR (3 downto 0);      -- this is the unity digit
			tenths      : out   STD_LOGIC_VECTOR (3 downto 0);      -- this is the tens digit
			hunderths   : out   STD_LOGIC_VECTOR (3 downto 0);      -- this is the hundreds digit
			thousands   : out   STD_LOGIC_VECTOR (3 downto 0);      -- 
			clk         : in    STD_LOGIC                           -- clock input
		);
	end component;
	
	component derivative is
		port(
			CLK		:	in std_logic;
			RST		: 	in std_logic;
			SIG_IN	:	in std_logic;
			SIG_OUT	:	out	std_logic
		);
	end component;
	
	signal som_sig			: std_logic;
	signal som_button_sig	: std_logic := '0';
	signal dist_sig			: std_logic_vector(11 downto 0) := (others=>'0');

begin
	--Convert integer from sensor driver to logic vector
	dist_sig <= std_logic_vector(to_unsigned(Dist_in, dist_sig'length));
	--Choose between auto mode or manual mode
	with State_Button select
		SOM <=	som_button_sig 		when '0', --'not' becasue button is active low
				som_sig				when '1',
				'Z'					when others;
	
	SOM_Gen: clk_div --Divides clock for auto mode at 4Hz
	generic map(C_AUTO_SOM_DIV)
	port map(
		CLK 		=> clk,
		RST 		=> reset,
		STROBE		=> som_sig
	);
	
	som_der: derivative --Finds when SOM button is pressed (high -> low)
	port map(
		CLK         => clk,
		RST         => reset,
		SIG_IN      => SOM_Button,
		SIG_OUT     => som_button_sig
	);
	bin2bcd: bin2bcd_12bit_sync --Splits binary num to separate BCD digits
	port map(
		binIN		=> dist_sig,
		ones        => Ones,
		tenths      => Tens,
		hunderths   => Hunds,
		thousands   => open, -- thousands is not needed
		clk         => clk
	);
end architecture;
