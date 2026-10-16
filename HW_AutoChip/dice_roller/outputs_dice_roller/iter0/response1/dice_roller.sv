module dice_roller(
    input        clk,
    input        rst_n,   // active-low reset
    input [1:0]  die_select,
    input        roll,
    output [7:0] rolled_number
);
    // LFSR for pseudo‑random number generation (8-bit, polynomial x^8 + x^6 + x^5 + x^4 + 1)
    reg [7:0] lfsr;
    // Registered output to avoid glitches
    reg [7:0] rolled_number_reg;

    // Asynchronous active‑low reset
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            lfsr        <= 8'hA5;        // non‑zero seed
            rolled_number_reg <= 8'd0;
        end else begin
            if (roll) begin
                // Update LFSR each clock while roll is asserted
                lfsr <= {lfsr[6:0],
                         lfsr[7] ^ lfsr[5] ^ lfsr[4] ^ lfsr[3]};
                // Compute the rolled value based on the selected die
                case (die_select)
                    2'b00: rolled_number_reg <= (lfsr % 4)  + 1;  // d4
                    2'b01: rolled_number_reg <= (lfsr % 6)  + 1;  // d6
                    2'b10: rolled_number_reg <= (lfsr % 8)  + 1;  // d8
                    2'b11: rolled_number_reg <= (lfsr % 20) + 1;  // d20
                    default: rolled_number_reg <= 8'd0;
                endcase
            end
            // If roll is low, hold the last value (no change)
        end
    end

    assign rolled_number = rolled_number_reg;
endmodule
