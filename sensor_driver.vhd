library ieee;
use ieee.std_logic_1164.all;
entity sensor_driver is
	generic(
		pulse_width		: integer := 6;
		cnt_thr			: integer := 20;
		width_unit		: integer := 2915;
		max_distance		: integer := 300
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
end entity;

architecture behave of sensor_driver is
	type sensor_SM is(
		Wait_SOM, 
		Trigger_Out, 
		Wait_Echo,
		Measure_Echo,
		Data_Out,
		Wait_Thr
	);
	
	signal State			: sensor_SM := Wait_SOM;
	signal trigger_cnt_sig	: integer range 0 to pulse_width := 0;
	signal echo_cnt_sig		: integer range 0 to width_unit := 1; --Starts from one
	signal dist_cnt_sig		: integer range 0 to max_distance := 0;
	signal cnt_thr_sig		: integer range 0 to cnt_thr := 0;

begin
	process(clk, reset)
	begin
		if reset = '1' then
			State <= Wait_SOM;
			Trigger <= '0';
			EOM		<= '0';
			trigger_cnt_sig <= 0;
			echo_cnt_sig <= 1;
		elsif rising_edge(clk) then
			case State is
				when Wait_SOM =>
					Trigger <= '0';
					EOM		<= '0';
					--Waiting for SOM signal
					if SOM = '1' then
						State <= Trigger_Out;
					end if;

				when Trigger_Out =>
					Trigger <= '1';
					EOM		<= '0';
					--Output Trigger sigal with pulse_width width
					if trigger_cnt_sig < pulse_width - 1 then
						trigger_cnt_sig <= trigger_cnt_sig + 1;
					else
						State <= Wait_Echo;
					end if;

				when Wait_Echo =>
					Trigger <= '0';
					EOM		<= '0';
					--Wait for returning Echo signal
					if Echo = '1' then
						State <= Measure_Echo;
					end if;
					
				when Measure_Echo =>
					Trigger <= '0';
					EOM		<= '0';
					--2 Counters:
					--echo_cnt_sig: counts clocks until one unit of distance (one cm)
					--				starts from 1 because Echo rised in 'Wait_Echo' state in prev cycle
					--dist_cnt_sig: counts units of distance in Echo signal (also output distance)
					if Echo = '1' then
						if echo_cnt_sig < width_unit - 1 then
							echo_cnt_sig <= echo_cnt_sig + 1;
						else
							echo_cnt_sig <= 0;
							if dist_cnt_sig < max_distance then
								dist_cnt_sig <= dist_cnt_sig + 1;
							end if;
						end if;
					else
						State <= Data_Out;
					end if;

				when Data_Out =>
					Trigger <= '0';
					EOM		<= '1';
					--Copy measured dist to output Dist
					Dist <= dist_cnt_sig;
					State <= Wait_Thr;
					
				when Wait_Thr =>
					Trigger <= '0';
					EOM		<= '0';
					--Reset all counters
					trigger_cnt_sig <= 0;
					echo_cnt_sig <= 1;
					dist_cnt_sig <= 0;
					--Wait cnt_thr cycles before accepting new SOMs
					if cnt_thr_sig < cnt_thr - 1 then
						cnt_thr_sig <= cnt_thr_sig + 1;
					else
						cnt_thr_sig <= 0;
						State <= Wait_SOM;
					end if;
			end case;
		end if;
	end process;
end architecture;
