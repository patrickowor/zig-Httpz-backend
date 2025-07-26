const pg = @import("pg");
const std = @import("std");

pub const Users = struct { 
    first_name: [] u8, 
    last_name: [] u8, 
    age: [] u8,//pg.Numeric, 
    id: [] u8,//pg.Numeric,

    // pub fn serialize(self: *const Users) type {
    //     const value = struct {
    //         age: []const u8 =  self.age.digits,
    //         id: []const u8 = self.id.digits,
    //         first_name: []const u8= self.first_name,
    //         last_name: []const u8= self.last_name
    //     };
    //     return value;
    // }

    // fn init(pg.QueryRow) Users {

    // }
};
