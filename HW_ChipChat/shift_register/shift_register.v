
module shift_register (
    input  wire       clk,
    input  wire       reset_n,
    input  wire       data_in,
    input  wire       shift_enable,
    output reg [7:0] data_out
);

    // Synchronous active‑low reset
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin               // reset asserted (active‑low)
            data_out <= 8'b0;
        end else if (shift_enable) begin  // shift enabled
            // Left‑shift: insert data_in at LSB
            data_out <= {data_out[6:0], data_in};
        end else begin                    // hold current value
            data_out <= data_out;
        end
    end

endmodule
