package main

import "core:fmt"
import "term"

main :: proc() {
	term.enable_raw_mode()
	for {
		event := term.read()
		char := event.(term.KeyEvent).code.(term.Char).value
		if char == 'q' {
			break
		}
	}
	term.disable_raw_mode()
}
