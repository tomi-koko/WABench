#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main() {
    char data[1024] = {0};
    for (int i = 0; i < 1000; i++) {
        char fname[64];
        sprintf(fname, "data/smallfile_%d.bin", i);
        FILE *f = fopen(fname, "w");
        fwrite(data, 1, sizeof(data), f);
        fclose(f);
    }
    return 0;
}
