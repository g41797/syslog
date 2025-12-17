# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build Commands

```bash
# Build the library
zig build

# Run all tests
zig build test

# Run tests with reference trace (used in CI)
zig build test -freference-trace --summary all
```

## Architecture

This is a Zig syslog client library implementing a subset of RFC5424, supporting UDP and TCP protocols across Linux, macOS, and Windows.

### Core Components

- **syslog.zig** - Main `Syslog` struct that users interact with. Thread-safe via mutex. Provides `write_*` and `print_*` methods for each severity level, plus filtering capability.

- **rfc5424.zig** - `Formatter` that builds RFC5424-compliant messages. Format: `<PRIVAL>1 TIMESTAMP HOSTNAME APP-NAME PROCID MSGID - MSG`. Auto-grows buffer from 512 bytes up to 32KB.

- **transport.zig** - `Sender` wraps zig-network for UDP/TCP connectivity. Handles connection lifecycle and data transmission.

- **application.zig** - `Application` stores app metadata (name, facility, hostname, process ID). Hostname retrieved from environment on Windows/Linux, otherwise "-".

- **timestamp.zig** - RFC5424-compliant timestamp generation using zig-datetime.

- **shortstring.zig** - Fixed-capacity string type used for hostname (255 chars), app name (48 chars), and other bounded fields.

### Dependencies (in build.zig.zon)

- `zig-network` - TCP/UDP socket handling
- `zig-datetime` - Timestamp formatting
- `mailbox` - Used only in tests

### Entry Points

- **root.zig** - Public module exports (re-exports all submodules)
- **root_tests.zig** - Test entry point that imports all test declarations
