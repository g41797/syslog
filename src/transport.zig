//---------------------------------
const std = @import("std");
pub const network = @import("network");
//---------------------------------

//---------------------------------
pub const Protocol = network.Protocol;
const Socket = network.Socket;
const Allocator = std.mem.Allocator;
//---------------------------------

const TransportError = error{
    NotConnectedYet,
    AlreadyConnected,
};

pub const DefaultProto = .udp;
pub const DefaultAddr = "127.0.0.1";
pub const DafaultPort = 514;

pub const TransportOpts = struct {
    proto: Protocol = DefaultProto,
    // either ip or host
    addr: []const u8 = DefaultAddr,
    port: u16 = DafaultPort,
};

pub const Sender = struct {
    connected: bool = false,
    socket: Socket = undefined,

    pub fn connect(allocator: Allocator, opts: TransportOpts) !Sender {
        try network.init();
        errdefer network.deinit();

        return .{
            .socket = try network.connectToHost(allocator, opts.addr, opts.port, opts.proto),
            .connected = true,
        };
    }

    pub fn disconnect(sndr: *Sender) void {
        if (!sndr.connected) {
            return;
        }

        defer network.deinit();

        sndr.connected = false;
        sndr.socket.close();

        return;
    }

    pub fn send(sndr: *Sender, data: []const u8) !void {
        if (!sndr.connected) {
            return TransportError.NotConnectedYet;
        }

        if (data.len == 0) {
            return;
        }

        var start: usize = 0;

        while (start < data.len) {
            const block = data[start..];
            const done = try sndr.socket.send(block);
            start += done;
        }

        return;
    }
};
