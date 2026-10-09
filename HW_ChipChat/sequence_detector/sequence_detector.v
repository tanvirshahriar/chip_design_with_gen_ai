
module sequence_detector (
    input  wire        clk,
    input  wire        reset_n,   // active‑low asynchronous reset
    input  wire [2:0]  data,
    output reg         sequence_found
);

    // ----- state encoding -----
    parameter S0 = 4'd0;
    parameter S1 = 4'd1;
    parameter S2 = 4'd2;
    parameter S3 = 4'd3;
    parameter S4 = 4'd4;
    parameter S5 = 4'd5;
    parameter S6 = 4'd6;
    parameter S7 = 4'd7;

    reg [3:0] state;
    reg [3:0] next_state;

    // ----- state register (async reset) -----
    always @(posedge clk or negedge reset_n) begin
        if (!reset_n) begin
            state <= S0;
        end else begin
            state <= next_state;
        end
    end

    // ----- next‑state logic -----
    always @* begin
        // default: stay in current state (will be overridden on match/mismatch)
        next_state = state;

        case (state)
            S0: begin
                if (data == 3'b001) next_state = S1;
                else                next_state = S0;
            end
            S1: begin
                if (data == 3'b101) next_state = S2;
                else                next_state = (data == 3'b001) ? S1 : S0;
            end
            S2: begin
                if (data == 3'b110) next_state = S3;
                else                next_state = (data == 3'b001) ? S1 : S0;
            end
            S3: begin
                if (data == 3'b000) next_state = S4;
                else                next_state = (data == 3'b001) ? S1 : S0;
            end
            S4: begin
                if (data == 3'b110) next_state = S5;
                else                next_state = (data == 3'b001) ? S1 : S0;
            end
            S5: begin
                if (data == 3'b110) next_state = S6;
                else                next_state = (data == 3'b001) ? S1 : S0;
            end
            S6: begin
                if (data == 3'b011) next_state = S7;
                else                next_state = (data == 3'b001) ? S1 : S0;
            end
            S7: begin
                if (data == 3'b101) next_state = S0;   // pattern completed -> restart
                else                next_state = (data == 3'b001) ? S1 : S0;
            end
            default: next_state = S0;
        endcase
    end

    // ----- output logic (combinational) -----
    always @* begin
        if (!reset_n) begin
            sequence_found = 1'b0;
        end else begin
            sequence_found = (state == S7 && data == 3'b101);
        end
    end

endmodule
