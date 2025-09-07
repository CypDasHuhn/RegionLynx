const Axis = @import("axis.zig").Axis;
const Region = @import("region.zig").Region;

pub const Position = struct {
    x: i32,
    y: i32,
    z: i32,

    pub fn toRegion(self: @This(), other: Position) Region {
        return Region.fromPositions(self, other);
    }

    // TODO: Optimize
    pub fn byAxis(self: @This(), axis: Axis) i32 {
        switch (axis) {
            .X => return self.x,
            .Y => return self.y,
            .Z => return self.z,
        }
    }
    pub fn setByAxis(self: *Position, axis: Axis, value: i32) void {
        switch (axis) {
            .X => self.x = value,
            .Y => self.y = value,
            .Z => self.z = value,
        }
    }

    pub fn equal(self: @This(), other: Position) bool {
        return self.x == other.x and self.y == other.y and self.z == other.z;
    }
};
