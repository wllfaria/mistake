package text_object

import "core:slice"
import "core:strings"

TextObject :: struct {
	content: []string,
}

new :: proc(content: string) -> TextObject {
	split := strings.split_lines(content)

	return TextObject{content = split}
}

try_get_line :: proc(to: ^TextObject, #any_int line: int) -> Maybe(string) {
	if line >= len(to.content) {
		return nil
	}
	return to.content[line]
}

try_get_rune :: proc(line: string, #any_int col: int) -> Maybe(rune) {
	if col >= len(line) {
		return nil
	}
	return cast(rune)line[col]
}
