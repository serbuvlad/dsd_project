`define I_SIZE 16
`define RS_SIZE 3

`define IT_POS 15:14
`define IT_NH  2'b00
`define IT_LS  2'b01
`define IT_JMP 2'b10
`define IT_AR  2'b11

`define I_NH_OP_POS  15:0
`define I_NH_OP_NOP  16'b0000_0000_0000_0000
`define I_NH_OP_HALT 16'b0011_1111_1111_1111

`define I_LS_HAVE_IMM_POS 13
`define I_LS_IS_STORE_POS 12
`define I_LS_OP_POS 15:11

`define I_LS_OP0_POS 10:8
`define I_LS_OP1_POS 2:0

`define I_LS_OP_LOAD   5'b01_0_0_0
`define I_LS_OP_LOADC  5'b01_1_0_0
`define I_LS_OP_STORE  5'b01_0_1_0

`define I_AR_HAVE_IMM_POS 13
`define I_AR_F_POS   9
`define I_AR_OP_POS  15:9
`define I_AR_OP0_POS 8:6
`define I_AR_OP1_POS 5:3
`define I_AR_OP2_POS 2:0

`define I_AR_OP_ADD      7'b11_0_000_0
`define I_AR_OP_ADDF     7'b11_0_000_1
`define I_AR_OP_SUB      7'b11_0_001_0
`define I_AR_OP_SUBF     7'b11_0_001_1
`define I_AR_OP_AND      7'b11_0_010_0
`define I_AR_OP_OR       7'b11_0_011_0
`define I_AR_OP_XOR      7'b11_0_100_0
`define I_AR_OP_NAND     7'b11_0_101_0
`define I_AR_OP_NOR      7'b11_0_110_0
`define I_AR_OP_NXOR     7'b11_0_111_0
`define I_AR_OP_SHIFTR   7'b11_1_000_0
`define I_AR_OP_SHIFTRA  7'b11_1_001_0
`define I_AR_OP_SHIFTL   7'b11_1_010_0

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