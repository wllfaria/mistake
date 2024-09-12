package editor

import "../term"
import "core:fmt"

setup_terminal :: proc() {
	term.enter_alternate_screen()
	term.enable_raw_mode()
}

reset_terminal :: proc() {
	term.leave_alternate_screen()
	term.disable_raw_mode()
}

Action :: enum {
	Quit,
}

handle_key_event :: proc(event: term.KeyEvent) -> Maybe(Action) {
	switch c in event.code {
	case term.Char:
		fmt.println(event)
		if c.value == 'q' && event.modifier == .Control {
			return .Quit
		}
	case term.BaseKey:
	case term.F:
	}

	return nil
}

next_event :: proc() -> Maybe(Action) {
	event := term.read()
	switch ev in event {
	case term.KeyEvent:
		return handle_key_event(ev)
	case term.Focus:
	case term.Resize:
	}

	return nil
}

run :: proc() {
	for {
		action := next_event()
		if action == .Quit {
			break
		}
	}
}
