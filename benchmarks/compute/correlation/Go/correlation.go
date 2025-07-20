package main

import (
    "fmt"
    "math"
    "math/rand"
    "os"
    "strconv"
    "time"
)

const (
    SMALL    = 0
    STANDARD = 1
    LARGE    = 2
)

const DATASET = STANDARD

var M, N int

func init() {
    switch DATASET {
    case SMALL:
        M, N = 50, 60
    case LARGE:
        M, N = 2000, 2500
    default:
        M, N = 500, 600
    }
}

func initArray(seed int64) ([][]float64, float64) {
    rand.Seed(seed)
    data := make([][]float64, M)
    for i := range data {
        data[i] = make([]float64, N)
        for j := range data[i] {
            data[i][j] = rand.Float64()
        }
    }
    return data, float64(N)
}

func printMatrix(symmat [][]float64) {
    for i := 0; i < M && i < 8; i++ {
        for j := 0; j < M && j < 8; j++ {
            fmt.Printf("%0.2f ", symmat[i][j])
        }
        fmt.Println()
    }
}

func computeCorrelation(data [][]float64, float_n float64) [][]float64 {
    mean := make([]float64, M)
    stddev := make([]float64, M)
    symmat := make([][]float64, M)
    for i := range symmat {
        symmat[i] = make([]float64, M)
    }

    eps := 0.1

    for j := 0; j < M; j++ {
        sum := 0.0
        for i := 0; i < N; i++ {
            sum += data[j][i]
        }
        mean[j] = sum / float_n
    }

    for j := 0; j < M; j++ {
        sum := 0.0
        for i := 0; i < N; i++ {
            diff := data[j][i] - mean[j]
            sum += diff * diff
        }
        stddev[j] = math.Sqrt(sum / float_n)
        if stddev[j] <= eps {
            stddev[j] = 1.0
        }
    }

    for j := 0; j < M; j++ {
        for i := 0; i < N; i++ {
            data[j][i] = (data[j][i] - mean[j]) / (math.Sqrt(float_n) * stddev[j])
        }
    }

    for i := 0; i < M; i++ {
        symmat[i][i] = 1.0
        for j := i + 1; j < M; j++ {
            sum := 0.0
            for k := 0; k < N; k++ {
                sum += data[i][k] * data[j][k]
            }
            symmat[i][j] = sum
            symmat[j][i] = sum
        }
    }

    return symmat
}

func main() {
    seed := int64(42)
    if len(os.Args) > 1 {
        if s, err := strconv.ParseInt(os.Args[1], 10, 64); err == nil {
            seed = s
        }
    }

    data, float_n := initArray(seed)
    start := time.Now()
    symmat := computeCorrelation(data, float_n)
    duration := time.Since(start)
    fmt.Printf("Finished correlation calculation in %.3f seconds\n", duration.Seconds())
    printMatrix(symmat)
}

