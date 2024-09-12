package term

import "core:encoding/ansi"
import "core:fmt"
import "core:os"
import "core:strings"

escape :: proc(value: string) {
	buf := strings.builder_make()
	fmt.sbprintf(&buf, "%s%s", ansi.CSI, value)
	str := strings.to_string(buf)
	os.write_string(os.stdout, str)
}

os_escape :: proc(value: string) {
	buf := strings.builder_make()
	fmt.sbprintf(&buf, "%s%s", ansi.OSC, value)
	str := strings.to_string(buf)
	os.write_string(os.stdout, str)
}
