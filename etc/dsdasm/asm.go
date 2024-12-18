package dsdasm

import "fmt"

type Asm struct {
	Instructions []*Instruction `parser:"NL* @@*"`
}

func (asm *Asm) findLabel(label string) (int, error) {
	for i, instruction := range asm.Instructions {
		for _, l := range instruction.Labels {
			if label == l.Name {
				return i, nil
			}
		}
	}

	return 0, fmt.Errorf("label not found #%v", label)
}

type Instruction struct {
	Labels        []*Label    `parser:"(@@ NL?)*"`
	Instruction   string      `parser:"@Ident"`
	Arguments     []*Argument `parser:"(@@ (',' @@)*)? NL"`
}

type Label struct {
	Name string `parser:"@Ident ':'"`
}

type Argument struct {
	Integer  *int    `parser:"  @Int"`
	Register *string `parser:"| @('R0' | 'R1' | 'R2' | 'R3' | 'R4' | 'R5' | 'R6' | 'R7')"`
  Label    *string `parser:"| ('.' @Ident)"`
}

func (arg *Argument) getInt(bits uint, signed bool) (int, error) {
	if (arg.Integer == nil) {
		return 0, fmt.Errorf("expected integer")
	}

	i := *arg.Integer
	var max, min int
	if (signed) {
		max = (1 << (bits - 1)) - 1
		min = -(1 << (bits - 1))
	} else {
		max = (1 << bits) - 1
		min = 0
	}

	if i < min || i > max {
		return 0, fmt.Errorf("integer out of range [%v, %v]", min, max)
	}

	return i, nil
}

func (arg *Argument) getRegister() (uint16, error) {
	if (arg.Register == nil) {
		return 0, fmt.Errorf("expected register")
	}

	return regToNum(*arg.Register), nil
}

func (arg *Argument) getLabel() (string, error) {
	if (arg.Label == nil) {
		return "", fmt.Errorf("expected label")
	}

	return *arg.Label, nil
}

func regToNum(reg string) uint16 {
	switch (reg) {
	case "R0":
		return 0
	case "R1":
		return 1
	case "R2":
		return 2
	case "R3":
		return 3
	case "R4":
		return 4
	case "R5":
		return 5
	case "R6":
		return 6
	case "R7":
		return 7
	default:
		panic("Bad register")
	}
}
