`timescale 1ns/1ps

module tb(); // renamed for AutoChip (-s tb)
    reg clk;
    reg rst_n;
    reg A;
    reg B;
    wire O;
    wire [3:0] State;
    integer errors = 0, samples = 0;

    // Instantiate the ABRO state machine
    abro_state_machine uut (
        .clk(clk),
        .rst_n(rst_n),
        .A(A),
        .B(B),
        .O(O),
        .State(State)
    );

    // Clock generation
    always begin
        #5 clk = ~clk;
    end

    integer i;

    // EDIT: reference ABRO FSM replaces the original hard-coded expected values,
    // which contradicted each other (states as defined in the prompt)
    reg [3:0] expected_state;
    always @(posedge clk) begin
        if (!rst_n) expected_state <= 4'b0001;
        else case (expected_state)
            4'b0001: expected_state <= (A && B) ? 4'b1000 : A ? 4'b0010 : B ? 4'b0100 : 4'b0001;
            4'b0010: expected_state <= B ? 4'b1000 : 4'b0010;
            4'b0100: expected_state <= A ? 4'b1000 : 4'b0100;
            default: expected_state <= 4'b1000;
        endcase
    end
    wire expected_O = (expected_state == 4'b1000);

    // Test stimulus and checking
    initial begin
        // Initialize signals
        clk = 0;
        rst_n = 1;
        A = 0;
        B = 0;

        // Test cases
        for (i = 0; i < 16; i = i + 1) begin
            // Determine the input and expected output based on the test case index
            case (i)
                0: begin
                    A = 0; B = 0; // Reset
                end
                1: begin
                    A = 0; B = 1; // A=0, B=1
                end
                2: begin
                    A = 1; B = 0; // A=1, B=0
                end
                3: begin
                    A = 1; B = 1; // A=1, B=1
                end
                default: begin
                    // Repeat the same sequence of inputs for the remaining test cases
                    A = (i-1) % 2;
                    B = ((i-1) / 2) % 2;
                end
            endcase

            // Apply reset
            if (i == 0) begin
                rst_n = 0;
                @(negedge clk); // EDIT was posedge (race)
                rst_n = 1;
            end

            @(negedge clk); // EDIT: was posedge (race); state changes on the rising edge before this

            // Check the output and state
            samples = samples + 1; // EDIT: count instead of $finish
            if (O !== expected_O || State !== expected_state) begin
                $display("Error: Test case %0d failed (A=%b, B=%b)", i, A, B);
                $display("  Expected: O=%b, State=%b", expected_O, expected_state);
                $display("  Got: O=%b, State=%b", O, State);
                errors = errors + 1;
            end
        end

        if (errors == 0) $display("All test cases passed."); // EDIT: only print on pass
        $finish;
    end


	reg vcd_clk;
initial begin
    $dumpfile("my_design.vcd");
    $dumpvars(0, tb);
end

always #5 vcd_clk = ~vcd_clk; // Toggle clock every 5 time units

    final $display("Mismatches: %1d in %1d samples", errors, samples); // EDIT:  parsed by AutoChip

endmodule
