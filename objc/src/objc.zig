//! A simple wrapper around the Objective-C runtime on macOS

const std = @import("std");

const c = @cImport({
    @cInclude("objc/NSObjCRuntime.h");
    @cInclude("objc/objc-runtime.h");
});

pub fn getClass(name: [:0]const u8) Class {
    return .{ .value = c.objc_getClass(name.ptr) orelse unreachable };
}

/// Wraps Objective C Classes
pub const Class = struct {
    value: c.Class,

    /// Implements objc_msgSend for Classes
    pub fn send(class: Class, comptime Return: type, method: [:0]const u8, args: anytype) Return {
        const RealReturn = if (Return == Object) c.id else Return;
        const sel = c.sel_registerName(method);

        const Fn = MsgSendFn(RealReturn, c.Class, @TypeOf(args));
        var msg_send_ptr = @ptrCast(*const Fn, &c.objc_msgSend);
        const result = @call(.auto, msg_send_ptr, .{ class.value, sel } ++ args);
        return Object{
            .value = result,
        };
    }
};

/// Wraps Objective C Objects
pub const Object = struct {
    value: c.id,

    pub fn send(object: Object, comptime Return: type, method: [:0]const u8, args: anytype) Return {
        const RealReturn = if (Return == Object) c.id else Return;
        const sel = c.sel_registerName(method);

        const Fn = MsgSendFn(RealReturn, c.id, @TypeOf(args));
        var msg_send_ptr = @ptrCast(*const Fn, &c.objc_msgSend);
        const result = @call(.auto, msg_send_ptr, .{ object.value, sel } ++ args);
        if (Return != void) {
            if (Return == Object) {
                return Object{ .value = result };
            }
            return result;
        }
    }
};

fn MsgSendFn(comptime Return: type, comptime Target: type, comptime Args: type) type {
    const argsInfo = @typeInfo(Args).Struct;

    const Fn = std.builtin.Type.Fn;
    const params: []Fn.Param = params: {
        var acc: [argsInfo.fields.len + 2]Fn.Param = undefined;
        acc[0] = .{ .type = Target, .is_generic = false, .is_noalias = false };
        acc[1] = .{ .type = c.SEL, .is_generic = false, .is_noalias = false };

        for (argsInfo.fields, 2..) |field, i| {
            acc[i] = .{
                .type = field.type,
                .is_generic = false,
                .is_noalias = false,
            };
        }

        break :params &acc;
    };

    const alignment = @typeInfo(fn () callconv(.C) void).Fn.alignment;

    return @Type(.{
        .Fn = .{
            .calling_convention = .C,
            .alignment = alignment,
            .is_generic = false,
            .is_var_args = false,
            .return_type = Return,
            .params = params,
        },
    });
}

/// NSPasteboard types
pub extern const NSPasteboardTypeString: c.id;

/// NSString Encodings
pub const NSUTF8StringEncoding: c.NSUInteger = 4;
