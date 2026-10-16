module sequence_detector(
    input        clk,
    input        reset_n,   // active-low reset
    input [2:0]  data,
    output       sequence_found
);
    // Progress through the 8‑pattern sequence
    reg [3:0] state;               // 0‑8 (needs 4 bits)

    // Expected 3‑bit values for each step of the sequence
    reg [2:0] expected [0:7];
    initial begin
        expected[0] = 3'b001;
        expected[1] = 3'b101;
        expected[2] = 3'b110;
        expected[3] = 3'b000;
        expected[4] = 3'b110;
        expected[5] = 3'b110;
        expected[6] = 3'b011;
        expected[7] = 3'b101;
        state = 4'd0;
    end

    // State machine: advance on a match, reset on mismatch or after detection
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= 4'd0;                 // reset to idle
        end else begin
            if (state == 4'd8) begin       // just completed the sequence
                state <= 4'd0;             // ready for next detection
            end else begin
                if (data == expected[state]) begin
                    state <= state + 4'd1; // advance to next step
                end else begin
                    state <= 4'd0;         // restart search
                end
            end
        end
    end

    // Output is high only when the detector has just seen the 8th pattern
    assign sequence_found = (state == 4'd8);
endmodule
