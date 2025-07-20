import sys
import time
import math
import cmath
import random

# 数据集设定
SMALL, STANDARD, LARGE = 0, 1, 2
DATASET = STANDARD  # 可根据需要改为 SMALL 或 LARGE

if DATASET == SMALL:
    M, N = 64, 64
elif DATASET == LARGE:
    M, N = 2048, 2048
else:
    M, N = 512, 512

def init_array(m, n, seed):
    random.seed(seed)
    data = [[random.random() for _ in range(n)] for _ in range(m)]
    return data

def fft(n, real_in):
    if n == 1:
        return [complex(real_in[0], 0.0)]
    half = n // 2
    even = fft(half, real_in[0::2])
    odd = fft(half, real_in[1::2])
    result = [0] * n
    for k in range(half):
        twiddle = cmath.exp(-2j * math.pi * k / n) * odd[k]
        result[k] = even[k] + twiddle
        result[k + half] = even[k] - twiddle
    return result

def compute_fft(m, n, data):
    result = []
    for i in range(m):
        result.append(fft(n, data[i]))
    return result

def print_matrix(m, n, result):
    for i in range(min(m, 8)):
        for j in range(min(n, 8)):
            val = result[i][j]
            print(f"({val.real:.2f},{val.imag:.2f})", end=" ")
        print()

def main():
    seed = int(sys.argv[1]) if len(sys.argv) > 1 else 42
    data = init_array(M, N, seed)
    
    start = time.time()
    result = compute_fft(M, N, data)
    end = time.time()

    print(f"Finished FFT in {end - start:.3f} seconds")
    print_matrix(M, N, result)

if __name__ == "__main__":
    main()

