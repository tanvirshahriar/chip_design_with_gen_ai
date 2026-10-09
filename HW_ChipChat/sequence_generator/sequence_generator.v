
module sequence_generator (
    input  wire       clk,
    input  wire       reset_n,   // active‑low asynchronous reset
    input  wire       enable,
    output wire [7:0] data
);

    // ROM with the constant sequence
    reg [7:0] seq [0:7];
    reg [2:0] ptr;                 // 3‑bit pointer (0‑7)

    initial begin
        seq[0] = 8'hAF;
        seq[1] = 8'hBC;
        seq[2] = 8'hE2;
        seq[3] = 8'h78;
        seq[4] = 8'hFF;
        seq[5] = 8'hE2;
        seq[6] = 8'h0B;
        seq[7] = 8'h8D;
    end

    // Pointer update: reset clears it; on each enabled clock edge it advances.
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            ptr <= 3'b0;                 // reset to first element
        end else if (enable) begin
            ptr <= (ptr + 1) % 8;        // wrap‑around counter
        end
        // If enable == 0 the pointer holds its value.
    end

    // Combinational output directly from the ROM.
    assign data = seq[ptr];

endmodule
