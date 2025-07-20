# WABench: WebAssembly Benchmark Suite

This repository provides the code and configuration used in our experimental evaluation of WebAssembly toolchains and standalone runtimes across mainstream programming languages.

## Overview

The experiments are designed to assess two core aspects of the WebAssembly toolchain ecosystem:

1. **Compilation Performance** 
   Evaluate the compilation time and bytecode size across different toolchains and their versions, focusing on:
   - Variations across versions of the same toolchain (e.g., WASI-SDK 0.21.0 → 0.25.0)
   - Differences between alternative compilers for the same language (e.g., TinyGo vs Go)

2. **Runtime Performance** 
   Evaluate the JIT execution efficiency and I/O throughput in standalone Wasm runtimes:
   - Execution time of compute-oriented benchmarks across five programming languages in **Wasmtime**
   - I/O throughput of a dedicated benchmark in both **Wasmtime** and **Wasmer**

All benchmarks are executed 20 times in a controlled virtualized environment (Ubuntu 20.04, 2-core CPU, 4GB RAM), and average values are reported to mitigate cold-start bias and ensure result stability.

## Requirements

- Docker (recommended) or native installation of the following:
  - WASI-SDK (various versions)
  - Go / TinyGo
  - Rust + `wasm32-wasip1` target
  - Zig
  - Python + `py2wasm` (optional for Python Wasm builds)
  - Wasmtime / Wasmer runtimes



