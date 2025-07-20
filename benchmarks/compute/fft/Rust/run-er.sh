#!/bin/bash


if [ "$1" == "jit" ]; then
    /usr/bin/time -f "%e,%M" wasmer target/wasm32-wasip1/debug/fft.wasm


elif [ "$1" == "aot-compile" ]; then
    wasmer compile target/wasm32-wasip1/debug/fft.wasm -o target/wasm32-wasip1/debug/fft.wasmu


elif [ "$1" == "aot-run" ]; then
    /usr/bin/time -f "%e,%M" wasmer target/wasm32-wasip1/debug/fft.wasmu

else
    echo "Usage: $0 [jit|aot-compile|aot-run]"
    exit 1
fi

