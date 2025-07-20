#!/bin/bash


if [ "$1" == "jit" ]; then
    /usr/bin/time -f "%e,%M" wasmer hash.wasm


elif [ "$1" == "aot-compile" ]; then
    wasmer compile hash.wasm -o hash.wasmu


elif [ "$1" == "aot-run" ]; then
    /usr/bin/time -f "%e,%M" wasmer hash.wasmu

else
    echo "Usage: $0 [jit|aot-compile|aot-run]"
    exit 1
fi

