const std = @import("std");

pub fn getEnvVars(output: *std.StringHashMap([]const u8), env_file_path: []const u8) !void {
    const file = try std.fs.openFileAbsolute(env_file_path, .{ .mode = .read_only });
    errdefer file.close();
    defer file.close();
    var buf: [4096]u8 = undefined;
    while (try file.reader().readUntilDelimiterOrEof(&buf, '\n')) |line| {
        if (std.mem.eql(u8, line, "")) {
            continue;
        } else {
            var line_split = std.mem.splitScalar(u8, line, '=');
            try output.*.put(std.mem.trim(u8, line_split.first(), " "), std.mem.trim(u8, line_split.rest(), " "));
        }
    }
    // file.close();
}
