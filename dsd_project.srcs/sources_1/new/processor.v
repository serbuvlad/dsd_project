`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 11/20/2024 03:30:15 PM
// Design Name: 
// Module Name: processor
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


module processor
#(
    parameter D_SIZE = 32,
    parameter A_SIZE = 10
)
(
    // general
    input 		rst,   // active 0
    input		clk,
    // program memory
    output [A_SIZE-1:0] pc,
    input        [`I_SIZE:0] instruction,
    // data memory
    output  read,  // active 1
    output  write, // active 1
    output [A_SIZE-1:0]	address,
    input  [D_SIZE-1:0]	data_in,
    output [D_SIZE-1:0]	data_out
);

// Fetch to read interface
wire [`I_SIZE:0]  ir;

// Read to regs interface
wire [`RS_SIZE-1:0] reg_sel1;
wire [`RS_SIZE-1:0] reg_sel2;
wire [D_SIZE-1:0]   reg_op1;
wire [D_SIZE-1:0]   reg_op2;

// Read to execute interface
wire [`I_SIZE:0]     ir_read2exec;
wire [D_SIZE-1:0]    op1;
wire [D_SIZE-1:0]    op2;
wire [`RS_SIZE-1:0]  dest_read2exec;
wire                 dest_valid_read2exec;

// Execute to write back interface
wire [`RS_SIZE-1:0]  dest_exec2wb;
wire                 dest_valid_exec2wb;
wire [D_SIZE-1:0]    result_exec2wb;
wire                 src_mem;

// Write back to regs interface
wire [`RS_SIZE-1:0]  dest_wb2regs;
wire                 dest_valid_wb2regs;
wire [D_SIZE-1:0]    result_wb2regs;

fetch_block 
#(
    .D_SIZE(D_SIZE),
    .A_SIZE(A_SIZE)
)
fetcher
(
    .clk(clk),
    .rst(rst),
    
    .instruction(instruction),
    .pc(pc),
    
    .ir(ir)
);

read_block
#(
    .D_SIZE(D_SIZE),
    .A_SIZE(A_SIZE)
)
reader
(
    .clk(clk),
    .rst(rst),
    
    .ir(ir),
    
    .reg_op1(reg_op1),
    .reg_op2(reg_op2),
    .out_reg_sel1(reg_sel1),
    .out_reg_sel2(reg_sel2),
    
    .out_ir(ir_read2exec),
    .out_op1(op1),
    .out_op2(op2),
    
    .dest(dest_read2exec),
    .dest_valid(dest_valid_read2exec)
);

execute_block
#(
    .D_SIZE(D_SIZE),
    .A_SIZE(A_SIZE)
)
executor
(
    .clk(clk),
    .rst(rst),
    
    .ir(ir_read2exec),
    .op1(op1),
    .op2(op2),
    
    .dest(dest_read2exec),
    .dest_valid(dest_valid_read2exec),
    
    .out_result(result_exec2wb),
    
    .out_dest(dest_exec2wb),
    .out_dest_valid(dest_valid_exec2wb),
    .out_src_mem(src_mem),
    
    .out_read(read),
    .out_write(write),
    .out_addr(address),
    .out_data_out(data_out)
);

write_back_block
#(
    .D_SIZE(D_SIZE),
    .A_SIZE(A_SIZE)
)
write_back_writer
(
    .clk(clk),
    .rst(rst),
    
    .dest(dest_exec2wb),
    .dest_valid(dest_valid_exec2wb),
    .exec_result(result_exec2wb),
    .src_mem(src_mem),
    
    .data_in(data_in),
    
    .out_dest(dest_wb2regs),
    .out_dest_valid(dest_valid_wb2regs),
    .out_result(result_wb2regs)
);

regs_block
#(
    .D_SIZE(D_SIZE),
    .A_SIZE(A_SIZE)
)
regs
(
    .clk(clk),
    .rst(rst),
    
    .sel1(reg_sel1),
    .sel2(reg_sel2),
    
    .op1(reg_op1),
    .op2(reg_op2),
    
    .dest(dest_wb2regs),
    .dest_valid(dest_valid_wb2regs),
    .result(result_wb2regs)
);

endmodule
