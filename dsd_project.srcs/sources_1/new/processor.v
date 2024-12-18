`timescale 1ns / 1ps

`include "defines.vh"

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
    input        [`I_SIZE-1:0] instruction,
    // data memory
    output  read,  // active 1
    output  write, // active 1
    output [A_SIZE-1:0]	address,
    input  [D_SIZE-1:0]	data_in,
    output [D_SIZE-1:0]	data_out
);

// Fetch to data peddler interface
wire [`I_SIZE-1:0]  ir_fetch2dp;

// Data peddler to fetch interface
wire halt_dp2fetch;

// Read to regs interface
wire [`RS_SIZE-1:0] reg_sel1;
wire [`RS_SIZE-1:0] reg_sel2;
wire [D_SIZE-1:0]   reg_op1;
wire [D_SIZE-1:0]   reg_op2;

// Read to execute interface
wire [`RS_SIZE-1:0]  dest_read2exec;
wire                 dest_valid_read2exec;

// Read to data peddler interface
wire [`I_SIZE-1:0]   ir_read2dp;
wire [D_SIZE-1:0]    op1_read2dp;
wire [`RS_SIZE-1:0]  op1_reg_read2dp;
wire                 op1_reg_valid_read2dp;
wire [D_SIZE-1:0]    op2_read2dp;
wire [`RS_SIZE-1:0]  op2_reg_read2dp;
wire                 op2_reg_valid_read2dp;

// Data peddler to execute interface
wire [`I_SIZE-1:0] ir_dp2exec;
wire [D_SIZE-1:0]  op1_dp2exec;
wire [D_SIZE-1:0]  op2_dp2exec;


// Execute to write back interface
wire [D_SIZE-1:0]    result_exec2wb;
wire [`RS_SIZE-1:0]  dest_exec2wb;
wire                 dest_valid_exec2wb;
wire                 src_mem_exec2wb;

// Execute to fetch interface
wire [A_SIZE-1:0] proposed_pc_exec2fetch;
wire              proposed_pc_valid_exec2fetch;
wire              proposed_pc_relative_exec2fetch;

// Execute to data peddler
wire [D_SIZE-1:0]   result_exec2dp;
assign result_exec2dp = result_exec2wb;
wire [`RS_SIZE-1:0] dest_exec2dp;
assign dest_exec2dp = dest_exec2wb;
wire dest_valid_exec2dp;
assign dest_valid_exec2dp = dest_valid_exec2wb;
wire src_mem_exec2dp;
assign src_mem_exec2dp = src_mem_exec2wb;
wire pc_valid_exec2dp;
assign pc_valid_exec2dp = proposed_pc_valid_exec2fetch;

// Write back to regs interface
wire [D_SIZE-1:0]    result_wb2regs;
wire [`RS_SIZE-1:0]  dest_wb2regs;
wire                 dest_valid_wb2regs;

// Write back to data peddler
wire [D_SIZE-1:0] result_wb2dp;
assign result_wb2dp = result_wb2regs;
wire [`RS_SIZE-1:0] dest_wb2dp;
assign dest_wb2dp = dest_wb2regs;
wire dest_valid_wb2dp;
assign dest_valid_wb2dp = dest_valid_wb2regs;

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
    .out_pc(pc),
    
    .halt(halt_dp2fetch),
    
    .proposed_pc(proposed_pc_exec2fetch),
    .proposed_pc_valid(proposed_pc_valid_exec2fetch),
    .proposed_pc_relative(proposed_pc_relative_exec2fetch),
    
    .out_ir(ir_fetch2dp)
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
    
    .ir(ir_dp2read),
    
    .reg_op1(reg_op1),
    .reg_op2(reg_op2),
    .oquick_reg_sel1(reg_sel1),
    .oquick_reg_sel2(reg_sel2),
    
    .out_ir(ir_read2dp),
    .out_op1(op1_read2dp),
    .out_op1_reg(op1_reg_read2dp),
    .out_op1_reg_valid(op1_reg_valid_read2dp),
    .out_op2(op2_read2dp),
    .out_op2_reg(op2_reg_read2dp),
    .out_op2_reg_valid(op2_reg_valid_read2dp),
    
    .out_dest(dest_read2exec),
    .out_dest_valid(dest_valid_read2exec)
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
    
    .ir(ir_dp2exec),
    .op1(op1_dp2exec),
    .op2(op2_dp2exec),
    
    .dest(dest_read2exec),
    .dest_valid(dest_valid_read2exec),
    
    .out_result(result_exec2wb),
    
    .out_dest(dest_exec2wb),
    .out_dest_valid(dest_valid_exec2wb),
    .out_src_mem(src_mem_exec2wb),
    
    .out_read(read),
    .out_write(write),
    .out_addr(address),
    .out_data_out(data_out),
    
    .out_pc(proposed_pc_exec2fetch),
    .out_pc_valid(proposed_pc_valid_exec2fetch),
    .out_pc_relative(proposed_pc_relative_exec2fetch)
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

data_peddler_block
#(
    .D_SIZE(D_SIZE),
    .A_SIZE(A_SIZE)
)
data_peddler
(
    .halt_to_fetcher(halt_dp2fetch),
    
    .ir_from_fetcher(ir_fetch2dp),
    
    .ir_from_reader(ir_read2dp),
    .op1_from_reader(op1_read2dp),
    .op1_reg_from_reader(op1_reg_read2dp),
    .op1_reg_valid_from_reader(op1_reg_valid_read2dp),
    .op2_from_reader(op2_read2dp),
    .op2_reg_from_reader(op2_reg_read2dp),
    .op2_reg_valid_from_reader(op2_reg_valid_read2dp),
    
    .ir_to_executor(ir_dp2exec),
    .op1_to_executor(op1_dp2exec),
    .op2_to_executor(op2_dp2exec),
    
    .result_from_executor(result_exec2dp),
    .dest_from_executor(dest_exec2dp),
    .dest_valid_from_executor(dest_valid_exec2dp),
    .src_mem_from_executor(src_mem_exec2dp),
    .pc_valid_from_executor(pc_valid_exec2dp),
    
    .result_from_wb(result_wb2dp),
    .dest_from_wb(dest_wb2dp),
    .dest_valid_from_wb(dest_valid_wb2dp)
);

endmodule
