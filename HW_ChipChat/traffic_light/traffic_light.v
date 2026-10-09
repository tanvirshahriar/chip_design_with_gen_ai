
module traffic_light_fsm (
    input  wire        clk,      // system clock
    input  wire        reset_n,  // active‑low asynchronous reset
    input  wire        enable,   // enable counting
    output reg         red,      // RED   light (active‑high)
    output reg         yellow,   // YELLOW light (active‑high)
    output reg         green     // GREEN light (active‑high)
);

    // -----------------------------------------------------------------
    // 1) Parameter definitions (state encoding & timing)
    // -----------------------------------------------------------------
    parameter [1:0] RED   = 2'b00;
    parameter [1:0] GREEN = 2'b01;
    parameter [1:0] YELLOW= 2'b10;

    parameter integer RED_TIME   = 32;
    parameter integer GREEN_TIME = 20;
    parameter integer YELLOW_TIME= 7;

    // -----------------------------------------------------------------
    // 2) State & counter registers
    // -----------------------------------------------------------------
    reg [1:0] state, next_state;
    reg [$clog2(RED_TIME)-1:0] cnt;          // width big enough for the largest timeout

    // -----------------------------------------------------------------
    // 3) Function to obtain timeout for the current state
    // -----------------------------------------------------------------
    function automatic [$clog2(RED_TIME)-1:0] get_timeout;
        input [1:0] st;
        case (st)
            RED   : get_timeout = RED_TIME   - 1'b1;
            GREEN : get_timeout = GREEN_TIME - 1'b1;
            YELLOW: get_timeout = YELLOW_TIME- 1'b1;
            default: get_timeout = 0;
        endcase
    endfunction

    // Continuous assignment: timeout is a read‑only wire
    wire [$clog2(RED_TIME)-1:0] timeout = get_timeout(state);

    // -----------------------------------------------------------------
    // 4) Combinatorial logic: next‑state & output decoding
    // -----------------------------------------------------------------
    // Next‑state logic (only changes when enable is high and timeout reached)
    always @* begin
        // Default: stay in same state
        next_state = state;

        if (enable) begin
            if (cnt == timeout) begin
                case (state)
                    RED   : next_state = GREEN;
                    GREEN : next_state = YELLOW;
                    YELLOW: next_state = RED;
                    default: next_state = RED; // safety fallback
                endcase
            end
        end
    end

    // Output decoding (one‑hot)
    always @* begin
        red    = (state == RED);
        yellow = (state == YELLOW);
        green  = (state == GREEN);
    end

    // -----------------------------------------------------------------
    // 5) Sequential logic: state update & counter
    // -----------------------------------------------------------------
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin          // async active‑low reset
            state  <= RED;
            cnt    <= '0;
        end else begin
            state  <= next_state;

            // Counter only runs when enable is high
            if (enable) begin
                if (cnt == timeout)
                    cnt <= '0;
                else
                    cnt <= cnt + 1'b1;
            end else begin
                // Hold the counter when enable is low
                cnt <= cnt;
            end
        end
    end

endmodule
