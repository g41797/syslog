![](_logo/syslogzig-removebg.png)

# Zig syslog client

[![CI](https://github.com/g41797/syslog/actions/workflows/ci.yml/badge.svg)](https://github.com/g41797/syslog/actions/workflows/ci.yml)[![Wiki](https://img.shields.io/badge/Wikipedia-%23000000.svg?style=for-the-badge&logo=wikipedia&logoColor=white)](https://en.wikipedia.org/wiki/Syslog)


  This is a [syslog](https://en.wikipedia.org/wiki/Syslog) client library for Zig:

|           |                                                                    |
|-----------|:------------------------------------------------------------------:|
| Protocols |                              UDP, TCP                              |  
| RFC       | Subset of [RFC5424](https://datatracker.ietf.org/doc/html/rfc5424) |
| Tested on |       Mac, Windows, Linux                   |
  

## Hello, Zig!
     
When client code calls
```zig
    logger.write_info("Hello, Zig!");
```

[syslog client](src/syslog.zig) sends following text message to syslog receiver process:
>
> <190>1 2024-10-09T09:07:11+00:00 BLKF zigprocess 18548 1 - Hello, Zig!
> 
   
    
Let's see what this message consist of:
   
| Value | RFC Definition  | Description                                            |
|:-----------:|:---------------:|:-------------------------------------------------------|
|   190     |     PRIVAL      | [Priority](####priority)                               |
|   1     |     VERSION     | Always 1                                               |
|   2024-10-09T09:07:11+00:00     |    TIMESTAMP    | FULL-DATE "T" FULL-TIME                                |
|   BLKF     |    HOSTNAME     | Hostname or '-'                                        |
|   zigprocess     |    APP-NAME     | Application name provided by caller                    |
|   18548     |     PROCID      | Process ID or  '-'                                     |
|   1     |      MSGID      | Message ID - sequential number generated automatically |
|   -     | STRUCTURED-DATA | Always '-'                                             |
|   Hello, Zig!     |       MSG       | Message                                                |

   
     
#### Priority

>Priority = **Facility** * 8 + *Severity* 

**Facility** represents the machine process that created the Syslog event

| rfc5424.Facility      | Value | Description |
|:----------------------|  :---:           |          :--- |
| .kern                 | 0  |     kernel messages |
| .user                 | 1  |     random user-level messages |
| .mail                 | 2  |     mail system |
| .daemon               | 3  |     system daemons |
| .auth                 | 4  |     security/authorization messages |
| .syslog               | 5  |     messages generated internally by syslogd |
| .lpr                  | 6  |     line printer subsystem |
| .news                 | 7  |     network news subsystem |
| .uucp                 | 8  |     UUCP subsystem |
| .cron                 | 9  |     clock daemon |
| .authpriv             | 10 |     security/authorization messages (private) |
| .ftp                  | 11 |     ftp daemon |
| .local0               | 16 |     local use 0 |
| .local1               | 17 |     local use 1 |
| .local2               | 18 |     local use 2 |
| .local3               | 19 |     local use 3 |
| .local4               | 20 |     local use 4 |
| .local5               | 21 |     local use 5 |
| .local6               | 22 |     local use 6 |
| .local7               | 23 |     local use 7 |

Usually zig process will use [.local0-.local7] facilities 
(unless you are going to develop cron or ftp).
   
   

**Severity** describes the severity level of the syslog message in question.

| Level | rfc5424.Severity | Description |
| :---:          |:-----------------|          :--- |
|0| .emerg           |  system is unusable               |
|1| .alert           |  action must be taken immediately |
|2| .crit            |  critical conditions              |
|3| .err             |  error conditions                 |
|4| .warning         |  warning conditions               |
|5| .notice          |  normal but significant condition |
|6| .info            |  informational                    |
|7| .debug           |  debug-level messages             |


#### Quiz

What are *Facility* and *Severity* of **"Hello, Zig!"** message?

![](_logo/CLion_icon.png)
