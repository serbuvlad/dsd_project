`timescale 1ns / 1ps

`include "defines.vh"

module regs_block
#(
    parameter D_SIZE = 32,
    parameter A_SIZE = 10
)
(
    input clk,
    input rst,

    input [`RS_SIZE-1:0] sel1,
    input [`RS_SIZE-1:0] sel2,
    
    output [D_SIZE-1:0] op1,
    output [D_SIZE-1:0] op2,
    
    input [`RS_SIZE-1:0] dest,
    input                dest_valid,
    input [D_SIZE-1:0]   result
);

reg [D_SIZE-1:0] R [7:0];
integer i;

assign op1 = R[sel1];
assign op2 = R[sel2];

always @(posedge clk) begin
    if (rst) begin
        if (dest_valid) begin
            R[dest] <= result;
        end
    end else begin
        for (i = 0; i < 8; i = i + 1) begin
            R[i] <= 0;
        end
    end
end

endmodule
