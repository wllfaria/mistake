package pane

import "../../slab"
import "../cursor"

Pane :: struct {
	buffer: slab.Key,
	cursor: cursor.Cursor,
}

with_buffer :: proc(buffer_id: slab.Key) -> Pane {
	return Pane{buffer = buffer_id, cursor = cursor.new()}
}
