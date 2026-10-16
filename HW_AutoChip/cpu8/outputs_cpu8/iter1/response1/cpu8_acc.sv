module cpu8_acc (
    input  wire        clk,
    input  wire        rst_n,

    // Instruction ROM
    output wire [7:0]  imem_addr,
    input  wire [7:0]  imem_data,

    // Data RAM
    output wire [7:0]  dmem_addr,
    inout  wire [7:0]  dmem_data,
    output wire        dmem_we,

    // Simple I/O
    output wire [2:0]  io_port,
    output wire        io_wr,
    input  wire [7:0]  io_data_in,
    output wire [7:0]  io_data_out
);

    // Programmer‑visible registers
    reg  [7:0] ACC;
    reg  [7:0] MAR;
    reg  [7:0] PC;
    reg  [7:0] SP;          // internal stack pointer (not visible to software)
    reg        Z, N, C;     // flags

    // Instruction register (optional, used for clarity)
    reg  [7:0] IR;

    // Control signals for memory and I/O
    reg        dmem_we_int;
    reg  [7:0] dmem_addr_int;
    reg  [7:0] dmem_data_out_int;
    reg        io_wr_int;
    reg  [2:0] io_port_int;
    reg  [7:0] io_data_out_int;

    // Fetch address
    assign imem_addr = PC;

    // Memory bus handling
    assign dmem_addr = dmem_addr_int;
    assign dmem_we   = dmem_we_int;
    assign dmem_data = dmem_we_int ? dmem_data_out_int : 8'bz;
    wire [7:0] dmem_read = dmem_data;   // value read from RAM when not driving

    // I/O bus handling
    assign io_port    = io_port_int;
    assign io_wr      = io_wr_int;
    assign io_data_out= io_data_out_int;

    // Sign‑extend 4‑bit immediate to 8‑bit
    function [7:0] sext4;
        input [3:0] x;
        sext4 = {{4{x[3]}}, x};
    endfunction

    // Main sequential logic
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ACC   <= 8'h0;
            MAR   <= 8'h0;
            PC    <= 8'h0;
            SP    <= 8'hFF;   // start of stack at top of RAM
            Z     <= 1'b0;
            N     <= 1'b0;
            C     <= 1'b0;
            IR    <= 8'h0;
            dmem_we_int   <= 1'b0;
            dmem_addr_int <= 8'hz;
            dmem_data_out_int <= 8'hz;
            io_wr_int     <= 1'b0;
            io_port_int   <= 3'h0;
            io_data_out_int <= 8'hz;
        end else begin
            // Fetch instruction
            IR <= imem_data;

            // Defaults (no change)
            ACC   <= ACC;
            MAR   <= MAR;
            PC    <= PC + 1;        // fall‑through PC
            SP    <= SP;
            Z     <= Z;
            N     <= N;
            C     <= C;
            dmem_we_int   <= 1'b0;
            dmem_addr_int <= 8'hz;
            dmem_data_out_int <= 8'hz;
            io_wr_int     <= 1'b0;
            io_port_int   <= 3'h0;
            io_data_out_int <= 8'hz;

            // Decode and execute
            case (IR[7:4])
                4'h0: ; // NOP

                4'h1: begin // LDHI #imm4
                    MAR[7:4] <= IR[3:0];
                end

                4'h2: begin // LDLO #imm4
                    MAR[3:0] <= IR[3:0];
                end

                4'h3: begin // LOAD
                    ACC   <= dmem_read;
                end

                4'h4: begin // STORE
                    dmem_we_int   <= 1'b1;
                    dmem_addr_int <= MAR;
                    dmem_data_out_int <= ACC;
                end

                4'h5: begin // ADD #imm4
                    reg [8:0] sum;
                    sum = ACC + {{4{1'b0}}, IR[3:0]};
                    ACC   <= sum[7:0];
                    Z     <= (sum[7:0] == 8'h0);
                    N     <= sum[7];
                    C     <= sum[8];
                end

                4'h6: begin // SUB #imm4
                    reg [8:0] diff;
                    diff = ACC - {{4{1'b0}}, IR[3:0]};
                    ACC   <= diff[7:0];
                    Z     <= (diff[7:0] == 8'h0);
                    N     <= diff[7];
                    C     <= (ACC >= {{4{1'b0}}, IR[3:0]}) ? 1'b1 : 1'b0;
                end

                4'h7: begin // AND #imm4
                    reg [7:0] temp;
                    temp = ACC & {{4{1'b0}}, IR[3:0]};
                    ACC   <= temp;
                    Z     <= (temp == 8'h0);
                    N     <= temp[7];
                end

                4'h8: begin // OR #imm4
                    reg [7:0] temp;
                    temp = ACC | {{4{1'b0}}, IR[3:0]};
                    ACC   <= temp;
                    Z     <= (temp == 8'h0);
                    N     <= temp[7];
                end

                4'h9: begin // XOR #imm4
                    reg [7:0] temp;
                    temp = ACC ^ {{4{1'b0}}, IR[3:0]};
                    ACC   <= temp;
                    Z     <= (temp == 8'h0);
                    N     <= temp[7];
                end

                4'hA: begin // JMP rel4
                    PC    <= PC + 1 + sext4(IR[3:0]);
                end

                4'hB: begin // JZ rel4
                    if (Z)
                        PC <= PC + 1 + sext4(IR[3:0]);
                    else
                        PC <= PC + 1;
                end

                4'hC: begin // JC rel4
                    if (C)
                        PC <= PC + 1 + sext4(IR[3:0]);
                    else
                        PC <= PC + 1;
                end

                4'hD: begin // CALL rel4
                    // push return address (PC+1) onto stack
                    dmem_we_int   <= 1'b1;
                    dmem_addr_int <= SP - 1;
                    dmem_data_out_int <= PC + 1;
                    SP            <= SP - 1;
                    PC            <= PC + 1 + sext4(IR[3:0]);
                end

                4'hE: begin // RET
                    // pop return address from stack
                    dmem_we_int   <= 1'b0;
                    dmem_addr_int <= SP;
                    PC            <= dmem_read;
                    SP            <= SP + 1;
                end

                4'hF: begin // IO bppp
                    reg b;
                    reg [2:0] ppp;
                    b = IR[3];
                    ppp = IR[2:0];
                    io_port_int   <= ppp;
                    if (b == 0) begin // IN
                        ACC   <= io_data_in;
                        io_wr_int     <= 1'b0;
                        io_data_out_int <= 8'hz;
                    end else begin // OUT
                        io_wr_int     <= 1'b1;
                        io_data_out_int <= ACC;
                    end
                end

                default: ; // should not happen
            endcase
        end
    end
endmodule
