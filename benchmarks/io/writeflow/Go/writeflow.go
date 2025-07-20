package main

import (
    "bufio"
    "fmt"
    "math/rand"
    "os"
    "strconv"
    "strings"
    "time"
)

const NUM_SAMPLES = 10000
const FILENAME = "sensor_data_go.txt"

type SensorData struct {
    Timestamp int64
    Value     float64
}

func getCurrentMs() int64 {
    return time.Now().UnixNano() / int64(time.Millisecond)
}

func generateData(count int) []SensorData {
    rand.Seed(time.Now().UnixNano())
    data := make([]SensorData, count)
    for i := 0; i < count; i++ {
        data[i] = SensorData{
            Timestamp: getCurrentMs(),
            Value:     rand.Float64() * 100.0, // 0~100的随机值
        }
    }
    return data
}

func writeData(data []SensorData) {
    file, err := os.Create(FILENAME)
    if err != nil {
        fmt.Println("Failed to open file:", err)
        os.Exit(1)
    }
    defer file.Close()

    writer := bufio.NewWriter(file)
    for _, d := range data {
        fmt.Fprintf(writer, "%d,%.2f\n", d.Timestamp, d.Value)
    }
    writer.Flush()
}

func readAndCalculate() float64 {
    file, err := os.Open(FILENAME)
    if err != nil {
        fmt.Println("Failed to open file:", err)
        os.Exit(1)
    }
    defer file.Close()

    scanner := bufio.NewScanner(file)
    sum := 0.0
    count := 0

    for scanner.Scan() {
        line := scanner.Text()
        parts := strings.Split(line, ",")
        if len(parts) == 2 {
            value, err := strconv.ParseFloat(parts[1], 64)
            if err == nil {
                sum += value
                count++
            }
        }
    }

    if count == 0 {
        return 0.0
    }
    return sum / float64(count)
}

func main() {
    var start, end int64

    // 生成数据
    start = getCurrentMs()
    data := generateData(NUM_SAMPLES)
    end = getCurrentMs()
    fmt.Printf("[Go] Data generation time: %d ms\n", end-start)

    // 写入文件
    start = getCurrentMs()
    writeData(data)
    end = getCurrentMs()
    fmt.Printf("[Go] Write time: %d ms\n", end-start)

    // 读取并计算
    start = getCurrentMs()
    avg := readAndCalculate()
    end = getCurrentMs()
    fmt.Printf("[Go] Read & calculate time: %d ms\n", end-start)
    fmt.Printf("[Go] Average value: %.2f\n", avg)
}

