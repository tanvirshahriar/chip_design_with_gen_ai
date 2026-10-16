module traffic_light_fsm(
    input  clk,
    input  reset_n,   // active-low reset
    input  enable,
    output reg red,
    output reg yellow,
    output reg green
);
    // State encoding
    localparam [1:0] RED   = 2'b00,
                     GREEN = 2'b01,
                     YELLOW= 2'b10;

    // State registers
    reg [1:0] state, next_state;
    // Counter registers (enough to hold up to 31)
    reg [5:0] cnt, next_cnt;

    // Sequential logic: state and counter updates
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state  <= RED;
            cnt    <= 6'd0;
        end else if (enable) begin
            state  <= next_state;
            cnt    <= next_cnt;
        end else begin
            // Hold current state and counter when enable is low
            state  <= state;
            cnt    <= cnt;
        end
    end

    // Combinational logic: next state and next counter
    always @* begin
        // Defaults: hold state and counter
        next_state = state;
        next_cnt   = cnt;

        case (state)
            RED: begin
                if (enable) begin
                    if (cnt == 6'd31) begin   // 32 cycles elapsed
                        next_state = GREEN;
                        next_cnt   = 6'd0;
                    end else begin
                        next_cnt = cnt + 1'd1;
                    end
                end
            end
            GREEN: begin
                if (enable) begin
                    if (cnt == 6'd19) begin   // 20 cycles elapsed
                        next_state = YELLOW;
                        next_cnt   = 6'd0;
                    end else begin
                        next_cnt = cnt + 1'd1;
                    end
                end
            end
            YELLOW: begin
                if (enable) begin
                    if (cnt == 6'd6) begin    // 7 cycles elapsed
                        next_state = RED;
                        next_cnt   = 6'd0;
                    end else begin
                        next_cnt = cnt + 1'd1;
                    end
                end
            end
            default: begin
                // Should never happen
                next_state = RED;
                next_cnt   = 6'd0;
            end
        endcase
    end

    // Output logic
    always @* begin
        red    = (state == RED);
        yellow = (state == YELLOW);
        green  = (state == GREEN);
    end

endmodule
