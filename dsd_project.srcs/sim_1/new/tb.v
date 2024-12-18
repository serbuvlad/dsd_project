`timescale 1ns / 1ps

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
    
    reg  [D_SIZE-1:0] mem [0:1023];

    assign #1 instruction = instructions[pc];

    processor #(.D_SIZE(D_SIZE), .A_SIZE(A_SIZE)) s (
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
        
    instructions[0] = 16'b0;
        instructions[1] = 16'b0;
        instructions[2] = 16'b110000100010110;
        instructions[3] = 16'b110001000100001;
        instructions[4] = 16'b0;
        instructions[5] = 16'b0;
        instructions[6] = 16'b0;
        instructions[7] = 16'b0;
        instructions[8] = 16'b1100000000001010;
        instructions[9] = 16'b11111111111111;

        #20
        
        rst <= 1;
        
        #1000
        
        $finish;
    end
    
endmodule
