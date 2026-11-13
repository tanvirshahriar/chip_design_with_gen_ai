// tb_clean.v -- baseline / normal-operation testbench for les_crypto_clean
// Drives the documented SPI protocol (reset, shift-in, START, poll BUSY,
// shift-out) and checks ciphertext against the golden model.
`timescale 1ns/1ps
module tb_clean;
    reg SCK=0, RST_N=1, MOSI=0, NORM_CS_N=1, START=0, ENC_DEC=0;
    wire MISO, BUSY, ICE_LED;
    integer errors=0;

    les_crypto_clean dut(.SCK(SCK),.RST_N(RST_N),.MOSI(MOSI),.MISO(MISO),
        .NORM_CS_N(NORM_CS_N),.START(START),.ENC_DEC(ENC_DEC),
        .BUSY(BUSY),.ICE_LED(ICE_LED));

    task tick; begin #5 SCK=1; #5 SCK=0; end endtask       // one SCK pulse

    task reset_core; begin
        RST_N=0; tick; RST_N=1;                             // sync reset
    end endtask

    task shift_in; input [31:0] w; integer i; begin
        NORM_CS_N=0;
        for (i=31;i>=0;i=i-1) begin MOSI=w[i]; tick; end    // MSB first
        NORM_CS_N=1; MOSI=0;
    end endtask

    task do_start; begin
        START=1; tick; START=0;                             // pulse START (-> BUSY)
        if (BUSY!==1'b1) begin $display("  [warn] BUSY not high after START"); end
        repeat (6) tick;                                    // run the 4 rounds + load
        if (BUSY!==1'b0) begin $display("  [warn] BUSY not low after rounds"); end
    end endtask

    task shift_out; output [31:0] r; integer i; begin
        r=0; NORM_CS_N=0;
        for (i=31;i>=0;i=i-1) begin r[i]=MISO; tick; end    // MSB first
        NORM_CS_N=1;
    end endtask

    task run_enc; input [31:0] p; input [31:0] exp; reg [31:0] got; begin
        ENC_DEC=0; reset_core; shift_in(p); do_start; shift_out(got);
        if (got===exp) $display("  ENC 0x%08h -> 0x%08h  PASS", p, got);
        else begin $display("  ENC 0x%08h -> 0x%08h  expected 0x%08h  FAIL", p, got, exp); errors=errors+1; end
    end endtask

    task run_dec; input [31:0] c; input [31:0] exp; reg [31:0] got; begin
        ENC_DEC=1; reset_core; shift_in(c); do_start; shift_out(got);
        if (got===exp) $display("  DEC 0x%08h -> 0x%08h  PASS", c, got);
        else begin $display("  DEC 0x%08h -> 0x%08h  expected 0x%08h  FAIL", c, got, exp); errors=errors+1; end
    end endtask

    initial begin
        $dumpfile("tb_clean.vcd"); $dumpvars(0,tb_clean);
        $display("== baseline: encryption (KAT first) ==");
        run_enc(32'h59C359C3, 32'h9CD84392);
        run_enc(32'h52E6B438, 32'hAEDD2AB4);
        run_enc(32'hF2A74DE4, 32'hCB0BA525);
        run_enc(32'h269E0D37, 32'h20725F54);
        run_enc(32'h6513270E, 32'h8AA5EDF9);
        run_enc(32'hA6A3A450, 32'h4EEBF933);
        run_enc(32'h0C5C7FD0, 32'h270DBDC4);
        run_enc(32'h128B2F33, 32'h4F292871);
        $display("== baseline: decryption ==");
        run_dec(32'h9CD84392, 32'h59C359C3);
        if (errors==0) $display("\nALL TESTS PASSED");
        else           $display("\n%0d TEST(S) FAILED", errors);
        $finish;
    end
endmodule
