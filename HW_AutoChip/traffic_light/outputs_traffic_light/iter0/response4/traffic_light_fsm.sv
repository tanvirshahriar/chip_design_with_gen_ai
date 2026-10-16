module traffic_light_fsm (
    input  wire        clk,
    input  wire        reset_n,   // active-low reset
    input  wire        enable,
    output reg         red,
    output reg         yellow,
    output reg         green
);

    // State encoding
    localparam [1:0] STATE_RED   = 2'b00;
    localparam [1:0] STATE_GREEN = 2'b01;
    localparam [1:0] STATE_YELLOW= 2'b10;

    // Timer values (in clock cycles)
    localparam integer RED_TIME   = 32;
    localparam integer GREEN_TIME = 20;
    localparam integer YELLOW_TIME= 7;

    // State registers
    reg [1:0] state;
    reg [1:0] next_state;
    reg [5:0] count; // enough to hold max(RED_TIME,GREEN_TIME,YELLOW_TIME)-1

    // Combinational next-state logic
    always @* begin
        case (state)
            STATE_RED:    next_state = STATE_GREEN;
            STATE_GREEN:  next_state = STATE_YELLOW;
            STATE_YELLOW: next_state = STATE_RED;
            default:      next_state = STATE_RED;
        endcase
    end

    // Sequential state and counter update
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state    <= STATE_RED;
            count    <= 6'd0;
        end else if (enable) begin
            // Determine the timeout for the current state
            integer timeout;
            case (state)
                STATE_RED:    timeout = RED_TIME;
                STATE_GREEN:  timeout = GREEN_TIME;
                STATE_YELLOW: timeout = YELLOW_TIME;
                default:      timeout = RED_TIME;
            endcase

            if (count == timeout - 1) begin
                // Time elapsed: move to next state and reset counter
                count    <= 6'd0;
                state    <= next_state;
            end else begin
                // Still counting within the current state
                count    <= count + 6'd1;
            end
        end
        // If enable is low, hold current state and counter
    end

    // Output logic (one-hot)
    always @* begin
        red    = (state == STATE_RED);
        yellow = (state == STATE_YELLOW);
        green  = (state == STATE_GREEN);
    end

endmodule
