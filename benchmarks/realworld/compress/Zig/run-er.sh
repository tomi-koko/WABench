#!/bin/bash


if [ "$1" == "jit" ]; then
    /usr/bin/time -f "%e,%M" wasmer correlation.wasm


elif [ "$1" == "aot-compile" ]; then
    wasmer compile correlation.wasm -o correlation.wasmu


elif [ "$1" == "aot-run" ]; then
    /usr/bin/time -f "%e,%M" wasmer correlation.wasmu

else
    echo "Usage: $0 [jit|aot-compile|aot-run]"
    exit 1
fi

