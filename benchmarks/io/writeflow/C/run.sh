#!/bin/bash

if [ "$1" == "jit" ]; then
    /usr/bin/time -f "%e,%M" wasmtime --dir=. writeflow.wasm

elif [ "$1" == "aot-compile" ]; then
    wasmtime compile writeflow.wasm -o writeflow.cwasm

elif [ "$1" == "aot-run" ]; then
    /usr/bin/time -f "%e,%M" wasmtime --allow-precompiled --dir=. writeflow.cwasm

else
    echo "Usage: $0 [jit|aot-compile|aot-run]"
    exit 1
fi

