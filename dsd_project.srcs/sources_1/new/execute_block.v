`timescale 1ns / 1ps

`include "defines.vh"

module execute_block
#(
    parameter D_SIZE = 32,
    parameter A_SIZE = 10
)
(
    // general
    input 		rst,   // active 0
    input		clk,
    
    input [`I_SIZE-1:0] ir,
    
    input [D_SIZE-1:0] op1,
    input [D_SIZE-1:0] op2,
    
    input [`RS_SIZE-1:0] dest,
    input                dest_valid,
     
    output reg [D_SIZE-1:0] out_result,
    
    output reg [`RS_SIZE-1:0] out_dest,
    output reg                out_dest_valid,
    output reg                out_src_mem,
    
    output reg              out_read,
    output reg              out_write,
    output reg [A_SIZE-1:0] out_addr,
    output reg [D_SIZE-1:0] out_data_out,
    
    output reg [A_SIZE-1:0] out_pc,
    output reg              out_pc_valid,
    output reg              out_pc_relative
);

reg [D_SIZE-1:0] result;
reg              src_mem;
reg              read;
reg              write;
reg [A_SIZE-1:0] addr;
reg [D_SIZE-1:0] data_out;
reg [A_SIZE-1:0] pc;
reg              pc_valid;
wire             pc_relative;

assign pc_relative = ir[`I_JMP_HAVE_IMM_POS];

`undef NOP
`define NOP   read = 0; write = 0; addr = 0; data_out = 0; src_mem = 0; result = 0; pc = 0; pc_valid = 0;
`define NO_RW read = 0; write = 0; addr = 0; data_out = 0; src_mem = 0;
`define NO_PC pc = 0; pc_valid = 0;

always @* begin
    case (ir[`IT_POS])
        // NOP or HALT
        `IT_NH: begin
            case(ir[`I_NH_OP_POS])
                `I_NH_OP_NOP: begin
                    `NOP
                end
                
                `I_NH_OP_HALT: begin
                    `NOP
                end
                
                default: begin
                    `NOP
                end
            endcase
        end
        
        // LOAD/STORE
        `IT_LS: begin
            case (ir[`I_LS_OP_POS])
                `I_LS_OP_STORE: begin
                    result = 0;
                    
                    read = 0;
                    write = 1;
                    addr = op1;
                    data_out = op2;
                    src_mem = 0;
                    
                    `NO_PC
                end
                `I_LS_OP_LOADC: begin
                    result = {op1[D_SIZE-1:8], op2[7:0]};
                    
                    `NO_RW
                    `NO_PC
                end
                `I_LS_OP_LOAD: begin
                    result = 0;
                    
                    read = 1;
                    write = 0;
                    addr = op2;
                    data_out = 0;
                    src_mem = 1;
                    
                    `NO_PC
                end
                default: begin
                    `NOP
                end
            endcase
        end
        
        // Jump
        `IT_JMP: begin
            
            if (
                !ir[`I_JMP_HAVE_COND_POS] ||
                (ir[`I_JMP_HAVE_COND_POS] && ir[`I_JMP_COND_POS] == `I_JMP_COND_N  &&  op2[`D_SIZE_NEGATIVE_BIT_POS]) ||
                (ir[`I_JMP_HAVE_COND_POS] && ir[`I_JMP_COND_POS] == `I_JMP_COND_NN && !op2[`D_SIZE_NEGATIVE_BIT_POS]) ||
                (ir[`I_JMP_HAVE_COND_POS] && ir[`I_JMP_COND_POS] == `I_JMP_COND_Z  && op2 == 0) ||
                (ir[`I_JMP_HAVE_COND_POS] && ir[`I_JMP_COND_POS] == `I_JMP_COND_NZ && op2 != 0)
            ) begin
                pc = op1;
                pc_valid = 1;
                
                result = 0;
                `NO_RW
            end else begin
                `NO_PC
                
                result = 0;
                `NO_RW
            end 
        end
        
        // Arithmethic
        `IT_AR: begin
            case(ir[`I_AR_OP_POS]) 
                `I_AR_OP_ADD: begin
                    result = op1 + op2;
                    
                    `NO_RW
                    `NO_PC
                end
                `I_AR_OP_ADDF: begin
                    result = op1 + op2;
                    
                    `NO_RW
                    `NO_PC
                end
                `I_AR_OP_SUB: begin
                    result = op1 - op2;
                    
                    `NO_RW
                    `NO_PC
                end
                `I_AR_OP_SUBF: begin
                    result = op1 - op2;
                    
                    `NO_RW
                    `NO_PC
                end
                `I_AR_OP_AND: begin
                    result = op1 & op2;
                    
                    `NO_RW
                    `NO_PC
                end
                `I_AR_OP_OR: begin
                    result = op1 | op2;
                    
                    `NO_RW
                    `NO_PC
                end
                `I_AR_OP_XOR: begin
                    result = op1 ^ op2;
                    
                    `NO_RW
                    `NO_PC
                end
                `I_AR_OP_NAND: begin
                    result = ~(op1 & op2);
                    
                    `NO_RW
                    `NO_PC
                end
                `I_AR_OP_NOR: begin
                    result = ~(op1 | op2);
                    
                    `NO_RW
                    `NO_PC
                end
                `I_AR_OP_NXOR: begin
                    result = ~(op1 ^ op2);
                    
                    `NO_RW
                    `NO_PC
                end
                default: begin
                    `NOP
                end
            endcase
        end
        
        
        
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        out_result <= result;
        out_dest <= dest;
        out_dest_valid <= dest_valid;
        out_src_mem <= src_mem;
        out_read <= read;
        out_write <= write;
        out_addr <= addr;
        out_data_out <= data_out;
        out_pc <= pc;
        out_pc_valid <= pc_valid;
        out_pc_relative <= pc_relative;
    end else begin
        out_result <= 0;
        out_dest <= 0;
        out_dest_valid <= 0;
        out_src_mem <= 0;      
        out_read <= 0;
        out_write <= 0;
        out_addr <= 0;
        out_data_out <= 0;
        out_pc <= 0;
        out_pc_valid <= 0;
        out_pc_relative <= 0;
    end
end

endmodule
