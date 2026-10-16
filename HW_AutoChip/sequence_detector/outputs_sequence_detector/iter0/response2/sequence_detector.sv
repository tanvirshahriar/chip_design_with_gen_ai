module sequence_detector (
    input  wire        clk,
    input  wire        reset_n,   // active-low reset
    input  wire [2:0]  data,      // 3-bit input data
    output reg         sequence_found
);

    // State encoding: progress through the 8‑step sequence
    localparam [3:0] S0 = 4'd0,
                     S1 = 4'd1,
                     S2 = 4'd2,
                     S3 = 4'd3,
                     S4 = 4'd4,
                     S5 = 4'd5,
                     S6 = 4'd6,
                     S7 = 4'd7,
                     S8 = 4'd8;   // sequence detected

    reg [3:0] state, next_state;

    // State register (synchronous reset)
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            state <= S0;
        else
            state <= next_state;
    end

    // Next-state logic
    always @* begin
        // default: stay in current state (will be overridden if a match occurs)
        next_state = state;

        case (state)
            S0: if (data == 3'b001) next_state = S1;
            S1: if (data == 3'b101) next_state = S2;
            S2: if (data == 3'b110) next_state = S3;
            S3: if (data == 3'b000) next_state = S4;
            S4: if (data == 3'b110) next_state = S5;
            S5: if (data == 3'b110) next_state = S6;
            S6: if (data == 3'b011) next_state = S7;
            S7: if (data == 3'b101) next_state = S8;
            S8: // after detection we go back to idle on the next cycle
                next_state = S0;
            default: next_state = S0;
        endcase
    end

    // Output logic: pulse high for one clock cycle when the full sequence is seen
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            sequence_found <= 1'b0;
        else
            sequence_found <= (state == S8);
    end

endmodule
