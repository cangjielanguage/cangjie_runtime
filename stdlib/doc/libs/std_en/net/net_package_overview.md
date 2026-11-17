# std.net

## Features

The net package is used for network communication, providing functionalities such as starting a `Socket` server, connecting to a `Socket` server, sending data, receiving data, as well as related data structures for `IP` addresses, `IP` prefixes (also known as `IP` subnets), and `Socket` addresses.

We support three types of `Socket`: UDP/TCP/UDS, which users can choose according to their needs.

UDP (User Datagram Protocol) is a connectionless transport protocol that does not provide reliability or flow control but offers lower latency and reduced network overhead. The UDP protocol is primarily used in scenarios requiring high real-time performance, such as live video streaming and online gaming.

TCP (Transmission Control Protocol) is a connection-oriented, reliable transport protocol. It provides reliable data transmission, flow control, congestion control, error detection, and traffic management, making it one of the most commonly used transport protocols on the internet.

UDS (Unix Domain Socket) is a mechanism for inter-process communication on the same computer. Unlike network sockets, UDS does not require a network protocol stack or network devices, enabling faster communication with lower latency and higher throughput.

The following is the class inheritance hierarchy for `Socket` provided by this library:

```cangjie
Hierarchy
 Resource
 ├StreamingSocket
 │   ├TcpSocket
 │   └UnixSocket
 │
 ├DatagramSocket
 │   ├UdpSocket
 │   └UnixDatagramSocket
 │
 └ServerSocket
     ├TcpServerSocket
     └UnixServerSocket
```

## API List

### Interfaces

|              Interface Name          |           Functionality           |
| ----------------------------------- | --------------------------------- |
| [DatagramSocket](./net_package_api/net_package_interfaces.md#interface-datagramsocket) | `DatagramSocket` is a socket for receiving and reading datagrams. |
| [ServerSocket](./net_package_api/net_package_interfaces.md#interface-serversocket) | Provides the interface required for server-side `Socket`. |
| [StreamingSocket](./net_package_api/net_package_interfaces.md#interface-streamingsocket) | A `Socket` operating in full-duplex streaming mode, capable of being read from and written to. |

### Classes

|              Class Name          |           Functionality           |
| ----------------------------------- | --------------------------------- |
| [IPAddress](./net_package_api/net_package_classes.md#class-ipaddress) | This class represents an Internet Protocol (IP) address. |
| [IPPrefix](./net_package_api/net_package_classes.md#class-ipprefix) | This class represents an IP prefix (also known as an "IP subnet"), i.e., a contiguous block of IP addresses bounded by a power of two. |
| [IPSocketAddress](./net_package_api/net_package_classes.md#class-ipsocketaddress) | This class implements an IP protocol socket address (IP address + port number). |
| [IPv4Address](./net_package_api/net_package_classes.md#class-ipv4address) | This class represents an Internet Protocol version 4 (IPv4) address. |
| [IPv6Address](./net_package_api/net_package_classes.md#class-ipv6address) | This class represents an Internet Protocol version 6 (IPv6) address. |
| [RawSocket](./net_package_api/net_package_classes.md#class-rawsocket) | `RawSocket` provides basic socket functionalities. |
| [SocketAddress](./net_package_api/net_package_classes.md#class-socketaddress) | This class represents a protocol-independent socket address. |
| [TcpServerSocket](./net_package_api/net_package_classes.md#class-tcpserversocket) | A server that listens for TCP connections. |
| [TcpSocket](./net_package_api/net_package_classes.md#class-tcpsocket) | A client that requests TCP connections. |
| [UdpSocket](./net_package_api/net_package_classes.md#class-udpsocket) | Provides UDP datagram communication. |
| [UnixDatagramSocket](./net_package_api/net_package_classes.md#class-unixdatagramsocket) | Provides host communication capabilities based on datagrams. |
| [UnixServerSocket](./net_package_api/net_package_classes.md#class-unixserversocket) | Provides a server for full-duplex streaming-based host communication. |
| [UnixSocket](./net_package_api/net_package_classes.md#class-unixsocket) | Provides a client for full-duplex streaming-based host communication. |
| [UnixSocketAddress](./net_package_api/net_package_classes.md#class-unixsocketaddress) | This class implements a Unix Domain Socket address. |

### Enums

|              Enum Name          |           Functionality           |
| ----------------------------------- | --------------------------------- |
| [SocketNet](./net_package_api/net_package_enums.md#enum-socketnet) | Transport layer protocol types. |

### Structs

|              Struct Name          |           Functionality           |
| ----------------------------------- | --------------------------------- |
| [AddressFamily](./net_package_api/net_package_structs.md#struct-addressfamily) | The address family is used to identify individual network address schemes or numbering plans in contexts where the use of individual addresses may be ambiguous. |
| [OptionLevel](./net_package_api/net_package_structs.md#struct-optionlevel) | Provides commonly used socket option levels. |
| [OptionName](./net_package_api/net_package_structs.md#struct-optionname) | Provides commonly used socket options. |
| [ProtocolType](./net_package_api/net_package_structs.md#struct-protocoltype) | Provides commonly used socket protocols and the functionality to construct socket protocols by specifying an `Int32` value. |
| [RawAddress](./net_package_api/net_package_structs.md#struct-rawaddress) | Provides functionality for creating and retrieving communication addresses for `RawSocket`. |
| [SocketDomain](./net_package_api/net_package_structs.md#struct-socketdomain) | Provides commonly used socket communication domains and the functionality to construct socket communication domains by specifying an `Int32` value. |
| [SocketKeepAliveConfig](./net_package_api/net_package_structs.md#struct-socketkeepaliveconfig) | TCP KeepAlive property configuration. |
| [SocketOptions](./net_package_api/net_package_structs.md#struct-socketoptions) | `SocketOptions` stores some parameter constants for setting socket options for subsequent calls. |
| [SocketType](./net_package_api/net_package_structs.md#struct-sockettype) | Provides commonly used socket types and the functionality to construct socket types by specifying an `Int32` value. |

### Exception Classes

|              Exception Class Name          |           Functionality           |
| ----------------------------------- | --------------------------------- |
| [SocketException](./net_package_api/net_package_exceptions.md#class-socketexception) | Provides exception handling related to sockets. |
| [SocketTimeoutException](./net_package_api/net_package_exceptions.md#class-sockettimeoutexception) | Provides exception handling related to socket operation timeouts. |