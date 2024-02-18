`timescale 1us / 1ps

module ECSU(
    input CLK,
    input RST,
    input thunderstorm,
    input [5:0] wind,
    input [1:0] visibility,
    input signed [7:0] temperature,
    output reg severe_weather,
    output reg emergency_landing_alert,
    output reg [1:0] ECSU_state
);

// Define states
parameter ALL_CLEAR = 2'b00;
parameter CAUTION = 2'b01;
parameter HIGH_ALERT = 2'b10;
parameter EMERGENCY = 2'b11;

// Define state registers
reg [1:0] current_state;
reg [1:0] next_state;

// Define internal signals
reg wind_condition;
reg visibility_condition;
reg temperature_condition;

// State transitions and logic
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        current_state <= ALL_CLEAR;
    end else begin
        current_state <= next_state;
    end
end


always @* begin
    // Default next state
    next_state = current_state;
    
    // Default conditions
    wind_condition = (wind > 10) && (wind <= 15); // 10 to 15 in 6-bit binary
    visibility_condition = (visibility == 2'b01);

    temperature_condition = (temperature > 35) || (temperature < -35);
    
    // State transitions logic
    case (current_state)


        ALL_CLEAR: begin
            if (wind_condition || visibility_condition) begin
                next_state = CAUTION;
            end else if (thunderstorm || (wind > 15) || (temperature > 35) || (temperature < -35) || (visibility == 2'b11)) begin
                next_state = HIGH_ALERT;
            end
        end




        CAUTION: begin
            if ((wind <= 10) && (visibility == 2'b00)) begin
                next_state = ALL_CLEAR;
            end else if (thunderstorm || (wind > 15) || (temperature > 35) || (temperature < -35) || (visibility == 2'b11)) begin
                next_state = HIGH_ALERT;
            end
        end





        HIGH_ALERT: begin
            severe_weather = 1;
            if ((temperature < -40) || (temperature > 40) || (wind > 20)) begin
                next_state = EMERGENCY;
            end else if (!thunderstorm && (wind <= 10) && (temperature >= -35) && (temperature <= 35) && (visibility < 11)) begin
                next_state = CAUTION;
                severe_weather = 0; // Deactivate severe weather alert
            end
        end





        EMERGENCY: begin
            emergency_landing_alert = 1;
            // Reset only when RST is triggered after landing and thorough reevaluation of environmental conditions
        end


    endcase
end

// Output assignment
always @(posedge CLK or posedge RST) begin
    if (RST) begin
        severe_weather <= 0;
        emergency_landing_alert <= 0;
        ECSU_state <= ALL_CLEAR;
    end else begin
        ECSU_state <= current_state;
    end
end

endmodule
