import struct
import math
import time

def now_sec():
    return time.time()

def clamp(val, min_val, max_val):
    return min(max(val, min_val), max_val)

def main():
    import sys
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <image.bmp>")
        return 1

    with open(sys.argv[1], 'rb') as fp:
        # Read BITMAPFILEHEADER
        data = fp.read(14)
        bfType, bfSize, bfReserved1, bfReserved2, bfOffBits = \
            struct.unpack('<HIHHI', data)
        
        if bfType != 0x4D42:
            print("Only BMP supported.")
            return 1

        # Read BITMAPINFOHEADER
        data = fp.read(40)
        (biSize, biWidth, biHeight, biPlanes, biBitCount, biCompression,
         biSizeImage, biXPelsPerMeter, biYPelsPerMeter, biClrUsed,
         biClrImportant) = struct.unpack('<IiiHHIIiiII', data)
        
        if biBitCount != 24:
            print("Only 24-bit BMP supported.")
            return 1

        width = biWidth
        height = abs(biHeight)
        padding = (4 - (width * 3) % 4) % 4

        gray = bytearray(width * height)
        fp.seek(bfOffBits)

        for y in range(height - 1, -1, -1):
            for x in range(width):
                bgr = fp.read(3)
                gray_val = int(0.299 * bgr[2] + 0.587 * bgr[1] + 0.114 * bgr[0])
                gray[y * width + x] = gray_val
            fp.seek(padding, 1)

    # Sobel Kernel
    gx = [[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]]
    gy = [[1, 2, 1], [0, 0, 0], [-1, -2, -1]]

    start = now_sec()

    output = bytearray(width * height)
    for y in range(1, height - 1):
        for x in range(1, width - 1):
            sum_x = sum_y = 0
            for dy in range(-1, 2):
                for dx in range(-1, 2):
                    val = gray[(y + dy) * width + (x + dx)]
                    sum_x += val * gx[dy + 1][dx + 1]
                    sum_y += val * gy[dy + 1][dx + 1]
            mag = int(math.sqrt(sum_x**2 + sum_y**2))
            output[y * width + x] = clamp(mag, 0, 255)

    end = now_sec()
    print(f"Edge detection time: {end - start:.6f} seconds")

    # Optional: write output.raw
    with open('output.raw', 'wb') as f:
        f.write(output)

if __name__ == "__main__":
    main()
