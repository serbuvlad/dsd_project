`timescale 1ns / 1ps

`include "defines.vh"

module read_block
#(
    parameter D_SIZE = 32,
    parameter A_SIZE = 10
)
(
    input 		rst,
    input		clk,

    input [`I_SIZE-1:0] ir,
    
    input [D_SIZE-1:0] reg_op1,
    input [D_SIZE-1:0] reg_op2,
    output [`RS_SIZE-1:0] reg_sel1,
    output [`RS_SIZE-1:0] reg_sel2,
    
    output reg [`I_SIZE-1:0] out_ir,
    output reg [D_SIZE-1:0] out_op1,
    output reg [D_SIZE-1:0] out_op2
);

wire [D_SIZE-1:0] op1;
wire [D_SIZE-1:0] op2;

always @* begin
    case (ir[15:14])
        // Arithmethic
        2'b00 : begin
            if (ir[13]) begin // has immediate
                op1 = { 10'b0, ir[5:0] };
                op2 = 16'b0;
                
                reg_sel1 = 0;
                reg_sel2 = 0;
            end
            else begin
                op1 = reg_op1;
                op2 = reg_op2;
                
                reg_sel1 = ir[5:3];
                reg_sel2 = ir[2:0];
            end
        end
        
        // Load/Store
        2'b01: begin
            if (ir[13]) begin // has immediate
                op1 = { 8'b0, ir[7:0] };
                op2 = 0;
                
                reg_sel1 = 0;
                reg_sel2 = 0;
            end
            else begin
                op1 = reg_op1;
                op2 = 0;

                reg_sel1 = ir[2:0];
                reg_sel2 = 0;
            end
        end
        
        // Jumps
        2'b10: begin
            if (ir[13]) begin // has immediate
                op1 = { 10'b0, ir[5:0] };
                
                reg_sel1 = 0;
            end
            else begin
                op1 = reg_op1;
                
                reg_sel1 = ir[2:0];
            end
            
            if (ir[12]) begin // has comparison operand
                op2 = reg_op2;
                
                reg_sel2 = ir[8:6];
            end
        end
        
        // NOP or HALT
        3'b11: begin
            op1 = 16'b0;
            op2 = 16'b0;
            
            reg_sel1 = 0;
            reg_sel2 = 0;
        end
    endcase
end


always @(negedge rst) begin
    pc <= 0;
    ir <= 0;
end

always @(posedge clk) begin
    if (rst) begin
        out_ir <= ir;
    end
end

endmodule