//---------------------------------
const std           = @import("std");
const mem           = std.mem;
const testing       = std.testing;
const string        = @import("shortstring.zig");
const pid        	= @import("pid.zig");
const ShortString   = string.ShortString;
const builtin       = @import("builtin");
const native_os     = builtin.os.tag;
//---------------------------------

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
// MSGID           = NILVALUE / 1*32PRINTUSASCII
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
// STRUCTURED-DATA = NILVALUE / 1*SD-ELEMENT
// SD-ELEMENT      = "[" SD-ID *(SP SD-PARAM) "]"
// SD-PARAM        = PARAM-NAME "=" %d34 PARAM-VALUE %d34
// SD-ID           = SD-NAME
// PARAM-NAME      = SD-NAME
// PARAM-VALUE     = UTF-8-STRING ; characters '"', '\' and ; ']' MUST be escaped.
// SD-NAME         = 1*32PRINTUSASCII ; except '=', SP, ']', %d34 (")
//
// MSG             = MSG-ANY / MSG-UTF8
// MSG-ANY         = *OCTET ; not starting with BOM
// MSG-UTF8        = BOM UTF-8-STRING
// BOM             = %xEF.BB.BF
// UTF-8-STRING    = *OCTET ; UTF-8 string as specified
// ; in RFC 3629
//
// OCTET           = %d00-255
// SP              = %d32
// PRINTUSASCII    = %d33-126
// NONZERO-DIGIT   = %d49-57
// DIGIT           = %d48 / NONZERO-DIGIT
// NILVALUE        = "-"
//--------------------------------------------------------------------------------------


pub const MAX_MSGID: u8     = 32;
pub const MAX_TIMESTAMP: u8 = 48;

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

pub inline fn priority(fcl: Facility, svr: Severity) u8 { return fcl + svr; }

