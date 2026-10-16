module sequence_detector(
    input clk,
    input reset_n,
    input [2:0] data,
    output reg sequence_found
);

    // State register
    reg [2:0] state;
    reg [2:0] next_state;

    // State encoding (0 = idle, 1-7 = partial match, 8 = full sequence detected)
    localparam [2:0] S0 = 3'd0,
                     S1 = 3'd1,
                     S2 = 3'd2,
                     S3 = 3'd3,
                     S4 = 3'd4,
                     S5 = 3'd5,
                     S6 = 3'd6,
                     S7 = 3'd7,
                     S8 = 3'd8;

    // State transition (synchronous reset)
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= S0;
        end else begin
            state <= next_state;
        end
    end

    // Next-state logic
    always @* begin
        next_state = state; // default: hold current state
        case (state)
            S0: next_state = (data == 3'b001) ? S1 : S0;
            S1: next_state = (data == 3'b101) ? S2 : S0;
            S2: next_state = (data == 3'b110) ? S3 : S0;
            S3: next_state = (data == 3'b000) ? S4 : S0;
            S4: next_state = (data == 3'b110) ? S5 : S0;
            S5: next_state = (data == 3'b110) ? S6 : S0;
            S6: next_state = (data == 3'b011) ? S7 : S0;
            S7: next_state = (data == 3'b101) ? S8 : S0;
            S8: next_state = S0; // after detection, restart searching
        endcase
    end

    // Output logic: pulse high when full sequence has been detected
    always @* begin
        sequence_found = (state == S8);
    end

endmodule
