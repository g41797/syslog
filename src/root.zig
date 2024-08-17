//---------------------------------
const std       =  @import("std");
const testing       = std.testing;

pub const rfc5424       = @import("rfc5424.zig");
pub const shortstring       = @import("shortstring.zig");
//---------------------------------

test {
    @import("std").testing.refAllDecls(@This());
}