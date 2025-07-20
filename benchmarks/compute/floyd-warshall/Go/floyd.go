package main

import (
    "fmt"
    "math/rand"
    "os"
    "strconv"
    "time"
)

const (
    SMALL = iota
    STANDARD
    LARGE
)

const DATASET = STANDARD

var N int

func init() {
    switch DATASET {
    case SMALL:
        N = 50
    case LARGE:
        N = 2000
    default:
        N = 500
    }
}

func initMatrix(n int, seed int64) [][]float64 {
    rand.Seed(seed)
    graph := make([][]float64, n)
    for i := range graph {
        graph[i] = make([]float64, n)
        for j := range graph[i] {
            if i == j {
                graph[i][j] = 0.0
            } else {
                graph[i][j] = float64(rand.Intn(100) + 1)
            }
        }
    }
    return graph
}

func printMatrix(n int, graph [][]float64) {
    for i := 0; i < n && i < 8; i++ {
        for j := 0; j < n && j < 8; j++ {
            fmt.Printf("%.2f ", graph[i][j])
        }
        fmt.Println()
    }
}

func floydWarshall(n int, graph [][]float64) {
    for k := 0; k < n; k++ {
        for i := 0; i < n; i++ {
            for j := 0; j < n; j++ {
                if graph[i][j] > graph[i][k]+graph[k][j] {
                    graph[i][j] = graph[i][k] + graph[k][j]
                }
            }
        }
    }
}

func main() {
    seed := int64(42)
    if len(os.Args) > 1 {
        s, _ := strconv.ParseInt(os.Args[1], 10, 64)
        seed = s
    }

    graph := initMatrix(N, seed)

    start := time.Now()
    floydWarshall(N, graph)
    elapsed := time.Since(start)

    fmt.Printf("Finished Floyd-Warshall in %.3f seconds\n", elapsed.Seconds())
    printMatrix(N, graph)
}

