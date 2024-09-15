package ui

import "../../slab"
import "../../term"
import "../buffer"
import "../geometry"
import p "../pane"
import "../store"
import "../tab"
import "../viewport"

render_pane :: proc(st: ^store.Store, pane: ^p.Pane, pos: geometry.Pos, vp: ^viewport.Viewport) {
	buf := slab.get(&st.buffers, pane.buffer)
	viewport.fill(vp, &buf.text_object, &pane.cursor, pos)
}

render_tab :: proc(st: ^store.Store, vp: ^viewport.Viewport) {
	layout := store.active_tab(st).layout
	switch n in layout {
	case tab.Leaf:
		pane := slab.get(&st.panes, n)
		pos := geometry.new_pos(0, 0, vp.width, vp.height)
		render_pane(st, &pane, pos, vp)
	case tab.Branch:
		panic("todo")
	}
}

flush :: proc(vp: ^viewport.Viewport) {
	for cell, idx in vp.cells {
		row := idx / vp.width
		col := idx % vp.width
		term.move_to(col, row)
		term.print(cell.value)
	}
}

render_cursor :: proc(pane: ^p.Pane) {
	term.move_to(pane.cursor.x, pane.cursor.y)
}
