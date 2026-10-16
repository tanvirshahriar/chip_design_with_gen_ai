module traffic_light_fsm(
    input        clk,
    input        reset_n,   // active‑low reset
    input        enable,
    output reg   red,
    output reg   yellow,
    output reg   green
);

    // State encoding
    typedef enum logic [1:0] {
        RED   = 2'b00,
        GREEN = 2'b01,
        YELLOW= 2'b10
    } state_t;

    state_t state, next_state;

    // Timing constants (number of clock cycles to stay in each state)
    localparam integer RED_TIME   = 32;
    localparam integer GREEN_TIME = 20;
    localparam integer YELLOW_TIME = 7;

    // Counter that tracks how many cycles we have been in the current state
    reg [$clog2(RED_TIME)-1:0] count; // width big enough for the largest timeout

    // Next‑state logic (combinational)
    always_comb begin
        // Default: stay in current state
        next_state = state;

        case (state)
            RED:   if (enable && count == RED_TIME-1)   next_state = GREEN;
            GREEN: if (enable && count == GREEN_TIME-1) next_state = YELLOW;
            YELLOW:if (enable && count == YELLOW_TIME-1)next_state = RED;
        endcase
    end

    // State register and counter update (sequential)
    always_ff @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state  <= RED;
            count  <= 0;
            red    <= 1'b1;
            yellow <= 1'b0;
            green  <= 1'b0;
        end else begin
            state  <= next_state;

            // Update counter only when enabled
            if (enable) begin
                if (count == (state == RED   ? RED_TIME-1   :
                              state == GREEN ? GREEN_TIME-1 :
                              state == YELLOW? YELLOW_TIME-1 : 0))
                    count <= 0; // reset counter when we are about to change state
                else
                    count <= count + 1;
            end else begin
                // When enable is low, hold the current state and counter
                count <= count;
            end

            // Output logic (registered for glitch‑free outputs)
            red    <= (state == RED);
            yellow <= (state == YELLOW);
            green  <= (state == GREEN);
        end
    end

endmodule
