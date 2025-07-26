const std = @import("std");

pub fn str(allocator: std.mem.Allocator, value : []const u8) []const u8 {
    const result =  std.fmt.allocPrint(allocator, "{s}", .{value}) catch return "hello";
    return result;
}