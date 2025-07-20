#!/bin/bash


if [ "$1" == "jit" ]; then
    /usr/bin/time -f "%e,%M" wasmer target/wasm32-wasip1/debug/compress.wasm


elif [ "$1" == "aot-compile" ]; then
    wasmer compile compress.wasm -o target/wasm32-wasip1/debug/compress.wasmu


elif [ "$1" == "aot-run" ]; then
    /usr/bin/time -f "%e,%M" wasmer target/wasm32-wasip1/debug/compress.wasmu

else
    echo "Usage: $0 [jit|aot-compile|aot-run]"
    exit 1
fi

