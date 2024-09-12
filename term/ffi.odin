package term

foreign import term_ffi "./ffi/term.a"

@(private)
foreign term_ffi {
	ffi_enable_raw_mode :: proc() ---
	ffi_disable_raw_mode :: proc() ---
}
