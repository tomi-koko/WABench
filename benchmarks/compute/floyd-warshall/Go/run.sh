#!/bin/bash


if [ "$1" == "jit" ]; then
    /usr/bin/time -f "%e,%M" wasmtime floyd.wasm


elif [ "$1" == "aot-compile" ]; then
    wasmtime compile floyd.wasm -o floyd.cwasm


elif [ "$1" == "aot-run" ]; then
    /usr/bin/time -f "%e,%M" wasmtime --allow-precompiled floyd.cwasm

else
    echo "Usage: $0 [jit|aot-compile|aot-run]"
    exit 1
fi


