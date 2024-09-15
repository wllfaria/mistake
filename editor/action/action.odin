package action

EditorAction :: enum {
	Quit,
}

CursorAction :: enum {
	MoveToTop,
	MoveToBottom,
}

Action :: union {
	EditorAction,
	CursorAction,
}
