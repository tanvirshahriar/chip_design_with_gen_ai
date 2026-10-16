module abro_state_machine(
    input clk,
    input rst_n,
    input A,
    input B,
    output O,
    output [3:0] State
);
    // One-hot state encoding
    localparam [3:0] S_A = 4'b0001; // State A
    localparam [3:0] S_B = 4'b0010; // State B (should never be reached)
    localparam [3:0] S_R = 4'b0100; // Reset state (called R in spec)
    localparam [3:0] S_O = 4'b1000; // Output state

    reg [3:0] state_reg;
    reg [3:0] state_next;

    // Outputs
    assign State = state_reg;
    assign O     = state_reg[3]; // High only in S_O

    // Next-state logic
    always @(*) begin
        state_next = state_reg; // Default: hold current state
        case (state_reg)
            S_A: begin
                if (B)        state_next = S_R; // A + B=1 -> R
                else if (A)   state_next = S_A; // A + A=1 -> stay A
                else          state_next = S_A; // A=0,B=0 -> stay A
            end
            S_B: begin
                // Should never be reached, but if we are here, stay in B
                state_next = S_B;
            end
            S_R: begin
                if (A | B)    state_next = S_O; // R + any input -> O
                else          state_next = S_R; // stay R if no input (though unlikely)
            end
            S_O: begin
                // O state holds regardless of inputs (Moore output O=1)
                state_next = S_O;
            end
            default: state_next = S_A; // Fallback to A
        endcase
    end

    // State register with active-low reset
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state_reg <= S_A;
        else
            state_reg <= state_next;
    end
endmodule
