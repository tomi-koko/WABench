package main

import (
	"fmt"
	"math"
	"math/cmplx"
	"math/rand"
	"os"
	"strconv"
	"time"
)

const (
	Small    = 0
	Standard = 1
	Large    = 2
)

// 编译时可覆盖此值：go build -ldflags="-X main.Dataset=Large"
var Dataset = Standard

var (
	M, N int
)

func init() {
	switch Dataset {
	case Small:
		M, N = 64, 64
	case Large:
		M, N = 2048, 2048
	default:
		M, N = 512, 512
	}
}

func initArray(data [][]float64, seed int64) {
	rand.Seed(seed)
	for i := range data {
		for j := range data[i] {
			data[i][j] = rand.Float64()
		}
	}
}

func fft(n int, in []float64, out []complex128) {
	if n == 1 {
		out[0] = complex(in[0], 0)
		return
	}

	half := n / 2
	evenIn, oddIn := make([]float64, half), make([]float64, half)
	evenOut, oddOut := make([]complex128, half), make([]complex128, half)

	for i := 0; i < half; i++ {
		evenIn[i] = in[2*i]
		oddIn[i] = in[2*i+1]
	}

	fft(half, evenIn, evenOut)
	fft(half, oddIn, oddOut)

	for k := 0; k < half; k++ {
		t := cmplx.Exp(complex(0, -2*math.Pi*float64(k)/float64(n))) * oddOut[k]
		out[k] = evenOut[k] + t
		out[k+half] = evenOut[k] - t
	}
}

func computeFFT(data [][]float64, result [][]complex128) {
	for i := range data {
		fft(N, data[i], result[i])
	}
}

func printMatrix(result [][]complex128) {
	rows := int(math.Min(8, float64(len(result))))
	cols := int(math.Min(8, float64(len(result[0]))))

	for i := 0; i < rows; i++ {
		for j := 0; j < cols; j++ {
			fmt.Printf("(%.2f,%.2f) ", real(result[i][j]), imag(result[i][j]))
		}
		fmt.Println()
	}
}

func main() {
	// 初始化二维数组
	data := make([][]float64, M)
	result := make([][]complex128, M)
	for i := range data {
		data[i] = make([]float64, N)
		result[i] = make([]complex128, N)
	}

	// 参数处理（默认种子42）
	seed := int64(42)
	if len(os.Args) > 1 {
		if s, err := strconv.ParseInt(os.Args[1], 10, 64); err == nil {
			seed = s
		}
	}

	initArray(data, seed)

	start := time.Now()
	computeFFT(data, result)
	elapsed := time.Since(start)

	fmt.Printf("Finished FFT in %.3f seconds\n", elapsed.Seconds())
	printMatrix(result)
}
