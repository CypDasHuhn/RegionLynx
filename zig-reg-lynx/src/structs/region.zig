const std = @import("std");

const Axis = enum {
    
}

const Position = struct {
    x: i32,
    y: i32,
    z: i32,

    fn toRegion(self: @This(), other: Position) Region {
        return .{ .pos1 = self, .pos2 = other };
    }
};

const Region = struct {
    pos1: Position,
    pos2: Position
};

test "1" {
    const pos1 = Position { .x = 0, .y = 0, .z = 0 };
    const pos2 = Position { .x = 10, .y = 10, .z = 10 };
    const region = pos1.toRegion(pos2);

    try std.testing.expect(region.pos1 == pos1);
    try std.testing.expect(region.pos2 == pos2);
}