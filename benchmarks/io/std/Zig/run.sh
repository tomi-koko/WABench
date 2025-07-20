#!/bin/bash

if [ "$1" == "jit" ]; then
    /usr/bin/time -f "%e,%M" wasmtime run std.wasm

elif [ "$1" == "aot-compile" ]; then
    wasmtime compile std.wasm -o std.cwasm

elif [ "$1" == "aot-run" ]; then
    /usr/bin/time -f "%e,%M" wasmtime --allow-precompiled --dir=. std.cwasm

else
    echo "Usage: $0 [jit|aot-compile|aot-run]"
    exit 1
fi


#time wasmtime --dir=. std.wasm
