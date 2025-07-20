#!/bin/bash


if [ "$1" == "jit" ]; then
    /usr/bin/time -f "%e,%M" wasmtime --dir=. target/wasm32-wasip1/debug/compress.wasm reports.zip


elif [ "$1" == "aot-compile" ]; then
    wasmtime compile target/wasm32-wasip1/debug/compress.wasm -o target/wasm32-wasip1/debug/compress.cwasm


elif [ "$1" == "aot-run" ]; then
    /usr/bin/time -f "%e,%M" wasmtime --allow-precompiled --dir=. target/wasm32-wasip1/debug/compress.cwasm run-er.sh

else
    echo "Usage: $0 [jit|aot-compile|aot-run]"
    exit 1
fi


