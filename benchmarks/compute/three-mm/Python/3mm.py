import sys
import time
import random

# ---------- 可选数据规模 ----------
SMALL = 0
STANDARD = 1
LARGE = 2

DATASET = SMALL

if DATASET == SMALL:
    NI, NJ, NK, NL, NM = 250, 300, 350, 400, 450
elif DATASET == LARGE:
    NI, NJ, NK, NL, NM = 2000, 2200, 2400, 2600, 2800
else:
    NI, NJ, NK, NL, NM = 500, 600, 700, 800, 900

# ---------- 初始化随机矩阵 ----------
def init_array(seed):
    random.seed(seed)
    A = [[random.random() * 10 for _ in range(NK)] for _ in range(NI)]
    B = [[random.random() * 10 for _ in range(NJ)] for _ in range(NK)]
    C = [[random.random() * 10 for _ in range(NM)] for _ in range(NJ)]
    D = [[random.random() * 10 for _ in range(NL)] for _ in range(NM)]
    return A, B, C, D

# ---------- 打印部分输出矩阵 ----------
def print_matrix(G):
    for i in range(min(8, len(G))):
        row = G[i]
        for l in range(min(8, len(row))):
            print(f"{row[l]:.2f} ", end="")
        print()

# ---------- 主计算过程 ----------
def compute_3mm(A, B, C, D):
    # E = A * B
    E = [[0.0 for _ in range(NJ)] for _ in range(NI)]
    for i in range(NI):
        for j in range(NJ):
            for k in range(NK):
                E[i][j] += A[i][k] * B[k][j]
    
    # F = C * D
    F = [[0.0 for _ in range(NL)] for _ in range(NJ)]
    for j in range(NJ):
        for l in range(NL):
            for m in range(NM):
                F[j][l] += C[j][m] * D[m][l]
    
    # G = E * F
    G = [[0.0 for _ in range(NL)] for _ in range(NI)]
    for i in range(NI):
        for l in range(NL):
            for j in range(NJ):
                G[i][l] += E[i][j] * F[j][l]
    
    return G

# ---------- 主函数 ----------
if __name__ == "__main__":
    seed = int(sys.argv[1]) if len(sys.argv) > 1 else 42
    A, B, C, D = init_array(seed)
    
    start = time.time()
    G = compute_3mm(A, B, C, D)
    end = time.time()
    
    print(f"Finished 3mm calculation in {end - start:.3f} seconds")
    print_matrix(G)
