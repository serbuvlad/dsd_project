`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 10/08/2024 01:13:00 PM
// Design Name: 
// Module Name: seq_core
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

module seq_core
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

reg [D_SIZE-1:0] R [0:7];
integer i;

`define op0       instruction[8:6]
`define op1       instruction[5:3]
`define op2       instruction[2:0]
`define val       instruction[5:0]
`define lsop0     instruction[10:8]
`define lsop1     instruction[2:0]
`define const     instruction[7:0]
`define offset    instruction[5:0]
`define offsetsgn instruction[5]
`define offsetsz  6
`define jmpop     instruction[2:0]
`define jmpcondop instruction[8:6]
`define cond      instruction[11:9]


always @*
begin
   case (instruction[15:11])
        `LOAD: begin
            read  = 1;
            write = 0;
            
            address  = R[`lsop1][A_SIZE-1:0];
        end
        `LOADC: begin
            read  = 1;
            write = 0;
        end
        `STORE: begin
            read  = 0;
            write = 1;
            
            address  = R[`lsop0][A_SIZE-1:0];
            data_out = R[`lsop1];
        end
        default: begin
            read  = 0;
            write = 0;
        end
        endcase     
end

always @(negedge rst)
begin
    pc <= 0;
    read <= 0;
    write <= 0;
    address <= 0;
    data_out <= 0;
    
    for (i = 0; i < 8; i = i + 1)
        R[i] <= 0;
end

always @(posedge clk)
begin
    if (rst == 1)
    begin
        case (instruction[15:0])
        `NOP:  ;
        `HALT: ;
        endcase
        
        case (instruction[15:9])
        `ADD:
            R[`op0] <= R[`op1] + R[`op2];
        `ADDF:
            R[`op0] <= R[`op1] + R[`op2];
        `SUB:
            R[`op0] <= R[`op1] - R[`op2];
        `SUBF:
            R[`op0] <= R[`op1] - R[`op2];
        `AND:
            R[`op0] <= R[`op1] & R[`op2];
        `OR:
            R[`op0] <= R[`op1] | R[`op2];
        `XOR:
            R[`op0] <= R[`op1] ^ R[`op2];
        `NAND:
            R[`op0] <= ~(R[`op1] & R[`op2]);
        `NOR:
            R[`op0] <= ~(R[`op1] | R[`op2]);
        `NXOR:
            R[`op0] <= ~(R[`op1] ^ R[`op2]);
        `SHIFTR:
            R[`op0] <= R[`op0] >> `val;
        `SHIFTRA:
            R[`op0] <= R[`op0] >>> `val;
        `SHIFTL:
            R[`op0] <= R[`op0] << `val;
        endcase
        
        case (instruction[15:11])
        `LOAD: begin
            R[`lsop0] <= data_in;
        end
        `LOADC: begin
            R[`lsop0] <= {R[`lsop0][D_SIZE-1:8], `const};
        end
        endcase
        
        case (instruction[15:12])
        `JMP:
            pc <= R[`jmpop];
        `JMPR:
            pc <= pc + { {(A_SIZE-`offsetsz){`offsetsgn}}, `offset};
        `JMPcond:
            if ((`cond == `JMPcondN  && R[`jmpcondop] <  0) ||
                (`cond == `JMPcondNN && R[`jmpcondop] >= 0) ||
                (`cond == `JMPcondZ  && R[`jmpcondop] == 0) ||
                (`cond == `JMPcondNZ && R[`jmpcondop] != 0))
                
                pc <= R[`jmpop];
            else
                pc <= pc + 1;
        `JMPRcond:
            if ((`cond == `JMPcondN  && R[`jmpcondop] <  0) ||
                (`cond == `JMPcondNN && R[`jmpcondop] >= 0) ||
                (`cond == `JMPcondZ  && R[`jmpcondop] == 0) ||
                (`cond == `JMPcondNZ && R[`jmpcondop] != 0))
                
                pc <= pc + { {(A_SIZE-`offsetsz){`offsetsgn}}, `offset};
            else
                pc <= pc + 1;
                
        default:
            if (instruction[15:0] != `HALT)
                pc <= pc + 1;
        endcase
    end
end


endmodule
