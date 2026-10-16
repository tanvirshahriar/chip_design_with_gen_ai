module sequence_detector(
    input  clk,
    input  reset_n,      // active-low reset
    input  [2:0] data,   // 3-bit input data
    output reg sequence_found
);
    // Sequence to detect: 001, 101, 110, 000, 110, 110, 011, 101
    localparam [7:0][2:0] SEQ = {
        3'b001,
        3'b101,
        3'b110,
        3'b000,
        3'b110,
        3'b110,
        3'b011,
        3'b101
    };

    // State holds how many elements of the sequence have been matched so far (0-7)
    reg [2:0] state; // 3 bits enough for 0-7

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin            // synchronous active-low reset
            state     <= 3'd0;
            sequence_found <= 1'b0;
        end else begin
            sequence_found <= 1'b0;   // default: no match this cycle

            if (data == SEQ[state]) begin // correct next symbol
                if (state == 3'd7) begin // last symbol matched
                    sequence_found <= 1'b1;
                    state     <= 3'd0; // restart detection (allow overlap)
                end else begin
                    state <= state + 3'd1; // advance to next state
                end
            end else begin
                // Mismatch: reset, but allow the current symbol to be a possible start
                if (data == SEQ[0]) begin
                    state <= 3'd1; // we have matched the first symbol already
                end else begin
                    state <= 3'd0; // no partial match
                end
            end
        end
    end
endmodule
