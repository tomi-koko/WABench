#!/bin/bash


if [ "$1" == "jit" ]; then
    /usr/bin/time -f "%e,%M" wasmtime fft.wasm


elif [ "$1" == "aot-compile" ]; then
    wasmtime compile fft.wasm -o fft.cwasm


elif [ "$1" == "aot-run" ]; then
    /usr/bin/time -f "%e,%M" wasmtime --allow-precompiled fft.cwasm

else
    echo "Usage: $0 [jit|aot-compile|aot-run]"
    exit 1
fi
