#!/bin/bash


if [ "$1" == "jit" ]; then
    /usr/bin/time -f "%e,%M" wasmtime --dir=. aes.wasm reports.zip


elif [ "$1" == "aot-compile" ]; then
    wasmtime compile hash.wasm -o hash.cwasm


elif [ "$1" == "aot-run" ]; then
    /usr/bin/time -f "%e,%M" wasmtime --allow-precompiled hash.cwasm

else
    echo "Usage: $0 [jit|aot-compile|aot-run]"
    exit 1
fi
