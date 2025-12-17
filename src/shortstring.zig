const std = @import("std");

pub fn ShortString(comptime length: u8) type {
    return struct {
        items: [length]u8 = undefined,
        len: usize = length,
        string: ?[]u8 = null,

        const Self = @This();

        pub fn fillFrom(self: *Self, src: []const u8) error{NoSpaceLeft}!usize {
            const currlen: usize = src.len;
            const maxlen: usize = self.*.items.len;

            if (currlen > maxlen) return error.NoSpaceLeft;

            self.*.len = src.len;

            if (src.len > 0) {
                @memset(&self.*.items, ' ');
                std.mem.copyForwards(u8, &self.*.items, src);
            }

            self.*.string = self.*.items[0..src.len];
            self.*.trimRight();
            return self.*.string.?.len;
        }

        pub fn bufPrint(self: *Self, comptime fmt: []const u8, args: anytype) !void {
            self.*.string = try std.fmt.bufPrint(&self.*.items, fmt, args);
            self.*.len = self.*.string.?.len;
            self.*.trimRight();
            return;
        }

        pub fn content(self: *Self) ?[]const u8 {
            if (self.*.string == null) {
                return null;
            }

            if (self.*.string.?.len == 0) {
                return self.*.string;
            }

            self.*.trimRight();

            return self.*.string;
        }

        pub fn trimRight(self: *Self) void {
            if (self.*.string == null) {
                return;
            }
            if (self.*.string.?.len == 0) {
                return;
            }

            const trimed: []const u8 = std.mem.trimRight(u8, self.*.string.?, " \n\r\t");
            self.*.string = self.*.items[0..trimed.len];
            return;
        }
    };
}
