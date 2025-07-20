#!/bin/bash


if [ "$1" == "jit" ]; then
    /usr/bin/time -f "%e,%M" wasmtime run --dir=. target/wasm32-wasip1/debug/std.wasm .


elif [ "$1" == "aot-compile" ]; then
    wasmtime compile target/wasm32-wasip1/debug/std.wasm -o target/wasm32-wasip1/debug/std.cwasm


elif [ "$1" == "aot-run" ]; then
    /usr/bin/time -f "%e,%M" wasmtime --allow-precompiled -dir=. target/wasm32-wasip1/debug/std.cwasm .

else
    echo "Usage: $0 [jit|aot-compile|aot-run]"
    exit 1
fi

#/usr/bin/time -v wasmtime --dir=. target/wasm32-wasip1/debug/std.wasm .
