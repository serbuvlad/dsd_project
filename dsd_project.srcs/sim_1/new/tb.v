`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/08/2024 04:54:18 PM
// Design Name: 
// Module Name: tb
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

`include "defines.vh"

module tb
#(
    parameter D_SIZE = 32,
    parameter A_SIZE = 10
)
(
);
    
    reg rst;
    reg clk;
    wire [A_SIZE-1:0] pc;
    reg  [15:0] instructions [0:8];
    wire [15:0] instruction;
    
    wire read;
    wire write;
    wire [A_SIZE-1:0] address;
    reg  [D_SIZE-1:0] data_in;
    wire [D_SIZE-1:0] data_out;
    
    assign instruction = instructions[pc];
    
    seq_core #(.D_SIZE(32), .A_SIZE(10)) s (
        .rst(rst),
        .clk(clk),
        .pc(pc),
        .instruction(instruction),
        .read(read),
        .write(write),
        .address(address),
        .data_in(data_in),
        .data_out(data_out)
    );
    
    always #10 clk = ~clk;
    
    initial begin
        rst <= 0;
        clk <= 0;
        
        data_in <= 5;
        
        
        // multiplication
        
        // R0 -- constant 0
        // R1 -- number to add
        // R2 -- number of times to add (coutner)
        // R4 -- accumulator
        // R5 -- constant 1
        
        instructions[0] = {`LOAD, `R1, 5'd0, `R0};
        instructions[1] = {`LOADC, `R2, 8'd7};
        
        instructions[2] = {`LOADC, `R5, 8'd1};
        
        instructions[3] = {`JMPRZ, `R2, 6'd4};
        instructions[4] = {`ADD, `R4, `R4, `R1};
        instructions[5] = {`SUB, `R2, `R2, `R5};
        instructions[6] = {`JMPR, 6'd0, 6'b111_101};
        
        instructions[7] = {`STORE, `R0, 5'd0, `R4}; // -3
        instructions[8] = `HALT;
        
        #20
        
        rst <= 1;
        
        #1000
        
        $finish;
    end
    
endmodule
