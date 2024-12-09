`timescale 1ns / 1ps

module fetch_block
#(
    parameter D_SIZE = 32,
    parameter A_SIZE = 10
)
(
    input 		rst,
    input		clk,

    input instruction,
    output reg [A_SIZE-1:0] pc,
    
    output reg [15:0] ir
);

always @(posedge clk) begin
    if (rst == 1) begin
        pc <= pc + 1;
        ir <= instruction;
    end else begin
        pc <= 0;
        ir <= 0;
    end
end

endmodule