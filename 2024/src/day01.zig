const std = @import("std");
const utils = @import("utils.zig");


pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    const context = utils.buildContext(allocator);

    const file = try std.fs.cwd().openFile("../inputs/day01.txt", .{});
    const contents = try context.readFile(file);
    _ = try parseInput(allocator, contents);

    // std.debug.print("{}", .{input});
}

const LocationIdList = std.ArrayList(u32);

const PuzzleInput = struct {
    list1: LocationIdList,
    list2: LocationIdList,

    pub fn deinit(self: PuzzleInput) void {
        self.list1.deinit();
        self.list2.deinit();
    }
};

fn parseInput(allocator: std.mem.Allocator, contents: []const u8) !PuzzleInput {
    var iterator = std.mem.tokenizeAny(u8, contents, &[_]u8{ '\n', ' ' });
    var list1 = LocationIdList.init(allocator);
    var list2 = LocationIdList.init(allocator);
    while (iterator.next()) |token| {
        const leftValue = try std.fmt.parseInt(u32, token, 10);
        const rightValue = try std.fmt.parseInt(u32, iterator.next().?, 10);
        try list1.append(leftValue);
        try list2.append(rightValue);
    }
    return .{
        .list1 = list1,
        .list2 = list2,
    };
}

test parseInput {
    const allocator = std.testing.allocator;
    const test_input =
    \\3   4
    \\4   3
    \\2   5
    \\1   3
    \\3   9
    \\3   3
    ;

    const parsed = try parseInput(allocator, test_input);
    defer parsed.deinit();

    var expectedList1 = LocationIdList.init(allocator);
    try expectedList1.appendSlice(&[_]u32{ 3, 4, 2, 1, 3, 3 });
    var expectedList2 = LocationIdList.init(allocator);
    try expectedList2.appendSlice(&[_]u32{ 4, 3, 5, 3, 9, 3 });
    const expected = PuzzleInput{
        .list1 = expectedList1,
        .list2 = expectedList2,
    };
    defer expected.deinit();
    try std.testing.expectEqualDeep(expected, parsed);
}
