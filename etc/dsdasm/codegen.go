package dsdasm

import "fmt"

const (
	NOP_OP  = 0b0000_0000_0000_0000
	HALT_OP = 0b0011_1111_1111_1111
	
	ADD_OP  = 0b11_0_000_0
	ADDF_OP = 0b11_0_000_1
	SUB_OP  = 0b11_0_001_0
	SUBF_OP = 0b11_0_001_1
	AND_OP  = 0b11_0_010_0
	OR_OP   = 0b11_0_011_0
	XOR_OP  = 0b11_0_100_0
	NAND_OP = 0b11_0_101_0
	NOR_OP  = 0b11_0_110_0
	NXOR_OP = 0b11_0_111_0

	SHIFTR_OP  = 0b11_1_000_0
	SHIFTRA_OP = 0b11_1_001_0
	SHIFTL_OP  = 0b11_1_010_0

	LOAD_OP  = 0b01_0_0_0
	LOADC_OP = 0b01_1_0_0
	STORE_OP = 0b01_0_1_0

	JMP_OP    = 0b10_0_0_000
	JMPR_OP   = 0b10_1_0_000
	JMPN_OP   = 0b10_0_1_000
	JMPNN_OP  = 0b10_0_1_001
	JMPZ_OP   = 0b10_0_1_010
	JMPNZ_OP  = 0b10_0_1_011
	JMPRN_OP  = 0b10_1_1_000
	JMPRNN_OP = 0b10_1_1_001
	JMPRZ_OP  = 0b10_1_1_010
	JMPRNZ_OP = 0b10_1_1_011
)

func Codegen(asm *Asm) ([]uint16, error) {
	var rez []uint16
	for i, instruction := range asm.Instructions {
		r, err := codegenInstruction(asm, i, instruction)
		if err != nil {
			return nil, err
		}
		rez = append(rez, r)
	}

	return rez, nil
}

