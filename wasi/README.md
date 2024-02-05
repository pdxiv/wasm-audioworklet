# WASI

Potentially, we could use WASI code to help us debug our web WASM code, by giving us access to printing values to the terminal etc.

## Printing strings

The `hello.wat` source code illustrates how to print strings using the WASI `fd_write` function.

Using `wasmtime` to run the program WASI program:

```bash
rm hello.wasm 2>/dev/null ; wat2wasm hello.wat && wasmtime hello.wasm
```

## Printing numbers

The `print_number.wat` source code adds a function to print positive 32 bit values as strings in a similar way to how `hello.wat` prints things.
