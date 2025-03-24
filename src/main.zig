const std = @import("std");
const http = std.http;
const env_handler = @import("env_handler.zig");

pub fn main() !void {
    var dba = std.heap.DebugAllocator(.{}).init;
    defer _ = dba.deinit();
    const allocator = dba.allocator();

    var env_vars = std.StringHashMap([]const u8).init(allocator);
    defer env_vars.deinit();

    try env_handler.getEnvVars(&env_vars, "/home/jakes/cecs/forfun/zig/gpt_api/.env");

    // test OPENAI_API_KEY
    std.debug.print("{s}\n", .{env_vars.get("OPENAI_API_KEY").?});

    const client = http.Client{
        .allocator = allocator,
    };

    const headers = http.Header{ .name = "headers", .value = "auth" };

    _ = client;
    _ = headers;
    // client.fetch(request);
}
