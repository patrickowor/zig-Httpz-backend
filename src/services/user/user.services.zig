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

    pub fn getByid(self: *const UserService, id: usize) !*Users {
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

        const idx: i32 = result.get(i32, 0);
        const age: pg.Numeric = result.get(pg.Numeric, 1);
        var first_name: []u8 = result.get([]u8, 2);
        var last_name: []u8 = result.get([]u8, 3);

        var age_buffer: [32] u8 = undefined;
        const age_len : usize = age.estimatedStringLen();
        _ = age.toString(&age_buffer);

        user.* = .{
            .id = idx,
            .age =  try self.arena.dupe(u8, age_buffer[0..age_len - 1]),
            .first_name = try self.arena.dupe(u8, first_name[0..]),
            .last_name = try self.arena.dupe(u8, last_name[0..]),
        };
        return user;
    }
};
