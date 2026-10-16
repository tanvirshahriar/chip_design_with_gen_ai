module dice_roller (
    input        clk,
    input        rst_n,      // active‑low reset
    input [1:0]  die_select, // 00:4‑sided, 01:6‑sided, 10:8‑sided, 11:20‑sided
    input        roll,       // pulse to trigger a roll
    output reg [7:0] rolled_number
);
    // ---------- LFSR for pseudo‑random data ----------
    reg [7:0] lfsr;

    // simple 8‑bit LFSR (taps at bits 7,5,4,3)
    wire feedback = lfsr[7] ^ lfsr[5] ^ lfsr[4] ^ lfsr[3];

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lfsr <= 8'hA5;   // any non‑zero seed
        end else begin
            lfsr <= {lfsr[6:0], feedback};
        end
    end

    // ---------- Edge detection for roll ----------
    reg roll_d;
    always @(posedge clk) roll_d <= roll;
    wire roll_edge = roll & ~roll_d;

    // ---------- Map LFSR output to die range ----------
    // sides encoding: 00->4, 01->6, 10->8, 11->20
    reg [4:0] sides;   // enough for max 20
    always @* begin
        case (die_select)
            2'b00: sides = 5'd4;
            2'b01: sides = 5'd6;
            2'b10: sides = 5'd8;
            2'b11: sides = 5'd20;
            default: sides = 5'd4;
        endcase
    end

    // ---------- Capture rolled value ----------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            rolled_number <= 8'd0;
        end else if (roll_edge) begin
            // (lfsr % sides) gives 0..sides-1, add 1 for 1..sides
            rolled_number <= { {(8-5){1'b0}}, (lfsr % sides) + 1'b1 };
        end
        // hold previous value when no roll edge
    end
endmodule
