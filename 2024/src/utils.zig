const std = @import("std");
const fs = std.fs;

pub fn readFile(file: fs.File, allocator: std.mem.Allocator) ![]u8 {
    const fileStats = try file.stat();
    const contents = try allocator.alloc(u8, fileStats.size);
    _ = try file.readAll(contents);
    return contents;
}

const test_dir_path = "tmp/tests";

const expect = std.testing.expect;

test "readFile returns the contents of a file" {
    try fs.cwd().makePath(test_dir_path);
    const test_dir = try fs.cwd().openDir(test_dir_path, .{});
    const test_file = try test_dir.createFile("test_file.txt", .{ .read = true });
    defer test_dir.deleteFile("test_file.txt") catch {};
    try test_file.writeAll("Hello, world!\n");
    try test_file.seekTo(0);

    const allocator = std.testing.allocator;
    const contents = try readFile(test_file, allocator);
    defer allocator.free(contents);
    try expect(std.mem.eql(u8, contents, "Hello, world!\n"));
}
