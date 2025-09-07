const std = @import("std");
const zig_reg_lynx = @import("zig_reg_lynx");

fn add_internal(a: i32, b: i32) i32 {
    return (a + b) * 10;
}

export fn add(a: c_int, b: c_int) c_int {
    return add_internal(a, b);
}