//---------------------------------
const std           = @import("std");
const testing       = std.testing;
const string        = @import("shortstring.zig");
const pid        	= @import("pid.zig");
const timestamp     = @import("timestamp.zig");
const application   = @import("application.zig");
const ShortString   = string.ShortString;
//---------------------------------

//--------------------------------------------------------------------------------------
// Current implementation supports subset of RFC5424:
//  - MSGID, STRUCTURED-DATA = NILVALUE
//  - MSG = *%d00-255 ; not starting with BOM
//  - HOSTNAME = NILVALUE for non-windows-linux
//  - PID = NILVALUE for non-windows-linux
//--------------------------------------------------------------------------------------
// SYSLOG-MSG      = HEADER SP STRUCTURED-DATA [SP MSG]
//
// HEADER          = PRI VERSION SP TIMESTAMP SP HOSTNAME SP APP-NAME SP PROCID SP MSGID
// PRI             = "<" PRIVAL ">"
// PRIVAL          = 1*3DIGIT ; range 0 .. 191
// VERSION         = NONZERO-DIGIT 0*2DIGIT
// HOSTNAME        = NILVALUE / 1*255PRINTUSASCII
//
// APP-NAME        = NILVALUE / 1*48PRINTUSASCII
// PROCID          = NILVALUE / 1*128PRINTUSASCII
// MSGID           = NILVALUE
//
// TIMESTAMP       = NILVALUE / FULL-DATE "T" FULL-TIME
// FULL-DATE       = DATE-FULLYEAR "-" DATE-MONTH "-" DATE-MDAY
// DATE-FULLYEAR   = 4DIGIT
// DATE-MONTH      = 2DIGIT  ; 01-12
// DATE-MDAY       = 2DIGIT  ; 01-28, 01-29, 01-30, 01-31 based on
// ; month/year
// FULL-TIME       = PARTIAL-TIME TIME-OFFSET
// PARTIAL-TIME    = TIME-HOUR ":" TIME-MINUTE ":" TIME-SECOND
// [TIME-SECFRAC]
// TIME-HOUR       = 2DIGIT  ; 00-23
// TIME-MINUTE     = 2DIGIT  ; 00-59
// TIME-SECOND     = 2DIGIT  ; 00-59
// TIME-SECFRAC    = "." 1*6DIGIT
// TIME-OFFSET     = "Z" / TIME-NUMOFFSET
// TIME-NUMOFFSET  = ("+" / "-") TIME-HOUR ":" TIME-MINUTE
//
//
// STRUCTURED-DATA = NILVALUE
//
// MSG             = *OCTET ; not starting with BOM
// OCTET           = %d00-255
// SP              = %d32
// PRINTUSASCII    = %d33-126
// NONZERO-DIGIT   = %d49-57
// DIGIT           = %d48 / NONZERO-DIGIT
// NILVALUE        = "-"
//--------------------------------------------------------------------------------------


pub const NILVALUE: [] const u8 = " - ";

pub const SP: [] const u8       = " ";

pub const Severity = enum(u3) {
    emerg   = 0,
    alert   = 1,
    crit    = 2,
    err     = 3,
    warning = 4,
    notice  = 5,
    info    = 6,
    debug   = 7
};

pub const Facility = enum(u8) {
    kern        = (0<<3),
    user        = (1<<3),
    mail        = (2<<3),
    daemon      = (3<<3),
    auth        = (4<<3),
    syslog      = (5<<3),
    lpr         = (6<<3),
    news        = (7<<3),
    uucp        = (8<<3),
    cron        = (9<<3),
    authpriv    = (10<<3),
    ftp         = (11<<3),

    local0      = (16<<3),
    local1      = (17<<3),
    local2      = (18<<3),
    local3      = (19<<3),
    local4      = (20<<3),
    local5      = (21<<3),
    local6      = (22<<3),
    local7      = (23<<3)
};

pub inline fn priority(fcl: Facility, svr: Severity) u8 { return @intFromEnum(fcl) +  @intFromEnum(svr); }

pub const MIN_BUFFER_LEN : u16 = 2048;

pub const Formatter = struct {

    const Self = @This();

    appl: application.Application           = undefined,
    timestamp: timestamp.TimeStamp          = undefined,
    buffer: []u8                            = undefined,
    fbs: std.io.FixedBufferStream([]u8)     = undefined,

    pub fn init(frmtr: *Formatter, opts: application.ApplicationOpts, buffer: []u8) !void {

        if (buffer.len < MIN_BUFFER_LEN) {return error.NoSpaceLeft;}

        _               = try frmtr.appl.init(opts);
        frmtr.buffer    = buffer;
        frmtr.fbs       = std.io.fixedBufferStream(frmtr.buffer);

        return;
    }

    pub inline fn build(frmtr: *Formatter, svr: Severity, msg: []const u8) ![]const u8 {
        return frmtr.*.format(svr, "{s}",  .{msg});
    }

    pub fn format(frmtr: *Formatter, svr: Severity, comptime fmt: []const u8, msg: anytype) ![]const u8 {

        _ = try timestamp.setNow(&frmtr.*.timestamp);

        frmtr.*.fbs.reset();

        //---------------------------------------------------------------------------------------------
        // EXTHEADER    = <PRV>1 SP TIMESTAMP SP HOSTNAME SP APP-NAME SP PROCID SP NILVALUE SP NILVALUE
        // SYSLOG-MSG   = EXTHEADER [SP MSG]
        //-----------------------------------------------------------------------------------
        _ = try frmtr.*.fbs.writer().print(
                "<{0d:0^3}>1 {1s} {2s} {3s} {4s} <->  <-> ",
                .{
                    priority(frmtr.*.appl.fcl, svr),
                    frmtr.*.timestamp.content().?,
                    frmtr.*.appl.host_name.content().?,
                    frmtr.*.appl.app_name.content().?,
                    frmtr.*.appl.procid.content().?,
                });

        _ = try frmtr.*.fbs.writer().print(fmt, msg);

        return frmtr.*.fbs.getWritten();
    }

};

test "formatter test" {
    var buffer: [2048]u8 = undefined;

    var fmtr: Formatter = undefined;

    _           = try fmtr.init(.{}, &buffer);

    const out   = try fmtr.build(Severity.alert, "!!!SOS!!!");

    _ = try testing.expectEqual(true,  out.len > 0);
}