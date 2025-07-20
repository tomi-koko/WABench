#!/bin/bash

CMD="tinygo build -target=wasi -opt=2 -gc=leaking -o correlation_release_tinygo.wasm correlation.go" 
N=10

total_time=0
total_mem=0
skip_first=1  

for i in $(seq 1 $N); do
    echo "Running iteration $i..."

    tmp_out=$(mktemp)

    /usr/bin/time -v $CMD 2> "$tmp_out"
    
    time_str=$(grep "Elapsed (wall clock) time" "$tmp_out" | awk '{print $8}')
    mem_kb=$(grep "Maximum resident set size" "$tmp_out" | awk '{print $6}')

    if [[ $time_str == *:*:* ]]; then
        IFS=':' read -r h m s <<< "$time_str"
        t=$(echo "$h*3600 + $m*60 + $s" | bc)
    else
        IFS=':' read -r m s <<< "$time_str"
        t=$(echo "$m*60 + $s" | bc)
    fi

    if (( i > skip_first )); then
        total_time=$(echo "$total_time + $t" | bc)
        total_mem=$(echo "$total_mem + $mem_kb" | bc)
        times+=("$t")
    fi

    rm "$tmp_out"
done

count=$((N - skip_first))
avg_time=$(echo "scale=3; $total_time / $count" | bc)
avg_mem=$(echo "scale=1; $total_mem / $count" | bc)

# 计算标准差
std=$(printf "%s\n" "${times[@]}" | awk -v mean="$avg_time" '
{
    sum += ($1 - mean)^2
}
END {
    printf "%.3f", sqrt(sum / NR)
}')

echo "======================="
echo "去除第一次冷启动后的平均运行时间: $avg_time 秒"
echo "去除第一次冷启动后的运行时间标准差: $std 秒"
echo "去除第一次冷启动后的平均内存占用: $avg_mem KB"
