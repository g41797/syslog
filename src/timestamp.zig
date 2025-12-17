//---------------------------------
const std = @import("std");
const string = @import("shortstring.zig");
const ShortString = string.ShortString;
pub const zig_dt = @import("zig-datetime");
pub const datetime = zig_dt.datetime;
pub const timezones = zig_dt.timezones;
//---------------------------------

// TIMESTAMP        = NILVALUE / FULL-DATE "T" FULL-TIME
pub const MAX_TIMESTAMP: u8 = 48;
pub const MiN_TIMESTAMP: u8 = 20;

pub const TimeStamp = ShortString(MAX_TIMESTAMP);

pub fn setNow(tstmp: *TimeStamp) !void {
    var buffer: [MAX_TIMESTAMP]u8 = undefined;

    var fbAllocator: std.heap.FixedBufferAllocator = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator: std.mem.Allocator = fbAllocator.allocator();

    var dt: datetime.Datetime = datetime.Datetime.now();

    const timeStamp: []const u8 = try dt.formatISO8601(allocator, false);

    defer allocator.free(timeStamp);

    _ = try tstmp.*.fillFrom(timeStamp);

    return;
}
