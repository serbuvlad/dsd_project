  LOADC   R0, 100
  LOAD    R2, R0
  LOADC   R0, 101
  LOAD    R3, R0

  XOR     R0, R0, R0
  LOADC   R1, 1

  XOR     R7, R7, R7

mul:
  JMPRZ   R3, .end
  ADD     R7, R7, R2
  SUB     R3, R3, R1

  JMPR    .mul

end:
  LOADC   R0, 200
  STORE   R0, R3

  HALT
