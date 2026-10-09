
module cpu (
    input        clk,
    input        rst_n,      // active-low asynchronous reset
    output [7:0] acc_out,
    output       halted
);

    // 4-bit PC for 16-byte memory
    reg [3:0]  PC;
    // 8-bit accumulator
    reg [7:0]  ACC;
    // Halt flag
    reg        halted_reg;
    // FSM state: 0 = FETCH, 1 = EXECUTE
    reg [1:0]  state;
    // Instruction register
    reg [7:0]  IR;
    // Internal memory (16x8)
    reg [7:0]  mem [0:15];

    // Output assignments
    assign acc_out = ACC;
    assign halted  = halted_reg;

    // State encoding
    localparam FETCH = 2'b00;
    localparam EXEC  = 2'b01;

    always @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            // Synchronous reset (async due to negedge)
            PC       <= 4'h0;
            ACC      <= 8'h0;
            halted_reg <= 1'b0;
            state    <= FETCH;
            IR       <= 8'h0;
        end else begin
            if (halted_reg) begin
                // Remain halted; do nothing
            end else begin
                case (state)
                    FETCH: begin
                        // Fetch instruction from memory[PC]
                        IR <= mem[PC];
                        state <= EXEC;
                    end
                    EXEC: begin
                        // Execute instruction based on opcode IR[7:5]
                        case (IR[7:5])
                            3'b000: // LDA: ACC <- mem[addr]
                                ACC <= mem[IR[3:0]];
                            3'b001: // STA: mem[addr] <- ACC
                                mem[IR[3:0]] <= ACC;
                            3'b010: // ADD: ACC <- ACC + mem[addr]
                                ACC <= ACC + mem[IR[3:0]];
                            3'b011: // SUB: ACC <- ACC - mem[addr]
                                ACC <= ACC - mem[IR[3:0]];
                            3'b100: // AND: ACC <- ACC & mem[addr]
                                ACC <= ACC & mem[IR[3:0]];
                            3'b101: // JMP: PC <- addr
                                PC <= IR[3:0];
                            3'b110: // JZ: if ACC==0 then PC <- addr else PC <- PC+1
                                if (ACC == 8'h0)
                                    PC <= IR[3:0];
                                else
                                    PC <= PC + 1;
                            3'b111: // HLT: set halted flag
                                halted_reg <= 1'b1;
                        endcase

                        // Default PC increment for non-branch, non-halt instructions
                        if (IR[7:5] == 3'b000 || IR[7:5] == 3'b001 ||
                            IR[7:5] == 3'b010 || IR[7:5] == 3'b011 ||
                            IR[7:5] == 3'b100) begin
                            PC <= PC + 1;
                        end

                        // Return to fetch state
                        state <= FETCH;
                    end
                endcase
            end
        end
    end
endmodule
