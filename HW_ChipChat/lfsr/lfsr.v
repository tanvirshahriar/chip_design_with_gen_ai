
module lfsr (
    input  wire        clk,      // system clock
    input  wire        reset_n,  // active‑low reset
    output wire [7:0]  data      // 8‑bit LFSR output
);

    // -------------------------------------------------------------
    // Internal state register
    // -------------------------------------------------------------
    reg [7:0] state;

    // Initial state = 10001010b
    parameter [7:0] INIT_STATE = 8'b10001010;

    // Tap locations (numbered from 1 starting at the LSB):
    //   taps at positions 1,4,6,7  -> bits 0,3,5,6
    //   mask = b0110_1001
    parameter [7:0] TAP_MASK   = 8'b01101001;

    // -------------------------------------------------------------
    // Synchronous reset + LFSR update (left‑shift, feedback into LSB)
    // -------------------------------------------------------------
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= INIT_STATE;                 // reset to seed
        end else begin
            // feedback = XOR of tapped bits
            state <= {state[6:0], ^(state & TAP_MASK)};
        end
    end

    // -------------------------------------------------------------
    // Output assignment
    // -------------------------------------------------------------
    assign data = state;

endmodule
