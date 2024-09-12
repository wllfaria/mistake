package term

import "core:fmt"
import "core:os"
import "core:testing"

@(private = "file")
BUFFER_SIZE :: 1024

ParsingState :: enum {
	Base,
	ESC,
	CSI,
}

Char :: struct {
	value: rune,
}

BaseKey :: enum {
	Backspace,
	Enter,
	Escape,
	Left,
	Down,
	Right,
	Up,
	Home,
	End,
	BackTab,
}

F :: struct {
	value: u8,
}

KeyCode :: union {
	Char,
	BaseKey,
	F,
}

KeyModifier :: enum {
	Control,
	None,
	Shift,
}

KeyEvent :: struct {
	code:     KeyCode,
	modifier: KeyModifier,
}

Focus :: enum {
	FocusGained,
	FocusLost,
}

Resize :: struct {
	width:  int,
	height: int,
}

Event :: union {
	KeyEvent,
	Focus,
	Resize,
}

@(private = "file")
parse_csi :: proc(
	buffer: ^[BUFFER_SIZE]byte,
	#any_int idx: int,
	#any_int len: int,
	state: ParsingState,
) -> (
	ParsingState,
	Maybe(Event),
) {
	byte := buffer[idx]
	switch byte {
	case 'D':
		key_event := KeyEvent {
			code     = .Left,
			modifier = .None,
		}
		return state, key_event
	case 'B':
		key_event := KeyEvent {
			code     = .Down,
			modifier = .None,
		}
		return state, key_event
	case 'A':
		key_event := KeyEvent {
			code     = .Up,
			modifier = .None,
		}
		return state, key_event
	case 'C':
		key_event := KeyEvent {
			code     = .Right,
			modifier = .None,
		}
		return state, key_event
	case 'H':
		key_event := KeyEvent {
			code     = .Home,
			modifier = .None,
		}
		return state, key_event
	case 'F':
		key_event := KeyEvent {
			code     = .End,
			modifier = .None,
		}
		return state, key_event
	case 'Z':
		key_event := KeyEvent {
			code     = .BackTab,
			modifier = .Shift,
		}
		return state, key_event
	case 'P':
		key_event := KeyEvent {
			code = F{value = 1},
			modifier = .Shift,
		}
		return state, key_event
	case 'Q':
		key_event := KeyEvent {
			code = F{value = 2},
			modifier = .Shift,
		}
		return state, key_event
	case 'S':
		key_event := KeyEvent {
			code = F{value = 4},
			modifier = .Shift,
		}
		return state, key_event
	case:
		panic("TODO")
	}
}

@(private = "file")
parse_esc :: proc(
	buffer: ^[BUFFER_SIZE]byte,
	#any_int idx: int,
	#any_int len: int,
	state: ParsingState,
) -> (
	ParsingState,
	Maybe(Event),
) {
	byte := buffer[idx]
	if idx == 1 {
		switch byte {
		case '0':
			return .ESC, nil
		case '[':
			return .CSI, nil
		case '\x1b':
			key_event := KeyEvent {
				code     = .Escape,
				modifier = .None,
			}
			return state, key_event
		}
	}

	switch buffer[idx] {
	case 'D':
		key_event := KeyEvent {
			code     = .Left,
			modifier = .None,
		}
		return state, key_event
	case 'B':
		key_event := KeyEvent {
			code     = .Down,
			modifier = .None,
		}
		return state, key_event
	case 'A':
		key_event := KeyEvent {
			code     = .Up,
			modifier = .None,
		}
		return state, key_event
	case 'C':
		key_event := KeyEvent {
			code     = .Right,
			modifier = .None,
		}
		return state, key_event
	case 'H':
		key_event := KeyEvent {
			code     = .Home,
			modifier = .None,
		}
		return state, key_event
	case 'F':
		key_event := KeyEvent {
			code     = .End,
			modifier = .None,
		}
		return state, key_event
	case:
		if byte >= 'P' && byte <= 'S' {
			code := F {
				value = byte + 1 - 'P',
			}
			key_event := KeyEvent {
				code     = code,
				modifier = .None,
			}
			return state, key_event
		}

		panic("unknown escape sequence")
	}
}

