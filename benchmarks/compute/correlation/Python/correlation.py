import sys
import math
import time
import random

# Dataset selector
SMALL, STANDARD, LARGE = 0, 1, 2
DATASET = STANDARD  # Change to SMALL or LARGE as needed

if DATASET == SMALL:
    M, N = 50, 60
elif DATASET == LARGE:
    M, N = 2000, 2500
else:
    M, N = 500, 600

# ---------- 初始化随机矩阵 ----------
def init_array(m, n, seed):
    random.seed(seed)
    data = [[random.random() for _ in range(n)] for _ in range(m)]
    float_n = float(n)
    return data, float_n

# ---------- 打印部分输出矩阵（防止优化） ----------
def print_matrix(m, symmat):
    for i in range(min(m, 8)):
        print(' '.join(f"{symmat[i][j]:.2f}" for j in range(min(m, 8))))

# ---------- 主计算 ----------
def compute_correlation(m, n, float_n, data):
    mean = [0.0] * m
    stddev = [0.0] * m
    symmat = [[0.0 for _ in range(m)] for _ in range(m)]
    eps = 0.1

    for j in range(m):
        mean[j] = sum(data[j]) / float_n

    for j in range(m):
        stddev[j] = math.sqrt(sum((data[j][i] - mean[j]) ** 2 for i in range(n)) / float_n)
        if stddev[j] <= eps:
            stddev[j] = 1.0

    for j in range(m):
        for i in range(n):
            data[j][i] = (data[j][i] - mean[j]) / (math.sqrt(float_n) * stddev[j])

    for i in range(m):
        symmat[i][i] = 1.0
        for j in range(i + 1, m):
            val = sum(data[i][k] * data[j][k] for k in range(n))
            symmat[i][j] = val
            symmat[j][i] = val

    return symmat

# ---------- 主函数 ----------
def main():
    seed = int(sys.argv[1]) if len(sys.argv) > 1 else 42
    data, float_n = init_array(M, N, seed)

    start = time.time()
    symmat = compute_correlation(M, N, float_n, data)
    end = time.time()

    print(f"Finished correlation calculation in {end - start:.3f} seconds")
    print_matrix(M, symmat)

if __name__ == "__main__":
    main()

