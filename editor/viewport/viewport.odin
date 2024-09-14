package viewport

import "../cursor"
import "../geometry"
import to "../text_object"

Viewport :: struct {
	cells:  []Cell,
	width:  int,
	height: int,
}

new :: proc(#any_int width: int, #any_int height: int) -> Viewport {
	cells := make([]Cell, width * height)
	defer delete(cells)
	return Viewport{cells = cells, width = width, height = height}
}

set_cell :: proc(vp: ^Viewport, rune: rune, #any_int col: int, #any_int row: int) {
	idx := (row * vp.width) + col
	vp.cells[idx] = Cell {
		value = rune,
	}
}

fill :: proc(
	viewport: ^Viewport,
	text_object: ^to.TextObject,
	cursor: ^cursor.Cursor,
	pos: geometry.Pos,
) {
	for y in pos.y ..< pos.height {
		line := to.try_get_line(text_object, y)
		for x in pos.x ..< pos.width {
			char: rune
			if line != nil {
				if r := to.try_get_rune(line.(string), x); r != nil {
					char = r.(rune)
				}
			}
			set_cell(viewport, char, x, y)
		}
	}
}
