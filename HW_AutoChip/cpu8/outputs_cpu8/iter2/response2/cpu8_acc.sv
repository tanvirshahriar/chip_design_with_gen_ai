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
    output reg  [2:0]  io_port,
    output reg         io_wr,
    input  wire [7:0]  io_data_in,
    output reg [7:0]   io_data_out
);
    // -----------------------------------------------------------------
    // Internal registers
    // -----------------------------------------------------------------
    reg  [7:0] ACC;        // Accumulator
    reg  [7:0] MAR;        // Memory Address Register
    reg  [2:0] FLAGS;      // {Z, N, C}
    reg  [7:0] PC;         // Program Counter
    reg  [7:0] IR;         // Instruction Register
    reg  [7:0] SP;         // Stack Pointer (points to next free location)

    // Memory control signals
    reg  [7:0] dmem_addr_reg;
    reg        dmem_we_reg;
    reg  [7:0] dmem_data_out;   // driven onto dmem_data when writing

    // -----------------------------------------------------------------
    // Wire declarations for decoding
    // -----------------------------------------------------------------
    wire [3:0] opcode = IR[7:4];
    wire [3:0] operand = IR[3:0];

    wire [7:0] imm4        = {4'b0, operand};               // zero‑extended 4‑bit immediate
    wire [7:0] imm4_se     = {{4{operand[3]}}, operand};    // sign‑extended 4‑bit immediate
    wire [7:0] pc_plus_1   = PC + 8'd1;
    wire [7:0] branch_target = pc_plus_1 + imm4_se;

    // FLAGS bit positions: [2] = Z, [1] = N, [0] = C
    wire Z = FLAGS[2];
    wire N = FLAGS[1];
    wire C = FLAGS[0];

    // -----------------------------------------------------------------
    // Memory port handling (inout)
    // -----------------------------------------------------------------
    wire [7:0] dmem_data_in = dmem_data;
    assign dmem_data = dmem_we_reg ? dmem_data_out : 8'bz;

    // -----------------------------------------------------------------
    // Combinational next-state and control logic
    // -----------------------------------------------------------------
    reg  [7:0] ACC_next;
    reg  [7:0] MAR_next;
    reg  [2:0] FLAGS_next;
    reg  [7:0] PC_next;
    reg  [7:0] SP_next;

    always @* begin
        // Defaults (hold values, no memory activity, no I/O)
        ACC_next   = ACC;
        MAR_next   = MAR;
        FLAGS_next = FLAGS;
        PC_next    = pc_plus_1;        // default: PC+1
        SP_next    = SP;
        dmem_addr_reg  = 8'd0;
        dmem_we_reg    = 1'b0;
        dmem_data_out  = 8'd0;
        io_port    = 3'd0;
        io_wr      = 1'b0;
        io_data_out = 8'd0;

        case (opcode)
            4'h0: ; // NOP

            4'h1: MAR_next = {operand, MAR[3:0]};          // LDHI

            4'h2: MAR_next = {MAR[7:4], operand};          // LDLO

            4'h3: begin // LOAD
                    dmem_addr_reg = MAR;
                    dmem_we_reg   = 1'b0;
                    ACC_next      = dmem_data_in;
                  end

            4'h4: begin // STORE
                    dmem_addr_reg = MAR;
                    dmem_we_reg   = 1'b1;
                    dmem_data_out = ACC;
                  end

            4'h5: begin // ADD #imm4
                    wire [8:0] sum = ACC + imm4;
                    ACC_next = sum[7:0];
                    FLAGS_next = { (sum[7:0] == 8'd0), sum[7], sum[8] }; // Z,N,C
                  end

            4'h6: begin // SUB #imm4
                    wire [8:0] diff = ACC - imm4;
                    ACC_next = diff[7:0];
                    FLAGS_next = { (diff[7:0] == 8'd0), diff[7], ~diff[8] }; // Z,N,C (C=~borrow)
                  end

            4'h7: begin // AND #imm4
                    ACC_next = ACC & imm4;
                    FLAGS_next = { ((ACC & imm4) == 8'd0), (ACC & imm4)[7], FLAGS[0] }; // Z,N (C unchanged)
                  end

            4'h8: begin // OR #imm4
                    ACC_next = ACC | imm4;
                    FLAGS_next = { ((ACC | imm4) == 8'd0), (ACC | imm4)[7], FLAGS[0] };
                  end

            4'h9: begin // XOR #imm4
                    ACC_next = ACC ^ imm4;
                    FLAGS_next = { ((ACC ^ imm4) == 8'd0), (ACC ^ imm4)[7], FLAGS[0] };
                  end

            4'hA: begin // JMP rel4
                    PC_next = branch_target;
                  end

            4'hB: begin // JZ rel4
                    if (Z) PC_next = branch_target;
                  end

            4'hC: begin // JC rel4
                    if (C) PC_next = branch_target;
                  end

            4'hD: begin // CALL rel4
                    // Push PC+1 onto stack (stack grows down)
                    dmem_addr_reg = SP - 8'd1;
                    dmem_we_reg   = 1'b1;
                    dmem_data_out = pc_plus_1;
                    SP_next    = SP - 8'd1;
                    PC_next    = branch_target;
                  end

            4'hE: begin // RET
                    // Pop from stack
                    dmem_addr_reg = SP;
                    dmem_we_reg   = 1'b0;
                    PC_next       = dmem_data_in;
                    SP_next       = SP + 8'd1;
                  end

            4'hF: begin // IO
                    io_port = operand[2:0];
                    if (operand[3]) begin // b=1 → OUT
                        io_wr   = 1'b1;
                        io_data_out = ACC;
                    end else begin // b=0 → IN
                        ACC_next = io_data_in;
                    end
                  end
        endcase
    end

    // -----------------------------------------------------------------
    // Sequential logic (state update on clock edge)
    // -----------------------------------------------------------------
    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            ACC   <= 8'd0;
            MAR   <= 8'd0;
            FLAGS <= 3'd0;
            PC    <= 8'd0;
            IR    <= 8'd0;
            SP    <= 8'hFF;          // initialise stack pointer to top of RAM
        end else begin
            ACC   <= ACC_next;
            MAR   <= MAR_next;
            FLAGS <= FLAGS_next;
            PC    <= PC_next;
            IR    <= imem_data;      // fetch instruction (ROM assumed combinational)
            SP    <= SP_next;
        end
    end

    // -----------------------------------------------------------------
    // Output assignments
    // -----------------------------------------------------------------
    assign imem_addr = PC;
    assign dmem_addr = dmem_addr_reg;
    assign dmem_we   = dmem_we_reg;
endmodule
