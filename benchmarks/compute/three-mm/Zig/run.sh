#!/bin/bash


if [ "$1" == "jit" ]; then
    /usr/bin/time -f "%e,%M" wasmtime three-mm.wasm


elif [ "$1" == "aot-compile" ]; then
    wasmtime compile three-mm.wasm -o three-mm.cwasm


elif [ "$1" == "aot-run" ]; then
    /usr/bin/time -f "%e,%M" wasmtime --allow-precompiled three-mm.cwasm

else
    echo "Usage: $0 [jit|aot-compile|aot-run]"
    exit 1
fi


#/usr/bin/time -v wasmtime quicksort.wasm
