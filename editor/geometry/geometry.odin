package geometry

Pos :: struct {
	x:      int,
	y:      int,
	width:  int,
	height: int,
}

new_pos :: proc(
	#any_int x: int,
	#any_int y: int,
	#any_int width: int,
	#any_int height: int,
) -> Pos {
	return Pos{x = x, y = y, width = width, height = height}
}
