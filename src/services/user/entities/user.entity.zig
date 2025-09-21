const pg = @import("pg");
const std = @import("std");

pub const Users = struct { 
    first_name: []const u8, 
    last_name: []const u8, 
    age: []const u8,//pg.Numeric, 
    id: i32,//pg.Numeric,
};
