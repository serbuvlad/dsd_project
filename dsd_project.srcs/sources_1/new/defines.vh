`define I_SIZE 32
`define RS_SIZE 3

`define NOP      16'b00000000_00000000
`define HALT     16'b11111111_11111111
`define ADD       7'b0000001
`define ADDF      7'b0000010
`define SUB       7'b0000011
`define SUBF      7'b0000100
`define AND       7'b0000101
`define OR        7'b0000111
`define XOR       7'b0001000
`define NAND      7'b0001001
`define NOR       7'b0001010
`define NXOR      7'b0001011
`define SHIFTR    7'b0001100
`define SHIFTRA   7'b0001101
`define SHIFTL    7'b0001110
`define LOAD      5'b00100
`define LOADC     5'b00101
`define STORE     5'b00110
`define JMP       4'b0100
`define JMPR      4'b0101
`define JMPcond   4'b0110
`define JMPRcond  4'b0111

`define JMPcondN  3'b000
`define JMPcondNN 3'b001
`define JMPcondZ  3'b010
`define JMPcondNZ 3'b011

`define JMPN   {`JMPcond,  `JMPcondN}
`define JMPNN  {`JMPcond,  `JMPcondNN}
`define JMPZ   {`JMPcond,  `JMPcondZ}
`define JMPNZ  {`JMPcond,  `JMPcondNZ}
`define JMPRN  {`JMPRcond, `JMPcondN}
`define JMPRNN {`JMPRcond, `JMPcondNN}
`define JMPRZ  {`JMPRcond, `JMPcondZ}
`define JMPRNZ {`JMPRcond, `JMPcondNZ}

`define R0 3'd0
`define R1 3'd1
`define R2 3'd2
`define R3 3'd3
`define R4 3'd4
`define R5 3'd5
`define R6 3'd6
`define R7 3'd7