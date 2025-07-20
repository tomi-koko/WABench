package main

import (
	"fmt"
	"time"
)

var bufSizes = []int{1024, 4096, 16384, 65536}
const testDataSize = 100 * 1024 * 1024

func fillBuffer(bufSize int) []byte {
	buf := make([]byte, bufSize)
	for i := 0; i < bufSize; i++ {
		buf[i] = byte(i % 256)
	}
	return buf
}

func runBenchmark(bufSize int, totalSize int) {
	buf := fillBuffer(bufSize)
	start := time.Now()

	totalWritten := 0
	for totalWritten < totalSize {
		bytesToWrite := bufSize
		if remaining := totalSize - totalWritten; remaining < bufSize {
			bytesToWrite = remaining
		}
		// 模拟写入操作（实际使用 buf）
		totalWritten += bytesToWrite
		_ = buf[:bytesToWrite] // 确保 buf 被使用（避免编译器报错）
	}

	elapsedSec := time.Since(start).Seconds()
	throughput := float64(totalWritten) / (1024 * 1024) / elapsedSec

	fmt.Printf("| %-8d | %-8.2f MB | %-10.3f sec | %-10.2f MB/s |\n",
		bufSize,
		float64(totalWritten)/(1024*1024),
		elapsedSec,
		throughput)
}

func main() {
	fmt.Println("\n=== Go stdin/stdout Benchmark ===")
	fmt.Println("| Buffer   | Data     | Time       | Throughput |")
	fmt.Println("|----------|----------|------------|------------|")

	for _, bufSize := range bufSizes {
		runBenchmark(bufSize, testDataSize)
	}
}
