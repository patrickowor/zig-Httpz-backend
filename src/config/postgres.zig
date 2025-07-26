const pg = @import("pg");
const std = @import("std");

const PG_PORT: u16 = 5432;

//in wsl run to get host: grep nameserver /etc/resolv.conf | awk '{print $2}'
const PG_HOST: []const u8 = "localhost";// ; "winhost"
const PG_USERNAME: []const u8 = "postgres";
const PG_DBNAME: []const u8 = "postgres";
const PG_PASSWORD: []const u8 = "201101";

pub fn postgresFactory(allocator: std.mem.Allocator) !*pg.Pool {
    const pool = try pg.Pool.init(allocator, .{
    .size = 5,
    .connect = .{
        .port = PG_PORT,
        .host = PG_HOST,
    },
    .auth = .{
        .username = PG_USERNAME,
        .database = PG_DBNAME,
        .password = PG_PASSWORD,
        .timeout = 10_000,
    }
    });
    // defer pool.deinit();

    return pool;
}