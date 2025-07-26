const std = @import("std");
const pg = @import("pg");
const httpz = @import("httpz");

const UserService = @import("./services/user/user.services.zig").UserService;

pub const App = struct {
    allocator: std.mem.Allocator,
    db: *pg.Pool,

    // //the user services
    // userService: UserService,
};

pub const Methods = enum { GET, POST, DELETE, PUT, PATCH };

pub const AppRouter = struct {
    path: []const u8,
    method: Methods,
    handler: *const fn (app: *App, req: *httpz.Request, res: *httpz.Response) anyerror!void,
};
