package editor

import "../slab"
import "../term"
import "buffer"
import "core:fmt"
import "core:log"
import "fs"
import "pane"
import "store"
import "tab"
import "ui"
import "viewport"

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

Editor :: struct {
	store:    store.Store,
	viewport: viewport.Viewport,
}

@(private = "file")
editor: Editor

with_file :: proc(filename: string) {
	file_info: fs.FileInfo
	if filename != "" {
		if data := fs.read_file(filename); data != nil {
			file_info = data.(fs.FileInfo)
			buf := buffer.new_from_file(file_info)
			buf_id := store.add_buffer(&editor.store, buf)
			p := pane.with_buffer(buf_id)
			pane_id := store.add_pane(&editor.store, p)
			tab := tab.new(pane_id)
			store.add_tab(&editor.store, tab)
		} else {
			file_info = fs.with_new_file(filename)
			buf := buffer.new_from_file(file_info)
			buf_id := store.add_buffer(&editor.store, buf)
			p := pane.with_buffer(buf_id)
			pane_id := store.add_pane(&editor.store, p)
			tab := tab.new(pane_id)
			store.add_tab(&editor.store, tab)
		}
	}

	term_size := term.size()
	editor.viewport = viewport.new(term_size.width, term_size.height)
}

handle_key_event :: proc(event: term.KeyEvent) -> Maybe(Action) {
	switch c in event.code {
	case term.Char:
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
		term.hide_cursor()
		ui.render_tab(&editor.store, &editor.viewport)
		ui.flush(&editor.viewport)
		term.show_cursor()
		action := next_event()
		if action == .Quit {
			break
		}
	}
}

drop :: proc() {
	store.drop(editor.store)
}
