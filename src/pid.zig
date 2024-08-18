//---------------------------------
const std   	        = @import("std");
const builtin           = @import("builtin");
const process           = std.process;
const windows           = std.os.windows;
const linux             = std.os.linux;
const posix             = std.posix;
const native_os         = builtin.os.tag;
pub const rfc5424       = @import("rfc5424.zig");
pub const shortstring   = @import("shortstring.zig");
const testing           = std.testing;
//---------------------------------

pub const PID = switch (native_os) {
    .windows    => windows.DWORD,   //u32
    . wasi      => unreachable,     //
    else        => posix.pid_t,     //i32
};

pub fn getPID() PID {
    switch (native_os) {
        .windows    => return windows.kernel32.GetCurrentProcessId(),
        . wasi      => unreachable,
        else        => return linux.getpid(),
    }
}

pub const ProcID    = shortstring.ShortString(rfc5424.MAX_PROCID);

pub fn storePID(prcid: *ProcID) !void {

    const currPID = getPID();

    switch (native_os) {
        . wasi      => unreachable,
        else        => {
                            prcid.*.string = try std.fmt.bufPrint(&prcid.*.items, "{d}", .{currPID});
                            prcid.*.len = prcid.*.string.?.len;
                            return;
                       },
    }
}

test "storePID test" {
    var currprocid: ProcID = undefined;

    _ = try storePID(&currprocid);
}
