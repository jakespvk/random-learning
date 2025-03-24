const std = @import("std");

pub fn getEnvVars(output: *std.StringHashMap([]const u8), env_file_relative: []const u8) !void {
    const dir = std.fs.cwd();
    const file = try dir.openFile(env_file_relative, .{ .mode = .read_only });
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
