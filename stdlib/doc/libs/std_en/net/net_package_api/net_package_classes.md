# Class

## class IPAddress

```cangjie
sealed abstract class IPAddress <: ToString & Equatable<IPAddress> & Hashable & BigEndianOrder<IPAddress>
```

Function: This class represents an Internet Protocol (IP) address. An Internet Protocol address (IP address) is a numerical label, such as *192.0.2.1* or *2001:0db8:0000:0000:0000:ff00:0042:8329*, assigned to devices connected to a computer network that uses the Internet Protocol for communication. IP addresses serve two main functions: network interface identification and location addressing.

Parent Types:

- [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring)
- [Equatable](../../core/core_package_api/core_package_interfaces.md#interface-equatablet)\<[IPAddress](#class-ipaddress)>
- [Hashable](../../core/core_package_api/core_package_interfaces.md#interface-hashable)
- [BigEndianOrder](../../binary/binary_package_api/binary_package_interfaces.md#interface-bigendianordert)\<[IPAddress](#class-ipaddress)>

### prop hostName

```cangjie
public prop hostName: ?String
```

Function: Returns the hostname corresponding to the current [IPAddress](net_package_classes.md#class-ipaddress) object, or None if resolution fails (currently unimplemented).

Exceptions:

- [UnsupportedException](../../core/core_package_api/core_package_exceptions.md#class-unsupportedexception) - Thrown if not a valid string.

Type: ?[String](../../core/core_package_api/core_package_structs.md#struct-string)

### prop size

```cangjie
public prop size: Int64
```

Function: Gets the byte length of the IP address object.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

### static func parse(String)

```cangjie
public static func parse(s: String): IPAddress
```

Function: Converts an IP protocol socket string to an [IPAddress](net_package_classes.md#class-ipaddress) object.

Parameters:

- s: [String](../../core/core_package_api/core_package_structs.md#struct-string) - IP protocol socket string.

Returns:

- [IPAddress](net_package_classes.md#class-ipaddress) - [IPAddress](net_package_classes.md#class-ipaddress) object.

Exceptions:

- [IllegalFormatException](../../core/core_package_api/core_package_exceptions.md#class-illegalformatexception) - Thrown if not a valid string.

Example:
<!-- run -->

```cangjie
import std.net.*
import std.unittest.*
import std.unittest.testmacro.*

main() {
    let v4: IPAddress = IPAddress.parse("192.168.1.2")
    let v6: IPAddress = IPAddress.parse("2001:0250:1006:dff0:4913:2aa5:8075:7c10")
    @Assert(v4.toString(), "192.168.1.2")
    @Assert(v6.toString(), "2001:250:1006:dff0:4913:2aa5:8075:7c10")
}
```

### static func readBigEndian(Array\<Byte>)

```cangjie
public static func readBigEndian(buffer: Array<Byte>): IPAddress
```

Function: Reads an [IPAddress](net_package_classes.md#class-ipaddress) object from a byte array in big-endian order.

Parameters:

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - Buffer containing the data to be read.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if the buffer is too small to read an [IPAddress](net_package_classes.md#class-ipaddress) value.

Returns:

- [IPAddress](net_package_classes.md#class-ipaddress) - [IPAddress](net_package_classes.md#class-ipaddress) object.

Example:
<!-- run -->

```cangjie
import std.net.*
import std.unittest.*
import std.unittest.testmacro.*

main() {
    let bufferV4: Array<Byte> = [0xC0, 0xA8, 0x1, 0x2]
    let bufferV6: Array<Byte> = [0x20, 0x01, 0x02, 0x50, 0x10, 0x06, 0xdf, 0xf0, 0x49, 0x13, 0x2a, 0xa5, 0x80, 0x75,
        0x7c, 0x10]
    let v4: IPAddress = IPAddress.readBigEndian(bufferV4)
    let v6: IPAddress = IPAddress.readBigEndian(bufferV6)
    @Assert(v4.toString(), "192.168.1.2")
    @Assert(v6.toString(), "2001:250:1006:dff0:4913:2aa5:8075:7c10")
}
```

### static func resolve(AddressFamily, String)

```cangjie
public static func resolve(family: AddressFamily, domain: String): Array<IPAddress>
```

Function: Resolves a domain name to obtain a list of [IPAddress](net_package_classes.md#class-ipaddress) objects.

> **Note:**
>
> - This API only parses literal IP addresses or resolves DNS names. It does not provide protection against DNS rebinding and does not filter loopback, private, link-local, unspecified, or multicast addresses.
> - When `domain` comes from an untrusted source, callers should validate the resolved addresses before opening a connection, for example by allowing only `isGlobalUnicast()` addresses, to reduce risks such as SSRF, internal network probing, or access to local services.

Parameters:

- family: [AddressFamily](net_package_structs.md#struct-addressfamily) - Address family.
- domain: [String](../../core/core_package_api/core_package_structs.md#struct-string) - Domain name.

Returns:

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[IPAddress](net_package_classes.md#class-ipaddress)> - [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[IPAddress](net_package_classes.md#class-ipaddress)> object.

Example:
<!-- run -->

```cangjie
import std.net.*

main() {
    let iplist: Array<IPAddress> = IPAddress.resolve(AddressFamily.UNSPEC, "localhost")
    println(iplist)
}
// may output: [127.0.0.1, ::1]
```

### static func resolve(String)

```cangjie
public static func resolve(domain: String): Array<IPAddress>
```

Function: Resolves a domain name to obtain a list of [IPAddress](net_package_classes.md#class-ipaddress) objects.

> **Note:**
>
> - This API only parses literal IP addresses or resolves DNS names. It does not provide protection against DNS rebinding and does not filter loopback, private, link-local, unspecified, or multicast addresses.
> - When `domain` comes from an untrusted source, callers should validate the resolved addresses before opening a connection, for example by allowing only `isGlobalUnicast()` addresses, to reduce risks such as SSRF, internal network probing, or access to local services.

Parameters:

- domain: [String](../../core/core_package_api/core_package_structs.md#struct-string) - Domain name.

Returns:

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[IPAddress](net_package_classes.md#class-ipaddress)> - [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[IPAddress](net_package_classes.md#class-ipaddress)> object.

Example:
<!-- run -->

```cangjie
import std.net.*

main() {
    let iplist: Array<IPAddress> = IPAddress.resolve("localhost")
    println(iplist)
}
// may output: [127.0.0.1, ::1]
```

### static func tryParse(String)

```cangjie
public static func tryParse(s: String): ?IPAddress
```

Function: Converts an IP address string to an [IPAddress](net_package_classes.md#class-ipaddress) object, returning `None` if the string is invalid.

Parameters:

- s: [String](../../core/core_package_api/core_package_structs.md#struct-string) - IP address string.

Returns:

- ?[IPAddress](net_package_classes.md#class-ipaddress) - ?[IPAddress](net_package_classes.md#class-ipaddress) object.

Example:
<!-- run -->

```cangjie
import std.net.*
import std.unittest.*
import std.unittest.testmacro.*

main() {
    let v4: ?IPAddress = IPAddress.tryParse("192.168.1.2")
    let v6: ?IPAddress = IPAddress.tryParse("2001:0250:1006:dff0:4913:2aa5:8075:7c10")
    @Assert(v4.toString(), "Some(192.168.1.2)")
    @Assert(v6.toString(), "Some(2001:250:1006:dff0:4913:2aa5:8075:7c10)")
}
```

### func getAddressBytes()

```cangjie
public func getAddressBytes(): Array<Byte>
```

Function: Returns the raw IP address of this [IPAddress](net_package_classes.md#class-ipaddress) object.

Returns:

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> representation of the raw IP address.

Example:
<!-- run -->

```cangjie
import std.net.*
import std.unittest.*
import std.unittest.testmacro.*

main() {
    let expectV4: Array<Byte> = [0xC0, 0xA8, 0x1, 0x2]
    let expectV6: Array<Byte> = [0x20, 0x01, 0x02, 0x50, 0x10, 0x06, 0xdf, 0xf0, 0x49, 0x13, 0x2a, 0xa5, 0x80, 0x75,
        0x7c, 0x10]
    let v4: IPAddress = IPAddress.parse("192.168.1.2")
    let v6: IPAddress = IPAddress.parse("2001:0250:1006:dff0:4913:2aa5:8075:7c10")
    @Assert(v4.getAddressBytes(), expectV4)
    @Assert(v6.getAddressBytes(), expectV6)
}
```

### func getPrefix(UInt8)

```cangjie
public open func getPrefix(prefixLen: UInt8): IPPrefix
```

Function: Creates a network prefix object from this [IPAddress](net_package_classes.md#class-ipaddress) object based on the specified network prefix length.

Parameters:

- prefixLen: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - Network prefix length.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if prefixLen is out of range.

Returns:

- [IPPrefix](net_package_classes.md#class-ipprefix) - Network prefix object.

Example:
<!-- run -->

```cangjie
import std.net.*
import std.unittest.*
import std.unittest.testmacro.*

main() {
    let prefix: IPPrefix = IPAddress.parse("192.168.1.2").getPrefix(24)
    @Assert(prefix.toString(), "192.168.1.2/24")
}
```

### func hashCode()

```cangjie
public func hashCode(): Int64
```

Function: Gets the `hashcode` value.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - `hashcode` value.

### func isGlobalUnicast()

```cangjie
public open func isGlobalUnicast(): Bool
```

Function: Determines whether this [IPAddress](net_package_classes.md#class-ipaddress) object is a global unicast address.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if it is a global unicast address, otherwise false.

Example:
<!-- run -->

```cangjie
import std.net.*
import std.unittest.*
import std.unittest.testmacro.*

main() {
    // 2000::/3
    @Assert(IPAddress.parse("2001:250:1006:dff0:4913:2aa5:8075:7c10").isGlobalUnicast(), true)
}
```

### func isIPv4()

```cangjie
public func isIPv4(): Bool
```

Function: Determines whether this [IPAddress](net_package_classes.md#class-ipaddress) object is an IPv4 address.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if it is an IPv4 address, otherwise false.

Example:
<!-- run -->

```cangjie
import std.net.*
import std.unittest.*
import std.unittest.testmacro.*

main() {
    @Assert(IPAddress.parse("192.168.1.2").isIPv4(), true)
}
```

### func isIPv6()

```cangjie
public func isIPv6(): Bool
```

Function: Determines whether this [IPAddress](net_package_classes.md#class-ipaddress) object is an IPv6 address.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if it is an IPv6 address, otherwise false.

Example:
<!-- run -->

```cangjie
import std.net.*
import std.unittest.*
import std.unittest.testmacro.*

main() {
    @Assert(IPAddress.parse("2001:250:1006:dff0:4913:2aa5:8075:7c10").isIPv6(), true)
}
```

### func isLinkLocal()

```cangjie
public open func isLinkLocal(): Bool
```

Function: Determines whether this [IPAddress](net_package_classes.md#class-ipaddress) object is a link-local address.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if it is a link-local address, otherwise false.

Example:
<!-- run -->

```cangjie
import std.net.*
import std.unittest.*
import std.unittest.testmacro.*

main() {
    // 169.254.0.0 ~ 169.254.255.255
    @Assert(IPAddress.parse("169.254.0.1").isLinkLocal(), true)
    // fe80::/10
    @Assert(IPAddress.parse("fe80::1").isLinkLocal(), true)
}
```

### func isLoopback()

```cangjie
public open func isLoopback(): Bool
```

Function: Determines whether this [IPAddress](net_package_classes.md#class-ipaddress) object is a loopback address.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if it is a loopback address, otherwise false.

Example:
<!-- run -->

```cangjie
import std.net.*
import std.unittest.*
import std.unittest.testmacro.*

main() {
    @Assert(IPAddress.parse("127.0.0.1").isLoopback(), true)
    @Assert(IPAddress.parse("::1").isLoopback(), true)
}
```

### func isMulticast()

```cangjie
public open func isMulticast(): Bool
```

Function: Determines whether this [IPAddress](net_package_classes.md#class-ipaddress) object is a multicast address.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if it is a multicast address, otherwise false.

### func isPrivate()

```cangjie
public open func isPrivate(): Bool
```

Function: Determines whether this [IPAddress](net_package_classes.md#class-ipaddress) object is a private address.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if it is a private address, otherwise false.

### func isUnspecified()

```cangjie
public open func isUnspecified(): Bool
```

Function: Determines whether this [IPAddress](net_package_classes.md#class-ipaddress) object is an "unspecified" IP address.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns true if it is an "unspecified" IP address, otherwise false.

Example:
<!-- run -->

```cangjie
import std.net.*
import std.unittest.*
import std.unittest.testmacro.*

main() {
    @Assert(IPAddress.parse("0.0.0.0").isUnspecified(), true)
    @Assert(IPAddress.parse("::").isUnspecified(), true)
}
```

### func writeBigEndian(Array\<Byte>)

```cangjie
public open func writeBigEndian(buffer: Array<Byte>): Int64
```

Function: Writes this [IPAddress](net_package_classes.md#class-ipaddress) object to a byte array in big-endian order.

Parameters:

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - Buffer for storing the data to be written.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if the buffer is too small to write an [IPv4Address](net_package_classes.md#class-ipv4address) or [IPv6Address](net_package_classes.md#class-ipv6address) value.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - Number of bytes written.

Example:
<!-- run -->

```cangjie
import std.net.*
import std.unittest.*
import std.unittest.testmacro.*

main() {
    let buffer = Array<Byte>(128, repeat: 0)
    let expectV4: Array<Byte> = [0xC0, 0xA8, 0x1, 0x2## class IPPrefix

```cangjie
sealed abstract class IPPrefix <: Equatable<IPPrefix> & Hashable & ToString
```

Function: This class represents an IP prefix, which is a contiguous block of IP addresses with boundaries that are powers of two (also known as an "IP subnet").

An IP prefix is specified by two pieces of information:

- Starting IP address (IPv4 or IPv6). This is the first IP address in the prefix.
- Prefix length. This specifies the length of the prefix by indicating the number of bits in the IP address, starting from the most significant bit in network byte order, that remain constant for all addresses in the prefix.

Parent Types:

- [Equatable](../../core/core_package_api/core_package_interfaces.md#interface-equatablet)\<[IPPrefix](#class-ipprefix)>
- [Hashable](../../core/core_package_api/core_package_interfaces.md#interface-hashable)
- [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring)

### prop address

```cangjie
public prop address: IPAddress
```

Function: Gets the [IPAddress](net_package_classes.md#class-ipaddress) used to construct the current [IPPrefix](net_package_classes.md#class-ipprefix) object.

Type: [IPAddress](net_package_classes.md#class-ipaddress)

### prop prefixLength

```cangjie
public prop prefixLength: UInt8
```

Function: Gets the prefix length.

Type: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8)

### static func parse(String)

```cangjie
public static func parse(s: String): IPPrefix
```

Function: Converts an IP protocol Socket string into an [IPPrefix](net_package_classes.md#class-ipprefix) object.

Parameters:

- s: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The IP protocol Socket string.

Exceptions:

- [IllegalFormatException](../../core/core_package_api/core_package_exceptions.md#class-illegalformatexception) - Throws an exception if the string is not valid.

Returns:

- [IPPrefix](net_package_classes.md#class-ipprefix) - The [IPPrefix](net_package_classes.md#class-ipprefix) object.

Example:
<!-- run -->

```cangjie
import std.net.*
import std.unittest.*
import std.unittest.testmacro.*

main() {
    let v4: IPPrefix = IPPrefix.parse("192.168.1.2/24")
    let v6: IPPrefix = IPPrefix.parse("2001:0250:1006:dff0:4913:2aa5:8075:7c10/32")
    @Assert(v4.toString(), "192.168.1.2/24")
    @Assert(v6.toString(), "2001:250:1006:dff0:4913:2aa5:8075:7c10/32")
}
```

### static func tryParse(String)

```cangjie
public static func tryParse(s: String): ?IPPrefix
```

Function: Converts an IP protocol Socket string into an [IPPrefix](net_package_classes.md#class-ipprefix) object. Returns `None` if the string is not valid.

Parameters:

- s: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The IP protocol Socket string.

Returns:

- ?[IPPrefix](net_package_classes.md#class-ipprefix) - The optional [IPPrefix](net_package_classes.md#class-ipprefix) object.

Example:
<!-- run -->
```cangjie
import std.net.*
import std.unittest.*
import std.unittest.testmacro.*

main() {
    let v4: ?IPPrefix = IPPrefix.tryParse("192.168.1.2/24")
    let v6: ?IPPrefix = IPPrefix.tryParse("2001:0250:1006:dff0:4913:2aa5:8075:7c10/32")
    @Assert(v4.toString(), "Some(192.168.1.2/24)")
    @Assert(v6.toString(), "Some(2001:250:1006:dff0:4913:2aa5:8075:7c10/32)")
}
```

### func broadcast()

```cangjie
public open func broadcast(): IPAddress
```

Function: Returns the broadcast address of this [IPPrefix](net_package_classes.md#class-ipprefix).

Returns:

- [IPAddress](net_package_classes.md#class-ipaddress) - The broadcast address of this [IPPrefix](net_package_classes.md#class-ipprefix).

### func contains(IPAddress)

```cangjie
public func contains(rhs: IPAddress): Bool
```

Function: Checks whether this [IPPrefix](net_package_classes.md#class-ipprefix) contains the specified [IPAddress](net_package_classes.md#class-ipaddress).

Parameters:

- rhs: [IPAddress](net_package_classes.md#class-ipaddress) - The specified [IPAddress](net_package_classes.md#class-ipaddress).

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the specified [IPAddress](net_package_classes.md#class-ipaddress) is contained, otherwise `false`.

### func contains(IPPrefix)

```cangjie
public func contains(rhs: IPPrefix): Bool
```

Function: Checks whether this [IPPrefix](net_package_classes.md#class-ipprefix) contains the specified [IPPrefix](net_package_classes.md#class-ipprefix).

Parameters:

- rhs: [IPPrefix](net_package_classes.md#class-ipprefix) - The specified [IPPrefix](net_package_classes.md#class-ipprefix).

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the specified [IPPrefix](net_package_classes.md#class-ipprefix) is contained, otherwise `false`.

### func hostmask()

```cangjie
public open func hostmask(): IPAddress
```

Function: Returns the hostmask address of this [IPPrefix](net_package_classes.md#class-ipprefix).

Returns:

- [IPAddress](net_package_classes.md#class-ipaddress) - The hostmask address of this [IPPrefix](net_package_classes.md#class-ipprefix).

### func masked()

```cangjie
public open func masked(): IPPrefix
```

Function: Returns the masked [IPPrefix](net_package_classes.md#class-ipprefix) based on the prefix length. For example, `192.168.12.34/16` returns `192.168.0.0/16`, and `fc00::1:2:3:4/16` returns `fc00::/16`.

Returns:

- [IPPrefix](net_package_classes.md#class-ipprefix) - The masked [IPPrefix](net_package_classes.md#class-ipprefix) based on the prefix length.

### func netmask()

```cangjie
public open func netmask(): IPAddress
```

Function: Returns the netmask address of this [IPPrefix](net_package_classes.md#class-ipprefix).

Returns:

- [IPAddress](net_package_classes.md#class-ipaddress) - The netmask address of this [IPPrefix](net_package_classes.md#class-ipprefix).

### func network()

```cangjie
public open func network(): IPAddress
```

Function: Returns the network address of this [IPPrefix](net_package_classes.md#class-ipprefix).

Returns:

- [IPAddress](net_package_classes.md#class-ipaddress) - The network address of this [IPPrefix](net_package_classes.md#class-ipprefix).

### func overlaps(IPPrefix)

```cangjie
public func overlaps(rhs: IPPrefix): Bool
```

Function: Checks whether this [IPPrefix](net_package_classes.md#class-ipprefix) overlaps with the specified [IPPrefix](net_package_classes.md#class-ipprefix).

Parameters:

- rhs: [IPPrefix](net_package_classes.md#class-ipprefix) - The specified [IPPrefix](net_package_classes.md#class-ipprefix).

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if there is an overlap, otherwise `false`.

### func toString()

```cangjie
public func toString(): String
```

Function: Returns the string representation of the current [IPPrefix](net_package_classes.md#class-ipprefix).

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - The string representation of the current [IPPrefix](net_package_classes.md#class-ipprefix), e.g., `192.168.0.0/16` or `fc00::/16`.

Example:
<!-- run -->

```cangjie
import std.net.*
import std.unittest.*
import std.unittest.testmacro.*

main() {
    let v4: IPPrefix = IPAddress.parse("192.168.1.2").getPrefix(24)
    let v6: IPPrefix = IPAddress.parse("2001:0250:1006:dff0:4913:2aa5:8075:7c10").getPrefix(32)
    @Assert(v4.toString(), "192.168.1.2/24")
    @Assert(v6.toString(), "2001:250:1006:dff0:4913:2aa5:8075:7c10/32")
}
```

### operator func ==(IPPrefix)

```cangjie
public operator func ==(rhs: IPPrefix): Bool
```

Function: Checks whether two [IPPrefix](net_package_classes.md#class-ipprefix) objects are equal.

Parameters:

- rhs: [IPPrefix](net_package_classes.md#class-ipprefix) - The [IPPrefix](net_package_classes.md#class-ipprefix) object to compare.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the objects are equal, otherwise `false`.

### operator func !=(IPPrefix)

```cangjie
public operator func !=(rhs: IPPrefix): Bool
```

Function: Checks whether two [IPPrefix](net_package_classes.md#class-ipprefix) objects are not equal.

Parameters:

- rhs: [IPPrefix](net_package_classes.md#class-ipprefix) - The [IPPrefix](net_package_classes.md#class-ipprefix) object to compare.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the objects are not equal, otherwise `false`.

## class IPSocketAddress

```cangjie
public class IPSocketAddress <: SocketAddress & Equatable<IPSocketAddress>{
    public init(address: Array<Byte>, port: UInt16)
    public init(address: String, port: UInt16)
    public init(address: IPAddress, port: UInt16)
}
```

Function: This class implements an IP protocol Socket address (IP address + port number). It provides an immutable object used for Socket binding, connection, or as a return value.

Parent Types:

- [SocketAddress](#class-socketaddress)
- [Equatable](../../core/core_package_api/core_package_interfaces.md#interface-equatablet)\<[IPSocketAddress](#class-ipsocketaddress)>

### prop address

```cangjie
public prop address: IPAddress
```

Function: Gets the IP address of the current [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) object.

Type: [IPAddress](net_package_classes.md#class-ipaddress)

### prop family

```cangjie
public prop family: AddressFamily
```

Function: Gets the address family of the current [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) object.

Type: [AddressFamily](net_package_structs.md#struct-addressfamily)

### prop port

```cangjie
public prop port: UInt16
```

Function: Gets the port of the current [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) object.

Type: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16)

### prop size

```cangjie
public prop size: Int64
```

Function: Gets the raw byte length of the current [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) object.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

### init(Array\<Byte>, UInt16)

```cangjie
public init(address: Array<Byte>, port: UInt16)
```

Function: Constructs an [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) from a big-endian [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> representing the IP address and a host-order [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) port.

Parameters:

- address: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - The big-endian IP address.
- port: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - The host-order port.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception if the address is invalid.

### init(String, UInt16)

```cangjie
public init(address: String, port: UInt16)
```

Function: Constructs an [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) from a string representing the IP address and a host-order [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) port.

Parameters:

- address: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The IP address string.
- port: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - The host-order port.

Exceptions:

- [IllegalFormatException](../../core/core_package_api/core_package_exceptions.md#class-illegalformatexception) - Throws an exception if the IP address is invalid.

### init(IPAddress, UInt16)

```cangjie
public init(address: IPAddress, port: UInt16)
```

Function: Constructs an [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) from an [IPAddress](net_package_classes.md#class-ipaddress) object and a host-order [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) port.

Parameters:

- address: [IPAddress](net_package_classes.md#class-ipaddress) - The [IPAddress](net_package_classes.md#class-ipaddress) object.
- port: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - The host-order port.

### static func parse(String)

```cangjie
public static func parse(s: String): IPSocketAddress
```

Function: Converts an IP protocol Socket string into an [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) object.

Parameters:

- s: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The IP protocol Socket string.

Returns:

- [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) - The [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) object.

Exceptions:

- [IllegalFormatException](../../core/core_package_api/core_package_exceptions.md#class-illegalformatexception) - The input must be a valid socket address, such as `192.168.0.0:80` or `[fc00::1]:8080`. Otherwise, an exception is thrown.

Example:
<!-- run -->

```cangjie
import std.net.*
import std.unittest.*
import std.unittest.testmacro.*

main() {
    let v4: IPSocketAddress = IPSocketAddress.parse("192.168.1.2:8080")
    let v6: IPSocketAddress = IPSocketAddress.parse("[2001:0250:1006:dff0:4913:2aa5:8075:7c10]:8080")
    @Assert(v4.address.toString(), "192.168.1.2")
    @Assert(v4.port, 8080u16)
    @Assert(v6.address.toString(), "2001:250:1006:dff0:4913:2aa5:8075:7c10")
    @Assert(v6.port, 8080u16)
    @Assert(v4.toString(), "192.168.1.2:8080")
    @Assert(v6.toString(), "[2001:250:1006:dff0:4913:2aa5:8075:7c10]:8080")
}
```

### static func tryParse(String)

```cangjie
public static func tryParse(s: String): ?IPSocketAddress
```

Function: Converts an IP protocol Socket string into an [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) object. Returns `None` if the string is not valid.

Parameters:

- s: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The IP protocol Socket string.

Returns:

- ?[IPSocketAddress](net_package_classes.md#class-ipsocketaddress) - The optional [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) object.

Example:
<!-- run -->

```cangjie
import std.net.*
import std.unittest.*
import std.unittest.testmacro.*

main() {
    let v4: ?IPSocketAddress = IPSocketAddress.tryParse("192.168.1.2:8080")
    let v6: ?## class IPv4Address

```cangjie
public class IPv4Address <: IPAddress & ToString & Equatable<IPv4Address> & LessOrEqual<IPv4Address> {
    public static let broadcast = IPv4Address(0xFF, 0xFF, 0xFF, 0xFF)
    public static let localhost = IPv4Address(0x7F, 0, 0, 0x01)
    public static let unspecified = IPv4Address(0, 0, 0, 0)
    public init(bits: UInt32)
    public init(a: Byte, b: Byte, c: Byte, d: Byte)
}
```

Function: This class represents an Internet Protocol version 4 (IPv4) address. Defined by [RFC 790](https://datatracker.ietf.org/doc/html/rfc790), [RFC 1918](https://datatracker.ietf.org/doc/html/rfc1918), and [RFC 2365](https://datatracker.ietf.org/doc/html/rfc2365).

Parent Types:

- [IPAddress](#class-ipaddress)
- [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring)
- [Equatable](../../core/core_package_api/core_package_interfaces.md#interface-equatablet)\<[IPv4Address](#class-ipv4address)>
- [LessOrEqual](../../core/core_package_api/core_package_interfaces.md#interface-lessorequalt)\<[IPv4Address](#class-ipv4address)>

### static let broadcast

```cangjie
public static let broadcast = IPv4Address(0xFF, 0xFF, 0xFF, 0xFF)
```

Function: Returns the broadcast address of [IPv4Address](net_package_classes.md#class-ipv4address): `255.255.255.255`.

Type: [IPv4Address](net_package_classes.md#class-ipv4address)

### static let localhost

```cangjie
public static let localhost = IPv4Address(0x7F, 0, 0, 0x01)
```

Function: Returns the `localhost` address of [IPv4Address](net_package_classes.md#class-ipv4address): `127.0.0.1`.

Type: [IPv4Address](net_package_classes.md#class-ipv4address)

### static let unspecified

```cangjie
public static let unspecified = IPv4Address(0, 0, 0, 0)
```

Function: Returns an unspecified [IPv4Address](net_package_classes.md#class-ipv4address) address: `0.0.0.0`, which corresponds to the constant `INADDR_ANY` in other languages.

Type: [IPv4Address](net_package_classes.md#class-ipv4address)

### init(UInt32)

```cangjie
public init(bits: UInt32)
```

Function: Constructs an [IPv4Address](net_package_classes.md#class-ipv4address) address from a native-endian [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) value.

Parameters:

- bits: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - Native-endian [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) value.

### init(Byte, Byte, Byte, Byte)

```cangjie
public init(a: Byte, b: Byte, c: Byte, d: Byte)
```

Function: Constructs an [IPv4Address](net_package_classes.md#class-ipv4address) address object from four 8-bit bytes, represented textually as `a.b.c.d`.

Parameters:

- a: [Byte](../../core/core_package_api/core_package_types.md#type-byte) - 8-bit byte.
- b: [Byte](../../core/core_package_api/core_package_types.md#type-byte) - 8-bit byte.
- c: [Byte](../../core/core_package_api/core_package_types.md#type-byte) - 8-bit byte.
- d: [Byte](../../core/core_package_api/core_package_types.md#type-byte) - 8-bit byte.

### static func readBigEndian(Array\<Byte>)

```cangjie
public static func readBigEndian(buffer: Array<Byte>): IPv4Address
```

Function: Reads an [IPv4Address](net_package_classes.md#class-ipv4address) object from a byte array in big-endian order.

Parameters:

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - Buffer containing the data to be read.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the buffer is too small to read an [IPv4Address](net_package_classes.md#class-ipv4address) value.

Returns:

- [IPv4Address](net_package_classes.md#class-ipv4address) - [IPv4Address](net_package_classes.md#class-ipv4address) object.

### func getPrefix(UInt8)

```cangjie
public func getPrefix(prefixLen: UInt8): IPPrefix
```

Function: Creates a network prefix object from this [IPv4Address](net_package_classes.md#class-ipv4address) address based on the specified network prefix length.

Parameters:

- prefixLen: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - Network prefix length, must be >= 0 and <= 32.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown if prefixLen is out of range.

Returns:

- [IPPrefix](net_package_classes.md#class-ipprefix) - Network prefix object.

### func isBroadcast()

```cangjie
public func isBroadcast(): Bool
```

Function: Determines whether this [IPv4Address](net_package_classes.md#class-ipv4address) object is a broadcast address.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if it is a broadcast address; otherwise, returns `false`.

### func isGlobalUnicast()

```cangjie
public func isGlobalUnicast(): Bool
```

Function: Determines whether this [IPv4Address](net_package_classes.md#class-ipv4address) object is a global unicast address.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if it is a global unicast address; otherwise, returns `false`.

### func isLinkLocal()

```cangjie
public func isLinkLocal(): Bool
```

Function: Determines whether this [IPv4Address](net_package_classes.md#class-ipv4address) object is a link-local address.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if it is a link-local address; otherwise, returns `false`.

### func isLoopback()

```cangjie
public func isLoopback(): Bool
```

Function: Determines whether this [IPv4Address](net_package_classes.md#class-ipv4address) object is a loopback address.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if it is a loopback address; otherwise, returns `false`.

### func isMulticast()

```cangjie
public func isMulticast(): Bool
```

Function: Determines whether this [IPv4Address](net_package_classes.md#class-ipv4address) object is a multicast address.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if it is a multicast address; otherwise, returns `false`.

## class IPv4Address

```cangjie
public class IPv4Address <: IPAddress & ToString & Equatable<IPv4Address> & LessOrEqual<IPv4Address> {
    public static let broadcast = IPv4Address(0xFF, 0xFF, 0xFF, 0xFF)
    public static let localhost = IPv4Address(0x7F, 0, 0, 0x01)
    public static let unspecified = IPv4Address(0, 0, 0, 0)
    public init(bits: UInt32)
    public init(a: Byte, b: Byte, c: Byte, d: Byte)
}
```

Function: This class represents an Internet Protocol version 4 (IPv4) address, as defined by [RFC 790](https://datatracker.ietf.org/doc/html/rfc790), [RFC 1918](https://datatracker.ietf.org/doc/html/rfc1918), and [RFC 2365](https://datatracker.ietf.org/doc/html/rfc2365).

Parent Types:

- [IPAddress](#class-ipaddress)
- [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring)
- [Equatable](../../core/core_package_api/core_package_interfaces.md#interface-equatablet)\<[IPv4Address](#class-ipv4address)>
- [LessOrEqual](../../core/core_package_api/core_package_interfaces.md#interface-lessorequalt)\<[IPv4Address](#class-ipv4address)>

### static let broadcast

```cangjie
public static let broadcast = IPv4Address(0xFF, 0xFF, 0xFF, 0xFF)
```

Function: Returns the broadcast address of [IPv4Address](net_package_classes.md#class-ipv4address): `255.255.255.255`.

Type: [IPv4Address](net_package_classes.md#class-ipv4address)

## class RawSocket

```cangjie
public class RawSocket {
    public init(domain: SocketDomain, `type`: SocketType, protocol: ProtocolType)
}
```

Function: [RawSocket](net_package_classes.md#class-rawsocket) provides basic socket functionality.

It allows access to sockets with specific combinations of communication domain, type, and protocol. The Socket package already supports common network protocols such as TCP and UDP, hence this type is suitable for other network programming requirements.

> **Note:**
>
> - Currently verified functionalities of [RawSocket](net_package_classes.md#class-rawsocket) include TCP, UDP, UDS, and ICMP protocol sockets. Other types may encounter unexpected issues.
> - Additionally, due to the open nature of the interface, using a combination of `connect` followed by `listen` may lead to unexpected problems in certain scenarios. Developers are advised to follow normal calling logic to avoid issues.

### prop localAddr <sup>(deprecated)</sup>

```cangjie
public prop localAddr: RawAddress
```

Function: Retrieves the local address of the current [RawSocket](net_package_classes.md#class-rawsocket) instance.

> **Note:**
>
> This property will be deprecated in future versions. Use [localAddress](#prop-localaddress) instead.

Type: [RawAddress](net_package_structs.md#struct-rawaddress)

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the current [RawSocket](net_package_classes.md#class-rawsocket) instance is already closed or the local address cannot be retrieved.

### prop localAddress

```cangjie
public prop localAddress: RawAddress
```

Function: Retrieves the local address of the current [RawSocket](net_package_classes.md#class-rawsocket) instance.

Type: [RawAddress](net_package_structs.md#struct-rawaddress)

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the current [RawSocket](net_package_classes.md#class-rawsocket) instance is already closed or the local address cannot be retrieved.

### prop readTimeout

```cangjie
public mut prop readTimeout: ?Duration
```

Function: Gets or sets the read timeout duration for the current [RawSocket](net_package_classes.md#class-rawsocket) instance.

Type: ?[Duration](../../core/core_package_api/core_package_structs.md#struct-duration)

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the current [RawSocket](net_package_classes.md#class-rawsocket) instance is already closed.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the read timeout duration is set to a negative value.

### prop remoteAddr <sup>(deprecated)</sup>

```cangjie
public prop remoteAddr: RawAddress
```

Function: Retrieves the peer address of the current [RawSocket](net_package_classes.md#class-rawsocket) instance.

> **Note:**
>
> This property will be deprecated in future versions. Use [remoteAddress](#prop-remoteaddress) instead.

Type: [RawAddress](net_package_structs.md#struct-rawaddress)

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the current [RawSocket](net_package_classes.md#class-rawsocket) instance is already closed or the peer address cannot be retrieved.

### prop remoteAddress

```cangjie
public prop remoteAddress: RawAddress
```

Function: Retrieves the peer address of the current [RawSocket](net_package_classes.md#class-rawsocket) instance.

Type: [RawAddress](net_package_structs.md#struct-rawaddress)

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the current [RawSocket](net_package_classes.md#class-rawsocket) instance is already closed or the peer address cannot be retrieved.

### prop writeTimeout

```cangjie
public mut prop writeTimeout: ?Duration
```

Function: Gets or sets the write timeout duration for the current [RawSocket](net_package_classes.md#class-rawsocket) instance.

Type: ?[Duration](../../core/core_package_api/core_package_structs.md#struct-duration)

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the current [RawSocket](net_package_classes.md#class-rawsocket) instance is already closed.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the write timeout duration is set to a negative value.

### init(SocketDomain, SocketType, ProtocolType)

```cangjie
public init(domain: SocketDomain, `type`: SocketType, protocol: ProtocolType)
```

Function: Creates a socket with a specific combination of communication domain, type, and protocol.

Parameters:

- domain: [SocketDomain](net_package_structs.md#struct-socketdomain) - The communication domain.
- \`type`: [SocketType](net_package_structs.md#struct-sockettype) - The socket type.
- protocol: [ProtocolType](net_package_structs.md#struct-protocoltype) - The protocol type.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the combination of domain, type, and protocol cannot create a socket.

### func accept(?Duration)

```cangjie
public func accept(timeout!: ?Duration = None): RawSocket
```

Function: Accepts the first connection request in the pending connection queue of the current listening [RawSocket](net_package_classes.md#class-rawsocket) instance and returns a new [RawSocket](net_package_classes.md#class-rawsocket) for communication.

Parameters:

- timeout!: ?[Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - The maximum time to wait for a connection request. The default value `None` means wait indefinitely.

Returns:

- [RawSocket](net_package_classes.md#class-rawsocket) - A new [RawSocket](net_package_classes.md#class-rawsocket) instance for communication.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the current [RawSocket](net_package_classes.md#class-rawsocket) instance is already closed or the acceptance fails.
- [SocketTimeoutException](net_package_exceptions.md#class-sockettimeoutexception) - Thrown when the waiting time exceeds the timeout.

### func bind(RawAddress)

```cangjie
public func bind(addr: RawAddress): Unit
```

Function: Binds the current [RawSocket](net_package_classes.md#class-rawsocket) instance to the specified socket address.

Parameters:

- addr: [RawAddress](net_package_structs.md#struct-rawaddress) - The socket address.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the current [RawSocket](net_package_classes.md#class-rawsocket) instance is already closed or the binding fails.

### func close()

```cangjie
public func close(): Unit
```

Function: Closes the current [RawSocket](net_package_classes.md#class-rawsocket) instance.

### func connect(RawAddress, ?Duration)

```cangjie
public func connect(addr: RawAddress, timeout!: ?Duration = None): Unit
```

Function: Sends a connection request to the target address.

Parameters:

- addr: [RawAddress](net_package_structs.md#struct-rawaddress) - The target address for the connection request.
- timeout!: ?[Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - The maximum time to wait for the connection to be accepted. The default value `None` means wait indefinitely.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the current [RawSocket](net_package_classes.md#class-rawsocket) instance is already closed or the connection fails.
- [SocketTimeoutException](net_package_exceptions.md#class-sockettimeoutexception) - Thrown when the waiting time exceeds the timeout.

### func getSocketOption(Int32, Int32, CPointer\<Byte>, CPointer\<Int32>)

```cangjie
public unsafe func getSocketOption(level: Int32, option: Int32, value: CPointer<Byte>, len: CPointer<Int32>): Unit
```

Function: Retrieves the value of a socket option.

Parameters:

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The socket option level.
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The socket option name.
- value: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - The socket option value.
- len: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[Int32](../../core/core_package_api/core_package_intrinsics.md#int32)> - The length of the socket option value.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the current [RawSocket](net_package_classes.md#class-rawsocket) instance is already closed or retrieving the socket option fails.

### func listen(Int32)

```cangjie
public func listen(backlog: Int32): Unit
```

Function: Listens on the address bound to the current [RawSocket](net_package_classes.md#class-rawsocket) instance.

Parameters:

- backlog: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The maximum length of the pending connection queue.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the current [RawSocket](net_package_classes.md#class-rawsocket) instance is already closed or listening fails.

### func receive(Array\<Byte>, Int32)

```cangjie
public func receive(buffer: Array<Byte>, flags: Int32): Int64
```

Function: Receives data sent from the connected peer.

Parameters:

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - The array to store received data.
- flags: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - Flags specifying function behavior.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The length of the data.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the current [RawSocket](net_package_classes.md#class-rawsocket) instance is already closed or data reception fails.
- [SocketTimeoutException](net_package_exceptions.md#class-sockettimeoutexception) - Thrown when the read timeout is exceeded.

### func receiveFrom(Array\<Byte>, Int32)

```cangjie
public func receiveFrom(buffer: Array<Byte>, flags: Int32): (RawAddress, Int64)
```

Function: Receives data from another [RawSocket](net_package_classes.md#class-rawsocket) instance.

Parameters:

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - The array to store received data.
- flags: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - Flags specifying function behavior.

Returns:

- ([RawAddress](net_package_structs.md#struct-rawaddress), [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)) - The source address of the data and its length.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the current [RawSocket](net_package_classes.md#class-rawsocket) instance is already closed or data reception fails.
- [SocketTimeoutException](net_package_exceptions.md#class-sockettimeoutexception) - Thrown when the read timeout is exceeded.

### func send(Array\<Byte>, Int32)

```cangjie
public func send(buffer: Array<Byte>, flags: Int32): Unit
```

Function: Sends data to the connected peer.

Parameters:

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - The data to send.
- flags: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - Flags specifying function behavior.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the current [RawSocket](net_package_classes.md#class-rawsocket) instance is already closed or data transmission fails.
- [SocketTimeoutException](net_package_exceptions.md#class-sockettimeoutexception) - Thrown when the write timeout is exceeded.

### func sendTo(RawAddress, Array\<Byte>, Int32)

```cangjie
public func sendTo(addr: RawAddress, buffer: Array<Byte>, flags: Int32): Unit
```

Function: Sends data to the target address. If the [RawSocket](net_package_classes.md#class-rawsocket) is of type `DATAGRAM`, the data packet size must not exceed 65507 bytes.

Parameters:

- addr: [RawAddress](net_package_structs.md#struct-rawaddress) - The target address for sending data.
- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - The data to send.
- flags: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - Flags specifying function behavior.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the current [RawSocket](net_package_classes.md#class-rawsocket) instance is already closed, data transmission fails, or `sendTo` is called after `connect` on macOS.
- [SocketTimeoutException](net_package_exceptions.md#class-sockettimeoutexception) - Thrown when the write timeout is exceeded.

### func setSocketOption(Int32, Int32, CPointer\<Byte>, Int32)

```cangjie
public unsafe func setSocketOption(level: Int32, option: Int32, value: CPointer<Byte>, len: Int32): Unit
```

Function: Sets a socket option.

Parameters:

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The socket option level.
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The socket option name.
- value: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - The socket option value.
- len: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The length of the socket option value.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the current [RawSocket](net_package_classes.md#class-rawsocket) instance is already closed or setting the socket option fails.

## class SocketAddress

```cangjie
sealed abstract class SocketAddress <: ToString & Equatable<SocketAddress> & Hashable
```

Function: This class represents a protocol-independent Socket address. It provides an immutable object used for socket binding, connection, or as a return value.

Parent Types:

- [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring)
- [Equatable](../../core/core_package_api/core_package_interfaces.md#interface-equatablet)\<[SocketAddress](#class-socketaddress)>
- [Hashable](../../core/core_package_api/core_package_interfaces.md#interface-hashable)

### prop size

```cangjie
public prop size: Int64
```

Function: The raw byte length of the current [SocketAddress](net_package_classes.md#class-socketaddress) object.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

### prop family

```cangjie
public prop family: AddressFamily
```

Function: The address family of the current [SocketAddress](net_package_classes.md#class-socketaddress) object.

Type: [AddressFamily](net_package_structs.md#struct-addressfamily)

### func getAddressBytes()

```cangjie
public func getAddressBytes(): Array<Byte>
```

Function: Returns the raw IP address of this [SocketAddress](net_package_classes.md#class-socketaddress) object.

Returns:

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - An [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> representation of the raw IP address.

### operator func ==(SocketAddress)

```cangjie
public operator func ==(rhs: SocketAddress): Bool
```

Function: Determines whether two [SocketAddress](net_package_classes.md#class-socketaddress) objects are equal.

Parameters:

- rhs: [SocketAddress](net_package_classes.md#class-socketaddress) - The [SocketAddress](net_package_classes.md#class-socketaddress) object to compare.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the two [SocketAddress](net_package_classes.md#class-socketaddress)

## class TcpServerSocket

```cangjie
public class TcpServerSocket <: ServerSocket {
    public init(bindAt!: SocketAddress)
    public init(bindAt!: UInt16)
}
```

Function: A server-side socket for listening to TCP connections.

After socket creation, properties can be configured through attributes and the `setSocketOptionXX` interface.
To start listening, call `bind()` to bind the socket to a local port. The `accept()` interface will accept TCP connections, blocking until a connection is established. If there are already connections in the queue, it may return immediately.
The socket must be explicitly closed via `close`.

Parent Types:

- [ServerSocket](net_package_interfaces.md#interface-serversocket)

### prop backlogSize

```cangjie
public mut prop backlogSize: Int64
```

Function: Sets and reads the `backlog` size.

Can only be called before invoking `bind`, otherwise an exception will be thrown.
Whether the variable takes effect depends on system behavior.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when called after `bind`.

### prop bindToDevice

```cangjie
public mut prop bindToDevice: ?String
```

Function: Sets and reads the bound network interface.

Type: ?[String](../../core/core_package_api/core_package_structs.md#struct-string)

### prop localAddress

```cangjie
public override prop localAddress: SocketAddress
```

Function: Reads the local address to which the `Socket` will be or has been bound.

Type: [SocketAddress](net_package_classes.md#class-socketaddress)

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the `Socket` has been closed.

### prop receiveBufferSize

```cangjie
public mut prop receiveBufferSize: Int64
```

Function: Sets and reads the `SO_RCVBUF` attribute.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when `size` is less than or equal to 0.
- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the `Socket` is closed.

### prop reuseAddress

```cangjie
public mut prop reuseAddress: Bool
```

Function: Sets and reads the `SO_REUSEADDR` attribute, default is `true`.

The behavior after the attribute takes effect depends on the system. Before use, refer to the system documentation for `SO_REUSEADDR/SOCK_REUSEADDR`.

Type: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool)

### prop reusePort

```cangjie
public mut prop reusePort: Bool
```

Function: Sets and reads the `SO_REUSEPORT` attribute.

Can only be modified before binding. On Windows, `SO_REUSEADDR` can be used instead; this attribute is not supported, and an exception will be thrown.
The default and post-configuration behavior depends on the system. Before use, refer to the system documentation for `SO_REUSEPORT`.
Enabling both `SO_REUSEADDR` and `SO_REUSEPORT` may cause unpredictable system errors. Users should configure values carefully.

Type: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool)

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown on Windows as this type is not supported.

### prop sendBufferSize

```cangjie
public mut prop sendBufferSize: Int64
```

Function: Sets and reads the `SO_SNDBUF` attribute.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when `size` is less than or equal to 0.
- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the `Socket` is closed.

### init(SocketAddress)

```cangjie
public init(bindAt!: SocketAddress)
```

Function: Creates a [TcpServerSocket](net_package_classes.md#class-tcpserversocket) instance, not yet bound, so clients cannot connect.

Parameters:

- bindAt!: [SocketAddress](net_package_classes.md#class-socketaddress) - Specifies the local binding address. A port number of 0 means binding to a random available local address.

### init(UInt16)

```cangjie
public init(bindAt!: UInt16)
```

Function: Creates a [TcpServerSocket](net_package_classes.md#class-tcpserversocket) instance, not yet bound, so clients cannot connect.

Parameters:

- bindAt!: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - Specifies the local binding port. 0 means binding to a random available local port.

### func accept()

```cangjie
public override func accept(): TcpSocket
```

Function: Listens for or accepts client connections. Blocks until a connection is established.

Returns:

- [TcpSocket](net_package_classes.md#class-tcpsocket) - The client socket.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when listening fails due to system reasons.

### func accept(?Duration)

```cangjie
public override func accept(timeout!: ?Duration): TcpSocket
```

Function: Listens for or accepts client connections.

Parameters:

- timeout!: ?[Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - Timeout duration.

Returns:

- [TcpSocket](net_package_classes.md#class-tcpsocket) - The client socket.

Exceptions:

- [SocketTimeoutException](net_package_exceptions.md#class-sockettimeoutexception) - Thrown when the connection times out.
- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when listening fails due to system reasons.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the timeout duration is less than 0.

### func bind()

```cangjie
public override func bind(): Unit
```

Function: If binding to a local port fails, the socket must be `close`d. Retrying is not supported.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when binding fails due to system reasons.

### func close()

```cangjie
public override func close(): Unit
```

Function: Closes the socket. This interface can be called multiple times.

### func getSocketOption(Int32, Int32, CPointer\<Unit>, CPointer\<UIntNative>)

```cangjie
public func getSocketOption(
    level: Int32,
    option: Int32,
    value: CPointer<Unit>,
    valueLength: CPointer<UIntNative>
): Unit
```

Function: Gets the specified socket option.

Parameters:

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - Level, e.g., `SOL_SOCKET`.
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - Option, e.g., `SO_KEEPALIVE`.
- value: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[Unit](../../core/core_package_api/core_package_intrinsics.md#unit)> - Option value.
- valueLength: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[UIntNative](../../core/core_package_api/core_package_intrinsics.md#uintnative)> - Option value length.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when `getsockopt` fails.

### func getSocketOptionBool(Int32, Int32)

```cangjie
public func getSocketOptionBool(
    level: Int32,
    option: Int32
): Bool
```

Function: Gets the specified socket option. Converted from [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative). `0 => false`, non-`0 => true`.

Parameters:

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - Level, e.g., `SOL_SOCKET`.
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - Option, e.g., `SO_KEEPALIVE`.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The specified socket option. Converted from [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative). `0 => false`, non-`0 => true`.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when `getsockopt` fails or the option size exceeds the threshold of [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative).

### func getSocketOptionIntNative(Int32, Int32)

```cangjie
public func getSocketOptionIntNative(
    level: Int32,
    option: Int32
): IntNative
```

Function: Gets the specified socket option.

Parameters:

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - Level, e.g., `SOL_SOCKET`.
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - Option, e.g., `SO_KEEPALIVE`.

Returns:

- [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) - The retrieved socket option value.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when `getsockopt` fails or the option size exceeds the threshold of [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative).

### func isClosed()

```cangjie
public override func isClosed(): Bool
```

Function: Checks if the socket is closed.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if closed, otherwise `false`.

### func setSocketOption(Int32, Int32, CPointer\<Unit>, UIntNative)

```cangjie
public func setSocketOption(
    level: Int32,
    option: Int32,
    value: CPointer<Unit>,
    valueLength: UIntNative
): Unit
```

Function: Sets the specified socket option.

Parameters:

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - Level, e.g., `SOL_SOCKET`.
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - Option, e.g., `SO_KEEPALIVE`.
- value: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[Unit](../../core/core_package_api/core_package_intrinsics.md#unit)> - Option value.
- valueLength: [UIntNative](../../core/core_package_api/core_package_intrinsics.md#uintnative) - Option value length.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when `setsockopt` fails.

### func setSocketOptionBool(Int32, Int32, Bool)

```cangjie
public func setSocketOptionBool(
    level: Int32,
    option: Int32,
    value: Bool
): Unit
```

Function: Sets the specified socket option.

Parameters:

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - Level, e.g., `SOL_SOCKET`.
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - Option, e.g., `SO_KEEPALIVE`.
- value: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Option value.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when `setsockopt` fails.

### func setSocketOptionIntNative(Int32, Int32, IntNative)

```cangjie
public func setSocketOptionIntNative(
    level: Int32,
    option: Int32,
    value: IntNative
): Unit
```

Function: Sets the specified socket option.

Parameters:

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - Level, e.g., `SOL_SOCKET`.
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - Option, e.g., `SO_KEEPALIVE`.
- value: [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) - Option value.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when `setsockopt` fails.

### func toString()

```cangjie
public override func toString(): String
```

Function: Returns the status information of the current [TcpServerSocket](net_package_classes.md#class-tcpserversocket).

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - A string containing the status information of the current [TcpServerSocket](net_package_classes.md#class-tcpserversocket).

## class TcpSocket

```cangjie
public class TcpSocket <: StreamingSocket & Equatable<TcpSocket> & Hashable {
    public init(address: String, port: UInt16)
    public init(address: SocketAddress)
    public init(address: SocketAddress, localAddress!: ?SocketAddress)
}
```

Function: A client for requesting TCP connections.

After the instance is created, the `connect` function can be used to establish a connection, and `close` must be explicitly called when finished.
This type inherits from [StreamingSocket](net_package_interfaces.md#interface-streamingsocket). Refer to the [StreamingSocket](net_package_interfaces.md#interface-streamingsocket) section for more information.

Parent Types:

- [StreamingSocket](net_package_interfaces.md#interface-streamingsocket)
- [Equatable](../../core/core_package_api/core_package_interfaces.md#interface-equatablet)\<[TcpSocket](#class-tcpsocket)>
- [Hashable](../../core/core_package_api/core_package_interfaces.md#interface-hashable)

### prop bindToDevice

```cangjie
public mut prop bindToDevice: ?String
```

Function: Sets and reads the bound network interface.

Type: ?[String](../../core/core_package_api/core_package_structs.md#struct-string)

### prop keepAlive

```cangjie
public mut prop keepAlive: ?SocketKeepAliveConfig
```

Function: Sets and reads the keep-alive attribute. `None` means keep-alive is disabled.

If not set by the user, the system default configuration will be used. Setting this configuration may be delayed or ignored by the system, depending on system capabilities.

Type: ?[SocketKeepAliveConfig](net_package_structs.md#struct-socketkeepaliveconfig)
```### prop linger

```cangjie
public mut prop linger: ?Duration
```

Function: Sets and reads the `SO_LINGER` attribute. The default value is system-dependent, and `None` indicates this option is disabled.

> **Note:**
>
> - If `SO_LINGER` is set to `Some(v)`, when the socket closes, if there are pending byte streams, we will wait for `v` duration before closing the connection. If the timeout is exceeded and the byte stream has not been sent, the connection will be abnormally terminated (closed via RST packet).
> - If `SO_LINGER` is set to `None`, when the socket closes, the connection will be immediately closed. If there are pending characters to send, the connection will be closed using FIN-ACK. If there are remaining characters to send, the connection will be closed using RST.

Type: ?[Duration](../../core/core_package_api/core_package_structs.md#struct-duration)

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the timeout duration is less than 0.

### prop localAddress

```cangjie
public override prop localAddress: SocketAddress
```

Function: Reads the local address to which the `Socket` is or will be bound.

Type: [SocketAddress](net_package_classes.md#class-socketaddress)

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the `Socket` is already closed or no local address is available (local address is not configured and the socket is not connected).

### prop noDelay

```cangjie
public mut prop noDelay: Bool
```

Function: Sets and reads the `TCP_NODELAY` attribute, defaulting to `true`.

This option disables the Nagle algorithm, forwarding all written bytes without delay. When set to `false`, the Nagle algorithm introduces a delay before sending packets.

Type: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool)

### prop quickAcknowledge

```cangjie
public mut prop quickAcknowledge: Bool
```

Function: Sets and reads the `TCP_QUICKACK` attribute, defaulting to `false`.

This option is similar to `noDelay` but only affects TCP ACK and the first response. Not supported on Windows and macOS systems.

Type: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool)

### prop readTimeout

```cangjie
public override mut prop readTimeout: ?Duration
```

Function: Sets and reads the read operation timeout duration.

If the set duration is too small, it will be set to the minimum clock cycle value; if too large, it will be set to the maximum timeout duration (2<sup>63</sup>-1 nanoseconds). The default value is `None`.

Type: ?[Duration](../../core/core_package_api/core_package_structs.md#struct-duration)

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the timeout duration is less than 0.

### prop receiveBufferSize

```cangjie
public mut prop receiveBufferSize: Int64
```

Function: Sets and reads the `SO_RCVBUF` attribute, providing a way to specify the receive buffer size. The effectiveness of this option depends on the system.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the `size` is less than or equal to 0.
- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the `Socket` is already closed.

### prop remoteAddress

```cangjie
public override prop remoteAddress: SocketAddress
```

Function: Reads the remote address to which the `Socket` is or will be connected.

Type: [SocketAddress](net_package_classes.md#class-socketaddress)

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the `Socket` is already closed.

### prop sendBufferSize

```cangjie
public mut prop sendBufferSize: Int64
```

Function: Sets and reads the `SO_SNDBUF` attribute, providing a way to specify the send buffer size. The effectiveness of this option depends on the system.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the `size` is less than or equal to 0.
- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the `Socket` is already closed.

### prop writeTimeout

```cangjie
public override mut prop writeTimeout: ?Duration
```

Function: Sets and reads the write operation timeout duration.

If the set duration is too small, it will be set to the minimum clock cycle value; if too large, it will be set to the maximum timeout duration (2<sup>63</sup>-1 nanoseconds). The default value is `None`.

Type: ?[Duration](../../core/core_package_api/core_package_structs.md#struct-duration)

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the timeout duration is less than 0.

### init(SocketAddress)

```cangjie
public init(address: SocketAddress)
```

Function: Creates an unconnected socket.

Parameters:

- address: [SocketAddress](net_package_classes.md#class-socketaddress) - The address to which the socket will connect.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the `address` parameter is invalid or the address is a zero address on Windows.

### init(SocketAddress, ?SocketAddress)

```cangjie
public init(address: SocketAddress, localAddress!: ?SocketAddress)
```

Function: Creates an unconnected socket and binds it to the specified local address. If the local address is `None`, a random address will be selected for binding.

This interface defaults `SO_REUSEADDR` to `true` when `localAddress` is not `None`, otherwise it may cause an "address already in use" error. To change this configuration, call `setSocketOptionBool([SocketOptions](net_package_structs.md#struct-socketoptions).SOL_SOCKET, [SocketOptions](net_package_structs.md#struct-socketoptions).SO_REUSEADDR, false)`. Additionally, both local and remote addresses must be IPv4.

Parameters:

- address: [SocketAddress](net_package_classes.md#class-socketaddress) - The address to which the socket will connect.
- localAddress!: ?[SocketAddress](net_package_classes.md#class-socketaddress) - The local address to bind.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the `address` parameter is invalid or the address is a zero address on Windows.

### init(String, UInt16)

```cangjie
public init(address: String, port: UInt16)
```

Function: Creates an unconnected socket.

Parameters:

- address: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The address to which the socket will connect.
- port: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - The port to which the socket will connect.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the `address` parameter is invalid or the address is a zero address on Windows.

### func close()

```cangjie
public func close(): Unit
```

Function: Closes the socket. All operations except `close/isClosed` are no longer allowed. This method can be called multiple times.

### func connect(?Duration)

```cangjie
public func connect(timeout!: ?Duration = None): Unit
```

Function: Connects to the remote socket. Automatically binds the local address, so no additional binding operation is required.

Parameters:

- timeout!: ?[Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - The connection timeout duration. `None` means no timeout, and the connection operation will not retry. If the server rejects the connection, it will return a connection failure. This operation includes the binding operation, so there is no need to call the `bind` method separately.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the remote address is invalid or the connection timeout is less than 0.
- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the connection cannot be established due to system reasons (e.g., socket is closed, no access permissions, system error, etc.). Retrying may succeed.
- [SocketTimeoutException](net_package_exceptions.md#class-sockettimeoutexception) - Thrown when the connection times out.

### func getSocketOption(Int32, Int32, CPointer\<Unit>, CPointer\<UIntNative>)

```cangjie
public func getSocketOption(
    level: Int32,
    option: Int32,
    value: CPointer<Unit>,
    valueLength: CPointer<UIntNative>
): Unit
```

Function: Reads the specified socket option.

Parameters:

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The level, e.g., `SOL_SOCKET`.
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The option, e.g., `SO_KEEPALIVE`.
- value: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[Unit](../../core/core_package_api/core_package_intrinsics.md#unit)> - The option value.
- valueLength: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[UIntNative](../../core/core_package_api/core_package_intrinsics.md#uintnative)> - The length of the option value.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when `getsockopt` fails.

### func getSocketOptionBool(Int32, Int32)

```cangjie
public func getSocketOptionBool(
    level: Int32,
    option: Int32
): Bool
```

Function: Reads the specified socket option. Converted from [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative). `0 => false`, non-zero => `true`.

Parameters:

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The level, e.g., `SOL_SOCKET`.
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The option, e.g., `SO_KEEPALIVE`.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The read option value.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when `getsockopt` fails or the option size exceeds the threshold of [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative).

### func getSocketOptionIntNative(Int32, Int32)

```cangjie
public func getSocketOptionIntNative(
    level: Int32,
    option: Int32
): IntNative
```

Function: Reads the specified socket option.

Parameters:

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The level, e.g., `SOL_SOCKET`.
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The option, e.g., `SO_KEEPALIVE`.

Returns:

- [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) - The option value.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when `getsockopt` fails or the option size exceeds the threshold of [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative).

### func hashCode()

```cangjie
public override func hashCode(): Int64
```

Function: Gets the hash value of the current [TcpSocket](net_package_classes.md#class-tcpsocket) instance.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The hash value of the [TcpSocket](net_package_classes.md#class-tcpsocket) instance.

### func isClosed()

```cangjie
public func isClosed(): Bool
```

Function: Determines whether the socket has been explicitly closed by calling `close`.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the socket has been explicitly closed by calling `close`; otherwise, returns `false`.

### func read(Array\<Byte>)

```cangjie
public override func read(buffer: Array<Byte>): Int64
```

Function: Reads a message. Timeout behavior is determined by `readTimeout`. See `readTimeout` for details.

> **Note:**
>
> - Due to differences in underlying system interfaces, the behavior of `read` and `write` methods varies when the connection is closed by the peer.
> - On Windows, if the peer closes the connection, calling `write` once will clear the buffer content. Subsequently calling `read` will throw a connection closed exception.
> - On Linux/macOS, if the peer closes the connection, calling `write` followed by `read` will still read the content from the buffer.

Parameters:

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - The buffer to store the read data.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The length of the read data. Returns `0` when the remote peer closed the stream or when the local socket is closed via `close`.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the `buffer` size is 0 or the read operation fails due to system reasons.

### func setSocketOption(Int32, Int32, CPointer\<Unit>, UIntNative)

```cangjie
public func setSocketOption(
    level: Int32,
    option: Int32,
    value: CPointer<Unit>,
    valueLength: UIntNative
): Unit
```

Function: Sets the specified socket option.

Parameters:

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The level, e.g., `SOL_SOCKET`.
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The option, e.g., `SO_KEEPALIVE`.
- value: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[Unit](../../core/core_package_api/core_package_intrinsics.md#unit)> - The option value.
- valueLength: [UIntNative](../../core/core_package_api/core_package_intrinsics.md#uintnative) - The length of the option value.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when `setsockopt` fails.

### func setSocketOptionBool(Int32, Int32, Bool)

```cangjie
public func setSocketOptionBool(
    level: Int32,
    option: Int32,
    value: Bool
): Unit
```

Function: Sets the specified socket option.

Parameters:

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The level, e.g., `SOL_SOCKET`.
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The option, e.g., `SO_KEEPALIVE`.
- value: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The option value.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when `setsockopt` fails.

### func setSocketOptionIntNative(Int32, Int32, IntNative)

```cangjie
public func setSocketOptionIntNative(
    level: Int32,
    option: Int32,
    value: IntNative
): Unit
```

Function: Sets the specified socket option.

Parameters:

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The level, e.g., `SOL_SOCKET`.
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The option, e.g., `SO_KEEPALIVE`.
- value: [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) - The option value.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when `setsockopt` fails.

### func toString()

```cangjie
public override func toString(): String
```

Function: Returns the status information of the current [TcpSocket](net_package_classes.md#class-tcpsocket).

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - A string containing the status information of the current [TcpSocket](net_package_classes.md#class-tcpsocket).

### func write(Array\<Byte>)

```cangjie
public override func write(payload: Array<Byte>): Unit
```

Function: Writes a message. Timeout behavior is determined by `writeTimeout`. See `writeTimeout` for details.

Parameters:

- payload: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - The buffer containing the data to write.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the `buffer` size## class UdpSocket

```cangjie
public class UdpSocket <: DatagramSocket {
    public init(bindAt!: SocketAddress)
    public init(bindAt!: UInt16)
}
```

Function: Provides UDP datagram communication.

After creating an instance of `UdpSocket`, the `bind()` method must be called to bind the socket, allowing it to receive datagrams without establishing a connection to a remote endpoint. `UdpSocket` can also establish connections via the `connect()/disconnect()` interfaces. The UDP protocol requires that transmitted datagrams do not exceed 64KB in size.
`UdpSocket` must be explicitly closed using `close()`. For more information, refer to [DatagramSocket](net_package_interfaces.md#interface-datagramsocket).

Parent Type:

- [DatagramSocket](net_package_interfaces.md#interface-datagramsocket)

### prop localAddress

```cangjie
public override prop localAddress: SocketAddress
```

Function: Reads the local address to which the `Socket` is or will be bound.

Type: [SocketAddress](net_package_classes.md#class-socketaddress)

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the `Socket` is already closed or no local address is available (local address is unconfigured and the socket is not connected).

### prop receiveBufferSize

```cangjie
public mut prop receiveBufferSize: Int64
```

Function: Sets and reads the `SO_RCVBUF` property.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when `size` is less than or equal to 0.
- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the `Socket` is closed.

### prop receiveTimeout

```cangjie
public override mut prop receiveTimeout: ?Duration
```

Function: Sets and reads the timeout for `receive/receiveFrom` operations.

If the set timeout is too small, it will be adjusted to the minimum clock cycle value; if too large, it will be set to the maximum timeout (2<sup>63</sup>-1 nanoseconds). The default value is `None`.

Type: ?[Duration](../../core/core_package_api/core_package_structs.md#struct-duration)

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the timeout is less than 0.

### prop remoteAddress

```cangjie
public override prop remoteAddress: ?SocketAddress
```

Function: Reads the remote address to which the `Socket` is connected. Returns `None` if the `Socket` is not connected.

Type: ?[SocketAddress](net_package_classes.md#class-socketaddress)

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the `Socket` is already closed.

### prop reuseAddress

```cangjie
public mut prop reuseAddress: Bool
```

Function: Sets and reads the `SO_REUSEADDR` property.

The default behavior and post-configuration effects depend on the system. Before use, consult the system-specific documentation for `SO_REUSEADDR/SOCK_REUSEADDR`.

Type: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool)

### prop reusePort

```cangjie
public mut prop reusePort: Bool
```

Function: Sets and reads the `SO_REUSEPORT` property.

On Windows, `SO_REUSEADDR` can be used, but `SO_REUSEPORT` is not supported, so an exception will be thrown.
The default behavior and post-configuration effects depend on the system. Before use, consult the system-specific documentation for `SO_REUSEPORT`.

Type: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool)

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown on Windows as this property is unsupported.

### prop sendBufferSize

```cangjie
public mut prop sendBufferSize: Int64
```

Function: Sets and reads the `SO_SNDBUF` property.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when `size` is less than or equal to 0.
- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the `Socket` is closed.

### prop sendTimeout

```cangjie
public override mut prop sendTimeout: ?Duration
```

Function: Sets and reads the timeout for `send/sendTo` operations.

If the set timeout is too small, it will be adjusted to the minimum clock cycle value; if too large, it will be set to the maximum timeout (2<sup>63</sup>-1 nanoseconds). The default value is `None`.

Type: ?[Duration](../../core/core_package_api/core_package_structs.md#struct-duration)

### init(SocketAddress)

```cangjie
public init(bindAt!: SocketAddress)
```

Function: Creates an unbound `UdpSocket` instance.

Parameters:

- bindAt!: [SocketAddress](net_package_classes.md#class-socketaddress) - The address and port to bind.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the timeout is less than 0.

### init(UInt16)

```cangjie
public init(bindAt!: UInt16)
```

Function: Creates an unbound `UdpSocket` instance.

Parameters:

- bindAt!: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - The port to bind.

### func bind()

```cangjie
public func bind(): Unit
```

Function: If binding to the local port fails, the socket must be `close`d. Retries are not supported.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when binding fails due to system reasons.

### func close()

```cangjie
public override func close(): Unit
```

Function: Closes the socket. All operations except `close/isClosed` are no longer allowed. This method can be called multiple times.

### func connect(SocketAddress)

```cangjie
public func connect(remote: SocketAddress): Unit
```

Function: Connects to a specific remote address. The configuration can be undone via `disconnect`.

Only datagrams from this remote address will be accepted. Must be called after `bind`. After this operation, the port will start receiving ICMP messages. If an abnormal message is received, `send/sendTo` may fail.

Parameters:

- remote: [SocketAddress](net_package_classes.md#class-socketaddress) - The remote address.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the remote address is invalid.
- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the port is unbound, the connection cannot be established due to system reasons, or the remote address is a zero address on Windows.

### func disconnect()

```cangjie
public func disconnect(): Unit
```

Function: Stops the connection. Cancels receiving datagrams only from the specified peer. Can be called before `connect` and can be called multiple times.

### func getSocketOption(Int32, Int32, CPointer\<Unit>, CPointer\<UIntNative>)

```cangjie
public func getSocketOption(
    level: Int32,
    option: Int32,
    value: CPointer<Unit>,
    valueLength: CPointer<UIntNative>
): Unit
```

Function: Retrieves the specified socket option.

Parameters:

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The level, e.g., `SOL_SOCKET`.
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The option, e.g., `SO_KEEPALIVE`.
- value: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[Unit](../../core/core_package_api/core_package_intrinsics.md#unit)> - The option value.
- valueLength: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[UIntNative](../../core/core_package_api/core_package_intrinsics.md#uintnative)> - The length of the option value.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when `getsockopt` fails.

### func getSocketOptionBool(Int32, Int32)

```cangjie
public func getSocketOptionBool(
    level: Int32,
    option: Int32
): Bool
```

Function: Retrieves the specified socket option. Converted from [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative). `0 => false`, non-`0 => true`.

Parameters:

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The level, e.g., `SOL_SOCKET`.
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The option, e.g., `SO_KEEPALIVE`.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The specified socket option. Converted from [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative). `0 => false`, non-`0 => true`.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when `getsockopt` fails or the option size exceeds the threshold of [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative).

### func getSocketOptionIntNative(Int32, Int32)

```cangjie
public func getSocketOptionIntNative(
    level: Int32,
    option: Int32
): IntNative
```

Function: Retrieves the specified socket option.

Parameters:

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The level, e.g., `SOL_SOCKET`.
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The option, e.g., `SO_KEEPALIVE`.

Returns:

- [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) - The value of the specified socket option.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when `getsockopt` fails or the option size exceeds the threshold of [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative).

### func isClosed()

```cangjie
public override func isClosed(): Bool
```

Function: Determines whether the socket has been explicitly closed via `close`.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the socket has been explicitly closed via `close`; otherwise, returns `false`.

### func receive(Array\<Byte>)

```cangjie
public func receive(buffer: Array<Byte>): Int64
```

Function: Receives datagrams from the address connected via `connect`.

Parameters:

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - The buffer to store received datagrams.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The size of the received datagram.

### func receiveFrom(Array\<Byte>)

```cangjie
public override func receiveFrom(buffer: Array<Byte>): (SocketAddress, Int64)
```

Function: Receives datagrams.

Parameters:

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - The buffer to store received datagrams.

Returns:

- ([SocketAddress](net_package_classes.md#class-socketaddress), [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)) - The sender's address of the received datagram and the actual size of the received datagram, which may be 0 or larger than the size of the `buffer` parameter.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the local buffer is too small to read the datagram.
- [SocketTimeoutException](net_package_exceptions.md#class-sockettimeoutexception) - Thrown when the read operation times out.

### func send(Array\<Byte>)

```cangjie
public func send(payload: Array<Byte>): Unit
```

Function: Sends datagrams to the address connected via `connect`.

Parameters:

- payload: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - The content of the datagram to send.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the size of `payload` exceeds system limits or the system fails to send (e.g., when `connect` is called and an abnormal ICMP message is received).

### func sendTo(SocketAddress, Array\<Byte>)

```cangjie
public override func sendTo(recipient: SocketAddress, payload: Array<Byte>): Unit
```

Function: Sends datagrams. May block if insufficient buffer space is available.

Parameters:

- recipient: [SocketAddress](net_package_classes.md#class-socketaddress) - The recipient's address.
- payload: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - The content of the datagram to send.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the size of `payload` exceeds system limits, the system fails to send (e.g., when `connect` is called and an abnormal ICMP message is received), the remote address is a zero address on Windows, or `sendTo` is called after `connect` on macOS.

### func setSocketOption(Int32, Int32, CPointer\<Unit>, UIntNative)

```cangjie
public func setSocketOption(
    level: Int32,
    option: Int32,
    value: CPointer<Unit>,
    valueLength: UIntNative
): Unit
```

Function: Sets the specified socket option.

Parameters:

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The level, e.g., `SOL_SOCKET`.
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The option, e.g., `SO_KEEPALIVE`.
- value: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[Unit](../../core/core_package_api/core_package_intrinsics.md#unit)> - The option value.
- valueLength: [UIntNative](../../core/core_package_api/core_package_intrinsics.md#uintnative) - The length of the option value.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when `setsockopt` fails.

### func setSocketOptionBool(Int32, Int32, Bool)

```cangjie
public func setSocketOptionBool(
    level: Int32,
    option: Int32,
    value: Bool
): Unit
```

Function: Sets the specified socket option.

Parameters:

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The level, e.g., `SOL_SOCKET`.
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The option, e.g., `SO_KEEPALIVE`.
- value: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The option value.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when `setsockopt` fails.

### func setSocketOptionIntNative(Int32, Int32, IntNative)

```cangjie
public func setSocketOptionIntNative(
    level: Int32,
    option: Int32,
    value: IntNative
): Unit
```

Function: Sets the specified socket option.

Parameters:

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The level, e.g., `SOL_SOCKET`.
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The option, e.g., `SO_KEEPALIVE`.
- value: [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) - The option value.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when `setsockopt` fails.

### func toString()

```cangjie
public override func toString(): String
```

Function: Returns the status information of the current [UdpSocket](net_package_classes.md#class-udpsocket).

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - A string containing the status information of the current [UdpSocket](net_package_classes.md#class-udpsocket).## class UnixDatagramSocket

```cangjie
public class UnixDatagramSocket <: DatagramSocket {
    public init(bindAt!: SocketAddress)
    public init(bindAt!: String)
}
```

Function: Provides host communication capabilities based on datagrams.

After a [UnixDatagramSocket](net_package_classes.md#class-unixdatagramsocket) instance is created, the `bind()` interface should be explicitly called for binding. `Unix` datagram sockets do not require connection or multiple handshakes with remote endpoints. However, users can also establish and terminate connections with remote endpoints using the `connect/disconnect` interface.
Unlike UDP, UDS has no packet size limitation, with restrictions coming from the operating system and interface implementation.
Socket resources need to be explicitly released using the `close` interface. Refer to [DatagramSocket](net_package_interfaces.md#interface-datagramsocket) for more information.

> **Note:**
>
> This type is not supported on Windows platforms.

Parent Type:

- [DatagramSocket](net_package_interfaces.md#interface-datagramsocket)

### prop localAddress

```cangjie
public override prop localAddress: SocketAddress
```

Function: Reads the local address to which the `socket` will or has been bound.

Type: [SocketAddress](net_package_classes.md#class-socketaddress)

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the `socket` is already closed.

### prop receiveBufferSize

```cangjie
public mut prop receiveBufferSize: Int64
```

Function: Sets and reads the `SO_RCVBUF` property, providing a way to specify the receive buffer size. The effectiveness of this option depends on the system.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when `size` is less than or equal to 0.
- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the `Socket` is already closed.

### prop receiveTimeout

```cangjie
public override mut prop receiveTimeout: ?Duration
```

Function: Sets and reads the timeout for `receive/receiveFrom` operations.

If the set time is too small, it will be set to the minimum clock cycle value; if too large, it will be set to the maximum timeout (2<sup>63</sup>-1 nanoseconds). The default value is `None`.

Type: ?[Duration](../../core/core_package_api/core_package_structs.md#struct-duration)

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the timeout is less than 0.

### prop remoteAddress

```cangjie
public override prop remoteAddress: ?SocketAddress
```

Function: Reads the remote address to which the `Socket` is connected. Returns `None` when the `Socket` is not connected.

Type: ?[SocketAddress](net_package_classes.md#class-socketaddress)

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the `Socket` is already closed.

### prop sendBufferSize

```cangjie
public mut prop sendBufferSize: Int64
```

Function: Sets and reads the `SO_SNDBUF` property, providing a way to specify the send buffer size. The effectiveness of this option depends on the system.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when `size` is less than or equal to 0.
- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the `Socket` is already closed.

### prop sendTimeout

```cangjie
public override mut prop sendTimeout: ?Duration
```

Function: Sets and reads the timeout for `send/sendTo` operations.

If the set time is too small, it will be set to the minimum clock cycle value; if too large, it will be set to the maximum timeout (2<sup>63</sup>-1 nanoseconds). The default value is `None`.

Type: ?[Duration](../../core/core_package_api/core_package_structs.md#struct-duration)

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the timeout is less than 0.

### init(SocketAddress)

```cangjie
public init(bindAt!: SocketAddress)
```

Function: Creates an unconnected [UnixDatagramSocket](net_package_classes.md#class-unixdatagramsocket) instance.

This file type can be checked for existence using [isSock](../../posix/posix_package_api/posix_package_funcs.md#func-issockstring)() and deleted using the [unlink](../../posix/posix_package_api/posix_package_funcs.md#func-unlinkstring)() interface.

Parameters:

- bindAt!: [SocketAddress](net_package_classes.md#class-socketaddress) - The socket address to bind. The address should not exist; it will be created during `bind`.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the path is empty or already exists.

### init(String)

```cangjie
public init(bindAt!: String)
```

Function: Creates an unconnected [UnixDatagramSocket](net_package_classes.md#class-unixdatagramsocket) instance.

This file type can be checked for existence using [isSock](../../posix/posix_package_api/posix_package_funcs.md#func-issockstring)() and deleted using the [unlink](../../posix/posix_package_api/posix_package_funcs.md#func-unlinkstring)() interface.

Parameters:

- bindAt!: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The file address to bind. The file address should not exist; it will be created during `bind`.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Thrown when the file address is invalid.
- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the file address is empty or already exists.

### func bind()

```cangjie
public func bind(): Unit
```

Function: Binds a `Unix datagram` socket and creates a listening queue.

This interface automatically creates a socket file at the local address. If the file already exists, the binding will fail. This file type can be checked for existence using [isSock](../../posix/posix_package_api/posix_package_funcs.md#func-issockstring) and deleted using the [unlink](../../posix/posix_package_api/posix_package_funcs.md#func-unlinkstring)() interface. If the operation fails, the socket must be `close`d, and retries are not supported.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the file address already exists or file creation fails.

### func close()

```cangjie
public override func close(): Unit
```

Function: Closes the socket. All operations except `close/isClosed` are no longer allowed. The interface can be called multiple times.

### func connect(SocketAddress)

```cangjie
public func connect(remote: SocketAddress): Unit
```

Function: Connects to a specific remote address, which can be undone using `disconnect`.

Only accepts packets from this remote address. By default, `bind` is executed, so no additional `bind` call is needed. After this operation, the port will start receiving ICMP packets. If an abnormal packet is received, `send/sendTo` may fail.

Parameters:

- remote: [SocketAddress](net_package_classes.md#class-socketaddress) - The remote socket address.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the address is not bound.

### func connect(String)

```cangjie
public func connect(remotePath: String): Unit
```

Function: Connects to a specific remote address, which can be undone using `disconnect`.

Only accepts packets from this remote address. Must be called after `bind`. After this operation, the port will start receiving ICMP packets. If an abnormal packet is received, `send/sendTo` may fail.

Parameters:

- remotePath: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The remote file address.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the address is not bound.

### func disconnect()

```cangjie
public func disconnect(): Unit
```

Function: Stops the connection. Cancels receiving packets only from the specified peer. Can be called before `connect` and can be called multiple times.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when not bound.

### func getSocketOption(Int32, Int32, CPointer\<Unit>, CPointer\<UIntNative>)

```cangjie
public func getSocketOption(
    level: Int32,
    option: Int32,
    value: CPointer<Unit>,
    valueLength: CPointer<UIntNative>
): Unit
```

Function: Gets the specified socket option.

Parameters:

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The level, e.g., `SOL_SOCKET`.
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The option, e.g., `SO_KEEPALIVE`.
- value: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[Unit](../../core/core_package_api/core_package_intrinsics.md#unit)> - The option value.
- valueLength: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<UIntNative> - The option value length.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when `getsockopt` returns a failure.

### func getSocketOptionIntNative(Int32, Int32)

```cangjie
public func getSocketOptionIntNative(
    level: Int32,
    option: Int32
): IntNative
```

Function: Gets the specified socket option.

Parameters:

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The level, e.g., `SOL_SOCKET`.
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The option, e.g., `SO_KEEPALIVE`.

Returns:

- [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) - The specified socket option value.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when `getsockopt` returns a failure or the option size exceeds the threshold of [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative).

### func isClosed()

```cangjie
public override func isClosed(): Bool
```

Function: Checks whether the socket has been explicitly closed by calling `close`.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the socket has been explicitly closed by calling `close`; otherwise, returns `false`.

### func receive(Array\<Byte>)

```cangjie
public func receive(buffer: Array<Byte>): Int64
```

Function: Receives packets from the address connected via `connect`.

Parameters:

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - The address to store the received packets.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The size of the received packet.

### func receiveFrom(Array\<Byte>)

```cangjie
public override func receiveFrom(buffer: Array<Byte>): (SocketAddress, Int64)
```

Function: Receives packets.

Parameters:

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - The address to store the received packets.

Returns:

- ([SocketAddress](net_package_classes.md#class-socketaddress), [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)) - The sender address of the received packet and the actual size of the received packet, which may be 0 or larger than the size of the `buffer` parameter.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the local buffer is too small to read the packet.
- [SocketTimeoutException](net_package_exceptions.md#class-sockettimeoutexception) - Thrown when the read operation times out.

### func send(Array\<Byte>)

```cangjie
public func send(payload: Array<Byte>): Unit
```

Function: Sends packets to the address connected via `connect`.

Parameters:

- payload: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - The packet content to send.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the `payload` size exceeds system limits or the system fails to send.

### func sendTo(SocketAddress, Array\<Byte>)

```cangjie
public override func sendTo(recipient: SocketAddress, payload: Array<Byte>): Unit
```

Function: Sends packets. May block when there is insufficient buffer space.

Parameters:

- recipient: [SocketAddress](net_package_classes.md#class-socketaddress) - The recipient address.
- payload: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - The packet content to send.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when the `payload` size exceeds system limits, the system fails to send (e.g., when `connect` is called and an abnormal ICMP packet is received), or when `sendTo` is called after `connect` on macOS.

### func setSocketOption(Int32, Int32, CPointer\<Unit>, UIntNative)

```cangjie
public func setSocketOption(
    level: Int32,
    option: Int32,
    value: CPointer<Unit>,
    valueLength: UIntNative
): Unit
```

Function: Sets the specified socket option.

Parameters:

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The level, e.g., `SOL_SOCKET`.
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The option, e.g., `SO_KEEPALIVE`.
- value: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[Unit](../../core/core_package_api/core_package_intrinsics.md#unit)> - The option value.
- valueLength: [UIntNative](../../core/core_package_api/core_package_intrinsics.md#uintnative) - The option value length.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when `setsockopt` returns a failure.

### func setSocketOptionBool(Int32, Int32, Bool)

```cangjie
public func setSocketOptionBool(
    level: Int32,
    option: Int32,
    value: Bool
): Unit
```

Function: Sets the specified socket option.

Parameters:

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The level, e.g., `SOL_SOCKET`.
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The option, e.g., `SO_KEEPALIVE`.
- value: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - The option value.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when `setsockopt` returns a failure.

### func setSocketOptionIntNative(Int32, Int32, IntNative)

```cangjie
public func setSocketOptionIntNative(
    level: Int32,
    option: Int32,
    value: IntNative
): Unit
```

Function: Sets the specified socket option.

Parameters:

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The level, e.g., `SOL_SOCKET`.
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The option, e.g., `SO_KEEPALIVE`.
- value: [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) - The option value.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Thrown when `setsockopt` returns a failure.

### func getSocketOptionBool(Int32, Int32)

```cangjie
public func getSocketOptionBool(
    level: Int32,
    option: Int32
): Bool
```

Function: Gets the specified socket option. Converted from [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative). `0 => false, non-zero => true`.

Parameters:

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The level, e.g., `SOL_SOCKET`.
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - The option, e.g., `SO_KEEPALIVE`.

Returns:

-## class UnixServerSocket

```cangjie
public class UnixServerSocket <: ServerSocket {
    public init(bindAt!: String)
    public init(bindAt!: SocketAddress)
}
```

Function: Provides duplex stream-based host communication server-side.

[UnixServerSocket](net_package_classes.md#class-unixserversocket) listens for connections. After creation, property values can be configured through properties and `setSocketOptionXX` interfaces. Requires calling the `bind()` interface to bind a local address and start listening for connections. Connections can be accepted via the `accept()` interface.

> **Note:**
>
> This type is not supported on Windows platforms.

Parent Types:

- [ServerSocket](net_package_interfaces.md#interface-serversocket)

### prop backlogSize

```cangjie
public mut prop backlogSize: Int64
```

Function: Sets and reads the `backlog` size. Can only be called before invoking `bind`, otherwise an exception will be thrown. Whether the variable takes effect depends on system behavior.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Throws an exception when called after `bind`.

### prop localAddress

```cangjie
public override prop localAddress: SocketAddress
```

Function: Reads the local address to which the `Socket` will be or has been bound.

Type: [SocketAddress](net_package_classes.md#class-socketaddress)

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Throws an exception when the `Socket` has been closed.

### prop receiveBufferSize

```cangjie
public mut prop receiveBufferSize: Int64
```

Function: Sets and reads the `SO_RCVBUF` property.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when `size` is less than or equal to 0.
- [SocketException](net_package_exceptions.md#class-socketexception) - Throws an exception when the `Socket` is closed.

### prop sendBufferSize

```cangjie
public mut prop sendBufferSize: Int64
```

Function: Sets and reads the `SO_SNDBUF` property.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when `size` is less than or equal to 0.
- [SocketException](net_package_exceptions.md#class-socketexception) - Throws an exception when the `Socket` is closed.

### init(SocketAddress)

```cangjie
public init(bindAt!: SocketAddress)
```

Function: Creates an unconnected [UnixServerSocket](net_package_classes.md#class-unixserversocket) instance.

Parameters:

- bindAt!: [SocketAddress](net_package_classes.md#class-socketaddress) - The socket address to bind.

### init(String)

```cangjie
public init(bindAt!: String)
```

Function: Creates an unconnected [UnixServerSocket](net_package_classes.md#class-unixserversocket) instance.

This file type can be checked for existence via [isSock](../../posix/posix_package_api/posix_package_funcs.md#func-issockstring) and deleted via the [unlink](../../posix/posix_package_api/posix_package_funcs.md#func-unlinkstring)() interface.

Parameters:

- bindAt!: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The file address to bind.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when the file address is invalid.

### func accept()

```cangjie
public override func accept(): UnixSocket
```

Function: Waits to accept a client connection or reads a connection from the queue.

Returns:

- [UnixSocket](net_package_classes.md#class-unixsocket) - The connected client socket.

### func accept(?Duration)

```cangjie
public override func accept(timeout!: ?Duration): UnixSocket
```

Function: Waits to accept a client connection or reads a connection from the queue.

Parameters:

- timeout!: ?[Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - Timeout duration.

Returns:

- [UnixSocket](net_package_classes.md#class-unixsocket) - The connected client socket.

Exceptions:

- [SocketTimeoutException](net_package_exceptions.md#class-sockettimeoutexception) - Throws an exception when the connection times out.
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when the timeout duration is less than 0.

### func bind()

```cangjie
public override func bind(): Unit
```

Function: Binds a `Unix domain` socket and creates a listening queue.

This interface automatically creates a socket file at the local address. If the file already exists, binding will fail. This file type can be checked for existence via [isSock](../../posix/posix_package_api/posix_package_funcs.md#func-issockstring) and deleted via [unlink](../../posix/posix_package_api/posix_package_funcs.md#func-unlinkstring)(). After failure, the socket must be `closed`. Multiple retries are not supported.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Throws an exception when binding fails due to system reasons.

### func close()

```cangjie
public override func close(): Unit
```

Function: Closes the socket. All operations except `close/isClosed` are no longer allowed. This interface can be called multiple times.

### func getSocketOption(Int32, Int32, CPointer\<Unit>, CPointer\<UIntNative>)

```cangjie
public func getSocketOption(
    level: Int32,
    option: Int32,
    value: CPointer<Unit>,
    valueLength: CPointer<UIntNative>
): Unit
```

Function: Gets the specified socket option.

Parameters:

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - Level, e.g., `SOL_SOCKET`.
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - Option, e.g., `SO_KEEPALIVE`.
- value: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[Unit](../../core/core_package_api/core_package_intrinsics.md#unit)> - Option value.
- valueLength: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[UIntNative](../../core/core_package_api/core_package_intrinsics.md#uintnative)> - Option value length.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Throws an exception when `getsockopt` returns failure.

### func getSocketOptionBool(Int32, Int32)

```cangjie
public func getSocketOptionBool(
    level: Int32,
    option: Int32
): Bool
```

Function: Gets the specified socket option. Converted from [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative). `0 => false`, non-zero => `true`.

Parameters:

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - Level, e.g., `SOL_SOCKET`.
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - Option, e.g., `SO_KEEPALIVE`.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns the specified socket option value. Converted from [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative). `0 => false`, non-zero => `true`.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Throws an exception when `getsockopt` returns failure or the option size exceeds the [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) threshold.

### func getSocketOptionIntNative(Int32, Int32)

```cangjie
public func getSocketOptionIntNative(
    level: Int32,
    option: Int32
): IntNative
```

Function: Gets the specified integer-type socket option.

Parameters:

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - Level, e.g., `SOL_SOCKET`.
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - Option, e.g., `SO_KEEPALIVE`.

Returns:

- [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) - The specified socket option value.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Throws an exception when `getsockopt` returns failure or the option size exceeds the [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) threshold.

### func isClosed()

```cangjie
public override func isClosed(): Bool
```

Function: Determines whether the socket has been explicitly closed via `close`.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the socket has been explicitly closed via `close`; otherwise, returns `false`.

### func setSocketOption(Int32, Int32, CPointer\<Unit>, UIntNative)

```cangjie
public func setSocketOption(
    level: Int32,
    option: Int32,
    value: CPointer<Unit>,
    valueLength: UIntNative
): Unit
```

Function: Sets the specified integer-type socket option.

Parameters:

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - Level, e.g., `SOL_SOCKET`.
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - Option, e.g., `SO_KEEPALIVE`.
- value: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[Unit](../../core/core_package_api/core_package_intrinsics.md#unit)> - Option value.
- valueLength: [UIntNative](../../core/core_package_api/core_package_intrinsics.md#uintnative) - Option value length.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Throws an exception when `setsockopt` returns failure.

### func setSocketOptionBool(Int32, Int32, Bool)

```cangjie
public func setSocketOptionBool(
    level: Int32,
    option: Int32,
    value: Bool
): Unit
```

Function: Sets the specified socket option.

Parameters:

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - Level, e.g., `SOL_SOCKET`.
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - Option, e.g., `SO_KEEPALIVE`.
- value: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Option value.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Throws an exception when `setsockopt` returns failure.

### func setSocketOptionIntNative(Int32, Int32, IntNative)

```cangjie
public func setSocketOptionIntNative(
    level: Int32,
    option: Int32,
    value: IntNative
): Unit
```

Function: Sets the specified socket option.

Parameters:

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - Level, e.g., `SOL_SOCKET`.
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - Option, e.g., `SO_KEEPALIVE`.
- value: [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) - Option value.

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Throws an exception when `setsockopt` returns failure.

### func toString()

```cangjie
public override func toString(): String
```

Function: Returns the status information of the current [UnixServerSocket](net_package_classes.md#class-unixserversocket).

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - A string containing the status information of the current [UnixServerSocket](net_package_classes.md#class-unixserversocket).

## class UnixSocket

```cangjie
public class UnixSocket <: StreamingSocket {
    public init(address: SocketAddress, localAddress!: ?SocketAddress = None)
    public init(path: String, localPath!: ?String = None)
}
```

Function: Provides duplex stream-based host communication client-side.

After creating a [UnixSocket](net_package_classes.md#class-unixsocket) instance, the `connect()` interface should be called to establish a connection, and `close()` should be explicitly called to release resources when finished. Refer to [StreamingSocket](net_package_interfaces.md#interface-streamingsocket) for more information.

> **Note:**
>
> This type is not supported on Windows platforms.

Parent Types:

- [StreamingSocket](net_package_interfaces.md#interface-streamingsocket)

### prop localAddress

```cangjie
public override prop localAddress: SocketAddress
```

Function: Reads the local address to which the `Socket` will be or has been bound.

Type: [SocketAddress](net_package_classes.md#class-socketaddress)

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Throws an exception when the `Socket` has been closed or no local address is available (local address not configured and socket not connected).

### prop readTimeout

```cangjie
public override mut prop readTimeout: ?Duration
```

Function: Sets and reads the read operation timeout duration.

If the set time is too small, it will be set to the minimum clock cycle value; if too large, it will be set to `None`. Default value is `None`.

Type: ?[Duration](../../core/core_package_api/core_package_structs.md#struct-duration)

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when the timeout duration is less than 0.

### prop receiveBufferSize

```cangjie
public mut prop receiveBufferSize: Int64
```

Function: Sets and reads the `SO_RCVBUF` property.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when `size` is less than or equal to 0.
- [SocketException](net_package_exceptions.md#class-socketexception) - Throws an exception when the `Socket` is closed.

### prop remoteAddress

```cangjie
public override prop remoteAddress: SocketAddress
```

Function: Reads the remote address to which the `Socket` has or will connect.

Type: [SocketAddress](net_package_classes.md#class-socketaddress)

Exceptions:

- [SocketException](net_package_exceptions.md#class-socketexception) - Throws an exception when the `Socket` has been closed.

### prop sendBufferSize

```cangjie
public mut prop sendBufferSize: Int64
```

Function: Sets and reads the `SO_SNDBUF` property.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when `size` is less than or equal to 0.
- [SocketException](net_package_exceptions.md#class-socketexception) - Throws an exception when the `Socket` is closed.

### prop writeTimeout

```cangjie
public override mut prop writeTimeout: ?Duration
```

Function: Sets and reads the write operation timeout duration.

If the set time is too small, it will be set to the minimum clock cycle value; if too large, it will be set to the maximum timeout duration (2<sup>63</sup>-1 nanoseconds). Default value is `None`.

Type: ?[Duration](../../core/core_package_api/core_package_structs.md#struct-duration)

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws an exception when the timeout duration is less than 0.

### init(SocketAddress, ?SocketAddress)

```cangjie
public init(address: SocketAddress, localAddress!: ?SocketAddress = None)
```

Function: Creates an unconnected [UnixSocket](net_package_classes.md#class-unixsocket) instance.

Parameters:

- address: [SocketAddress](net_package_classes.md#class-socketaddress) - The socket address to connect.
- localAddress!: ?[SocketAddress](net_package_classes.md#class-socketaddress) - The local socket address to bind; default is `None`.

### init(String, ?String)

```cangjie
public init(path: String, localPath!: ?String = None)
```

Function: Creates an unconnected [UnixSocket](net_package_classes.md#class-unixsocket) instance.

This file type can be checked for existence via [isSock](../../posix/posix_package_api/posix_package_funcs.md#func-issockstring) and deleted via [unlink](../../posix/posix_package_api/posix_package_funcs.md#func-unlinkstring)().

Parameters:

- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) - The file address## class UnixSocketAddress

```cangjie
public class UnixSocketAddress <: SocketAddress & Equatable<UnixSocketAddress> {
    public init(path: Array<Byte>)
    public init(path: String)
}
```

Function: This class implements Unix Domain Socket addresses. A UnixSocketAddress encapsulates the filesystem path to which a Unix Domain Socket is bound or connected, with the path length not exceeding 108 bytes.

If the path is an empty string, it represents an `unnamed` address. If the path starts with `\0`, it represents an `abstract` address. The path must not contain `\0` in the middle.

Parent Types:

- [SocketAddress](#class-socketaddress)
- [Equatable](../../core/core_package_api/core_package_interfaces.md#interface-equatablet)\<[UnixSocketAddress](#class-unixsocketaddress)>

### prop family

```cangjie
public prop family: AddressFamily
```

Function: Gets the address family of the current [UnixSocketAddress](net_package_classes.md#class-unixsocketaddress) object, always returns [AddressFamily.UNIX](net_package_structs.md#static-const-unix).

Type: [AddressFamily](net_package_structs.md#struct-addressfamily)

### prop size

```cangjie
public prop size: Int64
```

Function: Gets the raw byte length of the current [UnixSocketAddress](net_package_classes.md#class-unixsocketaddress) object.

Type: [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

### init(Array\<Byte>)

```cangjie
public init(path: Array<Byte>)
```

Function: Constructs a [UnixSocketAddress](net_package_classes.md#class-unixsocketaddress) from a filesystem path represented as an [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)>.

Parameters:

- path: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - Filesystem path byte array.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws if the address is invalid.

### init(String)

```cangjie
public init(path: String)
```

Function: Constructs a [UnixSocketAddress](net_package_classes.md#class-unixsocketaddress) from a filesystem path string.

Parameters:

- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) - Filesystem path string.

Exceptions:

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - Throws if the address is invalid.

### func getAddressBytes()

```cangjie
public func getAddressBytes(): Array<Byte>
```

Function: Returns the raw IP address of this [UnixSocketAddress](net_package_classes.md#class-unixsocketaddress) object, with content layout matching the `sockaddr_un` format.

Returns:

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - Raw IP address represented as [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)>.

Example:
<!-- run -->

```cangjie
import std.net.*
import std.unittest.*
import std.unittest.testmacro.*

main() {
    let udsa1_1: UnixSocketAddress = UnixSocketAddress("/tmp/server1.sock")
    @Assert(udsa1_1.getAddressBytes(), "\u{1}\u{0}/tmp/server1.sock".toArray())
}
```

### func hashCode()

```cangjie
public func hashCode(): Int64
```

Function: Gets the `hashcode` value.

Returns:

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - The `hashcode` value.

### func toString()

```cangjie
public func toString(): String
```

Function: Returns the string representation of the current [UnixSocketAddress](net_package_classes.md#class-unixsocketaddress).

Returns:

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - Text representation string of the current [UnixSocketAddress](net_package_classes.md#class-unixsocketaddress), e.g. `/tmp/socket1`.

Example:
<!-- run -->

```cangjie
import std.net.*
import std.unittest.*
import std.unittest.testmacro.*

main() {
    let expect1 = "/tmp/server1.sock"
    let expect2 = "\u{0}/tmp/server1.sock"
    let udsa1_1: UnixSocketAddress = UnixSocketAddress("/tmp/server1.sock")
    let udsa2_1: UnixSocketAddress = UnixSocketAddress("/tmp/server1.sock".toArray())
    let udsa2_2: UnixSocketAddress = UnixSocketAddress("/tmp/server1.sock\u{0}\u{0}".toArray())
    let udsa3_1: UnixSocketAddress = UnixSocketAddress("\u{0}/tmp/server1.sock")
    let udsa4_1: UnixSocketAddress = UnixSocketAddress("\u{0}/tmp/server1.sock".toArray())
    let udsa4_2: UnixSocketAddress = UnixSocketAddress("\u{0}/tmp/server1.sock\u{0}\u{0}".toArray())
    @Assert(udsa1_1.toString(), expect1)
    @Assert(udsa2_1.toString(), expect1)
    @Assert(udsa2_2.toString(), expect1)
    @Assert(udsa3_1.toString(), expect2)
    @Assert(udsa1_1, udsa2_1)
    @Assert(udsa1_1, udsa2_2)
    @Assert(udsa3_1, udsa4_1)
    @Assert(udsa3_1, udsa4_2)
    @Assert(udsa4_1.toString(), expect2)
    @Assert(udsa4_2.toString(), expect2)

    try {
        UnixSocketAddress("/tmp/server1\u{0}.sock")
    } catch (e: IllegalArgumentException) {
        @Assert(true)
    }

    try {
        UnixSocketAddress("/tmp/server1.sock\u{0}\u{0}")
    } catch (e: IllegalArgumentException) {
        @Assert(true)
    }
    try {
        UnixSocketAddress("\u{0}/tmp/server1.sock\u{0}\u{0}")
    } catch (e: IllegalArgumentException) {
        @Assert(true)
    }
    try {
        UnixSocketAddress("/tmp/server1\u{0}.sock".toArray())
    } catch (e: IllegalArgumentException) {
        @Assert(true)
    }
    return
}
```

### operator func ==(UnixSocketAddress)

```cangjie
public operator func ==(rhs: UnixSocketAddress): Bool
```

Function: Determines whether two [UnixSocketAddress](net_package_classes.md#class-unixsocketaddress) objects are equal.

Parameters:

- rhs: [UnixSocketAddress](net_package_classes.md#class-unixsocketaddress) - The [UnixSocketAddress](net_package_classes.md#class-unixsocketaddress) object to compare.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the two [UnixSocketAddress](net_package_classes.md#class-unixsocketaddress) objects are equal; otherwise, returns `false`.

### operator func !=(UnixSocketAddress)

```cangjie
public operator func !=(rhs: UnixSocketAddress): Bool
```

Function: Determines whether two [UnixSocketAddress](net_package_classes.md#class-unixsocketaddress) objects are not equal.

Parameters:

- rhs: [UnixSocketAddress](net_package_classes.md#class-unixsocketaddress) - The [UnixSocketAddress](net_package_classes.md#class-unixsocketaddress) object to compare.

Returns:

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - Returns `true` if the two [UnixSocketAddress](net_package_classes.md#class-unixsocketaddress) objects are not equal; otherwise, returns `false`.
