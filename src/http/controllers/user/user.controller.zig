const ctx = @import("../../../app.zig");
const AppRouter = ctx.AppRouter;
const AppMethod = ctx.Methods;
const App = ctx.App;
const httpz = @import("httpz");

pub const userRouters = [_]AppRouter{AppRouter{ .path = "/user", .method = AppMethod.GET, .handler = getUser }};

fn getUser(_: *App, _: *httpz.Request, res: *httpz.Response) !void {
    try res.json(.{ .id = "1", .name = "ade" }, .{});
}
