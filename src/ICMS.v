`timescale 1us / 1ps

module ICMS(
    input CLK,
    input RST,

    input radar_echo,
    input scan_for_target,
    input [31:0] jet_speed,
    input [31:0] max_safe_distance,
    input [5:0] wind,
    input thunderstorm,
    input [1:0] visibility,
    input signed [7:0] temperature,

    output radar_pulse_trigger,
    output [31:0] distance_to_target,
    output safe_to_engage,
    output threat_detected,
    output emergency_landing_alert,
    output [1:0] ECSU_state,  
    output [1:0] ARTAU_state
);

   // Your code goes here.
	
ECSU ecsu_inst (
    .CLK(CLK),
    .RST(RST),
    .thunderstorm(thunderstorm),
    .wind(wind),
    .visibility(visibility),
    .temperature(temperature),
    .severe_weather(severe_weather),
    .emergency_landing_alert(emergency_landing_alert),
    .ECSU_state(ECSU_state)
);

ARTAU artau_inst (
    .radar_echo(radar_echo),
    .scan_for_target(scan_for_target),
    .jet_speed(jet_speed),
    .max_safe_distance(max_safe_distance),
    .RST(RST),
    .CLK(CLK),
    .radar_pulse_trigger(radar_pulse_trigger),
    .distance_to_target(distance_to_target),
    .threat_detected(threat_detected),
    .ARTAU_state(ARTAU_state)
);

    

endmodule