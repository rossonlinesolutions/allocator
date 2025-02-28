# Allocator

> A fast and leightweight heap allocator, written in x64 nasm assembler.

An heap allocator written in pure x64 nasm assembly, callable from C and C++.

Small. Fast. and Freestanding.

## Usage

To build this library, run `make all`, for examples, run `make Example$(number)`
to build an example.

For debugging, run `make` with the example you want to debug, with `DEBUG=1` set,
for compiling with debug symbols.

For use for your projects, link `target/allocator.a` into your project, and
use `allocator.h` as header to use *allocator*. For documentation, reffer to
the doc strings in this header.

## License

MIT © [Ross Online Solutions](https://github.com/rossonlinesolutions)