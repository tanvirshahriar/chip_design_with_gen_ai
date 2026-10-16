module abro_state_machine(
    input        clk,   // Clock
    input        rst_n, // Active-low reset
    input        A,     // Input bit A
    input        B,     // Input bit B
    output       O,     // Output high when sequence detected
    output [3:0] State  // One-hot encoded current state
);

    // One-hot state registers
    reg state_A, state_B, state_R, state_O;
    reg next_A, next_B, next_R, next_O;

    // Decode the two-bit input into symbols
    wire sym_A = (~A & ~B); // 00 -> A
    wire sym_B = (~A &  B); // 01 -> B
    wire sym_R = ( A & ~B); // 10 -> R
    wire sym_O = ( A &  B); // 11 -> O

    // Next-state logic (Moore machine)
    always @* begin
        // Default: go to A state (only one bit will be set below)
        next_A = 1'b0;
        next_B = 0;
        next_R = 0;
        next_O = 0;

        if (sym_A) begin
            // Any A symbol restarts the sequence at state A
            next_A = 1'b1;
        end else if (state_A && sym_B) begin
            // A followed by B -> move to B
            next_B = 1'b1;
        end else if (state_B && sym_R) begin
            // B followed by R -> move to R
            next_R = 1'b1;
        end else if (state_R && sym_O) begin
            // R followed by O -> move to O (detect sequence)
            next_O = 1'b1;
        end else begin
            // Any other case (wrong symbol) resets to A
            next_A = 1'b1;
        end
    end

    // State register update
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state_A <= 1'b1;
            state_B <= 1'b0;
            state_R <= 1'b0;
            state_O <= 1'b0;
        end else begin
            state_A <= next_A;
            state_B <= next_B;
            state_R <= next_R;
            state_O <= next_O;
        end
    end

    // Output assignments
    assign O = state_O;                     // High when in O state
    assign State = {state_A, state_B, state_R, state_O}; // One-hot state vector

endmodule
