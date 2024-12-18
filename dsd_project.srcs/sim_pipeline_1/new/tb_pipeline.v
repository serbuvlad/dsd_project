`timescale 1ns / 1ps

module tb_pipeline
#(
    parameter D_SIZE = 32,
    parameter A_SIZE = 10
)
(
);

    reg rst;
    reg clk;
    wire [A_SIZE-1:0] pc;
    reg  [15:0] instructions [0:13];
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
    
    always @(posedge clk) begin
        if (write) begin
            mem[address] <= data_out;
        end
        
        if (read) begin
            data_in <= mem[address];
        end
    end
    
    initial begin
        rst <= 0;
        clk <= 0;
        
        mem[100] = 16;
        mem[101] = 3;
        
        
        instructions[0] = 16'b110000001100100;
        instructions[1] = 16'b100001000000000;
        instructions[2] = 16'b110000001100101;
        instructions[3] = 16'b100001100000000;
        instructions[4] = 16'b1101000000000000;
        instructions[5] = 16'b110000100000001;
        instructions[6] = 16'b1101000111111111;
        instructions[7] = 16'b1011010011000100;
        instructions[8] = 16'b1100000111111010;
        instructions[9] = 16'b1100010011011001;
        instructions[10] = 16'b1010000000111101;
        instructions[11] = 16'b110000011001000;
        instructions[12] = 16'b101000000000011;
        instructions[13] = 16'b11111111111111;


        #20
        
        rst <= 1;
        
        #1000
        
        $finish;
    end

endmodule
