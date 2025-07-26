const std = @import("std");
const App = @import("app.zig").App;
const ReqMethods = @import("app.zig").Methods;
const httpz = @import("httpz");
const pg = @import("pg");

const routers = @import("./http/controllers/router.zig").routers;

const postgresFactory = @import("./config/postgres.zig").postgresFactory;

// const c = @cImport({
//     @cInclude("libpq-fe.h");
// });

const PORT: u16 = 4000;

pub fn main() !void {




    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const allocator = gpa.allocator();

    const db = try postgresFactory(allocator);
    defer db.deinit();

    // var resp = try db.query("select first_name from users where id = $1", .{1});
    // defer resp.deinit();

    // while (try resp.next()) |row| {
    //     const id = row.get([]u8, 0);
    //     std.debug.print("value {s}", .{id});
    // }

    var app: App = .{
        .allocator = allocator,
        .db = db,
    };

    var server = try httpz.Server(*App).init(allocator, .{ .port = PORT }, &app);

    defer server.deinit();
    defer server.stop();

    var router = try server.router(.{});

    // router.get("/", getUser, .{});

    for (routers) |r| {
        switch (r.method) {
            ReqMethods.GET => router.get(r.path, r.handler, .{}),
            ReqMethods.POST => router.post(r.path, r.handler, .{}),
            ReqMethods.PUT => router.put(r.path, r.handler, .{}),
            ReqMethods.PATCH => router.patch(r.path, r.handler, .{}),
            ReqMethods.DELETE => router.delete(r.path, r.handler, .{}),
        }
    }

    std.debug.print("listening http://localhost:{d}/\n", .{PORT});
    try server.listen();
}

