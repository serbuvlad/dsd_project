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
    output reg [A_SIZE-1:0] pc,
    input        [15:0] instruction,
    // data memory
    output 	reg read,  // active 1
    output 	reg write, // active 1
    output reg [A_SIZE-1:0]	address,
    input  [D_SIZE-1:0]	data_in,
    output reg [D_SIZE-1:0]	data_out
);



endmodule
