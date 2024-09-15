package editor

import "../slab"
import "../term"
import "action"
import "buffer"
import "core:fmt"
import "core:log"
import "event"
import "fs"
import "keymap"
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

	keymap.setup()
	term_size := term.size()
	editor.viewport = viewport.new(term_size.width, term_size.height)
}

handle_editor_action :: proc(action: Maybe(action.EditorAction)) -> bool {
	switch action {
	case .Quit:
		return true
	}

	return false
}

run :: proc() {
	for {
		term.hide_cursor()

		ui.render_tab(&editor.store, &editor.viewport)
		ui.flush(&editor.viewport)

		curr_pane := store.active_pane(&editor.store)

		ui.render_cursor(&curr_pane)
		term.show_cursor()

		editor_action := event.next(&editor.store)
		if should_quit := handle_editor_action(editor_action); should_quit {
			break
		}
	}
}

drop :: proc() {
	store.drop(editor.store)
	keymap.drop()
}
