package main

import "core:fmt"
import "editor"

main :: proc() {
	editor.setup_terminal()
	defer editor.reset_terminal()

	editor.run()
}
