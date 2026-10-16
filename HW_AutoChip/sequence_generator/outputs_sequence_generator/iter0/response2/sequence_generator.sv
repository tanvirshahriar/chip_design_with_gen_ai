module sequence_generator (
    input  wire        clk,
    input  wire        reset_n,   // active-low reset
    input  wire        enable,
    output reg  [7:0]  data
);

    // Sequence to be generated (hex values)
    localparam [7:0] SEQ0 = 8'hAF;
    localparam [7:0] SEQ1 = 8'hBC;
    localparam [7:0] SEQ2 = 8'hE2;
    localparam [7:0] SEQ3 = 8'h78;
    localparam [7:0] SEQ4 = 8'hFF;
    localparam [7:0] SEQ5 = 8'hE2;
    localparam [7:0] SEQ6 = 8'h0B;
    localparam [7:0] SEQ7 = 8'h8D;

    // ROM holding the sequence
    reg [7:0] seq [0:7];
    initial begin
        seq[0] = SEQ0;
        seq[1] = SEQ1;
        seq[2] = SEQ2;
        seq[3] = SEQ3;
        seq[4] = SEQ4;
        seq[5] = SEQ5;
        seq[6] = SEQ6;
        seq[7] = SEQ7;
    end

    // 3-bit counter to index the sequence
    reg [2:0] idx;

    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            idx   <= 3'd0;
            data  <= seq[0];
        end else if (enable) begin
            // advance to next value, wrap around after the last element
            idx   <= idx + 3'd1;
            data  <= seq[idx + 3'd1]; // output the next value immediately
        end else begin
            // hold current output when enable is low
            data  <= data;
        end
    end

endmodule
