# TYPE_REFERENCE.md

This document lists all discovered types in the syslog codebase for refactoring reference.

## Standard Library Types

| Type | Description |
|------|-------------|
| `Allocator` | `std.mem.Allocator` |
| `Mutex` | `std.Thread.Mutex` |
| `Thread` | `std.Thread` |
| `std.io.FixedBufferStream([]u8)` | Fixed buffer stream for writing |
| `std.heap.FixedBufferAllocator` | Fixed buffer allocator |

## Transport Types (transport.zig)

| Type | Description |
|------|-------------|
| `Protocol` | `network.Protocol` - UDP/TCP protocol enum |
| `Socket` | `network.Socket` |
| `Sender` | Transport sender struct |
| `TransportOpts` | Transport configuration options |

## RFC5424 Types (rfc5424.zig)

| Type | Description |
|------|-------------|
| `Severity` | `enum(u3)` - emerg, alert, crit, err, warning, notice, info, debug |
| `Facility` | `enum(u8)` - kern, user, mail, daemon, auth, syslog, etc. |
| `Formatter` | RFC5424 message formatter struct |

## Application Types (application.zig)

| Type | Description |
|------|-------------|
| `Application` | Application metadata struct |
| `ApplicationOpts` | Application configuration options |
| `AppName` | `ShortString(48)` |
| `HostName` | `ShortString(255)` |

## PID Types (pid.zig)

| Type | Description |
|------|-------------|
| `PID` | Platform-specific PID type (DWORD on Windows, pid_t on Linux, u8 elsewhere) |
| `ProcID` | `ShortString(128)` |

## Timestamp Types (timestamp.zig)

| Type | Description |
|------|-------------|
| `TimeStamp` | `ShortString(48)` |

## ShortString Types (shortstring.zig)

| Type | Description |
|------|-------------|
| `ShortString(n)` | Generic fixed-capacity string type |

## Syslog Types (syslog.zig)

| Type | Description |
|------|-------------|
| `Syslog` | Main syslog struct (thread-safe) |
| `SyslogOpts` | Syslog configuration options |

## Test Types (syslog_tests.zig)

| Type | Description |
|------|-------------|
| `MsgBlock` | Message buffer struct for testing |
| `Msgs` | `mailbox.MailBox(MsgBlock)` |
| `Syslogd` | Test syslog daemon struct |

## Common Return Types

| Expression | Type |
|------------|------|
| `data[start..]` | `[]const u8` |
| `socket.send(block)` | `usize` |
| `socket.receive(&buffer)` | `usize` |
| `fbs.getWritten()` | `[]u8` |
| `fbs.writer()` | `std.io.FixedBufferStream([]u8).Writer` |
| `allocator.alloc(u8, len)` | `[]u8` |
| `frmtr.build(svr, msg)` | `[]const u8` |
| `frmtr.format(svr, fmt, msg)` | `[]const u8` |
| `b.standardTargetOptions(.{})` | `std.Build.ResolvedTarget` |
| `b.standardOptimizeOption(.{})` | `std.builtin.OptimizeMode` |
| `b.dependency(name, opts)` | `*std.Build.Dependency` |
| `b.addStaticLibrary(opts)` | `*std.Build.Step.Compile` |
| `b.addTest(opts)` | `*std.Build.Step.Compile` |
| `b.addRunArtifact(artifact)` | `*std.Build.Step.Run` |
| `b.step(name, desc)` | `*std.Build.Step` |
| `b.path(str)` | `std.Build.LazyPath` |
| `dep.module(name)` | `*std.Build.Module` |
| `std.mem.trimRight(u8, str, chars)` | `[]const u8` |
| `std.fmt.bufPrint(&buf, fmt, args)` | `[]u8` (or error) |
| `dt.formatISO8601(allocator, bool)` | `[]const u8` |
| `process.getEnvVarOwned(allocator, name)` | `[]u8` (or error) |
