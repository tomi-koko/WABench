import sys
import time
import random

# ---------- 可选数据规模 ----------
SMALL, STANDARD, LARGE = 0, 1, 2

DATASET = STANDARD  # 默认标准规模

if DATASET == SMALL:
    SIZE = 10000
elif DATASET == LARGE:
    SIZE = 10000000
else:
    SIZE = 1000000

# ---------- 初始化随机数组 ----------
def init_array(size, seed):
    random.seed(seed)
    return [random.random() for _ in range(size)]

# ---------- 打印部分输出数组 ----------
def print_array(data):
    for x in data[:8]:
        print(f"{x:.2f}", end=" ")
    print()

# ---------- 快速排序实现 ----------
def quicksort(data, low, high):
    if low < high:
        pi = partition(data, low, high)
        quicksort(data, low, pi - 1)
        quicksort(data, pi + 1, high)

def partition(data, low, high):
    pivot = data[high]
    i = low - 1
    
    for j in range(low, high):
        if data[j] < pivot:
            i += 1
            data[i], data[j] = data[j], data[i]
    
    data[i+1], data[high] = data[high], data[i+1]
    return i + 1

# ---------- 主函数 ----------
if __name__ == "__main__":
    seed = int(sys.argv[1]) if len(sys.argv) > 1 else 42
    data = init_array(SIZE, seed)

    start = time.time()
    quicksort(data, 0, SIZE - 1)
    end = time.time()

    print(f"Finished quicksort in {end - start:.3f} seconds")
    print_array(data)  # 打印前8个元素
