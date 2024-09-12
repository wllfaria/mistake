package geometry

import "../slab"

Pos :: struct {
	x:      int,
	y:      int,
	width:  int,
	height: int,
}


Pane :: struct {
	pos:    Pos,
	buffer: Maybe(slab.Key),
}

Buffer :: struct {}
