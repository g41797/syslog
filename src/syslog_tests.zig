//---------------------------------
const std = @import("std");
const testing = std.testing;
const mailbox = @import("mailbox");
const syslog = @import("syslog.zig");
const transport = @import("transport.zig");
const rfc = @import("rfc5424.zig");
const network = @import("network");
//---------------------------------

const Thread = std.Thread;
const Allocator = std.mem.Allocator;

const MsgBlock = struct {
    len: usize = undefined,
    buff: [rfc.MAX_BUFFER_LEN]u8 = undefined,
};

const Msgs = mailbox.MailBox(MsgBlock);

// real syslogd runs as root and has access to port 514
const sdport: u16 = 12345;

const Syslogd = struct {
    port: u16 = sdport,
    socket: network.Socket = undefined,
    msgs: Msgs = undefined,
    thread: Thread = undefined,
    ready: bool = false,
    loops: u16 = 0,

    fn start(sd: *Syslogd, loops: u16) !void {
        try network.init();
        errdefer network.deinit();

        sd.loops = loops;
        sd.socket = try network.Socket.create(.ipv4, .udp);
        errdefer sd.socket.close();
        _ = try sd.socket.enablePortReuse(true);

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
        defer {
            sd.socket.close();
            network.deinit();
        }

        for (0..sd.loops) |_| {
            const msg = std.testing.allocator.create(Msgs.Envelope) catch break;
            for (&msg.letter.buff) |*b| {
                b.* = 0xff;
            }
            errdefer std.testing.allocator.destroy(msg);

            msg.*.letter.len = sd.socket.receive(&msg.letter.buff) catch break;

            _ = sd.msgs.send(msg) catch break;
        }
    }

    fn stop(sd: *Syslogd) !void {
        if (!sd.ready) {
            return;
        }
        _ = sd.msgs.close();
    }

    fn waitFinish(sd: *Syslogd) void {
        sd.thread.join();
    }
};

test "init/deinit syslogd test" {
    var sd: Syslogd = .{};
    try sd.start(0);
    try sd.stop();
    sd.waitFinish();
}

test "Darwin: connection-mode socket was connected already" {
    const port: u16 = 12345;

    const Server = struct {
        const Self = @This();
        port: u16 = port,
        socket: network.Socket = undefined,
        thread: Thread = undefined,

        fn start(srv: *Self) !void {
            try network.init();
            errdefer network.deinit();

            srv.socket = try network.Socket.create(.ipv4, .udp);
            errdefer srv.socket.close();
            _ = try srv.socket.enablePortReuse(true);

            const bindAddr = network.EndPoint{
                .address = network.Address{ .ipv4 = network.Address.IPv4.any },
                .port = srv.port,
            };

            try srv.socket.bind(bindAddr);
            srv.thread = std.Thread.spawn(.{}, run, .{srv}) catch unreachable;
            return;
        }

        fn run(srv: *Self) void {
            defer {
                srv.socket.close();
                network.deinit();
            }
            var buff: [128]u8 = undefined;
            _ = srv.socket.receive(buff[0..]) catch return;
            return;
        }

        fn waitFinish(srv: *Self) void {
            srv.thread.join();
        }
    };

    var srv: Server = .{};
    try srv.start();
    defer srv.waitFinish();

    const addr: []const u8 = "127.0.0.1";

    try network.init();
    defer network.deinit();

    const sock = try network.connectToHost(std.testing.allocator, addr, port, .udp);
    defer sock.close();

    var buff: [128]u8 = undefined;
    _ = try sock.send(buff[0..]);

    return;
}

test "hellozig test" {
    try hellozig();
}

fn hellozig() !void {

    // Start Syslogd
    var sd: Syslogd = .{};
    try sd.start(1);
    defer {
        _ = sd.stop() catch unreachable;
        sd.waitFinish();
    }

    // Create logger
    var logger: syslog.Syslog = .{};
    try logger.init(std.testing.allocator, .{
        .port = sdport,
    });
    defer logger.deinit();

    logger.setfilter(.debug);

    // Send syslog message
    try logger.write_info("Hello, Zig!");

    const result = try sd.msgs.receive(10000000000);
    defer std.testing.allocator.destroy(result);
    const len = result.letter.len;
    std.debug.print("\n{s}\n", .{result.letter.buff[0..len]});

    // <190>1 2024-10-09T09:07:11+00:00 BLKF zigprocess 18548 1 - Hello, Zig!
    _ = std.mem.containsAtLeast(u8, result.letter.buff[0..len], 1, "Hello, Zig!");

    return;
}
