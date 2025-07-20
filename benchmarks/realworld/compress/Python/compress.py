import time

def now_sec():
    return time.monotonic()

def simple_compress(data):
    out = bytearray()
    i = 0
    while i < len(data):
        b = data[i]
        count = 1
        while i + count < len(data) and data[i + count] == b and count < 255:
            count += 1
        out.append(count)
        out.append(b)
        i += count
    return out

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <file>")
        sys.exit(1)

    with open(sys.argv[1], "rb") as f:
        input_data = f.read()

    t_start = now_sec()
    output_data = simple_compress(input_data)
    t_end = now_sec()

    print(f"Compression time: {t_end - t_start:.6f} sec")
    print(f"Original size: {len(input_data)} bytes")
    print(f"Compressed size: {len(output_data)} bytes")
