module sequence_detector(
    input clk,
    input reset_n,
    input [2:0] data,
    output reg sequence_found
);
    // Pattern to detect: 001,101,110,000,110,110,011,101
    localparam integer PAT_LEN = 8;
    localparam [2:0] PAT [0:PAT_LEN-1] = {
        3'b001,
        3'b101,
        3'b110,
        3'b000,
        3'b110,
        3'b110,
        3'b011,
        3'b101
    };

    // State register: counts how many pattern elements have been matched so far
    reg [3:0] state, next_state;   // 4 bits needed for values 0..8

    // State update (including reset)
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state        <= 4'd0;
            sequence_found <= 1'b0;
        end else begin
            state        <= next_state;
            // Output high when we have just matched the full pattern
            sequence_found <= (state == 4'd(PAT_LEN));
        end
    end

    // Next-state logic
    always @* begin
        // Default: stay in current state (will be overridden below)
        next_state = state;

        if (state < PAT_LEN) begin
            // Still in the middle of matching the pattern
            if (data == PAT[state]) begin
                // Correct next element – advance
                next_state = state + 1'b1;
            end else begin
                // Mismatch: see if this data can start a new pattern
                next_state = (data == PAT[0]) ? 4'd1 : 4'd0;
            end
        end else begin
            // Full pattern matched (state == PAT_LEN): go back to idle
            next_state = 4'd0;
        end
    end
endmodule
