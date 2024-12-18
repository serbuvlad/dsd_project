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
    output reg [`RS_SIZE-1:0] oquick_reg_sel1,
    output reg [`RS_SIZE-1:0] oquick_reg_sel2,
    
    output reg [`I_SIZE-1:0]  out_ir,
    output reg [D_SIZE-1:0]   out_op1,
    output reg [`RS_SIZE-1:0] out_op1_reg,
    output reg                out_op1_reg_valid,
    output reg [D_SIZE-1:0]   out_op2,
    output reg [`RS_SIZE-1:0] out_op2_reg,
    output reg                out_op2_reg_valid,
    
    output reg [`RS_SIZE-1:0] out_dest,
    output reg                out_dest_valid
);

reg [D_SIZE-1:0] op1;
reg [`RS_SIZE-1:0] op1_reg_valid;
reg [D_SIZE-1:0] op2;
reg [`RS_SIZE-1:0] op2_reg_valid;

reg [`RS_SIZE-1:0] dest;
reg                dest_valid;

`define NO_DEST dest = 0; dest_valid = 0;


always @* begin
    case (ir[`IT_POS])
        // Arithmethic
        `IT_AR : begin
            if (ir[`I_AR_HAVE_IMM_POS]) begin // has immediate
                op1 = { 10'b0, ir[5:0] };
                op2 = 16'b0;
                
                oquick_reg_sel1 = `RS_SIZE'b0;
                oquick_reg_sel2 = `RS_SIZE'b0;
                
                op1_reg_valid = 0;
                op2_reg_valid = 0;
                
                dest = ir[`I_AR_OP0_POS];
                dest_valid = 1;
            end
            else begin
                op1 = reg_op1;
                op2 = reg_op2;
                
                oquick_reg_sel1 = ir[`I_AR_OP1_POS];
                oquick_reg_sel2 = ir[`I_AR_OP2_POS];
                
                op1_reg_valid = 1;
                op2_reg_valid = 1;
                
                dest = ir[`I_AR_OP0_POS];
                dest_valid = 1;
            end
        end

        // Load/Store 
        `IT_LS: begin
            if (ir[`I_LS_HAVE_IMM_POS]) begin // has immediate
                op1 = reg_op1;
                op2 = { 8'b0, ir[7:0] };
                
                oquick_reg_sel1 = ir[`I_LS_OP0_POS];
                oquick_reg_sel2 = `RS_SIZE'b0;

                op1_reg_valid = 1;
                op2_reg_valid = 0;
            end
            else begin
                op1 = reg_op1;
                op2 = reg_op2;

                oquick_reg_sel1 = ir[`I_LS_OP0_POS];
                oquick_reg_sel2 = ir[`I_LS_OP1_POS];
                
                op1_reg_valid = 1;
                op2_reg_valid = 1;
            end
            
            if (ir[`I_LS_IS_STORE_POS]) begin
                `NO_DEST
            end else begin
                dest = ir[`I_LS_OP0_POS];
                dest_valid = 1;
            end
        end

        // Jumps
        `IT_JMP: begin
            if (ir[`I_JMP_HAVE_IMM_POS]) begin // has immediate
                // sign extended
                op1 = { {(10){ir[5]}}, ir[5:0] };
                
                oquick_reg_sel1 = `RS_SIZE'b0;
                
                op1_reg_valid = 0;
            end
            else begin
                op1 = reg_op1;
                
                oquick_reg_sel1 = ir[2:0];
                
                op1_reg_valid = 1;
            end

            if (ir[`I_JMP_HAVE_COND_POS]) begin // has comparison operand
                op2 = reg_op2;
                
                oquick_reg_sel2 = ir[8:6];

                op2_reg_valid = 1;
            end
            else begin
                op2 = 16'b0;
                
                oquick_reg_sel2 = `RS_SIZE'b0;
                
                op2_reg_valid = 0;
            end
            
            `NO_DEST
        end

        // NOP or HALT
        `IT_NH: begin
            op1 = 16'b0;
            op2 = 16'b0;
            
            oquick_reg_sel1 = `RS_SIZE'b0;
            oquick_reg_sel2 = `RS_SIZE'b0;
                
            op1_reg_valid = 0;
            op2_reg_valid = 0;
            
            `NO_DEST
        end
    endcase
end

always @(posedge clk) begin
    if (rst) begin
        out_ir <= ir;

        out_op1 <= op1;
        out_op1_reg <= oquick_reg_sel1;
        out_op1_reg_valid <= op1_reg_valid;

        out_op2 <= op2;
        out_op2_reg <= oquick_reg_sel2;
        out_op2_reg_valid <= op2_reg_valid;
        
        out_dest <= dest;
        out_dest_valid <= dest_valid;
    end else begin
        out_ir <= 0;

        out_op1 <= 0;
        out_op1_reg <= 0;
        out_op1_reg_valid <= 0;

        out_op2 <= 0;
        out_op2_reg <= 0;
        out_op2_reg_valid <= 0;
        
        out_dest <= 0;
        out_dest_valid <= 0;
    end
end

endmodule