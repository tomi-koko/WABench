#!/bin/bash


if [ "$1" == "jit" ]; then
    /usr/bin/time -f "%e,%M" wasmer --dir=. batch_write.wasm data


elif [ "$1" == "aot-compile" ]; then
    wasmer compile batch_write.wasm -o batch_write.wasmu


elif [ "$1" == "aot-run" ]; then
    /usr/bin/time -f "%e,%M" wasmer --dir=. batch_write.wasmu data

else
    echo "Usage: $0 [jit|aot-compile|aot-run]"
    exit 1
fi

