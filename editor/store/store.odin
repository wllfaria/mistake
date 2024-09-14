package store

import "../../slab"
import "../buffer"
import "../geometry"
import "../pane"
import "../tab"

Store :: struct {
	panes:      slab.Slab(pane.Pane),
	buffers:    slab.Slab(buffer.Buffer),
	tabs:       slab.Slab(tab.Tab),
	active_tab: slab.Key,
}

empty :: proc() -> Store {
	return Store {
		panes = slab.empty(pane.Pane),
		buffers = slab.empty(buffer.Buffer),
		tabs = slab.empty(tab.Tab),
		active_tab = 0,
	}
}

drop :: proc(store: Store) {
	for entry in store.buffers.inner {
		#partial switch buf in entry {
		case slab.Full(buffer.Buffer):
			buffer.drop(buf.inner)
		}
	}
	slab.drop(store.panes)
	slab.drop(store.buffers)
	slab.drop(store.tabs)
}

add_buffer :: proc(store: ^Store, buf: buffer.Buffer) -> slab.Key {
	return slab.push(&store.buffers, buf)
}

add_pane :: proc(store: ^Store, p: pane.Pane) -> slab.Key {
	return slab.push(&store.panes, p)
}

add_tab :: proc(store: ^Store, t: tab.Tab) -> slab.Key {
	return slab.push(&store.tabs, t)
}

active_tab :: proc(store: ^Store) -> tab.Tab {
	return slab.get(&store.tabs, store.active_tab)
}
