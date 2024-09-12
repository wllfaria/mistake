package store

import "../geometry"
import "../slab"


Store :: struct {
	panes:   slab.Slab(geometry.Pane),
	buffers: slab.Slab(geometry.Buffer),
}
