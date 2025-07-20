package main

import (
	"fmt"
	"math/rand"
	"os"
	"strconv"
	"time"
)

// ---------- 可选数据规模 ----------
const (
	SMALL = iota
	STANDARD
	LARGE
)

const DATASET = STANDARD // 默认标准规模

var SIZE int

func init() {
	switch DATASET {
	case SMALL:
		SIZE = 10000
	case LARGE:
		SIZE = 10000000
	default:
		SIZE = 1000000
	}
}

// ---------- 初始化随机数组 ----------
func initArray(size int, seed int64) []float64 {
	rand.Seed(seed)
	data := make([]float64, size)
	for i := range data {
		data[i] = rand.Float64()
	}
	return data
}

// ---------- 打印部分输出数组 ----------
func printArray(data []float64) {
	for _, x := range data[:8] {
		fmt.Printf("%.2f ", x)
	}
	fmt.Println()
}

// ---------- 快速排序实现 ----------
func quicksort(data []float64, low, high int) {
	if low < high {
		pi := partition(data, low, high)
		quicksort(data, low, pi-1)
		quicksort(data, pi+1, high)
	}
}

func partition(data []float64, low, high int) int {
	pivot := data[high]
	i := low - 1

	for j := low; j < high; j++ {
		if data[j] < pivot {
			i++
			data[i], data[j] = data[j], data[i]
		}
	}

	data[i+1], data[high] = data[high], data[i+1]
	return i + 1
}

// ---------- 主函数 ----------
func main() {
	var seed int64 = 42
	if len(os.Args) > 1 {
		if s, err := strconv.ParseInt(os.Args[1], 10, 64); err == nil {
			seed = s
		}
	}

	data := initArray(SIZE, seed)

	start := time.Now()
	quicksort(data, 0, SIZE-1)
	duration := time.Since(start)

	fmt.Printf("Finished quicksort in %.3f seconds\n", duration.Seconds())
	printArray(data) // 打印前8个元素
}
