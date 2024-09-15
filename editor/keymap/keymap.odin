package keymap

import "../../term"
import "../../trie"
import "../action"
import "../common"
import "core:fmt"
import "core:log"
import "core:strings"

@(private = "file")
buffered_keymap := ""

@(private = "file")
normal_keymaps := trie.empty([dynamic]action.Action)

@(private = "file")
insert_keymaps := trie.empty([dynamic]action.Action)

setup :: proc() {
	setup_normal_keymaps()
	setup_insert_keymaps()
}

KeymapEntry :: struct {
	word:    string,
	actions: [dynamic]action.Action,
}

@(private)
setup_normal_keymaps :: proc() {
	keymaps := [dynamic]KeymapEntry {
		KeymapEntry{word = "gg", actions = [dynamic]action.Action{action.CursorAction.MoveToTop}},
		KeymapEntry {
			word = "G",
			actions = [dynamic]action.Action{action.CursorAction.MoveToBottom},
		},
		KeymapEntry{word = "Q", actions = [dynamic]action.Action{action.EditorAction.Quit}},
	}
	defer delete(keymaps)

	for entry in keymaps {
		trie.add_word(&normal_keymaps, entry.word, entry.actions)
	}
}

@(private)
setup_insert_keymaps :: proc() {}

key_event_to_str :: proc(key: term.KeyEvent) -> string {
	key_str: string
	buf := strings.builder_make()

	switch v in key.code {
	case term.Char:
		fmt.sbprintf(&buf, "%c", v.value)
		key_str = strings.to_string(buf)
	case term.BaseKey:
		switch v {
		case term.BaseKey.Left:
			fmt.sbprint(&buf, "<left>")
			key_str = strings.to_string(buf)
		case term.BaseKey.Down:
			fmt.sbprint(&buf, "<down>")
			key_str = strings.to_string(buf)
		case term.BaseKey.Up:
			fmt.sbprint(&buf, "<up>")
			key_str = strings.to_string(buf)
		case term.BaseKey.Right:
			fmt.sbprint(&buf, "<right>")
			key_str = strings.to_string(buf)
		case term.BaseKey.End:
			fmt.sbprint(&buf, "<end>")
			key_str = strings.to_string(buf)
		case term.BaseKey.Home:
			fmt.sbprint(&buf, "<home>")
			key_str = strings.to_string(buf)
		case term.BaseKey.Enter:
			fmt.sbprint(&buf, "<cr>")
			key_str = strings.to_string(buf)
		case term.BaseKey.Escape:
			fmt.sbprint(&buf, "<esc>")
			key_str = strings.to_string(buf)
		case term.BaseKey.BackTab:
			fmt.sbprint(&buf, "<bt>")
			key_str = strings.to_string(buf)
		case term.BaseKey.Backspace:
			fmt.sbprint(&buf, "<bs>")
			key_str = strings.to_string(buf)
		}
	case term.F:
		fmt.sbprintf(&buf, "<f%d>", v.value)
		key_str = strings.to_string(buf)
	}

	#partial switch key.modifier {
	case .Control:
		_buf := strings.builder_make()
		fmt.sbprintf(&_buf, "<c-%s>", key_str)
		key_str = strings.to_string(_buf)
	}

	return key_str
}

format_keymap :: proc(key: term.KeyEvent) -> string {
	key_str := key_event_to_str(key)
	defer delete(key_str)
	buf := strings.builder_make()
	fmt.sbprintf(&buf, "%s%s", buffered_keymap, key_str)
	return strings.to_string(buf)
}

has_keymap :: proc(mode: common.Mode, key: term.KeyEvent) -> Maybe([dynamic]action.Action) {
	result: trie.QueryResult([dynamic]action.Action)
	keymap_str := format_keymap(key)
	defer delete(keymap_str)

	switch mode {
	case .Normal:
		result = trie.find_word(&normal_keymaps, keymap_str)
	case .Insert:
		result = trie.find_word(&insert_keymaps, keymap_str)
	}

	#partial switch v in result {
	case trie.TrieQuery([dynamic]action.Action):
		if v.continues {
			buffered_keymap = strings.clone(keymap_str)
			return nil
		}
		buffered_keymap = ""
		return v.data
	}

	return nil
}

drop :: proc() {
	free_data := proc(v: [dynamic]action.Action) {
		delete(v)
	}
	trie.drop(normal_keymaps, free_data)
	trie.drop(insert_keymaps, free_data)
}
