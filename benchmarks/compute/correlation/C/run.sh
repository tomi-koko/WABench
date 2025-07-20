#!/bin/bash


if [ "$1" == "jit" ]; then
    /usr/bin/time -f "%e,%M" wasmtime correlation.wasm


elif [ "$1" == "aot-compile" ]; then
    wasmtime compile correlation.wasm -o correlation.cwasm


elif [ "$1" == "aot-run" ]; then
    /usr/bin/time -f "%e,%M" wasmtime --allow-precompiled correlation.cwasm

else
    echo "Usage: $0 [jit|aot-compile|aot-run]"
    exit 1
fi

