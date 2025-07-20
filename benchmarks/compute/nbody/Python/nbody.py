import time
import random
import math
import sys

# ---------- 可选数据规模 ----------
DATASET = 'STANDARD'

if DATASET == 'SMALL':
    BODIES = 100
    ITERATIONS = 10
elif DATASET == 'LARGE':
    BODIES = 5000
    ITERATIONS = 100
else:
    BODIES = 1000
    ITERATIONS = 50

class Vec3:
    def __init__(self, x=0.0, y=0.0, z=0.0):
        self.x = x
        self.y = y
        self.z = z

class Body:
    def __init__(self):
        self.position = Vec3()
        self.velocity = Vec3()
        self.acceleration = Vec3()
        self.mass = 0.0

# ---------- 初始化天体 ----------
def init_bodies(n, seed):
    random.seed(seed)
    bodies = [Body() for _ in range(n)]
    for i in range(n):
        bodies[i].position.x = random.random() * 100.0
        bodies[i].position.y = random.random() * 100.0
        bodies[i].position.z = random.random() * 100.0
        
        bodies[i].velocity.x = random.random() * 10.0
        bodies[i].velocity.y = random.random() * 10.0
        bodies[i].velocity.z = random.random() * 10.0
        
        bodies[i].acceleration.x = 0.0
        bodies[i].acceleration.y = 0.0
        bodies[i].acceleration.z = 0.0
        
        bodies[i].mass = random.random() * 1000.0 + 100.0
    return bodies

# ---------- 打印部分输出 ----------
def print_result(bodies):
    for i in range(min(3, len(bodies))):
        print(f"Body {i}: pos=({bodies[i].position.x:.2f}, {bodies[i].position.y:.2f}, {bodies[i].position.z:.2f}) "
              f"vel=({bodies[i].velocity.x:.2f}, {bodies[i].velocity.y:.2f}, {bodies[i].velocity.z:.2f})")

# ---------- 主计算过程 ----------
def compute_nbody(n, iterations, bodies):
    G = 6.67430e-11  # 万有引力常数
    
    for _ in range(iterations):
        # 重置加速度
        for i in range(n):
            bodies[i].acceleration.x = 0.0
            bodies[i].acceleration.y = 0.0
            bodies[i].acceleration.z = 0.0
        
        # 计算引力
        for i in range(n):
            for j in range(i + 1, n):
                dx = bodies[j].position.x - bodies[i].position.x
                dy = bodies[j].position.y - bodies[i].position.y
                dz = bodies[j].position.z - bodies[i].position.z
                
                dist_sq = dx*dx + dy*dy + dz*dz + 1e-10  # 避免除以零
                dist = math.sqrt(dist_sq)
                force = G * bodies[i].mass * bodies[j].mass / dist_sq
                
                fx = force * dx / dist
                fy = force * dy / dist
                fz = force * dz / dist
                
                bodies[i].acceleration.x += fx / bodies[i].mass
                bodies[i].acceleration.y += fy / bodies[i].mass
                bodies[i].acceleration.z += fz / bodies[i].mass
                
                bodies[j].acceleration.x -= fx / bodies[j].mass
                bodies[j].acceleration.y -= fy / bodies[j].mass
                bodies[j].acceleration.z -= fz / bodies[j].mass
        
        # 更新速度和位置
        for i in range(n):
            bodies[i].velocity.x += bodies[i].acceleration.x
            bodies[i].velocity.y += bodies[i].acceleration.y
            bodies[i].velocity.z += bodies[i].acceleration.z
            
            bodies[i].position.x += bodies[i].velocity.x
            bodies[i].position.y += bodies[i].velocity.y
            bodies[i].position.z += bodies[i].velocity.z

# ---------- 主函数 ----------
if __name__ == "__main__":
    seed = int(sys.argv[1]) if len(sys.argv) > 1 else 42
    bodies = init_bodies(BODIES, seed)

    start = time.time()
    compute_nbody(BODIES, ITERATIONS, bodies)
    end = time.time()

    print(f"Finished N-body simulation in {end - start:.3f} seconds")
    print_result(bodies)
