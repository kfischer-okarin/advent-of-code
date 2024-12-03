const std = @import("std");
const utils = @import("utils.zig");
const Allocator = std.mem.Allocator;
const ArrayList = std.ArrayList;


pub fn main() !void {
    var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
    defer arena.deinit();

    const allocator = arena.allocator();
    const context = utils.buildContext(allocator);

    const file = try std.fs.cwd().openFile("../inputs/day01.txt", .{});
    const contents = try context.readFile(file);
    _ = try PuzzleInput.parse(allocator, contents);

    // std.debug.print("{}", .{input});
}

const LocationIdList = []u32;

const PuzzleInput = struct {
    list1: LocationIdList,
    list2: LocationIdList,

    pub fn fromSlices(allocator: Allocator, list1: []const u32, list2: []const u32) !PuzzleInput {
        return .{
            .list1 = try allocator.dupe(u32, list1),
            .list2 = try allocator.dupe(u32, list2),
        };
    }

    // []const u8 is a subtype of []u8 - it's a stricter contract
    // You can pass a []u8 to a function that expects a []const u8, but not the other way around
    pub fn parse(allocator: Allocator, contents: []const u8) !PuzzleInput {
        var iterator = std.mem.tokenizeAny(u8, contents, &[_]u8{ '\n', ' ' });

        var list1 = ArrayList(u32).init(allocator);
        defer list1.deinit();
        var list2 = ArrayList(u32).init(allocator);
        defer list2.deinit();

        while (iterator.next()) |token| {
            const leftValue = try std.fmt.parseInt(u32, token, 10);
            const rightValue = try std.fmt.parseInt(u32, iterator.next().?, 10);
            try list1.append(leftValue);
            try list2.append(rightValue);
        }
        return .{
            .list1 = try list1.toOwnedSlice(),
            .list2 = try list2.toOwnedSlice(),
        };
    }

    pub fn deinit(self: PuzzleInput, allocator: Allocator) void {
        allocator.free(self.list1);
        allocator.free(self.list2);
    }
};

test "parse" {
    const allocator = std.testing.allocator;
    const test_input =
    \\3   4
    \\4   3
    \\2   5
    \\1   3
    \\3   9
    \\3   3
    ;

    const parsed = try PuzzleInput.parse(allocator, test_input);
    defer parsed.deinit(allocator);

    const expected = try PuzzleInput.fromSlices(
        allocator,
        &[_]u32{ 3, 4, 2, 1, 3, 3 },
        &[_]u32{ 4, 3, 5, 3, 9, 3 }
    );
    defer expected.deinit(allocator);
    try std.testing.expectEqualDeep(expected, parsed);
}
