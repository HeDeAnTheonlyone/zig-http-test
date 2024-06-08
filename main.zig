
const std = @import("std");

const http = std.http;



pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const allocator = gpa.allocator();
    
    var client = http.Client{.allocator = allocator};
    defer client.deinit();

    const uri = try std.Uri.parse("https://whatthecommit.com");

    const buffer = try allocator.alloc(u8, 1024 * 1024 * 4);
    defer allocator.free(buffer);

    var req = try client.open(.GET, uri, .{.server_header_buffer = buffer});
    defer req.deinit();

    try req.send();
    try req.finish();
    try req.wait();

    var iter = req.response.iterateHeaders();

    while (iter.next()) |header| {
        std.debug.print("\nHEADER: {s}\nVALUE: {s}\n", .{header.name, header.value});
    }

    const req_reader = req.reader();
    const body = try req_reader.readAllAlloc(allocator, 1024 * 1024 * 4);
    defer allocator.free(body);
    client.fetch()

    std.debug.print("\nBODY: {s}\n", .{body});
}
