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

var dataset = SMALL

var (
	NI int
	NJ int
	NK int
	NL int
	NM int
)

func init() {
	switch dataset {
	case SMALL:
		NI = 250
		NJ = 300
		NK = 350
		NL = 400
		NM = 450
	case LARGE:
		NI = 2000
		NJ = 2200
		NK = 2400
		NL = 2600
		NM = 2800
	default:
		NI = 500
		NJ = 600
		NK = 700
		NL = 800
		NM = 900
	}
}

// ---------- 初始化随机矩阵 ----------
func initArray(A [][]float64, B [][]float64, C [][]float64, D [][]float64, seed int64) {
	rand.Seed(seed)

	for i := 0; i < len(A); i++ {
		for k := 0; k < len(A[0]); k++ {
			A[i][k] = rand.Float64() * 10
		}
	}

	for k := 0; k < len(B); k++ {
		for j := 0; j < len(B[0]); j++ {
			B[k][j] = rand.Float64() * 10
		}
	}

	for j := 0; j < len(C); j++ {
		for m := 0; m < len(C[0]); m++ {
			C[j][m] = rand.Float64() * 10
		}
	}

	for m := 0; m < len(D); m++ {
		for l := 0; l < len(D[0]); l++ {
			D[m][l] = rand.Float64() * 10
		}
	}
}

// ---------- 打印部分输出矩阵（防止被编译器优化） ----------
func printMatrix(G [][]float64) {
	rows := len(G)
	if rows > 8 {
		rows = 8
	}

	cols := len(G[0])
	if cols > 8 {
		cols = 8
	}

	for i := 0; i < rows; i++ {
		for l := 0; l < cols; l++ {
			fmt.Printf("%.2f ", G[i][l])
		}
		fmt.Println()
	}
}

// ---------- 主计算过程 ----------
func compute3mm(A, B, C, D, E, F, G [][]float64) {
	ni := len(A)
	nj := len(B[0])
	nk := len(B)
	nl := len(D[0])
	nm := len(C[0])

	// E = A * B
	for i := 0; i < ni; i++ {
		for j := 0; j < nj; j++ {
			E[i][j] = 0.0
			for k := 0; k < nk; k++ {
				E[i][j] += A[i][k] * B[k][j]
			}
		}
	}

	// F = C * D
	for j := 0; j < nj; j++ {
		for l := 0; l < nl; l++ {
			F[j][l] = 0.0
			for m := 0; m < nm; m++ {
				F[j][l] += C[j][m] * D[m][l]
			}
		}
	}

	// G = E * F
	for i := 0; i < ni; i++ {
		for l := 0; l < nl; l++ {
			G[i][l] = 0.0
			for j := 0; j < nj; j++ {
				G[i][l] += E[i][j] * F[j][l]
			}
		}
	}
}

// ---------- 主函数 ----------
func main() {
	// 初始化矩阵
	A := make([][]float64, NI)
	for i := range A {
		A[i] = make([]float64, NK)
	}

	B := make([][]float64, NK)
	for i := range B {
		B[i] = make([]float64, NJ)
	}

	C := make([][]float64, NJ)
	for i := range C {
		C[i] = make([]float64, NM)
	}

	D := make([][]float64, NM)
	for i := range D {
		D[i] = make([]float64, NL)
	}

	E := make([][]float64, NI)
	for i := range E {
		E[i] = make([]float64, NJ)
	}

	F := make([][]float64, NJ)
	for i := range F {
		F[i] = make([]float64, NL)
	}

	G := make([][]float64, NI)
	for i := range G {
		G[i] = make([]float64, NL)
	}

	// 处理命令行参数
	seed := int64(42)
	if len(os.Args) > 1 {
		if s, err := strconv.ParseInt(os.Args[1], 10, 64); err == nil {
			seed = s
		}
	}

	initArray(A, B, C, D, seed)

	start := time.Now()
	compute3mm(A, B, C, D, E, F, G)
	elapsed := time.Since(start)

	fmt.Printf("Finished 3mm calculation in %.3f seconds\n", elapsed.Seconds())

	printMatrix(G) // 打印前8x8子矩阵
}
