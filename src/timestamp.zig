//---------------------------------
const std           = @import("std");
const mem           = std.mem;
const testing       = std.testing;
const string        = @import("shortstring.zig");
const pid        	= @import("pid.zig");
const ShortString   = string.ShortString;
const builtin       = @import("builtin");
const native_os     = builtin.os.tag;
const rfc5424   	= @import("rfc5424.zig");
pub const datetime      = @import("./zig-datetime/src/datetime.zig");
pub const timezones     = @import("./zig-datetime/src/timezones.zig");
//---------------------------------

// TIMESTAMP       = NILVALUE / FULL-DATE "T" FULL-TIME
pub const MAX_TIMESTAMP: u8 = 48;
pub const MiN_TIMESTAMP: u8 = 20;

const TimeStamp   = ShortString(MAX_TIMESTAMP);

pub fn setNow(tstmp: *TimeStamp) !void {

    var buffer: [MAX_TIMESTAMP]u8 = undefined;

    var   fbAllocator   = std.heap.FixedBufferAllocator.init(&buffer);
    const allocator     = fbAllocator.allocator();

    var dt = datetime.Datetime.now();

    const timeStamp      = try dt.formatISO8601(allocator, false);

    defer allocator.free(timeStamp);

    _ = try tstmp.fillFrom(timeStamp);

    return;
}

test "timestamp" {
    var timestamp: TimeStamp = undefined;

    _ = try setNow(&timestamp);

    try testing.expect(timestamp.len >= MiN_TIMESTAMP);
}
