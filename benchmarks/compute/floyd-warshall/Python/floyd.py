import sys
import time
import random

SMALL = 0
STANDARD = 1
LARGE = 2

DATASET = STANDARD

if DATASET == SMALL:
    N = 50
elif DATASET == LARGE:
    N = 2000
else:
    N = 500

def init_matrix(n, seed):
    random.seed(seed)
    return [[0.0 if i == j else random.randint(1, 100)
             for j in range(n)] for i in range(n)]

def print_matrix(n, graph):
    for i in range(min(n, 8)):
        for j in range(min(n, 8)):
            print(f"{graph[i][j]:.2f}", end=' ')
        print()

def floyd_warshall(n, graph):
    for k in range(n):
        for i in range(n):
            for j in range(n):
                if graph[i][j] > graph[i][k] + graph[k][j]:
                    graph[i][j] = graph[i][k] + graph[k][j]

def main():
    seed = int(sys.argv[1]) if len(sys.argv) > 1 else 42
    graph = init_matrix(N, seed)

    start = time.time()
    floyd_warshall(N, graph)
    end = time.time()

    print(f"Finished Floyd-Warshall in {end - start:.3f} seconds")
    print_matrix(N, graph)

if __name__ == "__main__":
    main()

