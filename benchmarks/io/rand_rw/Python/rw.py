import os, random
f = open('randio.bin', 'r+b') if os.path.exists('randio.bin') else open('randio.bin', 'w+b')
f.truncate(104857600)
for _ in range(10000):
    offset = random.randint(0, (104857600 // 4096) -1) * 4096
    f.seek(offset)
    f.write(b'\0' * 4096)
f.close()
