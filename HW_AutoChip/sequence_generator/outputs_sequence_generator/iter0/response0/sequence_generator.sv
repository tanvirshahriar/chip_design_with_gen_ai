module sequence_generator (
    input  clk,
    input  reset_n,
    input  enable,
    output reg [7:0] data
);
    // State pointer for the 8‑element sequence
    reg [2:0] ptr;          // 3‑bit counter (0‑7)
    // ROM holding the required hexadecimal values
    reg [7:0] seq [0:7];

    // Initialize the lookup table
    initial begin
        seq[0] = 8'hAF;
        seq[1] = 8'hBC;
        seq[2] = 8'hE2;
        seq[3] = 8'h78;
        seq[4] = 8'hFF;
        seq[5] = 8'hE2;
        seq[6] = 8'h0B;
        seq[7] = 8'h8D;
        ptr    = 3'b0;
        data   = seq[0];
    end

    // Synchronous reset (active‑low) and enable logic
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            // Reset to the first element of the sequence
            ptr    <= 3'b0;
            data   <= seq[0];
        end
        else if (enable) begin
            // Output the current value, then advance the pointer
            data   <= seq[ptr];
            ptr    <= ptr + 3'b1;   // wraps automatically from 7 to 0
        end
        // If enable is low, hold the current output (no change to ptr or data)
    end
endmodule
