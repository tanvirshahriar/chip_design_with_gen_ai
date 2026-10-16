// Let us make a brand new microprocessor design together. We're severely constrained on space and I/O. We have to fit in 1000 standard cells of an ASIC, so I think we will need to restrict ourselves to an accumulator based 8-bit architecture with no multi-byte instructions. Given this, how do you think we should begin?
//
// We settled on the following design. Implement it with the module interface below.
//
// **Accumulator‑8‑bit ASIC Core (≈1 k cells)**  
//
// ---
//
// ### 1. Instruction Set  (all instructions are a single 8‑bit word)
//
// | Opcode (hex) | Binary  (opcode[7:4] | operand[3:0]) | Mnemonic | Operand meaning | Action (one clock cycle) |
// |--------------|----------------------|----------|----------|------------------|--------------------------|
// | 0x0 | `0000 xxxx` | **NOP** | – | No operation |
// | 0x1 | `0001 xxxx` | **LDHI #imm4** | imm4 = operand | MAR[7:4] ← imm4  (MAR = Memory‑Address Register) |
// | 0x2 | `0010 xxxx` | **LDLO #imm4** | imm4 = operand | MAR[3:0] ← imm4 |
// | 0x3 | `0011 xxxx` | **LOAD** | – | ACC ← RAM[MAR] |
// | 0x4 | `0100 xxxx` | **STORE** | – | RAM[MAR] ← ACC |
// | 0x5 | `0101 xxxx` | **ADD #imm4** | imm4 = operand (0‑15) | ACC ← ACC + imm4  (set Z,N,C) |
// | 0x6 | `0110 xxxx` | **SUB #imm4** | imm4 = operand | ACC ← ACC – imm4  (set Z,N,C) |
// | 0x7 | `0111 xxxx` | **AND #imm4** | imm4 = operand | ACC ← ACC & imm4  (set Z,N) |
// | 0x8 | `1000 xxxx` | **OR  #imm4** | imm4 = operand | ACC ← ACC \| imm4  (set Z,N) |
// | 0x9 | `1001 xxxx` | **XOR #imm4** | imm4 = operand | ACC ← ACC ^ imm4  (set Z,N) |
// | 0xA | `1010 xxxx` | **JMP rel4** | rel4 = signed 4‑bit (‑8…+7) | PC ← PC + 1 + sign‑extend(rel4) |
// | 0xB | `1011 xxxx` | **JZ rel4** | rel4 = signed 4‑bit | if Z=1 then PC ← PC + 1 + sign‑extend(rel4) |
// | 0xC | `1100 xxxx` | **JC rel4** | rel4 = signed 4‑bit | if C=1 then PC ← PC + 1 + sign‑extend(rel4) |
// | 0xD | `1101 xxxx` | **CALL rel4** | rel4 = signed 4‑bit | push (PC+1) onto stack; PC ← PC + 1 + sign‑extend(rel4) |
// | 0xE | `1110 xxxx` | **RET** | – | PC ← pop from stack |
// | 0xF | `1111 bppp` | **IO** | b = direction (0=IN,1=OUT)  <br> ppp = port number (0‑7) | if b=0: ACC ← IO_PORT[ppp]  <br> if b=1: IO_PORT[ppp] ← ACC |
//
// *All arithmetic/logic instructions update Z (zero) and N (negative‑flag = MSB of result).  
// ADD/SUB also update C (carry out of the MSB).  
// The stack is located in the data RAM; the stack pointer is maintained in software (e.g., reserve the top 16 bytes).*
//
// ---
//
// ### 2. Programmer‑Visible Registers
//
// | Register | Width | Description |
// |----------|-------|-------------|
// | **ACC**  | 8 bit | Accumulator – source/destination for ALU, load/store, I/O |
// | **MAR**  | 8 bit | Memory‑Address Register (built from two 4‑bit halves: MARH = MAR[7:4], MARL = MAR[3:0]) |
// | **FLAGS**| 4 bit | Z (zero), N (negative), C (carry), V (overflow – optional, can be omitted) |
// | **PC**   | 8 bit | Program Counter (points to instruction ROM) |
// | **IR**   | 8 bit | Instruction Register (internal, not visible to software) |
//
// *Total flip‑flops ≈ 8+8+4+8+8 = 36 FFs → ≈ 200‑250 cells in a typical 65 nm library.*
//
// ---
//
// ### 3. Memory Organisation
//
// | Memory | Size | Access | Remarks |
// |--------|------|--------|---------|
// | **Instruction ROM** | 256 × 8 bits (read‑only) | Address = **PC** (8 bit) → data → IR | Harvard‑style; can be implemented as a synchronous ROM macro. |
// | **Data RAM** | 256 × 8 bits (read/write) | Address = **MAR** (8 bit) → data bus | Used for variables, stack, and memory‑mapped I/O if desired. |
// | **I/O ports** | 8 × 8‑bit registers (optional) | Selected by **IO** instruction (port 0‑7) | No extra CPU registers needed; the ACC drives the port directly. |
//
// *Both ROM and RAM are assumed to be provided as hard macros by the ASIC library; they do not consume standard‑cell count.*

module cpu8_acc (
    input  wire        clk,          // system clock
    input  wire        rst_n,        // active‑low asynchronous reset

    // ----- Instruction ROM (read‑only) -----
    output wire [7:0]  imem_addr,    // address to ROM
    input  wire [7:0]  imem_data,    // data from ROM

    // ----- Data RAM (read/write) -----
    output wire [7:0]  dmem_addr,    // address to RAM
    inout  wire [7:0]  dmem_data,    // bidirectional data bus
    output wire        dmem_we,      // 1 = write, 0 = read

    // ----- Simple memory‑mapped I/O (port‑mapped) -----
    output wire [2:0]  io_port,      // 3‑bit port selector (0‑7)
    output wire        io_wr,        // write strobe (high during OUT)
    input  wire [7:0]  io_data_in,   // data from external pins
    output wire [7:0]  io_data_out   // data driven to external pins
);
