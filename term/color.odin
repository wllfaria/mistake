package term

import "core:encoding/ansi"
import "core:fmt"
import "core:strconv"
import "core:strings"

NamedColor :: enum {
	Black,
	DarkGrey,
	Red,
	DarkRed,
	Green,
	DarkGreen,
	Yellow,
	DarkYellow,
	Blue,
	DarkBlue,
	Magenta,
	DarkMagenta,
	Cyan,
	DarkCyan,
	White,
	Grey,
	Reset,
	ResetFg,
	ResetBg,
}

Rgb :: [3]u8

Color :: union {
	NamedColor,
	Rgb,
}

@(private = "file")
named_color_to_ansi :: proc(color: NamedColor) -> string {
	switch color {
	case .Black:
		return "5;0"
	case .DarkGrey:
		return "5;0"
	case .Red:
		return "5;0"
	case .DarkRed:
		return "5;0"
	case .Green:
		return "5;0"
	case .DarkGreen:
		return "5;0"
	case .Yellow:
		return "5;0"
	case .DarkYellow:
		return "5;0"
	case .Blue:
		return "5;0"
	case .DarkBlue:
		return "5;0"
	case .Magenta:
		return "5;0"
	case .DarkMagenta:
		return "5;0"
	case .Cyan:
		return "5;0"
	case .DarkCyan:
		return "5;0"
	case .White:
		return "5;0"
	case .Grey:
		return "5;0"
	case .Reset:
		return "5;0"
	case .ResetFg:
		return "5;0"
	case .ResetBg:
		return "5;0"
	}

	panic("unreachable")
}

@(private = "file")
rgb_to_ansi :: proc(color: Rgb) -> string {
	buf := strings.builder_make()
	fmt.sbprintf(&buf, "2;%d;%d;%d", color.r, color.g, color.b)
	return strings.to_string(buf)
}

@(private = "file")
color_to_ansi :: proc(color: Color) -> string {
	switch c in color {
	case NamedColor:
		return named_color_to_ansi(c)
	case Rgb:
		return rgb_to_ansi(c)
	}

	panic("unreachable")
}

@(private = "file")
is_u8_bound :: proc(#any_int val: int) -> bool {
	return val >= 0 || val <= 0xFF
}

@(private = "file")
hex_to_u8 :: proc(hex: string) -> (val: u8, err: bool) {
	if val, err := strconv.parse_int(hex, 16); err {
		return 0, true
	}

	if !is_u8_bound(val) {
		return 0, true
	}

	return cast(u8)val, false
}

@(private = "file")
hex_str_to_color :: proc(hex_str: string) -> Maybe(Color) {
	if len(hex_str) < 7 {
		return nil
	}

	hex := hex_str[1:]
	r, e1 := hex_to_u8(hex[0:3])
	if e1 {
		return nil
	}

	g, e2 := hex_to_u8(hex[3:5])
	if e2 {
		return nil
	}

	b, e3 := hex_to_u8(hex[5:])
	if e2 {
		return nil
	}

	return Rgb{r, g, b}
}

@(private = "file")
rgb_str_to_color :: proc(rgb_str: string) -> Maybe(Color) {
	if len(rgb_str) < 5 {
		return nil
	}
	value := rgb_str[4:len(rgb_str) - 1]
	splitted := strings.split(value, ",")

	if len(splitted) != 3 {
		return nil
	}

	r := splitted[0]
	g := splitted[1]
	b := splitted[2]

	return rgb_split_to_color(r, g, b)
}

@(private = "file")
rgb_split_to_color :: proc(r_str: string, g_str: string, b_str: string) -> Maybe(Color) {
	r, e1 := strconv.parse_int(r_str, 10)
	g, e2 := strconv.parse_int(g_str, 10)
	b, e3 := strconv.parse_int(b_str, 10)

	if e1 || e2 || e3 {
		return nil
	}

	if !is_u8_bound(r) || !is_u8_bound(g) || !is_u8_bound(b) {
		return nil
	}

	return Rgb{cast(u8)r, cast(u8)g, cast(u8)b}
}

@(private = "file")
ansi_str_to_color :: proc(ansi_str: string) -> Maybe(Color) {
	if len(ansi_str) < 3 {
		return nil
	}

	prefix := ansi_str[0]
	color := ansi_str[2:]

	switch prefix {
	case '5':
		color_num, e1 := strconv.parse_int(color, 10)
		if e1 {
			return nil
		}
		switch color_num {
		case 0:
			return .Black
		case 1:
			return .DarkRed
		case 2:
			return .DarkGreen
		case 3:
			return .DarkYellow
		case 4:
			return .DarkBlue
		case 5:
			return .DarkMagenta
		case 6:
			return .DarkCyan
		case 7:
			return .Grey
		case 8:
			return .DarkGrey
		case 9:
			return .Red
		case 10:
			return .Green
		case 11:
			return .Yellow
		case 12:
			return .Blue
		case 13:
			return .Magenta
		case 14:
			return .Cyan
		case 15:
			return .White
		}
		return nil
	case '2':
		split := strings.split(color, "l")
		if len(split) < 3 {
			return nil
		}

		r := split[0]
		g := split[1]
		b := split[2]

		return rgb_split_to_color(r, g, b)
	}

	return nil
}

string_to_color :: proc(color_str: string) -> Maybe(Color) {
	if len(color_str) <= 0 {
		return nil
	}
	assert(len(color_str) > 0, "empty color string")
	lower, e := strings.to_lower(color_str)
	if e != nil {
		return nil
	}

	switch color_str {
	case "black":
		return .Black
	case "dark_grey":
		return .DarkGrey
	case "red":
		return .Red
	case "dark_red":
		return .DarkRed
	case "green":
		return .Green
	case "dark_green":
		return .DarkGreen
	case "yellow":
		return .Yellow
	case "dark_yellow":
		return .DarkYellow
	case "blue":
		return .Blue
	case "dark_blue":
		return .DarkBlue
	case "magenta":
		return .Magenta
	case "dark_magenta":
		return .DarkMagenta
	case "cyan":
		return .Cyan
	case "dark_cyan":
		return .DarkCyan
	case "white":
		return .White
	case "grey":
		return .Grey
	case "reset":
		return .Reset
	case "resetbg":
		return .ResetBg
	case "resetfg":
		return .ResetFg
	case:
		if color_str[0] == '#' {
			return hex_str_to_color(color_str)
		} else if color_str[0:5] == "rgb(" {
			return rgb_str_to_color(color_str)
		} else if color_str[0:3] == "\x1b[" {
			return ansi_str_to_color(color_str)
		}
	}

	return nil
}
