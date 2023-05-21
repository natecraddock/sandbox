# objc

This is where I experimented with Objective-C, C, Zig, and Lua. A bunch of code to read and write strings to the macOS clipboard. This code will only work on macOS.

This assumes Lua is installed with homebrew. I am testing this on an aarch64 machine, and I'm pretty sure homebrew has different include and library directories on x86_64.

## pboard.m

This is a Lua C module written in Objective-C that exposes a single function `set()` to write a string to the clipboard

To use

```shell
$ cc -framework Cocoa -l lua -I /opt/homebrew/include -L /opt/homebrew/lib -shared -o pboard.so pboard.m
$ lua
> pboard = require 'pboard'
> pboard.set('this text will be copied to the clipboard')
```

## pboard.c

This is nearly identical to the Objective-C version, but all of the Objective-C code has been rewritten to use the C runtime library.

To use

```shell
$ cc -framework Cocoa -l lua -I /opt/homebrew/include -L /opt/homebrew/lib -shared -o pboard.so pboard.c
$ lua
> pboard = require 'pboard'
> pboard.set('this text will be copied to the clipboard')
```

## Zig

This is a much more complex and complete example. The file `src/objc.zig` is based heavily on [mitchellh/zig-objc](https://github.com/mitchellh/zig-objc), but with some tweaks to simplify and make it fit my preferences a bit better. (I also couldn't get that library working, so I rewrote it myself).

This also depends on my [ziglua](https://github.com/natecraddock/ziglua) library. Clone it to the `lib/ziglua` directory.

To use
```shell
$ zig build -fsummary
$ mv zig-out/lib/libpboard.dylib pboard.so
$ lua
> pboard = require 'pboard'
> pboard.set('this text will be copied to the clipboard')
```
