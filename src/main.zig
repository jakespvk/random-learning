const std = @import("std");
const http = std.http;
const env_handler = @import("env_handler.zig");

const URL = "https://api.openai.com/v1/chat/completions";

pub fn main() !void {
    var dba = std.heap.DebugAllocator(.{}).init;
    defer _ = dba.deinit();
    const allocator = dba.allocator();

    var env_vars = std.StringHashMap([]const u8).init(allocator);
    defer env_vars.deinit();
    var buf: [4096]u8 = undefined;

    try env_handler.getEnvVars(&env_vars, ".env", &buf);

    // test env vars
    var env_vars_iter = env_vars.iterator();
    while (env_vars_iter.next()) |kv| {
        std.debug.print("{s}: {s}\n", .{ kv.key_ptr.*, kv.value_ptr.* });
    }

    std.debug.print("{s}\n", .{env_vars.get("OPENAI_API_KEY").?});
    const token = env_vars.get("OPENAI_API_KEY").?;
    std.debug.print("{d}, {d}\n", .{ token.len, "Bearer ".len });
    const bearer_token = std.mem.concat(allocator, u8, &[_][]const u8{ "Bearer ", token }) catch "";
    defer allocator.free(bearer_token);

    std.debug.print("{s}\n", .{bearer_token});
    std.debug.print("{d}\n", .{bearer_token.len});

    var client = http.Client{
        .allocator = allocator,
    };
    defer client.deinit();

    const uri = try std.Uri.parse(URL);

    const headers = http.Client.Request.Headers{
        .authorization = .{ .override = bearer_token[0..] },
        .content_type = .{ .override = "application/json" },
    };

    var dyn_response = std.ArrayList(u8).init(allocator);
    defer dyn_response.deinit();

    const body = try allocator.dupe(u8,
        \\ {
        \\      "model": "gpt-4o-mini",
        \\      "messages": [
        \\          {
        \\              "role": "user",
        \\              "content": [
        \\                  {
        \\                      "type": "text",
        \\                      "text": "Say hi"
        \\                  }
        \\              ]
        \\          }
        \\      ]
        \\ }
    );
    defer allocator.free(body);

    const request = http.Client.FetchOptions{
        .location = .{ .uri = uri },
        .method = .POST,
        .headers = headers,
        .response_storage = .{ .dynamic = &dyn_response },
        .payload = body,
    };

    const response = try client.fetch(request);
    std.debug.print("status: {any}\n", .{response.status});
    for (dyn_response.items) |c| {
        std.debug.print("{c}", .{c});
    }
    std.debug.print("\n", .{});
}
