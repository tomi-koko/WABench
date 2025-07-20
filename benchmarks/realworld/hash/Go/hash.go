package main

import (
	"fmt"
	"os"
	"time"
)

const BUF_SIZE = 8192

type SHA256Context struct {
	state    [8]uint32
	bitlen   uint64
	data     [64]byte
	datalen  int
}

func (ctx *SHA256Context) init() {
	ctx.state = [8]uint32{
		0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
		0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19,
	}
	ctx.bitlen = 0
	ctx.datalen = 0
}

func rightRotate(x uint32, n uint) uint32 {
	return (x >> n) | (x << (32 - n))
}

func (ctx *SHA256Context) transform() {
	k := [64]uint32{
		0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
		0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
		0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
		0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
		0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
		0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
		0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
		0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2,
	}

	var w [64]uint32
	for i := 0; i < 16; i++ {
		w[i] = uint32(ctx.data[i*4])<<24 | uint32(ctx.data[i*4+1])<<16 |
			uint32(ctx.data[i*4+2])<<8 | uint32(ctx.data[i*4+3])
	}
	for i := 16; i < 64; i++ {
		s0 := rightRotate(w[i-15], 7) ^ rightRotate(w[i-15], 18) ^ (w[i-15] >> 3)
		s1 := rightRotate(w[i-2], 17) ^ rightRotate(w[i-2], 19) ^ (w[i-2] >> 10)
		w[i] = w[i-16] + s0 + w[i-7] + s1
	}

	a, b, c, d, e, f, g, h := ctx.state[0], ctx.state[1], ctx.state[2], ctx.state[3],
		ctx.state[4], ctx.state[5], ctx.state[6], ctx.state[7]

	for i := 0; i < 64; i++ {
		s1 := rightRotate(e, 6) ^ rightRotate(e, 11) ^ rightRotate(e, 25)
		ch := (e & f) ^ (^e & g)
		temp1 := h + s1 + ch + k[i] + w[i]
		s0 := rightRotate(a, 2) ^ rightRotate(a, 13) ^ rightRotate(a, 22)
		maj := (a & b) ^ (a & c) ^ (b & c)
		temp2 := s0 + maj

		h = g
		g = f
		f = e
		e = d + temp1
		d = c
		c = b
		b = a
		a = temp1 + temp2
	}

	ctx.state[0] += a
	ctx.state[1] += b
	ctx.state[2] += c
	ctx.state[3] += d
	ctx.state[4] += e
	ctx.state[5] += f
	ctx.state[6] += g
	ctx.state[7] += h
}

func (ctx *SHA256Context) update(data []byte) {
	i := 0
	for i < len(data) {
		remaining := 64 - ctx.datalen
		toCopy := remaining
		if len(data)-i < toCopy {
			toCopy = len(data) - i
		}

		copy(ctx.data[ctx.datalen:ctx.datalen+toCopy], data[i:i+toCopy])
		ctx.datalen += toCopy
		i += toCopy
		ctx.bitlen += uint64(toCopy) * 8

		if ctx.datalen == 64 {
			ctx.transform()
			ctx.datalen = 0
		}
	}
}

func (ctx *SHA256Context) finalize(hash *[32]byte) {
	i := ctx.datalen

	if i < 56 {
		ctx.data[i] = 0x80
		i++

		for i < 56 {
			ctx.data[i] = 0
			i++
		}
	} else {
		ctx.data[i] = 0x80
		i++

		for i < 64 {
			ctx.data[i] = 0
			i++
		}

		ctx.transform()
		for i := 0; i < 56; i++ {
			ctx.data[i] = 0
		}
	}

	// Write bit length in big-endian
	ctx.data[56] = byte(ctx.bitlen >> 56)
	ctx.data[57] = byte(ctx.bitlen >> 48)
	ctx.data[58] = byte(ctx.bitlen >> 40)
	ctx.data[59] = byte(ctx.bitlen >> 32)
	ctx.data[60] = byte(ctx.bitlen >> 24)
	ctx.data[61] = byte(ctx.bitlen >> 16)
	ctx.data[62] = byte(ctx.bitlen >> 8)
	ctx.data[63] = byte(ctx.bitlen)

	ctx.transform()

	for i := 0; i < 8; i++ {
		hash[i*4] = byte(ctx.state[i] >> 24)
		hash[i*4+1] = byte(ctx.state[i] >> 16)
		hash[i*4+2] = byte(ctx.state[i] >> 8)
		hash[i*4+3] = byte(ctx.state[i])
	}
}

func main() {
	if len(os.Args) != 2 {
		fmt.Printf("Usage: %s <file>\n", os.Args[0])
		os.Exit(1)
	}

	file, err := os.Open(os.Args[1])
	if err != nil {
		fmt.Println("Error opening file:", err)
		os.Exit(1)
	}
	defer file.Close()

	var ctx SHA256Context
	ctx.init()
	buffer := make([]byte, BUF_SIZE)

	start := time.Now()

	for {
		bytesRead, err := file.Read(buffer)
		if err != nil && bytesRead == 0 {
			break
		}
		ctx.update(buffer[:bytesRead])
	}

	var hash [32]byte
	ctx.finalize(&hash)

	elapsed := time.Since(start).Seconds()

	fmt.Printf("SHA256 time: %.6f sec\nHash: ", elapsed)
	for _, b := range hash {
		fmt.Printf("%02x", b)
	}
	fmt.Println()
}
