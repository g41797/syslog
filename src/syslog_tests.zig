//---------------------------------
const std = @import("std");
const testing = std.testing;
const mailbox = @import("deps/mailbox/src/mailbox.zig");
const syslog = @import("syslog.zig");
//---------------------------------

test "MailBox creation test" {
    const Mbx = mailbox.MailBox(u32);
    var mbox: Mbx = .{};
    try testing.expectError(error.Timeout, mbox.receive(10));
}
