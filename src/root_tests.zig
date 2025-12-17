const std = @import("std");
const testing = std.testing;

pub const application = @import("application.zig");
pub const pid = @import("pid.zig");
pub const rfc5424 = @import("rfc5424.zig");
pub const shortstring = @import("shortstring.zig");
pub const syslog = @import("syslog.zig");
pub const timestamp = @import("timestamp.zig");
pub const transport = @import("transport.zig");
pub const syslog_tests = @import("syslog_tests.zig");

test {
    @import("std").testing.refAllDecls(@This());
}

test "application init" {
    _ = try application.Application.init(.{});
}

test "storePID test" {
    var currprocid: pid.ProcID = undefined;

    _ = try pid.storePID(&currprocid);
}

test "formatter test" {
    const small: []const u8 = "!!!SOS!!!";
    const big: []const u8 = "*" ** (rfc5424.MIN_BUFFER_LEN * 16);
    const huge: []const u8 = "*" ** rfc5424.MAX_BUFFER_LEN;

    var fmtr: rfc5424.Formatter = rfc5424.Formatter{};
    _ = try fmtr.init(std.testing.allocator, .{});
    defer fmtr.deinit();

    var log: []const u8 = try fmtr.build(.crit, small);
    try testing.expect(log.len > small.len);

    log = try fmtr.build(.info, big);
    try testing.expect(log.len > big.len);

    try testing.expectError(error.NoSpaceLeft, fmtr.build(.notice, huge));
}

test "short string " {
    const maxLen: u8 = 16;
    const string16: type = shortstring.ShortString(maxLen);

    var testStr: string16 = undefined;

    const longStr: []const u8 = "12345678901234567890";

    try testing.expectError(error.NoSpaceLeft, testStr.fillFrom(longStr));

    const shortStr: []const u8 = "12345678";

    try testing.expectEqual(shortStr.len, testStr.fillFrom(shortStr));

    try testing.expect(std.mem.eql(u8, shortStr, testStr.content().?));

    try testing.expectError(error.NoSpaceLeft, testStr.bufPrint("{s}-{s}-{s}", .{ shortStr, shortStr, shortStr }));
}

test "timestamp" {
    var tsmp: timestamp.TimeStamp = undefined;

    _ = try timestamp.setNow(&tsmp);

    try testing.expect(tsmp.len >= timestamp.MiN_TIMESTAMP);
}

// test "Connect to an tcpbin.com ipv4" { // Just for testing that name may be also ip address
//
//     try network.init();
//     defer network.deinit();
//
//     // ping -4 tcpbin.com -c 10
//
//     const sock = try network.connectToHost(std.testing.allocator, "45.79.112.203", 4242, .tcp);
//     defer sock.close();
// }
