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

   _ = try UserService.init(app, res.arena).getByid( 1);
   

    // const conn = try app.db.acquire();
    // defer conn.deinit();
    // const row = (try conn.row("select id, age,first_name , last_name  from users  where id = $1", .{1}));
        
    // if (row == null) {   
    //     return error.ResultNotFound;
    // }
    // var result: pg.QueryRow = undefined;
    // result = row.?;
    // const user: Users = .{
    //     .id = result.get(pg.Numeric, 0),
    //     .age = result.get(pg.Numeric, 1),
    //     .first_name = result.get([]const u8, 2),
    //     .last_name  = result.get([]const u8, 3)
    // };




    try res.json(.{  .m = "hi",    }, .{});
}
