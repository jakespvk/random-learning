const std = @import("std");
const http = std.http;
const env_handler = @import("env_handler");

pub fn main() !void {
    var dba = std.heap.DebugAllocator(.{}).init;
    defer dba.deinit();
    const allocator = dba.allocator();

    const env_vars = std.StringHashMap(u8).init(allocator);
    defer env_vars.free();

    env_handler.getEnvVars(&env_vars, "/home/jakes/cecs/forfun/zig/gpt_api/.env");

    for (env_vars) |v| {
        std.debug.print("{s}: {s}\n", .{ v.key, v.value });
    }

    const client = http.Client{
        .allocator = allocator,
    };

    const headers = http.Header{};

    _ = client;
    _ = headers;
    // client.fetch(request);
}
