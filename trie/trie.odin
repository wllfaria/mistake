package trie

import "base:intrinsics"
import "core:fmt"
import "core:log"
import "core:slice"
import "core:testing"

Node :: struct($T: typeid) {
	final:    bool,
	value:    rune,
	data:     Maybe(T),
	children: [dynamic]Node(T),
}

QueryResult :: union($T: typeid) {
	TrieQuery(T),
	Maybe(int),
}

TrieQuery :: struct($T: typeid) {
	continues: bool,
	data:      Maybe(T),
}

@(private = "file")
make :: proc($T: typeid, final: bool, value: rune, data: Maybe(T)) -> Node(T) {
	return Node(T){final = final, value = value, data = data, children = [dynamic]Node(T){}}
}

empty :: proc($T: typeid) -> Node(T) {
	return Node(T){final = false, value = ' ', data = nil, children = [dynamic]Node(T){}}
}

@(require_results)
has_children :: proc(list: []Node($T), key: rune) -> (idx: int, found: bool) {
	for n, i in list {
		if n.value == key {
			return i, true
		}
	}
	return -1, false
}

add_word :: proc(root: ^Node($T), word: string, data: T) {
	if len(word) == 0 {
		return
	}
	curr := root
	for c, i in word {
		final := i == len(word) - 1
		idx, found := has_children(curr.children[:], c)
		if !found {
			new_node: Node(T)
			if final {
				new_node = make(T, final, c, data)
			} else {
				new_node = make(T, final, c, nil)
			}
			append(&curr.children, new_node)
			curr = &curr.children[len(curr.children) - 1]
		} else {
			curr = &curr.children[idx]
		}
	}
}

find_word :: proc(root: ^Node($T), word: string) -> QueryResult(T) {
	if len(word) == 0 {
		return nil
	}

	curr := root
	for c in word {
		idx, found := has_children(curr.children[:], c)
		if !found {
			return nil
		}
		curr = &curr.children[idx]
	}

	return TrieQuery(T){data = curr.data, continues = len(curr.children) > 0}
}

drop :: proc(node: Node($T), free_data: proc(v: T)) {
	if node.data != nil {
		free_data(node.data.(T))
	}

	for child in node.children {
		drop(child, free_data)
	}

	delete(node.children)
}
