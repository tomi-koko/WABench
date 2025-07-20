package main

import (
	"fmt"
	"os"
	"time"
)

var bufSizes = []int{1024, 4096, 16384, 65536}
const testDataSize = 100 * 1024 * 1024 // 100MB

func fillBuffer(buf []byte) {
	for i := range buf {
		buf[i] = byte(i % 256)
	}
}

func runBenchmark(bufSize, totalSize int) {
	buf := make([]byte, bufSize)
	fillBuffer(buf)
	
	start := time.Now()
	totalWritten := 0
	
	for totalWritten < totalSize {
		bytesToWrite := min(totalSize-totalWritten, bufSize)
		n, err := os.Stdout.Write(buf[:bytesToWrite])
		if err != nil {
			fmt.Fprintf(os.Stderr, "Write error: %v\n", err)
			return
		}
		totalWritten += n
	}
	
	elapsed := time.Since(start).Seconds()
	throughput := float64(totalWritten) / (1024 * 1024) / elapsed
	
	fmt.Fprintf(os.Stderr, "| %-8d | %-8.2f MB | %-10.3f sec | %-10.2f MB/s |\n",
		bufSize, float64(totalWritten)/(1024*1024), elapsed, throughput)
}

func main() {
	fmt.Fprintln(os.Stderr, "=== WASI Go Benchmark ===")
	fmt.Fprintln(os.Stderr, "| Buffer   | Data     | Time       | Throughput |")
	fmt.Fprintln(os.Stderr, "|----------|----------|------------|------------|")
	
	for _, size := range bufSizes {
		runBenchmark(size, testDataSize)
	}
	
	fmt.Fprintln(os.Stderr, "\nTest completed. Data was written to stdout via Go syscall.")
}
