#!/bin/bash


if [ "$1" == "jit" ]; then
    /usr/bin/time -f "%e,%M" wasmer --dir=. writeflow.wasm


elif [ "$1" == "aot-compile" ]; then
    wasmer compile writeflow.wasm -o writeflow.wasmu


elif [ "$1" == "aot-run" ]; then
    /usr/bin/time -f "%e,%M" wasmer --dir=. writeflow.wasmu

else
    echo "Usage: $0 [jit|aot-compile|aot-run]"
    exit 1
fi

