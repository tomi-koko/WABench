package main
import (
    "fmt"
    "os"
)

func main() {
    data := make([]byte, 1024)
    for i := 0; i < 1000; i++ {
        fname := fmt.Sprintf("data/smallfile_%d.bin", i)
        f, _ := os.Create(fname)
        f.Write(data)
        f.Close()
    }
}
