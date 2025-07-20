#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <time.h>

#define SMALL 0
#define STANDARD 1
#define LARGE 2

// ---------- 可选数据规模 ----------
#if !defined(DATASET)
#define DATASET STANDARD
#endif

#if DATASET == SMALL
#define BODIES 100
#define ITERATIONS 10
#elif DATASET == LARGE
#define BODIES 5000
#define ITERATIONS 100
#else
#define BODIES 1000
#define ITERATIONS 50
#endif

typedef struct {
    double x, y, z;
} Vec3;

typedef struct {
    Vec3 position;
    Vec3 velocity;
    Vec3 acceleration;
    double mass;
} Body;

// ---------- 初始化天体 ----------
void init_bodies(int n, Body bodies[n], unsigned int seed) {
    srand(seed);
    for (int i = 0; i < n; i++) {
        bodies[i].position.x = (double)rand() / RAND_MAX * 100.0;
        bodies[i].position.y = (double)rand() / RAND_MAX * 100.0;
        bodies[i].position.z = (double)rand() / RAND_MAX * 100.0;
        
        bodies[i].velocity.x = (double)rand() / RAND_MAX * 10.0;
        bodies[i].velocity.y = (double)rand() / RAND_MAX * 10.0;
        bodies[i].velocity.z = (double)rand() / RAND_MAX * 10.0;
        
        bodies[i].acceleration.x = 0.0;
        bodies[i].acceleration.y = 0.0;
        bodies[i].acceleration.z = 0.0;
        
        bodies[i].mass = (double)rand() / RAND_MAX * 1000.0 + 100.0;
    }
}

// ---------- 打印部分输出（防止被编译器优化） ----------
void print_result(int n, Body bodies[n]) {
    for (int i = 0; i < n && i < 3; i++) {
        printf("Body %d: pos=(%.2f, %.2f, %.2f) vel=(%.2f, %.2f, %.2f)\n",
               i, bodies[i].position.x, bodies[i].position.y, bodies[i].position.z,
               bodies[i].velocity.x, bodies[i].velocity.y, bodies[i].velocity.z);
    }
}

// ---------- 主计算过程 ----------
void compute_nbody(int n, int iterations, Body bodies[n]) {
    const double G = 6.67430e-11; // 万有引力常数
    
    for (int iter = 0; iter < iterations; iter++) {
        // 重置加速度
        for (int i = 0; i < n; i++) {
            bodies[i].acceleration.x = 0.0;
            bodies[i].acceleration.y = 0.0;
            bodies[i].acceleration.z = 0.0;
        }
        
        // 计算引力
        for (int i = 0; i < n; i++) {
            for (int j = i + 1; j < n; j++) {
                double dx = bodies[j].position.x - bodies[i].position.x;
                double dy = bodies[j].position.y - bodies[i].position.y;
                double dz = bodies[j].position.z - bodies[i].position.z;
                
                double dist_sq = dx*dx + dy*dy + dz*dz + 1e-10; // 避免除以零
                double dist = sqrt(dist_sq);
                double force = G * bodies[i].mass * bodies[j].mass / dist_sq;
                
                double fx = force * dx / dist;
                double fy = force * dy / dist;
                double fz = force * dz / dist;
                
                bodies[i].acceleration.x += fx / bodies[i].mass;
                bodies[i].acceleration.y += fy / bodies[i].mass;
                bodies[i].acceleration.z += fz / bodies[i].mass;
                
                bodies[j].acceleration.x -= fx / bodies[j].mass;
                bodies[j].acceleration.y -= fy / bodies[j].mass;
                bodies[j].acceleration.z -= fz / bodies[j].mass;
            }
        }
        
        // 更新速度和位置
        for (int i = 0; i < n; i++) {
            bodies[i].velocity.x += bodies[i].acceleration.x;
            bodies[i].velocity.y += bodies[i].acceleration.y;
            bodies[i].velocity.z += bodies[i].acceleration.z;
            
            bodies[i].position.x += bodies[i].velocity.x;
            bodies[i].position.y += bodies[i].velocity.y;
            bodies[i].position.z += bodies[i].velocity.z;
        }
    }
}

// ---------- 主函数 ----------
int main(int argc, char** argv) {
    static Body bodies[BODIES];
    unsigned int seed = (argc > 1) ? atoi(argv[1]) : 42;

    init_bodies(BODIES, bodies, seed);

    clock_t start = clock();
    compute_nbody(BODIES, ITERATIONS, bodies);
    clock_t end = clock();

    printf("Finished N-body simulation in %.3f seconds\n",
           (double)(end - start) / CLOCKS_PER_SEC);

    print_result(BODIES, bodies);
    return 0;
}
