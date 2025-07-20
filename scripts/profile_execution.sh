#!/bin/bash

OUTFILE="/home/tomiko/work/wasm-benchmark-suite/results/raw/execution.csv"
mkdir -p ../results/raw
echo "benchmark,language,mode,exec_time_sec,peak_mem_kb,status" > "$OUTFILE"


find ../benchmarks -name run-er.sh | while read runscript; do
    dir=$(dirname "$runscript")
    language=$(basename "$dir")
    benchmark=$(basename "$(dirname "$dir")")

    echo "Processing $benchmark ($language)..."

    (
        cd "$dir" || exit 1
        bash ./run.sh aot-compile >/dev/null 2>&1
    )

(
    cd "$dir" || exit 1
    echo "Running JIT in $dir"
    start=$(date +%s.%N)
    result=$( ( /usr/bin/time -f "%M" bash ./run.sh jit ) 2>&1 )
    status=$?
    end=$(date +%s.%N)
    runtime=$(echo "$end - $start" | bc)
    peak_mem=$(echo "$result" | tail -n 1)

    if [ "$status" -eq 0 ]; then
        echo "$benchmark,$language,JIT,$runtime,$peak_mem,success" >> "$OUTFILE"
    else
        echo "ERROR: $benchmark ($language) JIT failed"
        echo "$result"
        echo "$benchmark,$language,JIT,0,0,fail" >> "$OUTFILE"
    fi
)


    (
        cd "$dir" || exit 1
        start=$(date +%s.%N)
        result=$( ( /usr/bin/time -f "%M" bash ./run.sh aot-run ) 2>&1 )
        end=$(date +%s.%N)
        runtime=$(echo "$end - $start" | bc)
        peak_mem=$(echo "$result" | tail -n 1)
        echo "$benchmark,$language,AOT,$runtime,$peak_mem,success" >> "$OUTFILE"
    ) || {
        echo "$benchmark,$language,AOT,0,0,fail" >> "$OUTFILE"
    }

done

