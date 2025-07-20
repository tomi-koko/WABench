#!/bin/bash


if [ "$1" == "jit" ]; then
    /usr/bin/time -f "%e,%M" wasmtime run --dir=. rand_rw.wasm


elif [ "$1" == "aot-compile" ]; then
    wasmtime compile rand_rw.wasm -o rand_rw.cwasm


elif [ "$1" == "aot-run" ]; then
    /usr/bin/time -f "%e,%M" wasmtime --allow-precompiled --dir=. rand_rw.cwasm

else
    echo "Usage: $0 [jit|aot-compile|aot-run]"
    exit 1
fi



