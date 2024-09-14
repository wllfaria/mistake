package term

import "core:encoding/ansi"
import "core:fmt"
import "core:strings"
import e "escape"

CursorStyle :: enum {
	Default,
	BlinkingBlock,
	SteadyBlock,
	BlinkingUnderscore,
	SteadyUnderscore,
	BlinkingBar,
	SteadyBar,
}

MoveTo :: [2]int
ToCol :: distinct int
ToRow :: distinct int
Left :: distinct int
Down :: distinct int
Up :: distinct int
Right :: distinct int

BaseCursorCommand :: enum {
	NextLine,
	PrevLine,
	SavePosition,
	RestorePosition,
	Hide,
	Show,
	EnableBlinking,
	DisableBlinking,
}

CursorCommand :: union {
	BaseCursorCommand,
	Left,
	Down,
	Up,
	Right,
	MoveTo,
	ToCol,
	ToRow,
	CursorStyle,
}

move_to :: proc(#any_int col: int, #any_int row: int) {
	execute(MoveTo{col, row})
}

execute :: proc(command: CursorCommand) {
	switch c in command {
	case MoveTo:
		buf := strings.builder_make()
		fmt.sbprintf(&buf, "%d;%d%s", c.x + 1, c.y + 1, ansi.CUP)
		e.escape(strings.to_string(buf))
	case ToCol:
		buf := strings.builder_make()
		fmt.sbprintf(&buf, "%d" + ansi.CHA, c)
		e.escape(strings.to_string(buf))
	case ToRow:
		buf := strings.builder_make()
		fmt.sbprintf(&buf, "%dd", c)
		e.escape(strings.to_string(buf))
	case Left:
		buf := strings.builder_make()
		fmt.sbprintf(&buf, "%d" + ansi.CUB, c)
		e.escape(strings.to_string(buf))
	case Down:
		buf := strings.builder_make()
		fmt.sbprintf(&buf, "%d" + ansi.CUD, c)
		e.escape(strings.to_string(buf))
	case Up:
		buf := strings.builder_make()
		fmt.sbprintf(&buf, "%d" + ansi.CUU, c)
		e.escape(strings.to_string(buf))
	case Right:
		buf := strings.builder_make()
		fmt.sbprintf(&buf, "%d" + ansi.CUF, c)
		e.escape(strings.to_string(buf))
	case CursorStyle:
		switch c {
		case .Default:
			e.escape("0 q")
		case .BlinkingBlock:
			e.escape("1 q")
		case .SteadyBlock:
			e.escape("2 q")
		case .BlinkingUnderscore:
			e.escape("3 q")
		case .SteadyUnderscore:
			e.escape("4 q")
		case .BlinkingBar:
			e.escape("5 q")
		case .SteadyBar:
			e.escape("6 q")
		}
	case BaseCursorCommand:
		switch c {
		case .NextLine:
			e.escape("1E")
		case .PrevLine:
			e.escape("1F")
		case .SavePosition:
			e.escape("7")
		case .RestorePosition:
			e.escape("8")
		case .Hide:
			e.escape(ansi.DECTCEM_HIDE)
		case .Show:
			e.escape(ansi.DECTCEM_SHOW)
		case .EnableBlinking:
			e.escape("?12h")
		case .DisableBlinking:
			e.escape("?12l")
		}
	}
}
