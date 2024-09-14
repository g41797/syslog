//---------------------------------
const std = @import("std");
const mem = std.mem;
const testing = std.testing;
const string = @import("shortstring.zig");
const pid = @import("pid.zig");
const ShortString = string.ShortString;
const builtin = @import("builtin");
const native_os = builtin.os.tag;
const rfc5424 = @import("rfc5424.zig");
const timestamp = @import("timestamp.zig");
//---------------------------------

// HOSTNAME        = NILVALUE / 1*255PRINTUSASCII
// APP-NAME        = NILVALUE / 1*48PRINTUSASCII

pub const MAX_HOST_NAME: u8 = 255;
pub const MAX_APP_NAME: u8 = 48;

const AppName = ShortString(MAX_APP_NAME);
const HostName = ShortString(MAX_HOST_NAME);

pub const ApplicationOpts = struct {
    name: []const u8 = "zigprocess",
    fcl: rfc5424.Facility = .local7,
};

pub const Application = struct {
    const Self = @This();

    app_name: AppName,
    host_name: HostName,
    procid: pid.ProcID,
    fcl: rfc5424.Facility = undefined,

    // pub fn init(app: *Application, opts: ApplicationOpts) !void {
    //
    //     _ = try app.*.app_name.fillFrom(opts.name);
    //
    //     _ = try pid.storePID(&app.*.procid);
    //
    //     _ = try app.setHostName();
    //
    //     app.*.fcl = opts.fcl;
    //
    //     return;
    // }

    pub fn init(opts: ApplicationOpts) !Application {
        var app: Application = undefined;

        _ = try app.app_name.fillFrom(opts.name);

        _ = try pid.storePID(&app.procid);

        _ = try app.setHostName();

        app.fcl = opts.fcl;

        return app;
    }

    fn setHostName(appl: *Application) !void {
        if (!((native_os == .windows) or (native_os == .linux))) {
            appl.*.host_name.fillFrom("-");
            return;
        }

        const envMame = switch (native_os) {
            .windows => "COMPUTERNAME",
            .linux => "HOSTNAME",
            else => unreachable,
        };

        var buffer: [MAX_HOST_NAME]u8 = undefined;

        var fbAllocator = std.heap.FixedBufferAllocator.init(&buffer);
        const allocator = fbAllocator.allocator();
        const hostName = std.process.getEnvVarOwned(allocator, envMame) catch "-";

        defer allocator.free(hostName);

        _ = try appl.*.host_name.fillFrom(hostName);

        return;
    }
};

test "application init" {
    _ = try Application.init(.{});
}
