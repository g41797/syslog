//---------------------------------
const std           = @import("std");
const testing       = std.testing;
pub const network	= @import("./zig-network/network.zig");
//---------------------------------

//---------------------------------
pub const Protocol	= network.Protocol;
const Mutex     	= std.Thread.Mutex;
const Socket        = network.Socket;
//---------------------------------

const TransportError = error {
    NotConnectedYet,
    AlreadyConnected,
};

pub const TransportOpts = struct {
    allocator:  std.mem.Allocator   = null,

    proto:      Protocol            = .udp,

    // either ip or host
    addr: []const u8                = "127.0.0.1",

    port: u16                       = 514,
};


pub const Sender = struct {

    const Self = @This();

    mutex:  Mutex                   = .{},
    connected: bool                 = false,
    socket:Socket                   = undefined,

    pub fn connect(sndr: *Sender, opts: TransportOpts) !void {
        sndr.mutex.lock();
        defer sndr.mutex.unlock();

        if(sndr.connected) {return TransportError.AlreadyConnected;}

        try network.init();
        errdefer network.deinit();

        sndr.socket     = try network.connectToHost(opts.allocator, opts.addr, opts.port, opts.proto);
        sndr.connected  = true;

        return;
    }

    pub fn disconnect(sndr: *Sender) !void {
        sndr.mutex.lock();
        defer sndr.mutex.unlock();

        if(!sndr.connected) {return;}

        defer network.deinit();

        sndr.connected = false;
        sndr.socket.close();

        return;
    }

    pub fn send(sndr: *Sender, data: []const u8) !void {
        sndr.mutex.lock();
        defer sndr.mutex.unlock();

        if(!sndr.connected) {return TransportError.NotConnectedYet;}

        if(data.len == 0) {return;}

        var start: usize    = 0;

        while(start < data.len) {
            const block = data[start..];
            const done = try sndr.sock.send(block);
            start += done;
        }

        return;
    }
};

// test "Connect to an tcpbin.com ipv4" { // Just for testing that name may be also ip address
//
//     try network.init();
//     defer network.deinit();
//
//     // ping -4 tcpbin.com -c 10
//
//     const sock = try network.connectToHost(std.testing.allocator, "45.79.112.203", 4242, .tcp);
//     defer sock.close();
// }