#!/bin/bash


if [ "$1" == "jit" ]; then
    /usr/bin/time -f "%e,%M" wasmer compress.wasm


elif [ "$1" == "aot-compile" ]; then
    wasmer compile correlation.wasm -o compress.wasmu


elif [ "$1" == "aot-run" ]; then
    /usr/bin/time -f "%e,%M" wasmer compress.wasmu

else
    echo "Usage: $0 [jit|aot-compile|aot-run]"
    exit 1
fi

