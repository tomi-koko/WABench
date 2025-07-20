#!/bin/bash


if [ "$1" == "jit" ]; then
    /usr/bin/time -f "%e,%M" wasmtime --dir=. batch_write.wasm data


elif [ "$1" == "aot-compile" ]; then
    wasmtime compile batch_write.wasm -o batch_write.cwasm


elif [ "$1" == "aot-run" ]; then
    /usr/bin/time -f "%e,%M" wasmtime --allow-precompiled --dir=. batch_write.cwasm data

else
    echo "Usage: $0 [jit|aot-compile|aot-run]"
    exit 1
fi

