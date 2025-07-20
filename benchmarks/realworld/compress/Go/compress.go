package main

import (
	"fmt"
	"os"
	"time"
)

func nowSec() float64 {
	return float64(time.Now().UnixNano()) / 1e9
}

func simpleCompress(input []byte) []byte {
	output := make([]byte, 0, len(input)*2)
	i := 0
	for i < len(input) {
		b := input[i]
		count := 1
		for i+count < len(input) && input[i+count] == b && count < 255 {
			count++
		}
		output = append(output, byte(count))
		output = append(output, b)
		i += count
	}
	return output
}

func main() {
	if len(os.Args) != 2 {
		fmt.Printf("Usage: %s <file>\n", os.Args[0])
		os.Exit(1)
	}

	inputData, err := os.ReadFile(os.Args[1])
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error reading file: %v\n", err)
		os.Exit(1)
	}

	tStart := nowSec()
	outputData := simpleCompress(inputData)
	tEnd := nowSec()

	fmt.Printf("Compression time: %.6f sec\n", tEnd-tStart)
	fmt.Printf("Original size: %d bytes\n", len(inputData))
	fmt.Printf("Compressed size: %d bytes\n", len(outputData))
}
