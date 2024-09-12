package term

enable_raw_mode :: proc() {
	ffi_enable_raw_mode()
}

disable_raw_mode :: proc() {
	ffi_disable_raw_mode()
}
