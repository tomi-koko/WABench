#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <math.h>
#include <time.h>

#pragma pack(push, 1)
typedef struct {
    uint16_t bfType;
    uint32_t bfSize;
    uint16_t bfReserved1, bfReserved2;
    uint32_t bfOffBits;
} BITMAPFILEHEADER;

typedef struct {
    uint32_t biSize;
    int32_t  biWidth, biHeight;
    uint16_t biPlanes, biBitCount;
    uint32_t biCompression, biSizeImage;
    int32_t  biXPelsPerMeter, biYPelsPerMeter;
    uint32_t biClrUsed, biClrImportant;
} BITMAPINFOHEADER;
#pragma pack(pop)

double now_sec() {
    struct timespec ts;
    clock_gettime(CLOCK_MONOTONIC, &ts);
    return ts.tv_sec + ts.tv_nsec / 1e9;
}

int clamp(int val, int min, int max) {
    if (val < min) return min;
    if (val > max) return max;
    return val;
}

int main(int argc, char *argv[]) {
    if (argc != 2) {
        printf("Usage: %s <image.bmp>\n", argv[0]);
        return 1;
    }

    FILE *fp = fopen(argv[1], "rb");
    if (!fp) {
        perror("fopen");
        return 1;
    }

    BITMAPFILEHEADER fileHeader;
    BITMAPINFOHEADER infoHeader;

    fread(&fileHeader, sizeof(fileHeader), 1, fp);
    fread(&infoHeader, sizeof(infoHeader), 1, fp);

    if (fileHeader.bfType != 0x4D42 || infoHeader.biBitCount != 24) {
        printf("Only 24-bit BMP supported.\n");
        fclose(fp);
        return 1;
    }

    int width = infoHeader.biWidth;
    int height = abs(infoHeader.biHeight);
    int padding = (4 - (width * 3) % 4) % 4;

    uint8_t *gray = malloc(width * height);
    fseek(fp, fileHeader.bfOffBits, SEEK_SET);

    for (int y = height - 1; y >= 0; y--) {
        for (int x = 0; x < width; x++) {
            uint8_t bgr[3];
            fread(bgr, 1, 3, fp);
            uint8_t grayVal = (uint8_t)(0.299 * bgr[2] + 0.587 * bgr[1] + 0.114 * bgr[0]);
            gray[y * width + x] = grayVal;
        }
        fseek(fp, padding, SEEK_CUR);
    }
    fclose(fp);

    // Sobel Kernel
    int gx[3][3] = {
        {-1, 0, 1}, {-2, 0, 2}, {-1, 0, 1}
    };
    int gy[3][3] = {
        {1, 2, 1}, {0, 0, 0}, {-1, -2, -1}
    };

    double start = now_sec();

    uint8_t *output = malloc(width * height);
    for (int y = 1; y < height - 1; y++) {
        for (int x = 1; x < width - 1; x++) {
            int sumX = 0, sumY = 0;
            for (int dy = -1; dy <= 1; dy++) {
                for (int dx = -1; dx <= 1; dx++) {
                    uint8_t val = gray[(y + dy) * width + (x + dx)];
                    sumX += val * gx[dy + 1][dx + 1];
                    sumY += val * gy[dy + 1][dx + 1];
                }
            }
            int mag = sqrt(sumX * sumX + sumY * sumY);
            output[y * width + x] = clamp(mag, 0, 255);
        }
    }

    double end = now_sec();

    printf("Edge detection time: %.6f seconds\n", end - start);

    FILE *out = fopen("output.raw", "wb");
// 写入 BMP 文件头（自定义 24bit 灰度 BMP）

    fwrite(output, 1, width * height, out);
    fclose(out);

    free(gray);
    free(output);
    return 0;
}

