#!/bin/bash


if [ "$1" == "jit" ]; then
    /usr/bin/time -f "%e,%M" wasmer --dir=. rand_rw.wasm


elif [ "$1" == "aot-compile" ]; then
    wasmer compile rand_rw.wasm -o rand_rw.wasmu


elif [ "$1" == "aot-run" ]; then
    /usr/bin/time -f "%e,%M" wasmer --dir=. rand_rw.wasmu

else
    echo "Usage: $0 [jit|aot-compile|aot-run]"
    exit 1
fi

