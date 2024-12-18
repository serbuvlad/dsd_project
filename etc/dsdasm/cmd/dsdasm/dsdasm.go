package main

import (
	"fmt"
	"os"

	"github.com/serbuvlad/dsdasm"
	"github.com/serbuvlad/dsdasm/parser"
	"github.com/serbuvlad/dsdasm/render"
)

func main() {
	options := readConfig()

	in, err := os.Open(options.In)
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to open input file %v: %v", options.In, err)
		os.Exit(1)
	}
	defer in.Close()

	asm, err := parser.Parse(options.In, in)
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to parse input file: %v", err)
		os.Exit(1)
	}

	instructions, err := dsdasm.Codegen(asm)
	if err != nil {
		fmt.Fprintf(os.Stderr, "codegen failed: %v", err)
		os.Exit(1)
	}

	var out *os.File
	if options.Append {
		out, err = os.OpenFile(options.Out, os.O_WRONLY | os.O_APPEND | os.O_CREATE, 0o666)
	} else {
		out, err = os.Create(options.Out)
	}
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to open output file %v: %v", options.Out, err)
	}
	defer out.Close()

	err = render.Render(instructions, out, options.Prefix, options.Vector)
	if err != nil {
		fmt.Fprintf(os.Stderr, "failed to write to output file: %v", err)
	}

}

