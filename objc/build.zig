const std = @import("std");

const ziglua = @import("lib/ziglua/build.zig");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const lib = b.addSharedLibrary(.{
        .name = "pboard",
        .root_source_file = .{ .path = "src/main.zig" },
        .target = target,
        .optimize = optimize,
    });

    lib.addModule("ziglua", ziglua.compileAndCreateModule(b, lib, .{ .shared = true }));

    lib.linkFramework("Cocoa");
    b.installArtifact(lib);
}
