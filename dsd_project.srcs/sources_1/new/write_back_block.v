`timescale 1ns / 1ps

`include "defines.vh"

module write_back_block
#(
    parameter D_SIZE = 32,
    parameter A_SIZE = 10
)
(
    input 		rst,   // active 0
    input		clk,
    
    input [`RS_SIZE-1:0] dest,
    input                dest_valid,
    input [D_SIZE-1:0]   exec_result,
    input                src_mem,
    
    input [D_SIZE-1:0] data_in,
    
    output reg [`RS_SIZE-1:0] out_dest,
    output reg                out_dest_valid,
    output reg [D_SIZE-1:0]   out_result
);

wire [D_SIZE-1:0] result;

assign result = (src_mem) ? data_in : exec_result;

always @(posedge clk) begin
    if (rst) begin
        out_dest <= dest;
        out_dest_valid <= dest_valid;
        out_result <= result;
    end else begin
        out_dest <= 0;
        out_dest_valid <= 0;
        out_result <= 0;
    end
end

endmodule