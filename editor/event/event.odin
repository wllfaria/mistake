package event

import "../../term"
import "../action"
import "../keymap"
import "../store"
import "core:log"

next :: proc(st: ^store.Store) -> Maybe(action.EditorAction) {
	actions: Maybe([dynamic]action.Action)

	switch ev in term.read() {
	case term.KeyEvent:
		actions = handle_key_event(ev)
	case term.Focus:
	case term.Resize:
	}

	if actions == nil {
		return nil
	}

	for ac in actions.([dynamic]action.Action) {
		switch v in ac {
		case action.EditorAction:
			return v
		case action.CursorAction:
			handle_cursor_action(v, st)
		}
	}

	return nil
}

handle_key_event :: proc(event: term.KeyEvent) -> Maybe([dynamic]action.Action) {
	switch c in event.code {
	case term.Char:
		return keymap.has_keymap(.Normal, event)
	case term.BaseKey:
	case term.F:
	}

	return nil
}

handle_cursor_action :: proc(ac: action.CursorAction, st: ^store.Store) {
}
