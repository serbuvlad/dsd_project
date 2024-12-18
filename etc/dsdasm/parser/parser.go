package parser

import (
	"io"

	"github.com/alecthomas/participle/v2"
	"github.com/alecthomas/participle/v2/lexer"
	"github.com/serbuvlad/dsdasm"
)

func New() *participle.Parser[dsdasm.Asm] {
	asmLexer := lexer.MustSimple([]lexer.SimpleRule{
		{Name: "Ident", Pattern: `[a-zA-Z_]\w*`},
		{Name: "Int", Pattern: `[0-9]+`},
		{Name: "NL", Pattern: `[\n\r]+`},
		{Name: "Punctuation", Pattern: `[:,.]`},
		{Name: "whitespace", Pattern: `[ \t]+`},
	})

	parser := participle.MustBuild[dsdasm.Asm](participle.Lexer(asmLexer))

	return parser
}

func Parse(filename string, r io.Reader) (*dsdasm.Asm, error) {
	p := New()

	return p.Parse(filename, r)
}
