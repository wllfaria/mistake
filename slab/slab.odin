package slab

import "core:fmt"
import "core:testing"

Key :: distinct int

Empty :: struct {
	idx: Maybe(Key),
}

Full :: struct($T: typeid) {
	inner: T,
}

Entry :: union($T: typeid) {
	Full(T),
	Empty,
}

Slab :: struct($T: typeid) {
	inner:   [dynamic]Entry(T),
	next_id: Maybe(Key),
}

empty :: proc($T: typeid) -> Slab(T) {
	return Slab(T){inner = [dynamic]Entry(T){}, next_id = nil}
}

push :: proc(slab: ^Slab($T), value: T) -> Key {
	if slab.next_id == nil {
		append(&slab.inner, Full(T){inner = value})
		return cast(Key)(len(slab.inner) - 1)
	}

	next_id := slab.next_id.(Key)
	entry := slab.inner[next_id]

	switch e in entry {
	case Empty:
		slab.next_id = e.idx
		slab.inner[next_id] = Full(T) {
			inner = value,
		}
		return next_id
	case Full(T):
		panic("unreachable")
	}

	panic("unreachable")
}


remove :: proc(slab: ^Slab($T), idx: Key) -> T {
	new_entry := Empty {
		idx = slab.next_id,
	}
	slab.next_id = idx
	entry := slab.inner[idx]
	slab.inner[idx] = new_entry

	#partial switch e in entry {
	case Empty:
		panic("attempt to remove empty slab item")
	}

	return entry.(Full(T)).inner
}

drop :: proc(slab: Slab($T)) {
	delete(slab.inner)
}

@(test)
push_and_remove :: proc(t: ^testing.T) {
	slab := empty(int)
	defer drop(slab)

	idx := push(&slab, 123)
	val := remove(&slab, idx)
	testing.expect_value(t, val, 123)
	testing.expect_value(t, len(slab.inner), 1)
	testing.expect_value(t, slab.inner[0], Empty{idx = nil})

	push(&slab, 123)
	testing.expect_value(t, len(slab.inner), 1)
	testing.expect_value(t, slab.inner[0], Full(int){inner = 123})

	push(&slab, 456)
	push(&slab, 789)
	push(&slab, 321)
	remove(&slab, 2)
	remove(&slab, 0)

	testing.expect_value(t, slab.inner[0], Empty{idx = 2})
	testing.expect_value(t, slab.inner[2], Empty{idx = nil})
	testing.expect_value(t, slab.next_id, 0)

	push(&slab, 999)

	testing.expect_value(t, slab.inner[0], Full(int){inner = 999})
	testing.expect_value(t, slab.inner[2], Empty{idx = nil})
	testing.expect_value(t, slab.next_id, 2)
}
