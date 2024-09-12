package term

import "core:encoding/ansi"
import "core:fmt"
import "core:strings"

ClearType :: enum {
	All,
	Purge,
	FromCursorDown,
	FromCursorUp,
	CurrentLine,
	UntilNewLine,
}

enable_raw_mode :: proc() {
	ffi_enable_raw_mode()
}

disable_raw_mode :: proc() {
	ffi_disable_raw_mode()
}

enable_line_wrap :: proc() {
	escape(ansi.DECAWM_ON)
}

disable_line_wrap :: proc() {
	escape(ansi.DECAWM_OFF)
}

enter_alternate_screen :: proc() {
	escape("?1049h")
}

leave_alternate_screen :: proc() {
	escape("?1049l")
}

scroll_up :: proc(#any_int n: int) {
	buf := strings.builder_make()
	fmt.sbprintf(&buf, "%d%s", n, ansi.SU)
	escape(strings.to_string(buf))
}

scroll_down :: proc(#any_int n: int) {
	buf := strings.builder_make()
	fmt.sbprintf(&buf, "%d%s", n, ansi.SD)
	escape(strings.to_string(buf))
}

set_size :: proc(#any_int width: int, #any_int height: int) {
	buf := strings.builder_make()
	fmt.sbprintf(&buf, "8;%d;%dt", height, width)
	escape(strings.to_string(buf))
}

set_title :: proc(title: ^string) {
	buf := strings.builder_make()
	fmt.println("should change the thing")
	fmt.sbprintf(&buf, "0;%s\x07", title)
	os_escape(strings.to_string(buf))
}

clear_screen :: proc(clear_type: ClearType) {
	switch clear_type {
	case .All:
		escape("2J")
	case .Purge:
		escape("3J")
	case .FromCursorDown:
		escape("J")
	case .FromCursorUp:
		escape("1J")
	case .CurrentLine:
		escape("2K")
	case .UntilNewLine:
		escape("1K")
	}
}
