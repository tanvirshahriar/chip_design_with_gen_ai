module traffic_light_fsm(
    input  clk,
    input  reset_n,   // active‑low reset
    input  enable,
    output red,
    output yellow,
    output green
);
    // State encoding
    localparam RED   = 2'b00,
               GREEN = 2'b01,
               YELLOW = 2'b10;

    reg [1:0] state;
    reg [5:0] cnt;   // enough to count up to 31 (32 cycles)

    // State transition logic
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= RED;
            cnt   <= 0;
        end else if (enable) begin
            case (state)
                RED: begin
                    if (cnt == 6'd31) begin   // 32 cycles elapsed
                        state <= GREEN;
                        cnt   <= 0;
                    end else begin
                        cnt <= cnt + 1'b1;
                    end
                end
                GREEN: begin
                    if (cnt == 6'd19) begin   // 20 cycles elapsed
                        state <= YELLOW;
                        cnt   <= 0;
                    end else begin
                        cnt <= cnt + 1'b1;
                    end
                end
                YELLOW: begin
                    if (cnt == 6'd6) begin    // 7 cycles elapsed
                        state <= RED;
                        cnt   <= 0;
                    end else begin
                        cnt <= cnt + 1'b1;
                    end
                end
                default: begin   // safety fallback
                    state <= RED;
                    cnt   <= 0;
                end
            endcase
        end else begin
            // Enable low → hold current state and counter
            state <= state;
            cnt   <= cnt;
        end
    end

    // Output assignments
    assign red    = (state == RED);
    assign yellow = (state == YELLOW);
    assign green  = (state == GREEN);
endmodule
