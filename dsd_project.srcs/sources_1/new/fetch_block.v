`timescale 1ns / 1ps

`include "defines.vh"

module fetch_block
#(
    parameter D_SIZE = 32,
    parameter A_SIZE = 10
)
(
    input 		rst,
    input		clk,

    input [`I_SIZE-1:0] instruction,
    output reg [A_SIZE-1:0] out_pc,
    
    input halt,
    
    input [A_SIZE-1:0] proposed_pc,
    input              proposed_pc_valid,
    input              proposed_pc_relative,
    
    output reg [`I_SIZE-1:0] out_ir
);

wire pc;

assign pc = 
    proposed_pc_valid ? (
        proposed_pc_relative ? 
            out_pc + proposed_pc :
            proposed_pc
        ) : (
        halt ? 
            out_pc :
            out_pc + 1
        );

always @(posedge clk) begin
    if (rst == 1) begin
        out_pc <= pc;
        out_ir <= instruction;
    end else begin
        out_pc <= 0;
        out_ir <= 0;
    end
end

endmodule
