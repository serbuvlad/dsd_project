`timescale 1ns / 1ps

`include "defines.vh"

module mem_test
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
    reg  [D_SIZE-1:0] mem [0:1023];
    
    wire read;
    wire write;
    wire [A_SIZE-1:0] address;
    wire [D_SIZE-1:0] data_in;
    wire [D_SIZE-1:0] data_out;
    
    assign #1 instruction = instructions[pc];
    assign #1 data_in = mem[address];
    
    always @(posedge clk) begin
        if (write == 1) begin
            mem[address] <= data_out;
        end
    end
    
    seq_core #(.D_SIZE(D_SIZE), .A_SIZE(A_SIZE)) s (
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
    
    initial begin
        clk = 0;
        forever #10 clk = ~clk;
    end
    
    initial begin
        rst <= 0;
        
        instructions[0] <= {`LOADC, `R1, 8'd9};
        instructions[1] <= {`LOADC, `R3, 8'd5};
        instructions[2] <= {`STORE, `R1, 5'd0, `R0};
        instructions[3] <= {`LOAD, `R3, 5'd0, `R1};
        instructions[4] <= `HALT;
        
        mem[0] <= 0;
        mem[1] <= 1;
        mem[2] <= 2;
        mem[3] <= 3;
        mem[4] <= 4;
        mem[5] <= 5;
        mem[6] <= 6;
        mem[7] <= 7;
        mem[8] <= 8;
        mem[9] <= 9;


        #20
        
        rst <= 1;
        
        #1000
        
        $finish;
    end
    
endmodule
