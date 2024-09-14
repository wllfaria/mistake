package term

import "./escape"
import "core:encoding/ansi"
import "core:fmt"
import "core:os"
import "core:strings"

print :: proc(r: rune) {
	os.write_rune(os.stdout, r)
}

ClearType :: enum {
	All,
	Purge,
	FromCursorDown,
	FromCursorUp,
	CurrentLine,
	UntilNewLine,
}

TermSize :: struct {
	width:  int,
	height: int,
}

enable_raw_mode :: proc() {
	ffi_enable_raw_mode()
}

disable_raw_mode :: proc() {
	ffi_disable_raw_mode()
}

size :: proc() -> TermSize {
	size := ffi_size()
	return TermSize{width = cast(int)size.width, height = cast(int)size.height}
}

enable_line_wrap :: proc() {
	escape.escape(ansi.DECAWM_ON)
}

disable_line_wrap :: proc() {
	escape.escape(ansi.DECAWM_OFF)
}

enter_alternate_screen :: proc() {
	escape.escape("?1049h")
}

leave_alternate_screen :: proc() {
	escape.escape("?1049l")
}

scroll_up :: proc(#any_int n: int) {
	buf := strings.builder_make()
	fmt.sbprintf(&buf, "%d%s", n, ansi.SU)
	escape.escape(strings.to_string(buf))
}

scroll_down :: proc(#any_int n: int) {
	buf := strings.builder_make()
	fmt.sbprintf(&buf, "%d%s", n, ansi.SD)
	escape.escape(strings.to_string(buf))
}

set_size :: proc(#any_int width: int, #any_int height: int) {
	buf := strings.builder_make()
	fmt.sbprintf(&buf, "8;%d;%dt", height, width)
	escape.escape(strings.to_string(buf))
}

set_title :: proc(title: ^string) {
	buf := strings.builder_make()
	fmt.sbprintf(&buf, "0;%s\x07", title)
	escape.os_escape(strings.to_string(buf))
}

clear_screen :: proc(clear_type: ClearType) {
	switch clear_type {
	case .All:
		escape.escape("2J")
	case .Purge:
		escape.escape("3J")
	case .FromCursorDown:
		escape.escape("J")
	case .FromCursorUp:
		escape.escape("1J")
	case .CurrentLine:
		escape.escape("2K")
	case .UntilNewLine:
		escape.escape("1K")
	}
}
