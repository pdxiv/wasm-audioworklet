# WebAssembly Audio Generator with AudioWorklet

This is a test to see if it is possible to use WASM to efficiently generate audio in a web browser.

## Buildning the WASM

To build the WAT source code into a WASM binary simply use:

```bash
wat2wasm phase_accumulator.wasm
```

## Serving the HTML

To serve the HTML data on a local web server, the simplest way is to simply use a Python one-liner like so:

```bash
python3 -m http.server 8000
```

This will let you access `index.html` on the URL http://localhost:8000/

## Dependencies 

WABT for building WAT source code files into WASM binaries.
Python for making a temporary web server for local testing.
