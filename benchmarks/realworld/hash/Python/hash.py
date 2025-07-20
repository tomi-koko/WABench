import sys
import time

# SHA-256 implementation (no external libraries)
def right_rotate(x, n):
    return (x >> n) | (x << (32 - n)) & 0xFFFFFFFF

def sha256_pad(data):
    orig_len = len(data)
    data += b'\x80'
    while (len(data) + 8) % 64 != 0:
        data += b'\x00'
    data += (orig_len * 8).to_bytes(8, 'big')
    return data

def sha256_chunk(chunk, state):
    k = [
        0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4, 0xab1c5ed5,
        0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe, 0x9bdc06a7, 0xc19bf174,
        0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f, 0x4a7484aa, 0x5cb0a9dc, 0x76f988da,
        0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7, 0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967,
        0x27b70a85, 0x2e1b2138, 0x4d2c6dfc, 0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85,
        0xa2bfe8a1, 0xa81a664b, 0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070,
        0x19a4c116, 0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
        0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7, 0xc67178f2
    ]
    
    w = [0] * 64
    for i in range(16):
        w[i] = int.from_bytes(chunk[i*4:i*4+4], 'big')
    
    for i in range(16, 64):
        s0 = right_rotate(w[i-15], 7) ^ right_rotate(w[i-15], 18) ^ (w[i-15] >> 3)
        s1 = right_rotate(w[i-2], 17) ^ right_rotate(w[i-2], 19) ^ (w[i-2] >> 10)
        w[i] = (w[i-16] + s0 + w[i-7] + s1) & 0xFFFFFFFF
    
    a, b, c, d, e, f, g, h = state
    
    for i in range(64):
        s1 = right_rotate(e, 6) ^ right_rotate(e, 11) ^ right_rotate(e, 25)
        ch = (e & f) ^ ((~e) & g)
        temp1 = (h + s1 + ch + k[i] + w[i]) & 0xFFFFFFFF
        s0 = right_rotate(a, 2) ^ right_rotate(a, 13) ^ right_rotate(a, 22)
        maj = (a & b) ^ (a & c) ^ (b & c)
        temp2 = (s0 + maj) & 0xFFFFFFFF
        
        h = g
        g = f
        f = e
        e = (d + temp1) & 0xFFFFFFFF
        d = c
        c = b
        b = a
        a = (temp1 + temp2) & 0xFFFFFFFF
    
    return [
        (state[0] + a) & 0xFFFFFFFF,
        (state[1] + b) & 0xFFFFFFFF,
        (state[2] + c) & 0xFFFFFFFF,
        (state[3] + d) & 0xFFFFFFFF,
        (state[4] + e) & 0xFFFFFFFF,
        (state[5] + f) & 0xFFFFFFFF,
        (state[6] + g) & 0xFFFFFFFF,
        (state[7] + h) & 0xFFFFFFFF
    ]

def sha256(data):
    state = [
        0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
        0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
    ]
    
    padded = sha256_pad(data)
    for i in range(0, len(padded), 64):
        chunk = padded[i:i+64]
        state = sha256_chunk(chunk, state)
    
    return b''.join(x.to_bytes(4, 'big') for x in state)

def sha256_file(filename):
    ctx = {
        'state': [
            0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a,
            0x510e527f, 0x9b05688c, 0x1f83d9ab, 0x5be0cd19
        ],
        'bitlen': 0,
        'data': bytearray(64),
        'datalen': 0
    }
    
    BUF_SIZE = 8192
    start = time.time()
    
    with open(filename, 'rb') as f:
        while True:
            chunk = f.read(BUF_SIZE)
            if not chunk:
                break
            
            ctx['bitlen'] += len(chunk) * 8
            idx = 0
            
            while idx < len(chunk):
                remaining = 64 - ctx['datalen']
                to_copy = min(remaining, len(chunk) - idx)
                
                ctx['data'][ctx['datalen']:ctx['datalen']+to_copy] = chunk[idx:idx+to_copy]
                ctx['datalen'] += to_copy
                idx += to_copy
                
                if ctx['datalen'] == 64:
                    ctx['state'] = sha256_chunk(bytes(ctx['data']), ctx['state'])
                    ctx['datalen'] = 0
    
    # Finalize
    if ctx['datalen'] > 0:
        ctx['data'][ctx['datalen']] = 0x80
        ctx['datalen'] += 1
        
        if ctx['datalen'] > 56:
            while ctx['datalen'] < 64:
                ctx['data'][ctx['datalen']] = 0
                ctx['datalen'] += 1
            ctx['state'] = sha256_chunk(bytes(ctx['data']), ctx['state'])
            ctx['datalen'] = 0
        
        while ctx['datalen'] < 56:
            ctx['data'][ctx['datalen']] = 0
            ctx['datalen'] += 1
        
        ctx['data'][56:64] = ctx['bitlen'].to_bytes(8, 'big')
        ctx['state'] = sha256_chunk(bytes(ctx['data']), ctx['state'])
    
    hash_bytes = b''.join(x.to_bytes(4, 'big') for x in ctx['state'])
    end = time.time()
    
    print(f"SHA256 time: {end - start:.6f} sec")
    print("Hash:", ''.join(f"{b:02x}" for b in hash_bytes))

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <file>")
        sys.exit(1)
    sha256_file(sys.argv[1])
