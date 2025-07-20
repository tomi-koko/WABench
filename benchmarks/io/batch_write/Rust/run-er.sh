#!/bin/bash


if [ "$1" == "jit" ]; then
    /usr/bin/time -f "%e,%M" wasmer --dir=. target/wasm32-wasip1/debug/batch_write.wasm data


elif [ "$1" == "aot-compile" ]; then
    wasmer compile target/wasm32-wasip1/debug/batch_write.wasm -o target/wasm32-wasip1/debug/batch_write.wasmu


elif [ "$1" == "aot-run" ]; then
    /usr/bin/time -f "%e,%M" wasmer --dir=. target/wasm32-wasip1/debug/batch_write.wasmu data

else
    echo "Usage: $0 [jit|aot-compile|aot-run]"
    exit 1
fi

