package cursor

Cursor :: struct {
	x:      int,
	y:      int,
	// virtual x is used to display the cursor when a line is smaller
	// than the actual x position
	virt_x: int,
}

new :: proc() -> Cursor {
	return Cursor{x = 0, y = 0, virt_x = 0}
}
