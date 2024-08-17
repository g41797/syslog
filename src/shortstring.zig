//---------------------------------
const std   = @import("std");
const mem   = std.mem;
const testing   = std.testing;
//---------------------------------

pub const StringError = error{
    TooLong,
};

pub fn ShortString(comptime length: u8) type {

    return struct {
        items: [length]u8   = undefined,
        len : usize         = length,
        string: ?[]u8       = null,

        const Self = @This();

        pub fn fillFrom(self: *Self, src: []const u8) StringError!usize {

            const currlen = src.len;
            const maxlen = self.*.items.len;

            if (currlen > maxlen) return StringError.TooLong;

            self.*.len = src.len;

            if(src.len > 0) {
                @memset(&self.*.items, 0);
                std.mem.copyForwards(u8, &self.*.items, src);
            }

            self.*.string = self.*.items[0..src.len];
            return src.len;
        }

        pub fn content(self: *Self) ?[]u8 {
            return self.*.string;
        }

    };
}

test "short string " {

    const maxLen:u8 = 16;
    const string16 = ShortString(maxLen);

    var   testStr: string16 = undefined;

    const longStr = "12345678901234567890";

    try testing.expectError(
        StringError.TooLong,
        testStr.fillFrom(longStr));

    const shortStr = "12345678";

    try testing.expectEqual(
        shortStr.len,
        testStr.fillFrom(shortStr));

    try testing.expect(std.mem.eql(u8, shortStr, testStr.content().?));
}
