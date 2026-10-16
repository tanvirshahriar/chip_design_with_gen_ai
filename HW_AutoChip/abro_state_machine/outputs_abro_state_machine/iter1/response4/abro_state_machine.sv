module abro_state_machine(
    input clk,
    input rst_n,
    input A,
    input B,
    output O,
    output [3:0] State
);
    // One-hot encoding: [0]=A, [1]=B, [2]=R, [3]=O
    localparam [3:0] S_A = 4'b0001;
    localparam [3:0] S_B = 4'b0010;
    localparam [3:0] S_R = 4'b0100;
    localparam [3:0] S_O = 4'b1000;

    reg [3:0] state_reg;
    reg [3:0] state_next;

    // Output assignments
    assign State = state_reg;
    assign O     = state_reg[3]; // High only in state O

    // Next-state logic (Moore machine)
    always @(*) begin
        state_next = state_reg; // default: hold state
        case (state_reg)
            S_A: begin
                if (A)      state_next = S_A;
                else if (B) state_next = S_B;
                else        state_next = S_R; // A=0,B=0 -> R
            end
            S_B: begin
                if (A)      state_next = S_A;
                else if (B) state_next = S_B;
                else        state_next = S_R; // A=0,B=0 -> R
            end
            S_R: begin
                if (A & B)  state_next = S_O; // both high -> O
                else if (A) state_next = S_A; // A=1,B=0 -> A
                else if (B) state_next = S_B; // A=0,B=1 -> B
                else        state_next = S_R; // A=0,B=0 -> R (stay)
            end
            S_O: begin
                if (A & B)  state_next = S_O; // remain O if both high
                else if (A) state_next = S_A; // A=1,B=0 -> A
                else if (B) state_next = S_B; // A=0,B=1 -> B
                else        state_next = S_R; // A=0,B=0 -> R
            end
            default: state_next = S_A; // fallback (should not happen)
        endcase
    end

    // State register with active-low reset
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n)
            state_reg <= S_R; // reset to R state
        else
            state_reg <= state_next;
    end
endmodule
