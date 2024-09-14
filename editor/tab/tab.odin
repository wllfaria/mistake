package tab

import "../../slab"

Tab :: struct {
	panes: []slab.Key,
}

new :: proc(pane_id: slab.Key) -> Tab {
	return Tab{panes = []slab.Key{pane_id}}
}
