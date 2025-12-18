const std = @import("std");

// Although this function looks imperative, note that its job is to
// declaratively construct a build graph that will be executed by an external
// runner.
pub fn build(b: *std.Build) void {
    // Standard target options allows the person running `zig build` to choose
    // what target to build for. Here we do not override the defaults, which
    // means any target is allowed, and the default is native. Other options
    // for restricting supported target set are available.
    const target: std.Build.ResolvedTarget = b.*.standardTargetOptions(.{});

    // Standard optimization options allow the person running `zig build` to select
    // between Debug, ReleaseSafe, ReleaseFast, and ReleaseSmall. Here we do not
    // set a preferred release mode, allowing the user to decide how to optimize.
    const optimize: std.builtin.OptimizeMode = b.*.standardOptimizeOption(.{});

    const mailbox: *std.Build.Dependency = b.*.dependency("mailbox", .{
        .target = target,
        .optimize = optimize,
    });

    const zig_datetime: *std.Build.Dependency = b.*.dependency("datetime", .{
        .target = target,
        .optimize = optimize,
    });

    const zig_network: *std.Build.Dependency = b.*.dependency("network", .{
        .target = target,
        .optimize = optimize,
    });

    const lib: *std.Build.Step.Compile = b.*.addStaticLibrary(.{
        .name = "syslog",
        // In this case the main source file is merely a path, however, in more
        // complicated build scripts, this could be a generated file.
        .root_source_file = b.*.path("src/root.zig"),
        .target = target,
        .optimize = optimize,
        .single_threaded = false,
    });

    lib.*.root_module.addImport("datetime", zig_datetime.*.module("datetime"));
    lib.*.root_module.addImport("network", zig_network.*.module("network"));

    // This declares intent for the library to be installed into the standard
    // location when the user invokes the "install" step (the default step when
    // running `zig build`).
    b.*.installArtifact(lib);

    // Creates a step for unit testing. This only builds the test executable
    // but does not run it.
    const lib_unit_tests: *std.Build.Step.Compile = b.*.addTest(.{
        .root_source_file = b.*.path("src/root_tests.zig"),
        .target = target,
        .optimize = optimize,
    });

    lib_unit_tests.*.root_module.addImport("network", zig_network.*.module("network"));
    lib_unit_tests.*.root_module.addImport("datetime", zig_datetime.*.module("datetime"));
    lib_unit_tests.*.root_module.addImport("mailbox", mailbox.*.module("mailbox"));
    b.*.installArtifact(lib_unit_tests);

    const run_lib_unit_tests: *std.Build.Step.Run = b.*.addRunArtifact(lib_unit_tests);

    // Similar to creating the run step earlier, this exposes a `test` step to
    // the `zig build --help` menu, providing a way for the user to request
    // running the unit tests.
    const test_step: *std.Build.Step = b.*.step("test", "Run unit tests");
    test_step.*.dependOn(&run_lib_unit_tests.*.step);
}
