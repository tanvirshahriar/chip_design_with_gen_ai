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
    localparam [3:0] S_B = 4'b0010; // State B (unused, but defined for completeness)
    localparam [3:0] S_R = 4'b0100; // Reset/intermediate state
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
                if (A)       state_next = S_O;
                else if (B)  state_next = S_R;
                // else remain in S_A
            end
            S_R: begin
                if (A | B)   state_next = S_O;
                // else remain in S_R
            end
            S_O: begin
                // Once in O, stay in O regardless of inputs
            end
            S_B: begin
                // If we ever reach the unused B state, reset to A
                state_next = S_A;
            end
            default: begin
                // Catch any unexpected state (should not happen)
                state_next = S_A;
            end
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
