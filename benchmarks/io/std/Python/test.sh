#!/bin/bash

# 配置参数
WASM_CMD="wasmtime test.wasm > /dev/null"
ITERATIONS=20
BUF_SIZES=(1024 4096 16384 65536)

# 临时文件
TMP_FILE=$(mktemp)

# 运行测试
echo "开始性能测试，每个缓冲区大小运行 $ITERATIONS 次..."
for ((i=1; i<=$ITERATIONS; i++)); do
    echo "第 $i 次运行..."
    eval "$WASM_CMD" 2> "$TMP_FILE"
    
    # 提取有效结果
    while IFS= read -r line; do
        if [[ $line =~ ([0-9]+)[[:space:]]+\|[[:space:]]+([0-9.]+)[[:space:]]+MB.*\|[[:space:]]+([0-9.]+)[[:space:]]+sec.*\|[[:space:]]+([0-9.]+)[[:space:]]+MB/s ]]; then
            size=${BASH_REMATCH[1]}
            throughput=${BASH_REMATCH[4]}
            echo "$size $throughput" >> results.dat
        fi
    done < "$TMP_FILE"
done

# 计算统计信息
echo -e "\n测试结果（MB/s）："
echo "| Buffer Size | 平均吞吐量 (MB/s) | 最小值 | 最大值 | 标准差 |"
echo "|------------|------------------|--------|--------|--------|"

for size in "${BUF_SIZES[@]}"; do
    grep "^$size " results.dat | awk -v size="$size" '
    {
        sum+=$2; 
        vals[NR]=$2;
        if($2<min||NR==1) min=$2;
        if($2>max||NR==1) max=$2;
    }
    END {
        avg=sum/NR;
        var=0;
        for(i in vals) var+=(vals[i]-avg)^2;
        stddev=sqrt(var/NR);
        printf "| %10d | %16.2f | %6.2f | %6.2f | %6.2f |\n", 
               size, avg, min, max, stddev;
    }'
done

# 清理
rm "$TMP_FILE" results.dat 2>/dev/null
echo -e "\n测试完成。原始数据已保存到 results.dat"
