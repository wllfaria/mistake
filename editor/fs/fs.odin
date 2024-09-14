package fs

import "core:fmt"
import "core:mem"
import "core:os"
import "core:path/filepath"
import "core:strings"
import "core:testing"

FileInfo :: struct {
	path:     string,
	basename: string,
	content:  string,
	ext:      string,
	is_dir:   bool,
}

with_new_file :: proc(filename: string) -> FileInfo {
	clean_filename := filepath.clean(filename)
	defer delete(clean_filename)
	absolute := absolutize(clean_filename)
	basename := filepath.base(absolute)
	ext := filepath.ext(absolute)
	is_dir := false
	if exists(absolute) {
		is_dir = os.is_dir(absolute)
	}
	return FileInfo{path = absolute, basename = basename, is_dir = is_dir, content = "", ext = ext}
}

read_file :: proc(filename: string) -> Maybe(FileInfo) {
	clean_filename := filepath.clean(filename)
	defer delete(clean_filename)
	if !exists(clean_filename) {
		return nil
	}
	absolute := absolutize(clean_filename)
	basename := filepath.base(absolute)
	is_dir := os.is_dir(absolute)
	ext := filepath.ext(absolute)

	if data, ok := os.read_entire_file_from_filename(absolute); ok {
		return FileInfo {
			path = absolute,
			basename = basename,
			is_dir = is_dir,
			content = cast(string)data,
			ext = ext,
		}
	}

	return nil
}

exists :: proc(path: string) -> bool {
	return os.exists(path)
}

absolutize :: proc(path: string) -> string {
	cwd := os.get_current_directory()
	defer delete(cwd)
	buf := strings.builder_make()
	fmt.sbprintf(&buf, "%s/%s", cwd, path)
	formatted := strings.to_string(buf)
	defer strings.builder_destroy(&buf)

	clean := filepath.clean(formatted)
	return clean
}
