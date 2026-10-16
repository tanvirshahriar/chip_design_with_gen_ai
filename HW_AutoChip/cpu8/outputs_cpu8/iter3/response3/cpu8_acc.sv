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
    // -----------------------------------------------------------------
    // Internal registers
    // -----------------------------------------------------------------
    reg  [7:0] ACC;        // Accumulator
    reg  [7:0] MAR;        // Memory Address Register
    reg  [2:0] FLAGS;      // {Z, N, C}
    reg  [7:0] PC;         // Program Counter
    reg  [7:0] IR;         // Instruction Register
    reg  [7:0] SP;         // Stack Pointer (points to next free location)

    // -----------------------------------------------------------------
    // Combinational next-state and control logic
    // -----------------------------------------------------------------
    wire [3:0] opcode = IR[7:4];
    wire [3:0] operand = IR[3:0];

    wire Z = FLAGS[2];
    wire N = FLAGS[1];
    wire C = FLAGS[0];

    // -----------------------------------------------------------------
    // Next-state registers
    // -----------------------------------------------------------------
    reg  [7:0] ACC_next;
    reg  [7:0] MAR_next;
    reg  [2:0] FLAGS_next;
    reg  [7:0] PC_next;
    reg  [7:0] SP_next;

    // Memory control
    reg  [7:0] dmem_addr_reg;
    reg        dmem_we_reg;
    reg  [7:0] dmem_data_out;

    // I/O control
    reg  [2:0] io_port_reg;
    reg        io_wr_reg;
    reg  [7:0] io_data_out_reg;

    always @* begin
        // Defaults (hold values, no memory activity, no I/O)
        ACC_next   = ACC;
        MAR_next   = MAR;
        FLAGS_next = FLAGS;
        PC_next    = PC + 8'd1;        // default: PC+1
        SP_next    = SP;
        dmem_addr_reg  = 8'd0;
        dmem_we_reg    = 1'b0;
        dmem_data_out  = 8'd0;
        io_port_reg    = 3'd0;
        io_wr_reg      = 1'b0;
        io_data_out_reg = 8'd0;

        case (opcode)
            4'h0: ; // NOP

            4'h1: MAR_next = {operand, MAR[3:0]};          // LDHI

            4'h2: MAR_next = {MAR[7:4], operand};          // LDLO

            4'h3: begin // LOAD
                    dmem_addr_reg = MAR;
                    dmem_we_reg   = 1'b0;
                    ACC_next      = dmem_data;
                  end

            4'h4: begin // STORE
                    dmem_addr_reg = MAR;
                    dmem_we_reg   = 1'b1;
                    dmem_data_out = ACC;
                  end

            4'h5: begin // ADD #imm4
                    reg [8:0] sum;
                    sum = {1'b0, ACC} + {1'b0, operand};
                    ACC_next = sum[7:0];
                    FLAGS_next = { (sum[7:0] == 8'd0), sum[7], sum[8] };
                  end

            4'h6: begin // SUB #imm4
                    reg [8:0] diff;
                    diff = {1'b0, ACC} - {1'b0, operand};
                    ACC_next = diff[7:0];
                    FLAGS_next = { (diff[7:0] == 8'd0), diff[7], diff[8] };
                  end

            4'h7: begin // AND #imm4
                    ACC_next = ACC & operand;
                    FLAGS_next = { ((ACC & operand) == 8'd0), (ACC & operand)[7], FLAGS[0] };
                  end

            4'h8: begin // OR #imm4
                    ACC_next = ACC | operand;
                    FLAGS_next = { ((ACC | operand) == 8'd0), (ACC | operand)[7], FLAGS[0] };
                  end

            4'h9: begin // XOR #imm4
                    ACC_next = ACC ^ operand;
                    FLAGS_next = { ((ACC ^ operand) == 8'd0), (ACC ^ operand)[7], FLAGS[0] };
                  end

                4'hA: begin // JMP rel4
                    PC_next = PC + 8'd1 + {{4{operand[3]}}, operand};
                  end

                4'hB: begin // JZ rel4
                    if (Z) 
                        PC_next = PC + 8'd1 + {{4{operand[3]}}, operand};
                  end

                4'hC: begin // JC rel4
                    if (C) 
                        PC_next = PC + 8'd1 + {{4{operand[3]}}, operand};
                  end

                4'hD: begin // CALL rel4
                    // Push PC+1 onto stack (stack grows down)
                    dmem_addr_reg = SP - 8'd1;
                    dmem_we_reg   = 1'b1;
                    dmem_data_out = PC + 8'd1;
                    SP_next    = SP - 8'd1;
                    PC_next    = PC + 8'd1 + {{4{operand[3]}}, operand};
                  end

                4'hE: begin // RET
                    // Pop from stack
                    dmem_addr_reg = SP;
                    dmem_we_reg   = 1'b0;
                    PC_next       = dmem_data;
                    SP_next       = SP + 8'd1;
                  end

                4'hF: begin // IO
                    io_port_reg = operand[2:0];
                    if (operand[3]) begin // b=1 → OUT
                        io_wr_reg   = 1'b1;
                        io_data_out_reg = ACC;
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
    assign imem_addr   = PC;
    assign dmem_addr   = dmem_addr_reg;
    assign dmem_we     = dmem_we_reg;
    assign dmem_data   = dmem_we_reg ? dmem_data_out : 8'bz;
    assign io_port     = io_port_reg;
    assign io_wr       = io_wr_reg;
    assign io_data_out = io_data_out_reg;
endmodule
