//---------------------------------
const std = @import("std");
const testing = std.testing;
const mailbox = @import("deps/mailbox/src/mailbox.zig");
const syslog = @import("syslog.zig");
const transport = @import("transport.zig");
const rfc = @import("rfc5424.zig");
const network = @import("deps/zig-network/network.zig");
//---------------------------------

const Thread = std.Thread;

const MsgBlock = struct {
    len: usize = undefined,
    buff: [rfc.MAX_BUFFER_LEN]u8 = undefined,
};

const Msgs = mailbox.MailBox(MsgBlock);

const sdport: u16 = 12345;

const Syslogd = struct {
    port: u16 = sdport,
    socket: network.Socket = undefined,
    msgs: Msgs = undefined,
    //allocator: std.mem.Allocator = std.testing.allocator,
    thread: Thread = undefined,
    ready: bool = false,

    fn start(sd: *Syslogd) !void {
        try network.init();
        errdefer network.deinit();

        sd.socket = try network.Socket.create(.ipv4, .udp);
        errdefer sd.socket.close();

        // Bind to 0.0.0.0:0
        const bindAddr = network.EndPoint{
            .address = network.Address{ .ipv4 = network.Address.IPv4.any },
            .port = sd.port,
        };

        try sd.socket.bind(bindAddr);
        sd.msgs = .{};
        sd.thread = std.Thread.spawn(.{}, run, .{sd}) catch unreachable;

        sd.ready = true;
        return;
    }

    fn run(sd: *Syslogd) void {
        while (true) {
            const envelope = sd.msgs.receive(100000000) catch break;

            envelope.letter.len = sd.socket.receive(&envelope.letter.buff) catch break;

            _ = sd.msgs.send(envelope) catch break;
        }
    }

    fn stop(sd: *Syslogd) void {
        if (!sd.ready) {
            return;
        }
        _ = sd.msgs.close();
        sd.socket.close();
        network.deinit();
    }

    fn waitFinish(sd: *Syslogd) void {
        sd.thread.join();
    }
};

test "init/deinit syslogd test" {
    var sd: Syslogd = .{};
    try sd.start();
    sd.stop();
    sd.waitFinish();
}

test "MailBox creation test" {
    const Mbx = mailbox.MailBox(u32);
    var mbox: Mbx = .{};
    try testing.expectError(error.Timeout, mbox.receive(10));
}
