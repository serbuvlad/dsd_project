package parser_test

import (
	"testing"

	"github.com/serbuvlad/dsdasm/parser"
)

func TestParser(t *testing.T) {
	s := `
a:    b:
	ADD R1
`
	p := parser.New()

	a, err := p.ParseString("test.asm", s)
	if err != nil {
		t.Log(err)
		t.FailNow()
	}

	t.Logf("%#v\n", a)
}
