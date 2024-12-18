`timescale 1ns / 1ps

`include "defines.vh"

module data_peddler_block
#(
    parameter D_SIZE = 32,
    parameter A_SIZE = 10
)
(
    output reg halt_to_fetcher,

    input [`I_SIZE-1:0] ir_from_fetcher,
    
    output reg [`I_SIZE-1:0] ir_to_reader,
    
    input [`I_SIZE-1:0]  ir_from_reader,
    input [D_SIZE-1:0]   op1_from_reader,
    input [`RS_SIZE-1:0] op1_reg_from_reader,
    input                op1_reg_valid_from_reader,
    input [D_SIZE-1:0]   op2_from_reader,
    input [`RS_SIZE-1:0] op2_reg_from_reader,
    input                op2_reg_valid_from_reader,
    
    output reg [`I_SIZE-1:0]  ir_to_executor,
    output reg [D_SIZE-1:0]   op1_to_executor,
    output reg [D_SIZE-1:0]   op2_to_executor,
    
    input [D_SIZE-1:0] result_from_executor,
    input [D_SIZE-1:0] dest_from_executor,
    input              dest_valid_from_executor,
    input              src_mem_from_executor,
    input              pc_valid_from_executor,
    
    input [D_SIZE-1:0] result_from_wb,
    input [D_SIZE-1:0] dest_from_wb,
    input [D_SIZE-1:0] dest_valid_from_wb
);

`define HALT_FETCHER    halt_to_fetcher = 1;
`define NORMAL_FETCHER  halt_to_fetcher = 0;

`define NOP_READER     ir_to_reader = `I_SIZE'b0;
`define HALT_READER    ir_to_reader = ir_from_reader;
`define NORMAL_READER  ir_to_reader = ir_from_fetcher;

`define NOP_EXECUTOR     ir_to_executor = `I_SIZE'b0;
`define NORMAL_EXECUTOR  ir_to_executor = ir_from_reader;

reg op1_wants_halt;
reg op2_wants_halt;

always @* begin
    // Solve data dependencies for op1
    
    // In the case where op1 has just been calculated by the executor
    if (op1_reg_valid_from_reader && op1_reg_from_reader == dest_from_executor && dest_valid_from_executor && !src_mem_from_executor) begin
        op1_to_executor = result_from_executor;
        op1_wants_halt = 0;
    
    // In the case where op1 will be received from memory
    end else if (op1_reg_valid_from_reader && op1_reg_from_reader == dest_from_executor && dest_valid_from_executor && src_mem_from_executor) begin
        op1_to_executor = 0;
        op1_wants_halt = 1;
    
    // In the case where op1 is being written back
    end if (op1_reg_valid_from_reader && op1_reg_from_reader == dest_from_wb && dest_valid_from_wb) begin
        op1_to_executor = result_from_wb;
        op1_wants_halt = 0;
    
    // Normal case
    end else begin
        op1_to_executor = op1_from_reader;
        op1_wants_halt = 0;
    end
    
    // Same for op2
    
    // In the case where op2 has just been calculated by the executor
    if (op2_reg_valid_from_reader && op2_reg_from_reader == dest_from_executor && dest_valid_from_executor && !src_mem_from_executor ) begin
        op2_to_executor = result_from_executor;
        op2_wants_halt = 0;
    
    // In the case where op2 will be received from memory
    end else if (op2_reg_valid_from_reader && op2_reg_from_reader == dest_from_executor && dest_valid_from_executor && src_mem_from_executor) begin
        op2_to_executor = 0;
        op2_wants_halt = 1;
    
    // In the case where op2 is being written back
    end if (op2_reg_from_reader == dest_from_wb && dest_valid_from_wb) begin
        op2_to_executor = result_from_wb;
        op2_wants_halt = 0;
    
    // Normal case
    end else begin
        op2_to_executor = op2_from_reader;
        op2_wants_halt = 0;
    end
    
    // If a jump happened we need to invalidate reader and executor
    if (pc_valid_from_executor) begin
        `NORMAL_FETCHER
        `NOP_READER
        `NOP_EXECUTOR
    end else if (op1_wants_halt || op2_wants_halt) begin
        `HALT_FETCHER
        `NOP_READER
        `NOP_EXECUTOR
    end else begin
        `NORMAL_FETCHER
        `NORMAL_READER
        `NORMAL_EXECUTOR
    end
end

endmodule
