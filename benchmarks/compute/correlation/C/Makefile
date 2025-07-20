WASI_CC ?= /home/tomiko/work/wasm-benchmark-suite/toolchains/clang/wasi-sdk-25.0-x86_64-linux/bin/clang

LARGE:
	$(WASI_CC) correlation.c -DDATASET=LARGE -o correlation.wasm -lm -D_WASI_EMULATED_PROCESS_CLOCKS -lwasi-emulated-process-clocks

STANDARD:
	$(WASI_CC) correlation.c -DDATASET=STANDARD -o correlation.wasm -lm -D_WASI_EMULATED_PROCESS_CLOCKS -lwasi-emulated-process-clocks
	
SMALL:	
	$(WASI_CC) correlation.c -DDATASET=SMALL -o correlation.wasm -lm -D_WASI_EMULATED_PROCESS_CLOCKS -lwasi-emulated-process-clocks
