#!/bin/bash


if [ "$1" == "jit" ]; then
    /usr/bin/time -f "%e,%M" wasmtime --dir=. compress.wasm reports.zip


elif [ "$1" == "aot-compile" ]; then
    wasmtime compile compress.wasm -o compress.cwasm


elif [ "$1" == "aot-run" ]; then
    /usr/bin/time -f "%e,%M" wasmtime --allow-precompiled compress.cwasm

else
    echo "Usage: $0 [jit|aot-compile|aot-run]"
    exit 1
fi

