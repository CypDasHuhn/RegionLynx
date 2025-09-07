const Region = @import("region.zig").Region;
const Tree = @import("tree.zig").Tree;

pub const Node = struct {
    regions: ?[]*Region,
    tree: ?*Tree,

    pub fn isLeaf(self: @This()) bool {
        return self.regions != null;
    }
    pub fn isTree(self: @This()) bool {
        return self.regions == null;
    }

    pub fn fromRegions(regions: []*Region) Node {
        return Node { .regions = regions, .tree = null };
    }

    pub fn fromTree(tree: *Tree) Node {
        return Node { .regions = null, .tree = tree };
    }
};
