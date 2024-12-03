const std = @import("std");
const expect = std.testing.expect;
const expectEqualStrings = std.testing.expectEqualStrings;
const fs = std.fs;
const Allocator = std.mem.Allocator;

pub const StringLiteral = []const u8;

pub fn buildContext(allocator: Allocator) Context {
    return Context{ .allocator = allocator };
}

const Context = struct {
    allocator: std.mem.Allocator,

    pub fn readFile(self: Context, file: fs.File) ![]u8 {
        const fileStats = try file.stat();
        const contents = try self.allocator.alloc(u8, fileStats.size);
        _ = try file.readAll(contents);
        return contents;
    }
};

test "readFile returns the contents of a file" {
    const context = buildContext(std.testing.allocator);

    const test_file = try createTestFileWithContent("Hello, world!\n");
    defer test_file.delete() catch {};

    const contents = try context.readFile(test_file.file);
    defer context.allocator.free(contents);

    try expect(std.mem.eql(u8, contents, "Hello, world!\n"));
}

test "String Literal Type" {
    const literal = "Hello, world!";
    const literal_type = @typeName(@TypeOf(literal));
    try expectEqualStrings(literal_type, "*const [13:0]u8");

    const dereferenced = literal.*;
    const dereferenced_type = @typeName(@TypeOf(dereferenced));
    try expectEqualStrings(dereferenced_type, "[13:0]u8");
}

const DeletableFile = struct {
    file: fs.File,
    dir: fs.Dir,
    filename: []const u8,

    pub fn delete(self: DeletableFile) !void {
        return self.dir.deleteFile(self.filename);
    }
};

const test_dir_path = "tmp/tests";

fn createTestFileWithContent(content: StringLiteral) !DeletableFile {
    const filename = "test_file.txt";
    try fs.cwd().makePath(test_dir_path);
    const test_dir = try fs.cwd().openDir(test_dir_path, .{});
    const test_file = try test_dir.createFile(filename, .{ .read = true });
    try test_file.writeAll(content);
    try test_file.seekTo(0);
    return .{
        .dir = test_dir,
        .filename = filename,
        .file = test_file,
    };
}
