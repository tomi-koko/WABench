env GOOS=wasip1 GOARCH=wasm go build -ldflags="-w -s" -o correlation_gc_release.wasm correlation.go
