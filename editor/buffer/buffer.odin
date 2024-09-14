package buffer

import "../fs"
import to "../text_object"
import "core:fmt"

Buffer :: struct {
	file_info:   fs.FileInfo,
	text_object: to.TextObject,
}

new_from_file :: proc(file_info: fs.FileInfo) -> Buffer {
	return Buffer{file_info = file_info, text_object = to.new(file_info.content)}
}

drop :: proc(buffer: Buffer) {
	delete(buffer.file_info.path)
	delete(buffer.file_info.content)
	delete(buffer.text_object.content)
}
