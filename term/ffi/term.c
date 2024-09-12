#include <termios.h>
#include <unistd.h>

struct termios reset;

void ffi_disable_raw_mode() { tcsetattr(STDIN_FILENO, TCSANOW, &reset); }

void ffi_enable_raw_mode() {
  struct termios raw;
  tcgetattr(STDIN_FILENO, &reset);
  raw = reset;

  raw.c_lflag &= ~(ECHO | ICANON | IEXTEN | ISIG);
  raw.c_iflag &= ~(BRKINT | ICRNL | INPCK | ISTRIP | IXON);
  raw.c_oflag &= ~(OPOST);
  raw.c_cflag |= (CS8);
  raw.c_cc[VMIN] = 1;
  raw.c_cc[VTIME] = 0;

  tcsetattr(STDIN_FILENO, TCSANOW, &raw);
}
