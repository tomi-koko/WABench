package main

import (
	"encoding/binary"
	"fmt"
	"math"
	"os"
	"time"
)

func clamp(val, min, max int) int {
	if val < min {
		return min
	}
	if val > max {
		return max
	}
	return val
}

func main() {
	if len(os.Args) != 2 {
		fmt.Printf("Usage: %s <image.bmp>\n", os.Args[0])
		return
	}

	file, err := os.Open(os.Args[1])
	if err != nil {
		fmt.Println("Error opening file:", err)
		return
	}
	defer file.Close()

	// Read BITMAPFILEHEADER
	var bfType uint16
	var bfOffBits uint32
	binary.Read(file, binary.LittleEndian, &bfType)
	file.Seek(8, 1) // skip bfSize, bfReserved1, bfReserved2
	binary.Read(file, binary.LittleEndian, &bfOffBits)

	if bfType != 0x4D42 {
		fmt.Println("Only BMP supported.")
		return
	}

	// Read BITMAPINFOHEADER
	var biWidth, biHeight int32
	var biBitCount uint16
	binary.Read(file, binary.LittleEndian, new([4]byte)) // skip biSize
	binary.Read(file, binary.LittleEndian, &biWidth)
	binary.Read(file, binary.LittleEndian, &biHeight)
	file.Seek(2, 1) // skip biPlanes
	binary.Read(file, binary.LittleEndian, &biBitCount)
	file.Seek(24, 1) // skip the rest of info header

	if biBitCount != 24 {
		fmt.Println("Only 24-bit BMP supported.")
		return
	}

	width := int(biWidth)
	height := int(math.Abs(float64(biHeight)))
	padding := (4 - (width * 3) % 4) % 4

	gray := make([]byte, width*height)
	file.Seek(int64(bfOffBits), 0)

	for y := height - 1; y >= 0; y-- {
		for x := 0; x < width; x++ {
			bgr := make([]byte, 3)
			file.Read(bgr)
			grayVal := byte(0.299*float64(bgr[2]) + 0.587*float64(bgr[1]) + 0.114*float64(bgr[0]))
			gray[y*width+x] = grayVal
		}
		file.Seek(int64(padding), 1)
	}

	// Sobel Kernel
	gx := [3][3]int{{-1, 0, 1}, {-2, 0, 2}, {-1, 0, 1}}
	gy := [3][3]int{{1, 2, 1}, {0, 0, 0}, {-1, -2, -1}}

	start := time.Now()

	output := make([]byte, width*height)
	for y := 1; y < height-1; y++ {
		for x := 1; x < width-1; x++ {
			sumX, sumY := 0, 0
			for dy := -1; dy <= 1; dy++ {
				for dx := -1; dx <= 1; dx++ {
					val := int(gray[(y+dy)*width+(x+dx)])
					sumX += val * gx[dy+1][dx+1]
					sumY += val * gy[dy+1][dx+1]
				}
			}
			mag := int(math.Sqrt(float64(sumX*sumX + sumY*sumY)))
			output[y*width+x] = byte(clamp(mag, 0, 255))
		}
	}

	elapsed := time.Since(start)
	fmt.Printf("Edge detection time: %.6f seconds\n", elapsed.Seconds())

	// Optional: write output.raw
	outFile, err := os.Create("output.raw")
	if err != nil {
		fmt.Println("Error creating output file:", err)
		return
	}
	defer outFile.Close()
	outFile.Write(output)
}
