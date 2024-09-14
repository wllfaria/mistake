package viewport

Viewport :: struct {
	cells: []Cell,
}

new :: proc(#any_int width: int, #any_int height: int) -> Viewport {
	cells := make([]Cell, width * height)
	defer delete(cells)
	return Viewport{cells = cells}
}
