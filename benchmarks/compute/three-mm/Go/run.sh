#!/bin/bash


if [ "$1" == "jit" ]; then
    /usr/bin/time -f "%e,%M" wasmtime 3mm.wasm


elif [ "$1" == "aot-compile" ]; then
    wasmtime compile 3mm.wasm -o 3mm.cwasm


elif [ "$1" == "aot-run" ]; then
    /usr/bin/time -f "%e,%M" wasmtime --allow-precompiled 3mm.cwasm

else
    echo "Usage: $0 [jit|aot-compile|aot-run]"
    exit 1
fi



