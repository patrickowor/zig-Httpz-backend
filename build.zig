const std = @import("std");

pub fn build(b: *std.Build) void {
        
    const target = b.standardTargetOptions(.{});

    const optimize = b.standardOptimizeOption(.{});

    const exe_mod = b.createModule(.{    
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const httpz = b.dependency("httpz", .{
        .target = target,
        .optimize = optimize,
    });
    const pg = b.dependency("pg", .{
        .target = target,
        .optimize = optimize,
    });

    const exe = b.addExecutable(.{
        .name = "httpz_template",
        .root_module = exe_mod,
    });
    exe.linkLibC();

    const target_os = target.result.os.tag;
    if (target_os == .windows) {
        exe.addLibraryPath(b.path("src/lib/"));
        exe.linkSystemLibrary("libpq");
    } else {
        const postgres = b.dependency("libpq", .{ 
            .target = target,
            .optimize = optimize });
        const libpq = postgres.artifact("pq");

        exe.linkLibrary(libpq);
    }

        
    exe.addIncludePath(b.path("src/lib/"));
    exe.addCSourceFile(.{ .file = b.path("src/lib/libpq-fe.c"), .flags = &[_][]const u8{ "-g", "-O3" } });
    exe.root_module.addImport("httpz", httpz.module("httpz"));
    exe.root_module.addImport("pg", pg.module("pg"));

    b.installArtifact(exe);

   const run_cmd = b.addRunArtifact(exe);
    
    run_cmd.step.dependOn(b.getInstallStep());

    
    if (b.args) |args| {
        run_cmd.addArgs(args);
    }
    
    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);

    const exe_unit_tests = b.addTest(.{
        .root_module = exe_mod,
    });

    const run_exe_unit_tests = b.addRunArtifact(exe_unit_tests);
    
    const test_step = b.step("test", "Run unit tests");

    test_step.dependOn(&run_exe_unit_tests.step);
}
