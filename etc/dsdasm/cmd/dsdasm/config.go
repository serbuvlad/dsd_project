package main

import (
	"fmt"
	"path/filepath"

	"github.com/adrg/xdg"
	"github.com/spf13/pflag"
	"github.com/spf13/viper"
)

type Options struct {
	In      string
	Out     string
	Prefix  string
	Vector  string
	Append  bool
}

func readConfig() *Options {
	// Define the list of flags
	viper.SetDefault("in", "in.asm")
	viper.SetDefault("out", "/dev/stdout")
	viper.SetDefault("prefix", "\t")
	viper.SetDefault("vector", "instructions")
	viper.SetDefault("append", false)

	// Enable getting flags from enviornment
	viper.SetEnvPrefix("dsdasm")
	viper.AutomaticEnv()

	// Enable getting flags from moodle_chat_watchdog/config.yaml as defined in the XDG spec
	viper.SetConfigName("config")
	viper.SetConfigType("yaml")
	viper.AddConfigPath(filepath.Join(xdg.ConfigHome, "dsdasm"))
	for _, path := range xdg.ConfigDirs {
		viper.AddConfigPath(filepath.Join(path, "dsdasm"))
	}

	// Read the config file but ignore if we can not find it
        err := viper.ReadInConfig()
	if err != nil {
		if _, ok := err.(viper.ConfigFileNotFoundError); !ok {
			panic(fmt.Errorf("fatal error config file: %w", err))
		}
	}

	// Enable getting flags from the command line
	// Defaults here do not matter, but show up as documentation when running with --help
	pflag.String("in", "in.asm", "Input file")
	pflag.String("out", "stdout", "Output file")
	pflag.String("prefix", "", "Prefix to print on every line (indentation)")
	pflag.String("vector", "instructions", "Name of Verilog array")
	pflag.Bool("append", false, "Append to output file")
	pflag.Parse()
	viper.BindPFlags(pflag.CommandLine)

	// Construct the options structure
	return &Options{
		In:  viper.GetString("in"),
		Out: viper.GetString("out"),
		Prefix:  viper.GetString("prefix"),
		Vector: viper.GetString("vector"),
		Append: viper.GetBool("append"),
	}
}
