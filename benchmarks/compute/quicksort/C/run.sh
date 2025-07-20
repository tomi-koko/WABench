#!/bin/bash


if [ "$1" == "jit" ]; then
    /usr/bin/time -f "%e,%M" wasmtime quicksort.wasm


elif [ "$1" == "aot-compile" ]; then
    wasmtime compile quicksort.wasm -o quicksort.cwasm


elif [ "$1" == "aot-run" ]; then
    /usr/bin/time -f "%e,%M" wasmtime --allow-precompiled quicksort.cwasm

else
    echo "Usage: $0 [jit|aot-compile|aot-run]"
    exit 1
fi



