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
    output reg [D_SIZE-1:0] out_data_out
);

reg [D_SIZE-1:0] result;
reg              src_mem;
reg              read;
reg              write;
reg [A_SIZE-1:0] addr;
reg [D_SIZE-1:0] data_out;

`define NOP   read = 0; write = 0; addr = 0; data_out = 0; src_mem = 0; result = 0;
`define NO_RW read = 0; write = 0; addr = 0; data_out = 0; src_mem = 0;

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
                    src_mem = 1;
                end
                `I_LS_OP_LOADC: begin
                    result = {op1[D_SIZE-1:8], op2[7:0]};
                    
                    `NO_RW
                end
                `I_LS_OP_LOAD: begin
                    result = 0;
                    
                    read = 1;
                    write = 0;
                    addr = op2;
                    data_out = 0;
                    src_mem = 0;
                end
                default: begin
                    `NOP
                end
            endcase
        end
        
        // TODO
        `IT_JMP: begin
            `NOP
        end
        
        // Arithmethic
        `IT_AR: begin
            case(ir[`I_AR_OP_POS]) 
                `I_AR_OP_ADD: begin
                    result = op1 + op2;
                    
                    `NO_RW
                end
                `I_AR_OP_ADDF: begin
                    result = op1 + op2;
                    
                    `NO_RW
                end
                `I_AR_OP_SUB: begin
                    result = op1 - op2;
                    
                    `NO_RW
                end
                `I_AR_OP_SUBF: begin
                    result = op1 - op2;
                    
                    `NO_RW
                end
                `I_AR_OP_AND: begin
                    result = op1 & op2;
                    
                    `NO_RW
                end
                `I_AR_OP_OR: begin
                    result = op1 | op2;
                    
                    `NO_RW
                end
                `I_AR_OP_XOR: begin
                    result = op1 ^ op2;
                    
                    `NO_RW
                end
                `I_AR_OP_NAND: begin
                    result = ~(op1 & op2);
                    
                    `NO_RW
                end
                `I_AR_OP_NOR: begin
                    result = ~(op1 | op2);
                    
                    `NO_RW
                end
                `I_AR_OP_NXOR: begin
                    result = ~(op1 ^ op2);
                    
                    `NO_RW
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
    end else begin
        out_result <= 0;
        out_dest <= 0;
        out_dest_valid <= 0;
        out_src_mem <= 0;      
        out_read <= 0;
        out_write <= 0;
        out_addr <= 0;
        out_data_out <= 0;
    end
end

endmodule
