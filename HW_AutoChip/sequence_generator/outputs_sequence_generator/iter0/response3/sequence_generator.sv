module sequence_generator(
    input  clk,
    input  reset_n,
    input  enable,
    output reg [7:0] data
);

    // Sequence values
    localparam [7:0] SEQ0 = 8'hAF;
    localparam [7:0] SEQ1 = 8'hBC;
    localparam [7:0] SEQ2 = 8'hE2;
    localparam [7:0] SEQ3 = 8'h78;
    localparam [7:0] SEQ4 = 8'hFF;
    localparam [7:0] SEQ5 = 8'hE2;
    localparam [7:0] SEQ6 = 8'h0B;
    localparam [7:0] SEQ7 = 8'h8D;

    // State encoding: one-hot or binary, here binary 0-7
    reg [2:0] state, next_state;

    // Next state logic (synchronous)
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n)
            state <= 3'b000;
        else if (enable)
            state <= next_state;
        else
            state <= state;   // hold when disabled
    end

    // Compute next state (wrap around after 7)
    always @* begin
        if (enable)
            next_state = state + 3'b001;
        else
            next_state = state; // irrelevant when enable=0, but keeps combinational logic
    end

    // Output logic: map state to sequence value
    always @* begin
        case (state)
            3'b000: data = SEQ0;
            3'b001: data = SEQ1;
            3'b010: data = SEQ2;
            3'b011: data = SEQ3;
            3'b100: data = SEQ4;
            3'b101: data = SEQ5;
            3'b110: data = SEQ6;
            3'b111: data = SEQ7;
            default: data = 8'h00; // should never happen
        endcase
    end

endmodule
