#!/bin/bash


if [ "$1" == "jit" ]; then
    /usr/bin/time -f "%e,%M" wasmtime target/wasm32-wasip1/debug/nbody.wasm


elif [ "$1" == "aot-compile" ]; then
    wasmtime compile target/wasm32-wasip1/debug/floyd.wasm -o target/wasm32-wasip1/debug/nbody.cwasm


elif [ "$1" == "aot-run" ]; then
    /usr/bin/time -f "%e,%M" wasmtime --allow-precompiled target/wasm32-wasip1/debug/nbody.cwasm

else
    echo "Usage: $0 [jit|aot-compile|aot-run]"
    exit 1
fi



#/usr/bin/time -v wasmtime target/wasm32-wasip1/debug/nbody.wasm