@(private = "file")
parse_base :: proc(
	buffer: ^[BUFFER_SIZE]byte,
	#any_int idx: int,
	#any_int len: int,
	state: ParsingState,
) -> (
	ParsingState,
	Maybe(Event),
) {
	byte := buffer[idx]
	switch byte {
	case '\x1b':
		if len == 1 {
			key_event := KeyEvent {
				code     = .Escape,
				modifier = .None,
			}
			return state, key_event
		}
		return .ESC, nil
	case '\x00':
		key_event := KeyEvent {
			code = Char{value = ' '},
			modifier = .Control,
		}
		return state, key_event
	case '\x7F':
		key_event := KeyEvent {
			code     = .Backspace,
			modifier = .None,
		}
		return state, key_event
	case '\x0D':
		key_event := KeyEvent {
			code     = .Enter,
			modifier = .None,
		}
		return state, key_event
	case '\x0A':
		key_event := KeyEvent {
			code     = .Enter,
			modifier = .None,
		}
		return state, key_event
	case:
		code: KeyCode
		modifier: KeyModifier

		if byte >= 0x01 && byte <= 0x1A {
			// byte is between 1 and 26, which means is ctrl + a-z
			code = Char {
				value = cast(rune)(byte - 1 + 'a'),
			}
			modifier = .Control
		} else if byte >= 0x1C && byte <= 0x1F {
			// byte is between 28 and 31, which is ctrl 4-7
			code = Char {
				value = cast(rune)(byte - 0x1C + '4'),
			}
			modifier = .Control
		} else {
			code = Char {
				value = cast(rune)byte,
			}
			modifier = .None
		}

		key_event := KeyEvent{code, modifier}
		return state, key_event
	}

	panic("unreachable")
}

@(private = "file")
parse_buffer :: proc(buffer: ^[BUFFER_SIZE]byte, #any_int len: int) -> Event {
	state := ParsingState.Base
	event: Maybe(Event)

	for idx in 0 ..< len {
		switch state {
		case .Base:
			state, event = parse_base(buffer, idx, len, state)
		case .ESC:
			state, event = parse_esc(buffer, idx, len, state)
		case .CSI:
			state, event = parse_csi(buffer, idx, len, state)
		}
		if event != nil {
			return event.(Event)
		}
	}

	panic("unreachable")
}

read :: proc() -> Event {
	buffer := [BUFFER_SIZE]byte{}
	bytes_read, err := os.read(os.stdin, buffer[:])

	if err != os.ERROR_NONE {
		panic("failed to read from stdin")
	}

	return parse_buffer(&buffer, bytes_read)
}

@(test)
parsing_normal :: proc(t: ^testing.T) {
	codes := [dynamic]KeyCode{.Escape, Char{value = ' '}, .Backspace, .Enter, .Enter}
	modifiers := [dynamic]KeyModifier{.None, .Control, .None, .None, .None}
	bytes := [dynamic]byte{0x1b, 0x00, 0x7F, 0x0D, 0x0A}
	defer delete(codes)
	defer delete(modifiers)
	defer delete(bytes)

	for idx in 0 ..< 26 {
		append(&codes, Char{value = cast(rune)(idx + 65)})
		append(&codes, Char{value = cast(rune)(idx + 97)})

		append(&modifiers, KeyModifier.None)
		append(&modifiers, KeyModifier.None)

		append(&bytes, cast(u8)(idx + 65))
		append(&bytes, cast(u8)(idx + 97))
	}

	// bytes 10 and 13 are Enter
	append(&codes, BaseKey.Enter)
	append(&modifiers, KeyModifier.None)
	append(&bytes, 10)
	append(&codes, BaseKey.Enter)
	append(&modifiers, KeyModifier.None)
	append(&bytes, 13)

	//bytes 28 to 31 are ctrl 4-7
	for idx in 28 ..= 31 {
		append(&codes, Char{value = cast(rune)('4' + idx - 28)})
		append(&modifiers, KeyModifier.Control)
		append(&bytes, cast(u8)idx)
	}

	// every other CTRL + a-z
	for idx in 0 ..< 9 {
		append(&codes, Char{value = cast(rune)(idx + 'a')})
		append(&modifiers, KeyModifier.Control)
		append(&bytes, cast(u8)(idx + 1))
	}

	for idx in 10 ..< 12 {
		append(&codes, Char{value = cast(rune)(idx + 'a')})
		append(&modifiers, KeyModifier.Control)
		append(&bytes, cast(u8)(idx + 1))
	}

	for idx in 14 ..< 26 {
		append(&codes, Char{value = cast(rune)(idx + 'a')})
		append(&modifiers, KeyModifier.Control)
		append(&bytes, cast(u8)(idx + 1))
	}

	for idx in 0 ..< len(codes) {
		buffer := [BUFFER_SIZE]byte{}
		buffer[0] = bytes[idx]

		result := parse_buffer(&buffer, 1)

		testing.expect_value(t, result.(KeyEvent).code, codes[idx])
		testing.expect_value(t, result.(KeyEvent).modifier, modifiers[idx])
	}
}
