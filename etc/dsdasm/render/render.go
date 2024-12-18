package render

import (
	"fmt"
	"io"
	"strconv"
)

// Render outputs the instructions to w with the format name[i] = Verilog constant, prefixed by prefix.
// It only errors if w returns an error.
func Render(instructions []uint16, w io.Writer, prefix string, name string) error {
	for i, instruction := range instructions {
		_, err := fmt.Fprintf(w, "%v%v[%v] = 16'b%v;\n", prefix, name, i, renderInstruction(instruction));
		if err != nil {
			return fmt.Errorf("error rendering instructions: %w", err)
		}
	}

	return nil
}

// renderInstruction formats the instruction in Verilog 16'b0000111100001111 format
func renderInstruction(instruction uint16) string {
	return strconv.FormatUint(uint64(instruction), 2)
}
