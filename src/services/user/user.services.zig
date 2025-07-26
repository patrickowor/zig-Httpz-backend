const App = @import("../../app.zig").App;
const Users = @import("./entities/user.entity.zig").Users;
const std = @import("std");
const pg = @import("pg");

pub const UserService = struct {
    pg: *pg.Pool,
    arena: std.mem.Allocator,

    pub fn init(app: *App, alloc: std.mem.Allocator) UserService {
        return .{ .pg = app.db, .arena = alloc };
    }

    pub fn getByid(self: *const UserService, id: usize) !Users {
        const conn = try self.pg.acquire();
        defer conn.deinit();

        const row = (try conn.row("select id, age,first_name , last_name  from users  where id = $1", .{id}));
        
        if (row == null) {   
            return error.ResultNotFound;
        }
        

        var result: pg.QueryRow = undefined;
        result = row.?;
        defer result.deinit() catch {};
        
        const user = try self.arena.create(Users);

        // const idx: pg.Numeric = result.get(pg.Numeric, 0);
        // const age: pg.Numeric = result.get(pg.Numeric, 1);
        const first_name: []u8 = result.get([]u8, 2);
        const last_name: []u8 = result.get([]u8, 3);


        
        user.*.first_name = first_name[0..first_name.len];
        @memcpy(user.*.first_name, first_name[0..first_name.len]);
        @memcpy(user.*.last_name, last_name[0..last_name.len]);
        // user.*.last_name = last_name[0..last_name.len];
        user.*.age = last_name[0..last_name.len];
        user.*.id = last_name[0..last_name.len];

        std.debug.print("{any} {any}", .{user, &last_name[0..]});
        // result.get(pg.Numeric, 0)
        // @memcpy(user.first_name, result.get([]u8, 2));
        // @memcpy(user.last_name, result.get([]u8, 3));


        // user.* = .{
        //     .id = result.get(pg.Numeric, 0),
        //     .age = result.get(pg.Numeric, 1),
        //     .first_name = 
        //     .last_name = result.get([]u8, 3)
        // };
        // user.*
        // user.*.age = result.get(pg.Numeric, 1);
        // user.*.first_name = result.get([]u8, 2);
        // user.*.last_name = result.get([]u8, 3);
   
    //    std.debug.print("firstname={s}, firstname_arr={any} user={any}", .{user.first_name, user.last_name, user});
        return user.*;
    }
};
