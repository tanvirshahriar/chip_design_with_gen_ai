module traffic_light_fsm(
    input clk,
    input reset_n,
    input enable,
    output red,
    output yellow,
    output green
);
    // State encoding
    localparam [1:0] RED   = 2'b00,
                     GREEN = 2'b01,
                     YELLOW= 2'b10;

    // Timer limits for each state
    localparam [5:0] T_RED   = 6'd32,
                     T_GREEN = 6'd20,
                     T_YELLOW= 6'd7;

    reg [1:0] state;
    reg [5:0] cnt;

    // Next state and timer logic
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= RED;
            cnt   <= 6'd0;
        end else if (enable) begin
            case (state)
                RED: begin
                    if (cnt == T_RED - 1) begin
                        state <= GREEN;
                        cnt   <= 6'd0;
                    end else
                        cnt <= cnt + 1'b1;
                end
                GREEN: begin
                    if (cnt == T_GREEN - 1) begin
                        state <= YELLOW;
                        cnt   <= 6'd0;
                    end else
                        cnt <= cnt + 1'b1;
                end
                YELLOW: begin
                    if (cnt == T_YELLOW - 1) begin
                        state <= RED;
                        cnt   <= 6'd0;
                    end else
                        cnt <= cnt + 1'b1;
                end
                default: begin
                    state <= RED;
                    cnt   <= 6'd0;
                end
            endcase
        end
        // If enable is low, hold state and timer unchanged
    end

    // Output assignments
    assign red   = (state == RED);
    assign yellow= (state == YELLOW);
    assign green = (state == GREEN);

endmodule
