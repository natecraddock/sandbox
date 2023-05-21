const objc = @import("objc.zig");
const std = @import("std");
const ziglua = @import("ziglua");

const Class = objc.Class;
const Lua = ziglua.Lua;
const Object = objc.Object;

export fn luaopen_pboard(state: *ziglua.LuaState) i32 {
    var lua = Lua{ .state = state };
    lua.newLib(&funcs);
    return 1;
}

const funcs = [_]ziglua.FnReg{
    .{ .name = "set", .func = ziglua.wrap(set) },
    .{ .name = "get", .func = ziglua.wrap(get) },
    .{ .name = "clear", .func = ziglua.wrap(clear) },
};

fn set(lua: *Lua) i32 {
    const str = lua.checkBytes(1);

    // Get a reference to the NSPasteboard class
    const NSPasteboard = objc.getClass("NSPasteboard");

    // Send a message
    const pboard = NSPasteboard.send(Object, "generalPasteboard", .{});

    // Clear the clipboard
    pboard.send(void, "clearContents", .{});

    // Copy a string into the pasteboard
    const NSString = objc.getClass("NSString");
    const textToCopy = NSString.send(Object, "stringWithUTF8String:", .{str});

    const success = pboard.send(bool, "setString:forType:", .{ textToCopy.value, objc.NSPasteboardTypeString });
    lua.pushBoolean(success);

    return 1;
}

fn get(lua: *Lua) i32 {
    // Get a reference to the NSPasteboard class
    const NSPasteboard = objc.getClass("NSPasteboard");

    // Send a message
    const pboard = NSPasteboard.send(Object, "generalPasteboard", .{});
    const textPasted = pboard.send(Object, "stringForType:", .{objc.NSPasteboardTypeString});
    const textOrNull = std.mem.sliceTo(textPasted.send(?[*:0]const u8, "cStringUsingEncoding:", .{objc.NSUTF8StringEncoding}), 0);
    if (textOrNull) |text| {
        _ = lua.pushString(text);
    } else lua.pushNil();

    return 1;
}

fn clear(lua: *Lua) i32 {
    _ = lua;
    const NSPasteboard = objc.getClass("NSPasteboard");
    const pboard = NSPasteboard.send(Object, "generalPasteboard", .{});
    pboard.send(void, "clearContents", .{});
    return 0;
}
