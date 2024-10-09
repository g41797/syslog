![](_logo/syslogzig-removebg.png)

# Zig syslog client

[![CI](https://github.com/g41797/syslog/actions/workflows/ci.yml/badge.svg)](https://github.com/g41797/syslog/actions/workflows/ci.yml)[![Wiki](https://img.shields.io/badge/Wikipedia-%23000000.svg?style=for-the-badge&logo=wikipedia&logoColor=white)](https://en.wikipedia.org/wiki/Syslog)


  This is a [syslog](https://en.wikipedia.org/wiki/Syslog) client library for Zig. It supports:
- subset of [RFC5424](https://datatracker.ietf.org/doc/html/rfc5424)
- UDP
- TCP

  

  
  

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
   
| Value | Definition | Description                                            |
|:-----------:|  :---:           |:-------------------------------------------------------|
|   190     |    PRIVAL        | Priority                                               |
|   1     |    VERSION        | Always 1                                               |
|   2024-10-09T09:07:11+00:00     |    TIMESTAMP        | FULL-DATE "T" FULL-TIME                                |
|   BLKF     |    HOSTNAME        | Hostname or '-'                                        |
|   zigprocess     |    APP-NAME        | Application name provided by caller                    |
|   18548     |    PROCID        | Process ID or  '-'                                     |
|   1     |    MSGID        | Message ID - sequential number generated automatically |
|   -     |    STRUCTURED-DATA        | Always '-'                                             |
|   Hello, Zig!     |    MSG        | Message                                                |

    

     
     
       
    
![](_logo/CLion_icon.png)
