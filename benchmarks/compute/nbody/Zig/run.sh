#!/bin/bash


if [ "$1" == "jit" ]; then
    /usr/bin/time -f "%e,%M" wasmtime nbody.wasm


elif [ "$1" == "aot-compile" ]; then
    wasmtime compile nbody.wasm -o nbody.cwasm


elif [ "$1" == "aot-run" ]; then
    /usr/bin/time -f "%e,%M" wasmtime --allow-precompiled nbody.cwasm

else
    echo "Usage: $0 [jit|aot-compile|aot-run]"
    exit 1
fi


