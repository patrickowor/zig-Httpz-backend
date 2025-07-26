const c = @cImport({
    @cInclude("libpq-fe.h");
});
const std = @import("std");


const PG_PORT: u16 = 5432;

//in wsl run to get host: grep nameserver /etc/resolv.conf | awk '{print $2}'
const PG_HOST: []const u8 = "localhost";// ; "winhost"
const PG_USERNAME: []const u8 = "postgres";
const PG_DBNAME: []const u8 = "postgres";
const PG_PASSWORD: []const u8 = "201101";

pub const Connection = struct { 
    PG_PORT: u16,
    PG_HOST: []const u8,
    PG_USERNAME: []const u8,
    PG_DBNAME: []const u8,
    PG_PASSWORD: []const u8,

    pub fn getConnectionString(self: *const Connection, allocator: std.mem.Allocator) ![]const u8 {


        const result = try std.fmt.allocPrint(allocator, "host={s} port={d} dbname={s} user={s} password={s}", .{self.PG_HOST, self.PG_PORT, self.PG_DBNAME, self.PG_USERNAME, self.PG_PASSWORD});
        // std.debug.print("{s}", .{result});
        // defer allocator.free(result);
        return result;
    }
}; 

pub const Pg = struct {
    conn: *c.PGconn,

    pub fn connect(connection: Connection) !Pg {
      var arena = std.heap.ArenaAllocator.init(std.heap.page_allocator);
      defer arena.deinit();
      const allocator = arena.allocator();

      const connectionString = try connection.getConnectionString(allocator);

      std.debug.print("{s}, ", .{connectionString});
    

      const conn = c.PQconnectdb(connectionString.ptr) ;
    //   std.debug.print("conn: {any}, ", .{conn});
      
      if (conn == null) {
          return error.ConnectionFailed;
      }

      if (c.PQstatus(conn) == c.CONNECTION_BAD) {
          defer c.PQfinish(conn);
          return error.ConnectionFailed;
      }
      defer allocator.free(connectionString);

      return Pg{ .conn = conn.? };
   }

    pub fn isConnected(self: Pg) bool {
        return c.PQstatus(self.conn) != c.CONNECTION_BAD;
    }

    pub fn errorMessage(self: Pg) []const u8 {
        return std.mem.spanZ(c.PQerrorMessage(self.conn));
    }

    // ofr insert, update, delete
    pub fn execute(self: Pg, sql: []const u8) !void {
        const result = c.PQexec(self.conn, sql.ptr);
        defer c.PQclear(result);

        if (c.PQresultStatus(result) != c.PGRES_COMMAND_OK) {
            return error.QueryFailed;
        }
    }

    // MEMORY issue in my ubuntu
    pub fn queryxx(self: Pg, sql: []const u8) !std.ArrayList([]const u8) {
        const result = c.PQexec(self.conn, sql.ptr);
        defer c.PQclear(result);

        if (c.PQresultStatus(result) != c.PGRES_TUPLES_OK) {
            return error.QueryFailed;
        }

        var rows = std.ArrayList([]const u8).init(std.heap.page_allocator);
        const num_rows = c.PQntuples(result);
        const num_columns = c.PQnfields(result);

        // Add header row
        {
            var header_builder = std.ArrayList(u8).init(std.heap.page_allocator);
            defer header_builder.deinit();

            var j: i32 = 0;
            while (j < num_columns) : (j += 1) {
                // const _field_name = c.PQfname(result, j);
                const field_name_str= std.mem.span(@ptrCast([*c]const u8) );
                try header_builder.appendSlice(field_name_str);
                if (j < num_columns - 1) {
                    try header_builder.append(',');
                }
            }
            const header_str = header_builder.toOwnedSlice();
            try rows.append(header_str);
        }

        // Add data rows
        var i: i32 = 0;
        while (i < num_rows) : (i += 1) {
            var row_builder = std.ArrayList(u8).init(std.heap.page_allocator);
            defer row_builder.deinit();

            var j: i32 = 0;
            while (j < num_columns) : (j += 1) {
                // const value = c.PQgetvalue(result, i, j);
                const value_str = std.mem.span(@ptrCast([*c]const u8));
                try row_builder.appendSlice(value_str);
                if (j < num_columns - 1) {
                    try row_builder.append(',');
                }
            }
            const row_str = row_builder.toOwnedSlice();
            try rows.append(row_str);
        }

        return rows;
    }

    // Error handling: Out of memory
    pub fn query(self: Pg, sql: []const u8) !std.ArrayList([]const u8) {
        const result = c.PQexec(self.conn, sql.ptr);
        defer c.PQclear(result);

        if (c.PQresultStatus(result) != c.PGRES_TUPLES_OK) {
            return error.QueryFailed;
        }

        var rows = std.ArrayList([]const u8).init(std.heap.page_allocator);
        const num_rows = c.PQntuples(result);
        const num_columns = c.PQnfields(result);

        // Add header row
        {
            var header_builder = std.ArrayList(u8).init(std.heap.page_allocator);
            defer header_builder.deinit();

            var j: i32 = 0;
            while (j < num_columns) : (j += 1) {
                const field_name = c.PQfname(result, j);
                const field_name_str = std.mem.span(@as([*c]const u8,field_name));
                try header_builder.appendSlice(field_name_str);
                if (j < num_columns - 1) {
                    try header_builder.append(',');
                }
            }
            const header_str_result = header_builder.toOwnedSlice();
            if (header_str_result) |header_str| {
                try rows.append(header_str);
            } else |_| {
                return error.OutOfMemory;
            }
        }

        // Add data rows
        var i: i32 = 0;
        while (i < num_rows) : (i += 1) {
            var row_builder = std.ArrayList(u8).init(std.heap.page_allocator);
            defer row_builder.deinit();

            var j: i32 = 0;
            while (j < num_columns) : (j += 1) {
                const value = c.PQgetvalue(result, i, j);
                const value_str = std.mem.span(@as([*c]const u8,value));
                try row_builder.appendSlice(value_str);
                if (j < num_columns - 1) {
                    try row_builder.append(',');
                }
            }
            const row_str_result = row_builder.toOwnedSlice() catch |err| {
                return err;
            };
            try rows.append(row_str_result);
        }

        return rows;
    }


    pub fn close(self: Pg) void {
        c.PQfinish(self.conn);
    }
};


pub fn postgresCFactory() !Pg {
    const connection: Connection =  .{
        .PG_DBNAME = PG_DBNAME,
        .PG_PASSWORD = PG_PASSWORD,
        .PG_HOST = PG_HOST,
        .PG_PORT = PG_PORT,
        .PG_USERNAME = PG_USERNAME
    };
    const db_result = try Pg.connect(connection);
    std.debug.print("pgFactory: {any}, ", .{db_result});
    
    // catch |err| {
    //     std.debug.print("Connection to PostgreSQL database failed: {}\n", .{err});
    //     return;
    // };
    return db_result;
}