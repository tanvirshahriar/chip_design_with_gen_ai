module sequence_generator(
    input  clk,
    input  reset_n,   // active-low reset
    input  enable,
    output reg [7:0] data
);

    // 3-bit counter to index the 8‑element sequence
    reg [2:0] idx;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // Asynchronous reset: start at first value and index 0
            idx   <= 3'd0;
            data  <= 8'hAF;
        end
        else if (enable) begin
            // Output the value corresponding to the current index
            case (idx)
                3'd0: data <= 8'hAF;
                3'd1: data <= 8'hBC;
                3'd2: data <= 8'hE2;
                3'd3: data <= 8'h78;
                3'd4: data <= 8'hFF;
                3'd5: data <= 8'hE2;
                3'd6: data <= 8'h0B;
                3'd7: data <= 8'h8D;
            endcase
            // Advance to the next index (wrap around after 7)
            idx <= idx + 3'd1;
        end
        // If enable is low, hold the current output and index
    end

endmodule
