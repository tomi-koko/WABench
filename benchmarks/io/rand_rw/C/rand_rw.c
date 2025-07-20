#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <time.h>

#define FILESIZE 104857600 // 100 MB
#define OPS 10000

int main() {
    int fd = open("randio.bin", O_RDWR | O_CREAT, 0666);
    ftruncate(fd, FILESIZE);
    char buf[4096];
    srand(time(NULL));
    for (int i = 0; i < OPS; i++) {
        off_t offset = (rand() % (FILESIZE / 4096)) * 4096;
        lseek(fd, offset, SEEK_SET);
        write(fd, buf, 4096);
    }
    close(fd);
    return 0;
}
