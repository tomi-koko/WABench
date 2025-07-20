package main

import (
	"fmt"
	"math"
	"math/rand"
	"os"
	"strconv"
	"time"
)

// ---------- 可选数据规模 ----------
const (
	SMALL     = "SMALL"
	STANDARD  = "STANDARD"
	LARGE     = "LARGE"
	DATASET   = STANDARD
)

var (
	BODIES      int
	ITERATIONS  int
)

func init() {
	switch DATASET {
	case SMALL:
		BODIES = 100
		ITERATIONS = 10
	case LARGE:
		BODIES = 5000
		ITERATIONS = 100
	default:
		BODIES = 1000
		ITERATIONS = 50
	}
}

type Vec3 struct {
	x, y, z float64
}

type Body struct {
	position    Vec3
	velocity    Vec3
	acceleration Vec3
	mass        float64
}

// ---------- 初始化天体 ----------
func initBodies(n int, seed int64) []Body {
	rand.Seed(seed)
	bodies := make([]Body, n)
	for i := 0; i < n; i++ {
		bodies[i] = Body{
			position: Vec3{
				x: rand.Float64() * 100.0,
				y: rand.Float64() * 100.0,
				z: rand.Float64() * 100.0,
			},
			velocity: Vec3{
				x: rand.Float64() * 10.0,
				y: rand.Float64() * 10.0,
				z: rand.Float64() * 10.0,
			},
			acceleration: Vec3{
				x: 0.0,
				y: 0.0,
				z: 0.0,
			},
			mass: rand.Float64()*1000.0 + 100.0,
		}
	}
	return bodies
}

// ---------- 打印部分输出 ----------
func printResult(bodies []Body) {
	for i := 0; i < 3 && i < len(bodies); i++ {
		fmt.Printf("Body %d: pos=(%.2f, %.2f, %.2f) vel=(%.2f, %.2f, %.2f)\n",
			i, bodies[i].position.x, bodies[i].position.y, bodies[i].position.z,
			bodies[i].velocity.x, bodies[i].velocity.y, bodies[i].velocity.z)
	}
}

// ---------- 主计算过程 ----------
func computeNbody(n, iterations int, bodies []Body) {
	const G = 6.67430e-11 // 万有引力常数

	for iter := 0; iter < iterations; iter++ {
		// 重置加速度
		for i := 0; i < n; i++ {
			bodies[i].acceleration.x = 0.0
			bodies[i].acceleration.y = 0.0
			bodies[i].acceleration.z = 0.0
		}

		// 计算引力
		for i := 0; i < n; i++ {
			for j := i + 1; j < n; j++ {
				dx := bodies[j].position.x - bodies[i].position.x
				dy := bodies[j].position.y - bodies[i].position.y
				dz := bodies[j].position.z - bodies[i].position.z

				distSq := dx*dx + dy*dy + dz*dz + 1e-10 // 避免除以零
				dist := math.Sqrt(distSq)
				force := G * bodies[i].mass * bodies[j].mass / distSq

				fx := force * dx / dist
				fy := force * dy / dist
				fz := force * dz / dist

				bodies[i].acceleration.x += fx / bodies[i].mass
				bodies[i].acceleration.y += fy / bodies[i].mass
				bodies[i].acceleration.z += fz / bodies[i].mass

				bodies[j].acceleration.x -= fx / bodies[j].mass
				bodies[j].acceleration.y -= fy / bodies[j].mass
				bodies[j].acceleration.z -= fz / bodies[j].mass
			}
		}

		// 更新速度和位置
		for i := 0; i < n; i++ {
			bodies[i].velocity.x += bodies[i].acceleration.x
			bodies[i].velocity.y += bodies[i].acceleration.y
			bodies[i].velocity.z += bodies[i].acceleration.z

			bodies[i].position.x += bodies[i].velocity.x
			bodies[i].position.y += bodies[i].velocity.y
			bodies[i].position.z += bodies[i].velocity.z
		}
	}
}

// ---------- 主函数 ----------
func main() {
	var seed int64 = 42
	if len(os.Args) > 1 {
		if s, err := strconv.ParseInt(os.Args[1], 10, 64); err == nil {
			seed = s
		}
	}

	bodies := initBodies(BODIES, seed)

	start := time.Now()
	computeNbody(BODIES, ITERATIONS, bodies)
	duration := time.Since(start)

	fmt.Printf("Finished N-body simulation in %.3f seconds\n", duration.Seconds())
	printResult(bodies)
}
