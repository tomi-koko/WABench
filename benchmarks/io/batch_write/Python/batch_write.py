for i in range(1000):
    with open(f'data/smallfile_{i}.bin', 'wb') as f:
        f.write(b'\0' * 1024)
