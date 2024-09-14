default: configure

configure:
    #!/usr/bin/env sh
    if uname | grep -q "Darwin"; then
        gcc -c -fPIC term/ffi/term.c -o term/ffi/term.o
        ar rcs term/ffi/term.a term/ffi/term.o
        rm term/ffi/term.o
    else
        gcc -c term/ffi/term.c -o term/ffi/term.o
        ar rc term/ffi/term.a term/ffi/term.o
        rm term/ffi/term.o
    fi
