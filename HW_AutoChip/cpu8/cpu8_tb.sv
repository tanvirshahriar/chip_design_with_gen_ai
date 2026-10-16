`timescale 1ns/1ps
// Own testbench for the LLM-proposed CPU (cpu8_acc)
// Program: load 3 from RAM, output it and count down to 0 (OUT 3, 2, 1), then add 9 and store it.
// Checks the three OUT values, the number of OUTs and the stored result (5 samples).
// The last line printed is "Mismatches: <n> in <m> samples" (parsed by AutoChip).
module tb;
    reg clk = 0, rst_n = 0;
    always #5 clk = ~clk;

    wire [7:0] imem_addr, dmem_addr, dmem_data, io_data_out;
    wire       dmem_we, io_wr;
    wire [2:0] io_port;

    reg  [7:0] rom [0:255];
    reg  [7:0] ram [0:255];
    wire [7:0] imem_data = rom[imem_addr];
    assign dmem_data = (dmem_we === 1'b1) ? 8'bz : ram[dmem_addr];
    always @(posedge clk) if (dmem_we === 1'b1) ram[dmem_addr] <= dmem_data;

    cpu8_acc dut (.clk(clk), .rst_n(rst_n),
                  .imem_addr(imem_addr), .imem_data(imem_data),
                  .dmem_addr(dmem_addr), .dmem_data(dmem_data), .dmem_we(dmem_we),
                  .io_port(io_port), .io_wr(io_wr), .io_data_in(8'h00), .io_data_out(io_data_out));

    // record the value of every OUT (rising edge of io_wr)
    reg io_wr_prev = 0;
    integer n_out = 0;
    reg [7:0] outs [0:7];
    always @(negedge clk) begin
        if (rst_n && io_wr === 1'b1 && !io_wr_prev && n_out < 8) begin
            outs[n_out] = io_data_out;
            n_out = n_out + 1;
        end
        io_wr_prev = (io_wr === 1'b1);
    end

    // execution trace: instruction addresses fetched and RAM writes
    integer n_tr = 0, n_wr = 0;
    reg [7:0] tr_addr [0:23];
    reg [7:0] last_addr;
    reg [7:0] wr_addr [0:7], wr_data [0:7];
    reg dmem_we_prev = 0;
    always @(posedge rst_n) begin   // first fetch address, right when reset is released
        tr_addr[0] = imem_addr;
        last_addr  = imem_addr;
        n_tr = 1;
    end
    always @(negedge clk) begin
        if (rst_n) begin
            if ((n_tr == 0 || imem_addr !== last_addr) && n_tr < 24) begin
                tr_addr[n_tr] = imem_addr;
                n_tr = n_tr + 1;
            end
            last_addr = imem_addr;
            if (dmem_we === 1'b1 && !dmem_we_prev && n_wr < 8) begin
                wr_addr[n_wr] = dmem_addr;
                wr_data[n_wr] = dmem_data;
                n_wr = n_wr + 1;
            end
            dmem_we_prev = (dmem_we === 1'b1);
        end
    end

    integer i, errors = 0, samples = 0;
    task check(input [8*16-1:0] what, input [7:0] got, input [7:0] exp);
        begin
            samples = samples + 1;
            if (got !== exp) begin
                errors = errors + 1;
                $display("Error: %0s = %0d, expected %0d", what, got, exp);
            end
        end
    endtask

    initial begin
        for (i = 0; i < 256; i = i + 1) begin rom[i] = 8'hAF; ram[i] = 8'h00; end
        rom[0] = 8'h10; // LDHI 0      MAR = 0x0?
        rom[1] = 8'h25; // LDLO 5      MAR = 0x05
        rom[2] = 8'h30; // LOAD        ACC = RAM[5] = 3
        rom[3] = 8'hF9; // OUT port 1  (outputs 3, 2, 1)
        rom[4] = 8'h61; // SUB 1
        rom[5] = 8'hB1; // JZ +1       -> 7 when ACC = 0
        rom[6] = 8'hAC; // JMP -4      -> 3
        rom[7] = 8'h59; // ADD 9       ACC = 9
        rom[8] = 8'h40; // STORE       RAM[5] = 9
        rom[9] = 8'hAF; // JMP -1      (stop)
        ram[5] = 8'd3;

        #12 rst_n = 1;
        repeat (300) @(negedge clk);

        check("number of OUTs", n_out,   8'd3);
        check("OUT #0",         outs[0], 8'd3);
        check("OUT #1",         outs[1], 8'd2);
        check("OUT #2",         outs[2], 8'd1);
        check("RAM[5]",         ram[5],  8'd9);
        if (errors == 0) $display("CPU test passed");
        else begin   // ====TANVIR NEW==== print the trace on failure
            $display("Program (ROM address: byte instruction): 0:10 LDHI 0 | 1:25 LDLO 5 | 2:30 LOAD | 3:F9 OUT port 1 | 4:61 SUB 1 | 5:B1 JZ +1 | 6:AC JMP -4 | 7:59 ADD 9 | 8:40 STORE | 9:AF JMP -1. RAM[5] starts at 3.");
            $display("Expected instruction address order: 0 1 2 3 4 5 6 3 4 5 6 3 4 5 7 8 9");
            $write("Actual instruction addresses fetched (imem_addr):");
            for (i = 0; i < n_tr; i = i + 1) $write(" %0d", tr_addr[i]);
            $display("");
            $write("RAM writes (address=data):");
            for (i = 0; i < n_wr; i = i + 1) $write(" %0d=%0d", wr_addr[i], wr_data[i]);
            if (n_wr == 0) $write(" none");
            $display("   (expected: 5=9)");
        end
        $finish;
    end

    final $display("Mismatches: %1d in %1d samples", errors, samples);
endmodule
