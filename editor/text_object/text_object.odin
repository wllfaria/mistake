package text_object

import "core:slice"
import "core:strings"

TextObject :: struct {
	content: []string,
}

new :: proc(content: string) -> TextObject {
	return TextObject{content = strings.split_lines(content)}
}
