const std = @import("std");
const Position = @import("position.zig").Position;
const Axis = @import("axis.zig").Axis;

pub const Region = struct {
    pos1: Position,
    pos2: Position,
    min: Position,
    max: Position,

    pub fn fromPositions(pos1: Position, pos2: Position) Region {
        return .{ .pos1 = pos1, .pos2 = pos2, .min = .{
            .x = @min(pos1.x, pos2.x),
            .y = @min(pos1.y, pos2.y),
            .z = @min(pos1.z, pos2.z),
        }, .max = .{
            .x = @max(pos1.x, pos2.x),
            .y = @max(pos1.y, pos2.y),
            .z = @max(pos1.z, pos2.z),
        } };
    }

    pub fn byAxis(self: @This(), axis: Axis) struct { min: i32, max: i32 } {
        return .{ self.min.byAxis(axis), self.max.byAxis(axis) };
    }
    pub fn arrayByAxis(self: @This(), axis: Axis) [2]i32 {
        return .{ self.min.byAxis(axis), self.max.byAxis(axis) };
    }

    pub fn setByAxis(self: *Region, axis: Axis, values: struct { min: i32, max: i32 }) void {
        self.min.setByAxis(axis, values.min);
        self.max.setByAxis(axis, values.max);
    }

    pub fn equals(self: @This(), other: Region) bool {
        return self.pos1.equal(other.pos1) and self.pos2.equal(other.pos2);
    }
};

test "ToRegion" {
    const pos1 = Position{ .x = 0, .y = 0, .z = 0 };
    const pos2 = Position{ .x = 10, .y = 10, .z = 10 };
    const region = pos1.toRegion(pos2);

    try std.testing.expect(region.pos1.equal(pos1));
    try std.testing.expect(region.pos2.equal(pos2));
}

test "MinMax" {
    const pos1 = Position{ .x = 0, .y = 0, .z = 0 };
    const pos2 = Position{ .x = 10, .y = 10, .z = 10 };
    const region = pos1.toRegion(pos2);

    try std.testing.expect(region.min.x <= region.max.x);
    try std.testing.expect(region.min.y <= region.max.y);
    try std.testing.expect(region.min.z <= region.max.z);
}
