//---------------------------------
const std                   = @import("std");
const testing               = std.testing;
const Mutex                 = std.Thread.Mutex;
const Allocator             = std.mem.Allocator;

pub const rfc5424           = @import("rfc5424.zig");
pub const application       = @import("application.zig");
pub const transport         = @import("transport.zig");
//---------------------------------

//---------------------------------
pub const TransportOpts      = transport.TransportOpts;
pub const Protocol           = transport.Protocol;
pub const ApplicationOpts    = application.ApplicationOpts;
pub const Formatter          = rfc5424.Formatter;
pub const Severity           = rfc5424.Severity;     
pub const Sender             = transport.Sender;
//---------------------------------

pub const Syslog = struct {

    mutex: Mutex        = .{},
    frmtr: Formatter    = undefined,
    sndr:  Sender       = undefined,
    ready: bool         = false,
    filter: Severity    = .debug,

    pub fn init(appConf: ApplicationOpts, transpConf: TransportOpts) !Syslog {
        var gpa         = std.heap.GeneralPurposeAllocator(.{}){};
        const allocator = gpa.allocator();

        return .{
            .frmtr  = Formatter.init(allocator, appConf),
            .sndr   = Sender.connect(allocator, transpConf),
            .ready  = true,
        };
    }

    pub fn deinit(slog: *Syslog) void {
        slog.mutex.lock();
        defer slog.mutex.unlock();

        if(!slog.ready) {return;}

        slog.frmtr.deinit();
        slog.sndr.disconnect();
        slog.ready = false;

        return;
    }

    pub fn write(slog: *Syslog, svr: Severity, msg: []const u8) !void {
        slog.mutex.lock();
        defer slog.mutex.unlock();

        if(!slog.ready) {return error.NotReady;}

        if(@intFromEnum(svr) > @intFromEnum(slog.filter)) {return;}

        _ = try slog.*.sndr.send(try slog.*.frmtr.build(svr, msg));

        errdefer slog.ready = false;

        return;
    }

    pub fn print(slog: *Syslog, svr: Severity, comptime fmt: []const u8, msg: anytype) !void {
        slog.mutex.lock();
        defer slog.mutex.unlock();

        if(!slog.ready) {return error.NotReady;}

        if(@intFromEnum(svr) > @intFromEnum(slog.filter)) {return;}

        _ = try slog.*.sndr.send(try slog.*.frmtr.format(svr, fmt, msg));

        errdefer slog.ready = false;

        return;
    }

    pub fn setfilter(slog: *Syslog, svr: Severity) void {
        slog.mutex.lock();
        defer slog.mutex.unlock();

        slog.filter = svr;

        return;
    }
};
