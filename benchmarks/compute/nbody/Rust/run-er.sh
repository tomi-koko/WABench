#!/bin/bash


if [ "$1" == "jit" ]; then
    /usr/bin/time -f "%e,%M" wasmer target/wasm32-wasip1/debug/nbody.wasm


elif [ "$1" == "aot-compile" ]; then
    wasmer compile target/wasm32-wasip1/debug/nbody.wasm -o target/wasm32-wasip1/debug/nbody.wasmu


elif [ "$1" == "aot-run" ]; then
    /usr/bin/time -f "%e,%M" wasmer target/wasm32-wasip1/debug/nbody.wasmu

else
    echo "Usage: $0 [jit|aot-compile|aot-run]"
    exit 1
fi

