//---------------------------------
const std = @import("std");
const Mutex = std.Thread.Mutex;
const Allocator = std.mem.Allocator;

pub const rfc5424 = @import("rfc5424.zig");
pub const application = @import("application.zig");
pub const transport = @import("transport.zig");
//---------------------------------

//---------------------------------
pub const TransportOpts = transport.TransportOpts;
pub const Protocol = transport.Protocol;
pub const ApplicationOpts = application.ApplicationOpts;
pub const Formatter = rfc5424.Formatter;
pub const Severity = rfc5424.Severity;
pub const Sender = transport.Sender;
//---------------------------------

pub const SyslogOpts = struct {
    // application:
    name: []const u8 = application.DefaultAppName,
    fcl: rfc5424.Facility = application.DefaultFacility,

    // transport:
    proto: Protocol = transport.DefaultProto,
    addr: []const u8 = transport.DefaultAddr,
    port: u16 = transport.DafaultPort,
};

pub const Syslog = struct {
    mutex: Mutex = .{},
    frmtr: Formatter = undefined,
    sndr: Sender = undefined,
    ready: bool = false,
    filter: ?Severity = null,

    pub fn init(slog: *Syslog, allocator: Allocator, conf: SyslogOpts) !void {
        slog.mutex.lock();
        defer slog.mutex.unlock();

        if (slog.ready) {
            return error.WasInit;
        }

        _ = try slog.frmtr.init(allocator, .{ .name = conf.name, .fcl = conf.fcl });
        slog.sndr = try Sender.connect(allocator, .{ .proto = conf.proto, .addr = conf.addr, .port = conf.port });
        slog.ready = true;
    }

    pub fn deinit(slog: *Syslog) void {
        slog.mutex.lock();
        defer slog.mutex.unlock();

        if (!slog.ready) {
            return;
        }

        slog.frmtr.deinit();
        slog.sndr.disconnect();
        slog.ready = false;

        return;
    }

    pub inline fn write_emerg(slog: *Syslog, msg: []const u8) !void {
        return slog.write(.emerg, msg);
    }
    pub inline fn write_alert(slog: *Syslog, msg: []const u8) !void {
        return slog.write(.alert, msg);
    }
    pub inline fn write_crit(slog: *Syslog, msg: []const u8) !void {
        return slog.write(.crit, msg);
    }
    pub inline fn write_err(slog: *Syslog, msg: []const u8) !void {
        return slog.write(.err, msg);
    }
    pub inline fn write_warning(slog: *Syslog, msg: []const u8) !void {
        return slog.write(.warning, msg);
    }
    pub inline fn write_notice(slog: *Syslog, msg: []const u8) !void {
        return slog.write(.notice, msg);
    }
    pub inline fn write_info(slog: *Syslog, msg: []const u8) !void {
        return slog.write(.info, msg);
    }
    pub inline fn write_debug(slog: *Syslog, msg: []const u8) !void {
        return slog.write(.debug, msg);
    }

    pub inline fn print_emerg(slog: *Syslog, comptime fmt: []const u8, msg: anytype) !void {
        return slog.print(.emerg, fmt, msg);
    }
    pub inline fn print_alert(slog: *Syslog, comptime fmt: []const u8, msg: anytype) !void {
        return slog.print(.alert, fmt, msg);
    }
    pub inline fn print_crit(slog: *Syslog, comptime fmt: []const u8, msg: anytype) !void {
        return slog.print(.crit, fmt, msg);
    }
    pub inline fn print_err(slog: *Syslog, comptime fmt: []const u8, msg: anytype) !void {
        return slog.print(.err, fmt, msg);
    }
    pub inline fn print_warning(slog: *Syslog, comptime fmt: []const u8, msg: anytype) !void {
        return slog.print(.warning, fmt, msg);
    }
    pub inline fn print_notice(slog: *Syslog, comptime fmt: []const u8, msg: anytype) !void {
        return slog.print(.notice, fmt, msg);
    }
    pub inline fn print_info(slog: *Syslog, comptime fmt: []const u8, msg: anytype) !void {
        return slog.print(.info, fmt, msg);
    }
    pub inline fn print_debug(slog: *Syslog, comptime fmt: []const u8, msg: anytype) !void {
        return slog.print(.debug, fmt, msg);
    }

    pub fn write(slog: *Syslog, svr: Severity, msg: []const u8) !void {
        slog.mutex.lock();
        defer slog.mutex.unlock();

        if (!slog.ready) {
            return error.NotReady;
        }

        if (slog.filter != null) {
            if (@intFromEnum(svr) >= @intFromEnum(slog.filter.?)) {
                return;
            }
        }
        _ = try slog.*.sndr.send(try slog.*.frmtr.build(svr, msg));

        errdefer slog.ready = false;

        return;
    }

    pub fn print(slog: *Syslog, svr: Severity, comptime fmt: []const u8, msg: anytype) !void {
        slog.mutex.lock();
        defer slog.mutex.unlock();

        if (!slog.ready) {
            return error.NotReady;
        }

        if (slog.filter != null) {
            if (@intFromEnum(svr) >= @intFromEnum(slog.filter.?)) {
                return;
            }
        }

        _ = try slog.*.sndr.send(try slog.*.frmtr.format(svr, fmt, msg));

        errdefer slog.ready = false;

        return;
    }

    pub fn setfilter(slog: *Syslog, svr: ?Severity) void {
        slog.mutex.lock();
        defer slog.mutex.unlock();

        slog.filter = svr;

        return;
    }
};