func codegenInstruction(asm *Asm, i int, instruction *Instruction) (uint16, error) {
	arithmethicInstruction := func(name string, opcode uint16) (uint16, error) {
		if len(instruction.Arguments) != 3 {
			return 0, fmt.Errorf("bad number of arguments for %v", name)
		}

		op0, err := instruction.Arguments[0].getRegister()
		if err != nil {
			return 0, fmt.Errorf("bad first argument for %v: %w", name, err)
		}

		op1, err := instruction.Arguments[1].getRegister()
		if err != nil {
			return 0, fmt.Errorf("bad second argument for %v: %w", name, err)
		}

		op2, err := instruction.Arguments[2].getRegister()
		if err != nil {
			return 0, fmt.Errorf("bad third argument for %v: %w", name, err)
		}

		return (opcode << 9) | (op0 << 6) | (op1 << 3) | op2, nil
	}

	shiftInstruction := func(name string, opcode uint16) (uint16, error) {
		if len(instruction.Arguments) != 2 {
			return 0, fmt.Errorf("bad number of arguments for %v", name)
		}

		op0, err := instruction.Arguments[0].getRegister()
		if err != nil {
			return 0, fmt.Errorf("bad frist argument for %v: %w", name, err)
		}

		val, err := instruction.Arguments[1].getInt(6, false)
		if err != nil {
			return 0, fmt.Errorf("bad second argument for %v: %w", name, err)
		}

		return (opcode << 9) | (op0 << 6) | uint16(val), nil
	}

	loadStoreInstruction := func(name string, opcode uint16, haveImmediate bool) (uint16, error) {
		if len(instruction.Arguments) != 2 {
			return 0, fmt.Errorf("bad number of arguments for %v", name)
		}

		op0, err := instruction.Arguments[0].getRegister()
		if err != nil {
			return 0, fmt.Errorf("bad frist argument for %v: %w", name, err)
		}

		var constOrOp1 uint16
		if haveImmediate {
			var iint int
			iint, err = instruction.Arguments[1].getInt(8, false)
			constOrOp1 = uint16(iint)
		} else {
			constOrOp1, err = instruction.Arguments[1].getRegister()
		}
		if err != nil {
			return 0, fmt.Errorf("bad second argument for %v: %w", name, err)
		}

		return (opcode << 11) | (op0 << 8) | constOrOp1, nil
	}

	jumpInstruction := func(name string, opcode uint16, haveImmediate bool, haveCondition bool) (uint16, error) {
		var nargs int
		var op1Pos int
		var op1PosStr string
		if haveCondition {
			nargs = 2
			op1Pos = 1
			op1PosStr = "second"
		} else {
			nargs = 1
			op1Pos = 0
			op1PosStr = "first"
		}

		if len(instruction.Arguments) != nargs {
			return 0, fmt.Errorf("bad number of arguments for %v", name)
		}

		var op0 uint16
		var err error
		if haveCondition {
			op0, err = instruction.Arguments[0].getRegister()
			if err != nil {
				return 0, fmt.Errorf("bad first argument for %v: %w", name, err)
			}
		}

		var op1 uint16
		if haveImmediate {
			label, err := instruction.Arguments[op1Pos].getLabel()
			if err != nil {
				return 0, fmt.Errorf("bad %v argument for %v: %w", op1PosStr, name, err)
			}

			ilabel, err := asm.findLabel(label)
			if err != nil {
				return 0, fmt.Errorf("bad %v argument for %v: %w", op1PosStr, name, err)
			}

			delta := ilabel - i
			if delta < -32 || delta > 31 {
				return 0, fmt.Errorf("label #%v is too far for %v instruction", label, name)
			}

			op1 = uint16(delta & 0b111_111)
		} else {
			op1, err = instruction.Arguments[op1Pos].getRegister()
			if err != nil {
				return 0, fmt.Errorf("bad %v argument for %v: %w", op1PosStr, name, err)
			}
		}


		return (opcode << 9) | (op0 << 6) | op1, nil
	}
	
	switch (instruction.Instruction) {
	case "NOP":
		if len(instruction.Arguments) != 0 {
			return 0, fmt.Errorf("bad number of arguments for NOP")
		}

		return NOP_OP, nil
	case "HALT":
		if len(instruction.Arguments) != 0 {
			return 0, fmt.Errorf("bad number of arguments for HALT")
		}

		return HALT_OP, nil
	case "ADD":
		return arithmethicInstruction("ADD", ADD_OP)
	case "ADDF":
		return arithmethicInstruction("ADDF", ADDF_OP)
	case "SUB":
		return arithmethicInstruction("SUB", SUB_OP)
	case "SUBF":
		return arithmethicInstruction("SUBF", ADDF_OP)
	case "AND":
		return arithmethicInstruction("AND", AND_OP)
	case "OR":
		return arithmethicInstruction("OR", OR_OP)
	case "XOR":
		return arithmethicInstruction("XOR", XOR_OP)
	case "NAND":
		return arithmethicInstruction("NAND", NAND_OP)
	case "NOR":
		return arithmethicInstruction("NOR", NOR_OP)
	case "NXOR":
		return arithmethicInstruction("NXOR", NXOR_OP)

	case "SHIFTR":
		return shiftInstruction("SHIFTR", SHIFTR_OP)
	case "SHIFTRA":
		return shiftInstruction("SHIFTRA", SHIFTRA_OP)
	case "SHIFTL":
		return shiftInstruction("SHIFTL", SHIFTL_OP)

	case "LOAD":
		return loadStoreInstruction("LOAD", LOAD_OP, false)
	case "LOADC":
		return loadStoreInstruction("LOADC", LOADC_OP, true)
	case "STORE":
		return loadStoreInstruction("STORE", STORE_OP, false)

	case "JMP":
		return jumpInstruction("JMP", JMP_OP, false, false)
        case "JMPN":
                return jumpInstruction("JMPN", JMPN_OP, false, true)
        case "JMPNN":
                return jumpInstruction("JMPNN", JMPNN_OP, false, true)
        case "JMPZ":
                return jumpInstruction("JMPZ", JMPZ_OP, false, true)
        case "JMPNZ":
                return jumpInstruction("JMPNZ", JMPNZ_OP, false, true)
	case "JMPR":
		return jumpInstruction("JMPR", JMPR_OP, true, false)
        case "JMPRN":
                return jumpInstruction("JMPRN", JMPRN_OP, true, true)
        case "JMPRNN":
                return jumpInstruction("JMPRNN", JMPRNN_OP, true, true)
        case "JMPRZ":
                return jumpInstruction("JMPRZ", JMPRZ_OP, true, true)
        case "JMPRNZ":
                return jumpInstruction("JMPRNZ", JMPRNZ_OP, true, true)
	}

	return 0, fmt.Errorf("unkown instruction %v", instruction.Instruction)
}

