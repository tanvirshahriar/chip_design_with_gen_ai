module sequence_generator (
    input  clk,
    input  reset_n,   // active‑low reset
    input  enable,
    output reg [7:0] data
);

    // Sequence to be generated
    localparam [7:0] SEQ0 = 8'hAF;
    localparam [7:0] SEQ1 = 8'hBC;
    localparam [7:0] SEQ2 = 8'hE2;
    localparam [7:0] SEQ3 = 8'h78;
    localparam [7:0] SEQ4 = 8'hFF;
    localparam [7:0] SEQ5 = 8'hE2;
    localparam [7:0] SEQ6 = 8'h0B;
    localparam [7:0] SEQ7 = 8'h8D;

    // 3‑bit counter for the 8‑state sequence
    reg [2:0] state;

    // Synchronous reset and enable logic
    always @(posedge clk) begin
        if (!reset_n) begin
            state   <= 3'b000;
            data    <= SEQ0;   // start with first value after reset
        end else if (enable) begin
            // Advance to next state, wrapping after the last entry
            if (state == 3'b111) begin
                state   <= 3'b000;
                data    <= SEQ0;
            end else begin
                state   <= state + 3'b001;
                case (state)
                    3'b000: data <= SEQ1; // after 0xAF -> 0xBC
                    3'b001: data <= SEQ2; // 0xBC -> 0xE2
                    3'b010: data <= SEQ3; // 0xE2 -> 0x78
                    3'b011: data <= SEQ4; // 0x78 -> 0xFF
                    3'b100: data <= SEQ5; // 0xFF -> 0xE2
                    3'b101: data <= SEQ6; // 0xE2 -> 0x0B
                    3'b110: data <= SEQ7; // 0x0B -> 0x8D
                    default: data <= SEQ0; // safety fallback
                endcase
            end
        end
        // If enable == 0, hold current state and data (no change)
    end

endmodule
