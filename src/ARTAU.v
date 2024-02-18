`timescale 1us / 1ps

module ARTAU(
    input radar_echo,
    input scan_for_target,
    input [31:0] jet_speed,
    input [31:0] max_safe_distance,
    input RST,
    input CLK,
    output reg radar_pulse_trigger,
    output reg [31:0] distance_to_target,
    output reg threat_detected,
    output reg [1:0] ARTAU_state
);

// State parameters
parameter IDLE = 2'b00;
parameter EMIT = 2'b01;
parameter LISTEN = 2'b10;
parameter ASSESS = 2'b11;

// Define state registers
reg [1:0] current_state;
reg [1:0] next_state;

// Internal signals
reg echo_received;
reg [31:0] time_in_state;
reg [31:0] distance_at_emit;

// State transitions and logic
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        current_state <= IDLE;
        radar_pulse_trigger <= 0;
        distance_to_target <= 0;
        threat_detected <= 0;
        time_in_state <= 0;
        distance_at_emit <= 0;
    end else begin
        current_state <= next_state;
    end
end

always @* begin
    // Default next state
    next_state = current_state;





    case (current_state)
        IDLE: begin
            radar_pulse_trigger = 0;
            distance_to_target = 0;
            threat_detected = 0;
            if (scan_for_target) begin
                next_state = EMIT;
                time_in_state = 0;
            end
        end






        EMIT: begin
            radar_pulse_trigger = 1;
            if (time_in_state == 300) begin
                next_state = LISTEN;
                time_in_state = 0;
                distance_at_emit = distance_to_target; 
            end
        end





        LISTEN: begin
            radar_pulse_trigger = 0;
            if (radar_echo) begin
                if (!echo_received) begin
                    echo_received = 1;
                    distance_to_target = distance_at_emit + (time_in_state * jet_speed); 
                end
            end else begin
                echo_received = 0;
            end

            if (time_in_state >= 2000) begin
                next_state = ASSESS;
                time_in_state = 0;
            end
        end






        ASSESS: begin
            radar_pulse_trigger = 0;
            threat_detected = (distance_to_target < max_safe_distance && jet_speed > 0) ? 1 : 0;
            // Calculate new_distance_to_target if needed

            if (time_in_state >= 3000) begin
                next_state = IDLE;
            end
        end
    endcase




    // Increment time in state
    time_in_state = time_in_state + 1;
end




// Output assignment
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        ARTAU_state <= IDLE;
    end else begin
        ARTAU_state <= current_state;
    end
end

endmodule
