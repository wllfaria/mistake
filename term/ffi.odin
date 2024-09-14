package term

import "core:c"

foreign import term_ffi "./ffi/term.a"

@(private)
FFITermSize :: struct {
	width:  c.int,
	height: c.int,
}

@(private)
foreign term_ffi {
	ffi_enable_raw_mode :: proc() ---
	ffi_disable_raw_mode :: proc() ---
	ffi_size :: proc() -> FFITermSize ---
}
