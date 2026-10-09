
module abro_state_machine (
    input  wire        clk,      // system clock
    input  wire        rst_n,    // active‑low asynchronous reset
    input  wire        A,        // input A
    input  wire        B,        // input B
    output reg         O,        // registered output
    output reg [3:0]   State     // one‑hot state (for verification)
);

    // one‑hot encoding
    localparam [3:0] S_RESET = 4'b0001; // no input seen (reset state)
    localparam [3:0] S_A     = 4'b0010; // A seen, B not yet
    localparam [3:0] S_AB    = 4'b0100; // both A and B seen

    // --------------------------------------------------------------
    //  Sequential logic – state register updates each clock edge
    // --------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin               // asynchronous reset
            State <= S_RESET;
            O     <= 1'b0;
        end else begin
            // Next‑state logic depends **only** on the current A and B
            if (A & B) begin            // A && B → go to AB state, O = 1
                State <= S_AB;
                O     <= 1'b1;
            end else if (A) begin       // A alone → go to A‑seen state, O = 0
                State <= S_A;
                O     <= 1'b0;
            end else if (B) begin       // B alone → go to reset state, O = 0
                State <= S_RESET;
                O     <= 1'b0;
            end else begin              // neither A nor B → hold current state, O = 0
                State <= State;
                O     <= 1'b0;
            end
        end
    end

endmodule
