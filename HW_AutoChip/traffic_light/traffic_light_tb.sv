`timescale 1ps/1ps

module tb();

reg clk;
reg reset_n;
reg enable;
wire red;
wire yellow;
wire green;

integer error_count;
integer samples = 0;

// Instantiate the traffic_light_fsm
traffic_light_fsm traffic_light (
    .clk(clk),
    .reset_n(reset_n),
    .enable(enable),
    .red(red),
    .yellow(yellow),
    .green(green)
);

// Clock generation
always begin
    #5 clk = ~clk;
end

// Check the output and print test results
task check_output;
    input integer cycle;
    input logic exp_red;
    input logic exp_yellow;
    input logic exp_green;
    input integer test_case;
begin
    @(negedge clk);
    samples = samples + 1;
    if (red !== exp_red || yellow !== exp_yellow || green !== exp_green) begin
        $display("Error: Test case %0d failed - FSM did not transition to %s after %0d clock cycles.", test_case, exp_red ? "RED" : (exp_yellow ? "YELLOW" : "GREEN"), cycle);
        error_count = error_count + 1;
    end else begin
        $display("Test case %0d passed - FSM transitioned to %s after %0d clock cycles.", test_case, exp_red ? "RED" : (exp_yellow ? "YELLOW" : "GREEN"), cycle);
    end
end
endtask

initial begin
    // Initialize signals
    clk = 0;
    reset_n = 0;
    enable = 1;

    // Initialize error_count
    error_count = 0;

    // Test case 1 - Check if the FSM starts with the RED state
    check_output(0, 1, 0, 0, 1);

    // Apply reset
    reset_n = 1; // EDIT: was #5 (released on a rising edge, race)

    // Test case 2 - Check if the FSM transitions to GREEN after 32 clock cycles
    repeat (32) @(posedge clk);
    check_output(32, 0, 0, 1, 2);

    // Test case 3 - Check if the FSM transitions to YELLOW after 20 clock cycles
    repeat (20) @(posedge clk);
    check_output(20, 0, 1, 0, 3);

    // Test case 4 - Check if the FSM transitions to RED after 7 clock cycles
    repeat (7) @(posedge clk);
    check_output(7, 1, 0, 0, 4);

    if (error_count > 0) begin
        $display("Error: %0d test cases failed.", error_count);
    end else begin
        $display("All test cases passed!");
    end
    $finish;
end

final $display("Mismatches: %1d in %1d samples", error_count, samples); // EDIT: parsed by AutoChip

endmodule
