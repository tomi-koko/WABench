package main
import (
    "math/rand"
    "os"
)

func main() {
    f, _ := os.OpenFile("randio.bin", os.O_RDWR|os.O_CREATE, 0666)
    f.Truncate(104857600)
    buf := make([]byte, 4096)
    for i := 0; i < 10000; i++ {
        offset := rand.Intn(104857600/4096) * 4096
        f.Seek(int64(offset), 0)
        f.Write(buf)
    }
    f.Close()
}
