//---------------------------------
const std               = @import("std");
const builtin           = @import("builtin");
const process           = std.process;
const windows           = std.os.windows;
const WINAPI            = windows.WINAPI;
const DWORD             = windows.DWORD;
const kernel32          = windows.kernel32; 
const linux             = std.os.linux;
const posix             = std.posix;
const native_os         = builtin.os.tag;
pub const rfc5424       = @import("rfc5424.zig");
pub const shortstring   = @import("shortstring.zig");
const testing           = std.testing;
//---------------------------------

pub extern "kernel32" fn GetCurrentProcessId() callconv(WINAPI) DWORD;

pub const PID = switch (native_os) {
    .windows    => windows.DWORD,   //u32
    .linux      => posix.pid_t,     //i32
    else        => unreachable,     //
};

pub fn getPID() PID {
    switch (native_os) {
        .windows    => return GetCurrentProcessId(),
        .linux      => return linux.getpid(),
        else        => unreachable
    }
}

// PROCID                   = NILVALUE / 1*128PRINTUSASCII

pub const MAX_PROCID: u8    = 128;

pub const ProcID            = shortstring.ShortString(MAX_PROCID);

pub fn storePID(prcid: *ProcID) !void {

    const currPID = getPID();

    switch (native_os) {
        .linux, .windows        => {
                            return prcid.bufPrint("{d}", .{currPID});
                       },
        else                    => unreachable
    }
}

test "storePID test" {
    var currprocid: ProcID = undefined;

    _ = try storePID(&currprocid);
}
