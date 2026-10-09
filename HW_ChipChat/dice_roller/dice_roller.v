
module dice_roller (
    input        clk,          // system clock
    input        rst_n,        // active‑low asynchronous reset
    input [1:0]  die_select,   // die selector
    input        roll,         // pulse that initiates a roll
    output reg [7:0] rolled_number   // result (1‑N)
);

    // -------------------------------------------------------------
    // 1.  Edge detector for the roll signal (rising‑edge only)
    // -------------------------------------------------------------
    reg roll_d;                     // delayed version of roll
    wire roll_edge = roll & ~roll_d; // high for one clock when roll goes 0→1

    // -------------------------------------------------------------
    // 2.  16‑bit LFSR (maximal length polynomial x^16+x^14+x^13+x^11+1)
    // -------------------------------------------------------------
    reg [15:0] lfsr;                // LFSR state
    localparam LFSR_SEED = 16'hACE1; // any non‑zero seed works

    wire lfsr_fb = lfsr[15] ^ lfsr[13] ^ lfsr[12] ^ lfsr[10];
    wire [15:0] lfsr_next = {lfsr[14:0], lfsr_fb};

    // -------------------------------------------------------------
    // 3.  Helper registers used inside the always block
    // -------------------------------------------------------------
    integer sides;                  // number of sides of the selected die
    reg  [4:0] rand5;               // 5‑bit random value (0‑31)
    reg  [4:0] tmp;                 // temporary for modulo reduction

    // -------------------------------------------------------------
    // 4.  Main sequential logic
    // -------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin                     // asynchronous reset
            lfsr     <= LFSR_SEED;
            roll_d   <= 1'b0;
            rolled_number <= 8'h0;
        end else begin                        // normal operation
            // capture roll for edge detection next cycle
            roll_d   <= roll;

            // free‑running LFSR update
            lfsr     <= lfsr_next;

            // on a rising edge of roll, produce a die result
            if (roll_edge) begin
                // ----- map die_select to number of sides -----
                case (die_select)
                    2'b00: sides = 4;   // d4
                    2'b01: sides = 6;   // d6
                    2'b10: sides = 8;   // d8
                    2'b11: sides = 20;  // d20
                    default: sides = 4; // fallback (should never happen)
                endcase

                // ----- take 5 LSBs of the LFSR as a raw random number -----
                rand5 = lfsr[4:0];      // value in 0‑31

                // ----- reduce to the range 0‑(sides‑1) -----
                tmp = rand5;
                while (tmp >= sides) begin
                    tmp = tmp - sides;
                end

                // ----- convert to 1‑based die output -----
                rolled_number = tmp + 8'd1;
            end
        end
    end

endmodule
