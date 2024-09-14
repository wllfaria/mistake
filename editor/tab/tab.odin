package tab

import "../../slab"

Axis :: enum {
	Horizontal,
	Vertical,
}

Leaf :: slab.Key

Branch :: struct {
	direction: Axis,
	ratios:    []f32,
	children:  []PaneTree,
}

PaneTree :: union {
	Leaf,
	Branch,
}

Tab :: struct {
	layout: PaneTree,
}

new :: proc(pane_id: slab.Key) -> Tab {
	return Tab{layout = pane_id}
}
