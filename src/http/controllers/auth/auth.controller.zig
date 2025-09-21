const ctx = @import("../../../app.zig");
const AppRouter = ctx.AppRouter;
const AppMethod = ctx.Methods;
const App = ctx.App;
const httpz = @import("httpz");
const std = @import("std");

const Users = @import("../../../services/user/entities/user.entity.zig").Users;
const pg = @import("pg");

const str = @import("../../../utils/stringify.zig").str;

const UserService = @import("../../../services/user/user.services.zig").UserService;

pub const authRouters = [_]AppRouter{
    // AppRouter{ .path = "/", .method = AppMethod.GET, .handler = sayHello },
    AppRouter{ .path = "/hello", .method = AppMethod.GET, .handler = getUserInfo },
};

fn getUserInfo(app: *App, _: *httpz.Request, res: *httpz.Response) !void {

   const user = try UserService.init(app, res.arena).getByid( 1);
    defer res.arena.destroy(user);

    try res.json(.{ .user = user  }, .{});
}
