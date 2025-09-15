const std = @import("std");
const Region = @import("region.zig").Region;
const Axis = @import("axis.zig").Axis;
const Node = @import("node.zig").Node;
const Position = @import("position.zig").Position;

const TreeError = error{
    SplitterNotFound,
};

pub const Tree = struct {
    left: *Node,
    right: *Node,
    splitter: Splitter,
    boundingBox: Region,

    pub fn fromRegions(regions: []*Region, boundingBox: *const Region) !Tree {
        var bestSplitter: ?Splitter = null;
        var bestResult: SplitterResult = .{ .score = 0.0, .left = undefined, .right = undefined, .overlapping = undefined };

        const axisList = [_]Axis{ .X, .Y, .Z };
        for (axisList) |axis| {
            if (bestResult.score == 1.0) break;

            // TODO: replace gpa
            var gpa = std.heap.GeneralPurposeAllocator(.{}){};
            const allocator = gpa.allocator();

            var splitterValues = std.ArrayList(i32).initCapacity(allocator, 2^12);
            defer splitterValues.deinit();

            const forbiddenValues: [2]i32 = boundingBox.arrayByAxis(axis);
            for (regions) |region| {
                const values = region.arrayByAxis(axis);
                splitterValues.appendSlice(gpa, values);
            }
            // remove forbidden values
            splitterValues.removeRange(forbiddenValues[0], forbiddenValues[1]);

            // sort splitterValues
            std.mem.sort(i32, splitterValues.items, {}, struct {
                fn lessThan(_: void, a: i32, b: i32) bool {
                    return a < b;
                }
            }.lessThan);

            //const middleIndex = splitterValues.items.len / 2;
            // sort by how close its index is to the middle index of the array
            // PLACEHOLDER

            for (splitterValues.items) |value| {
                const splitter = Splitter{ .axis = axis, .value = value };
                const result = splitter.getScoreOfSplit(regions);
                if (bestSplitter == null or result.score > bestResult.score) {
                    bestSplitter = splitter;
                    bestResult = result;
                    if (bestResult.score == 1.0) break;
                }
            }
        }

        if (bestSplitter == null) {
            return error.SplitterNotFound;
        }

        const newBoundingBoxes = bestSplitter.splitBoundaryBox(boundingBox);
        var left: Node = undefined;
        if (isFinal(bestResult.left, newBoundingBoxes.left)) {
            left = Node.fromRegions(bestResult.left, newBoundingBoxes.left);
        } else {
            const leftTree = Tree.fromRegions(bestResult.left, newBoundingBoxes.left);
            left = Node.fromTree(&leftTree);
        }
        var right: Node = undefined;
        if (isFinal(bestResult.right, newBoundingBoxes.right)) {
            right = Node.fromRegions(bestResult.right, newBoundingBoxes.right);
        } else {
            const rightTree = Tree.fromRegions(bestResult.right, newBoundingBoxes.right);
            right = Node.fromTree(&rightTree);
        }

        return Tree{
            .left = &left,
            .right = &right,
            .splitter = bestSplitter,
            .boundingBox = boundingBox,
        };
    }
};

pub fn firstBoundingBox(regions: []*Region) Region {
    var min = Position{ .x = 0, .y = 0, .z = 0 };
    var max = min;

    for (regions) |region| {
        const axisList = [_]Axis{ .X, .Y, .Z };
        for (axisList) |axis| {
            if (region.min.byAxis(axis) < min.byAxis(axis)) min.setByAxis(axis, region.min.byAxis(axis) - 1);
            if (region.max.byAxis(axis) > max.byAxis(axis)) max.setByAxis(axis, region.max.byAxis(axis) + 1);
        }
    }
    return min.toRegion(max);
}

pub fn isFinal(regions: []*Region, boundingBox: *Region) bool {
    for (regions) |region| {
        if (!boundingBox.?.equals(region)) {
            return false;
        }
    }
}

pub const Splitter = struct {
    axis: Axis,
    value: i32,

    pub fn getScoreOfSplit(self: @This(), regions: []*Region) SplitterResult {
        const maxRegions = regions.len;

        var leftStorage: [maxRegions]*Region = undefined;
        var rightStorage: [maxRegions]*Region = undefined;
        var overlappingStorage: [maxRegions]*Region = undefined;

        var left = std.ArrayListUnmanaged(*Region).init(&leftStorage);
        var right = std.ArrayListUnmanaged(*Region).init(&rightStorage);
        var overlapping = std.ArrayListUnmanaged(*Region).init(&overlappingStorage);

        for (regions) |region| {
            // TODO: branchless byAxis later on
            const afterEdge1 = region.min.byAxis(self.axis) > self.value;
            const afterEdge2 = region.max.byAxis(self.axis) > self.value;

            // TODO: branchless later on
            if (afterEdge1 == afterEdge2) {
                if (afterEdge1) {
                    right.append(region);
                } else {
                    left.append(region);
                }
            } else {
                overlapping.append(region);
            }
        }

        const leftCount = left.items.len;
        const rightCount = right.items.len;
        const diff = @abs(leftCount - rightCount);
        const overlappingCount = overlapping.items.len;
        if (diff <= 1 and overlappingCount == 0) {
            return .{};
        } else {
            const relativeDiff = diff / (leftCount + rightCount);
            const relativeOverlapp = overlappingCount / (leftCount + rightCount + overlappingCount);
            return 1.0 * (1.0 - relativeDiff) * (1.0 - relativeOverlapp);
        }
    }

    pub fn splitBoundaryBox(self: @This(), boundingBox: *const Region) struct { left: Region, right: Region } {
        const left = boundingBox.clone();
        const right = boundingBox.clone();

        left.setByAxis(self.axis, .{ .min = left.min.byAxis(self.axis), .max = self.value });
        right.setByAxis(self.axis, .{ .min = self.value, .max = right.max.byAxis(self.axis) });
        return .{ .left = left, .right = right };
    }
};

const SplitterResult = struct {
    score: f32,
    left: []*Region,
    right: []*Region,
    overlapping: []*Region,
};

test "General" {
    var regionA = Region.fromPositions(Position{ .x = 0, .y = 0, .z = 0 }, Position{ .x = 2, .y = 2, .z = 2 });
    var regionB = Region.fromPositions(Position{ .x = 2, .y = 2, .z = 2 }, Position{ .x = 4, .y = 4, .z = 4 });
    var regionC = Region.fromPositions(Position{ .x = 4, .y = 4, .z = 4 }, Position{ .x = 6, .y = 6, .z = 6 });

    var regions = [_]*Region{ &regionA, &regionB, &regionC };
    const tree = Tree.fromRegions(regions[0..], &firstBoundingBox(&regions));

    try tree;
}
