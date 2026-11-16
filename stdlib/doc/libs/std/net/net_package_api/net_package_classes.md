# 类

## class IPAddress

```cangjie
sealed abstract class IPAddress <: ToString & Equatable<IPAddress> & Hashable & BigEndianOrder<IPAddress>
```

功能：此类表示 Internet 协议（IP）地址。互联网协议地址（IP 地址）是一个数字标签，例如 *192.0.2.1* 或 *2001:0db8:0000:0000:0000:ff00:0042:8329*，分配给连接到使用互联网协议进行通信的计算机网络设备。IP 地址有两个主要功能：网络接口标识和位置寻址。

父类型：

- [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring)
- [Equatable](../../core/core_package_api/core_package_interfaces.md#interface-equatablet)\<[IPAddress](#class-ipaddress)>
- [Hashable](../../core/core_package_api/core_package_interfaces.md#interface-hashable)
- [BigEndianOrder](../../binary/binary_package_api/binary_package_interfaces.md#interface-bigendianordert)\<[IPAddress](#class-ipaddress)>

### prop hostName

```cangjie
public prop hostName: ?String
```

功能：返回当前 [IPAddress](net_package_classes.md#class-ipaddress)  对象对应的主机名，如果无法成功解析，则为 None，当前暂未实现。

异常：

- [UnsupportedException](../../core/core_package_api/core_package_exceptions.md#class-unsupportedexception) - 如果不是合法字符串，抛出异常。

类型：?[String](../../core/core_package_api/core_package_structs.md#struct-string)

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    let v4: IPAddress = IPAddress.parse("192.168.1.2")
    try {
        println("IPv4地址主机名: ${v4.hostName}")
    } catch (e: Exception) {
        println("Error: ${e.message}")
    }
}
```

运行结果：

```text
Error: Current not supported.
```

### prop size

```cangjie
public prop size: Int64
```

功能：获取 IP 地址对象字节长度。

类型：[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    let v4: IPAddress = IPAddress.parse("192.168.1.2")
    let v6: IPAddress = IPAddress.parse("2001:0250:1006:dff0:4913:2aa5:8075:7c10")
    println("IPv4地址大小: ${v4.size}")
    println("IPv6地址大小: ${v6.size}")
}
```

运行结果：

```text
IPv4地址大小: 4
IPv6地址大小: 16
```

### static func parse(String)

```cangjie
public static func parse(s: String): IPAddress
```

功能：将 IP 协议的 Socket 字符串转换为 [IPAddress](net_package_classes.md#class-ipaddress) 对象。

参数：

- s: [String](../../core/core_package_api/core_package_structs.md#struct-string) - IP 协议的 Socket 字符串。

返回值：

- [IPAddress](net_package_classes.md#class-ipaddress) - [IPAddress](net_package_classes.md#class-ipaddress) 对象。

异常：

- [IllegalFormatException](../../core/core_package_api/core_package_exceptions.md#class-illegalformatexception) - 如果不是合法字符串，抛出异常。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    let v4: IPAddress = IPAddress.parse("192.168.1.2")
    let v6: IPAddress = IPAddress.parse("2001:0250:1006:dff0:4913:2aa5:8075:7c10")
    println(v4)
    println(v6)
}
```

运行结果：

```text
192.168.1.2
2001:250:1006:dff0:4913:2aa5:8075:7c10
```

### static func readBigEndian(Array\<Byte>)

```cangjie
public static func readBigEndian(buffer: Array<Byte>): IPAddress
```

功能：从字节数组中以大端序的方式读取一个 [IPAddress](net_package_classes.md#class-ipaddress) 对象。

参数：

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 缓冲区，用于存放待读取的数据。

返回值：

- [IPAddress](net_package_classes.md#class-ipaddress) - [IPAddress](net_package_classes.md#class-ipaddress) 对象。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当 buffer 太小，不足以读出 [IPAddress](net_package_classes.md#class-ipaddress) 值时，抛出异常。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    let bufferV4: Array<Byte> = [0xC0, 0xA8, 0x1, 0x2]
    let bufferV6: Array<Byte> = [0x20, 0x01, 0x02, 0x50, 0x10, 0x06, 0xdf, 0xf0, 0x49, 0x13, 0x2a, 0xa5, 0x80, 0x75,
        0x7c, 0x10]
    let v4: IPAddress = IPAddress.readBigEndian(bufferV4)
    let v6: IPAddress = IPAddress.readBigEndian(bufferV6)
    println(v4)
    println(v6)
}
```

运行结果：

```text
192.168.1.2
2001:250:1006:dff0:4913:2aa5:8075:7c10
```

### static func resolve(AddressFamily, String)

```cangjie
public static func resolve(family: AddressFamily, domain: String): Array<IPAddress>
```

功能：解析域名，得到 [IPAddress](net_package_classes.md#class-ipaddress) 列表。

> **注意：**
>
> - 此接口只负责解析字面量 IP 或 DNS 域名，本身不提供 DNS 重绑定防护，也不会过滤回环、私网、链路本地、未指定地址或组播地址。
> - 当 `domain` 来自不可信输入时，调用方应在发起连接前校验解析结果，例如仅允许 `isGlobalUnicast()` 的地址，以避免 SSRF、内网探测或访问本地服务等风险。

参数：

- family: [AddressFamily](net_package_structs.md#struct-addressfamily) - 地址族。
- domain: [String](../../core/core_package_api/core_package_structs.md#struct-string) - 域名。

返回值：

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[IPAddress](net_package_classes.md#class-ipaddress)> - [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[IPAddress](net_package_classes.md#class-ipaddress)> 对象。

示例：
<!-- run -->

```cangjie
import std.net.*

main() {
    let iplist: Array<IPAddress> = IPAddress.resolve(AddressFamily.UNSPEC, "localhost")
    println("may output: ${iplist}")
}
```

可能的运行结果：

```text
may output: [127.0.0.1]
```

### static func resolve(String)

```cangjie
public static func resolve(domain: String): Array<IPAddress>
```

功能：解析域名，得到 [IPAddress](net_package_classes.md#class-ipaddress) 列表。

> **注意：**
>
> - 此接口只负责解析字面量 IP 或 DNS 域名，本身不提供 DNS 重绑定防护，也不会过滤回环、私网、链路本地、未指定地址或组播地址。
> - 当 `domain` 来自不可信输入时，调用方应在发起连接前校验解析结果，例如仅允许 `isGlobalUnicast()` 的地址，以避免 SSRF、内网探测或访问本地服务等风险。

参数：

- domain: [String](../../core/core_package_api/core_package_structs.md#struct-string) - 域名。

返回值：

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[IPAddress](net_package_classes.md#class-ipaddress)> - [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[IPAddress](net_package_classes.md#class-ipaddress)> 对象。

示例：
<!-- run -->

```cangjie
import std.net.*

main() {
    let iplist: Array<IPAddress> = IPAddress.resolve("localhost")
    println("may output: ${iplist}")
}
```

可能的运行结果：

```text
may output: [127.0.0.1]
```

### static func tryParse(String)

```cangjie
public static func tryParse(s: String): ?IPAddress
```

功能：将 IP 地址字符串转换为 [IPAddress](net_package_classes.md#class-ipaddress) 对象，如果不是合法字符串，则返回 `None`。

参数：

- s: [String](../../core/core_package_api/core_package_structs.md#struct-string) - IP 地址字符串。

返回值：

- ?[IPAddress](net_package_classes.md#class-ipaddress) - ?[IPAddress](net_package_classes.md#class-ipaddress) 对象。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    let v4: ?IPAddress = IPAddress.tryParse("192.168.1.2")
    let v6: ?IPAddress = IPAddress.tryParse("2001:0250:1006:dff0:4913:2aa5:8075:7c10")
    println(v4)
    println(v6)
}
```

运行结果：

```text
Some(192.168.1.2)
Some(2001:250:1006:dff0:4913:2aa5:8075:7c10)
```

### func getAddressBytes()

```cangjie
public func getAddressBytes(): Array<Byte>
```

功能：返回此 [IPAddress](net_package_classes.md#class-ipaddress) 对象的原始 IP 地址。

返回值：

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 原始 IP 地址的 [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> 表示。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    let expectV4: Array<Byte> = [0xC0, 0xA8, 0x1, 0x2]
    let expectV6: Array<Byte> = [0x20, 0x01, 0x02, 0x50, 0x10, 0x06, 0xdf, 0xf0, 0x49, 0x13, 0x2a, 0xa5, 0x80, 0x75,
        0x7c, 0x10]
    let v4: IPAddress = IPAddress.parse("192.168.1.2")
    let v6: IPAddress = IPAddress.parse("2001:0250:1006:dff0:4913:2aa5:8075:7c10")
    let v4Bytes = v4.getAddressBytes()
    let v6Bytes = v6.getAddressBytes()
    println(v4Bytes == expectV4)
    println(v6Bytes == expectV6)
}
```

运行结果：

```text
true
true
```

### func getPrefix(UInt8)

```cangjie
public open func getPrefix(prefixLen: UInt8): IPPrefix
```

功能：此 [IPAddress](net_package_classes.md#class-ipaddress) 地址对象根据指定的网络前缀长度创建一个网络前缀对象。

参数：

- prefixLen: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 网络前缀长度。

返回值：

- [IPPrefix](net_package_classes.md#class-ipprefix) - 网络前缀对象。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 如果 prefixLen 大小超出范围，抛出异常。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    let prefix: IPPrefix = IPAddress.parse("192.168.1.2").getPrefix(24)
    println(prefix)
}
```

运行结果：

```text
192.168.1.2/24
```

### func hashCode()

```cangjie
public func hashCode(): Int64
```

功能：获取 `hashcode` 值。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - `hashcode` 值。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    let v4: IPAddress = IPAddress.parse("192.168.1.2")
    let v6: IPAddress = IPAddress.parse("2001:0250:1006:dff0:4913:2aa5:8075:7c10")
    println("IPv4地址的hashCode: ${v4.hashCode()}")
    println("IPv6地址的hashCode: ${v6.hashCode()}")
}
```

运行结果：

```text
IPv4地址的hashCode: -7046029251154117353
IPv6地址的hashCode: 2009812126445433271
```

### func isGlobalUnicast()

```cangjie
public open func isGlobalUnicast(): Bool
```

功能：判断此 [IPAddress](net_package_classes.md#class-ipaddress) 对象是不是全局单播地址。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回 true 表示是全局单播地址，否则返回 false。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 2000::/3
    let result = IPAddress.parse("2001:250:1006:dff0:4913:2aa5:8075:7c10").isGlobalUnicast()
    println(result)
}
```

运行结果：

```text
true
```

### func isIPv4()

```cangjie
public func isIPv4(): Bool
```

功能：判断此 [IPAddress](net_package_classes.md#class-ipaddress) 对象是不是 IPv4 地址。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回 true 表示是 IPv4 地址，否则返回 false。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    let result = IPAddress.parse("192.168.1.2").isIPv4()
    println(result)
}
```

运行结果：

```text
true
```

### func isIPv6()

```cangjie
public func isIPv6(): Bool
```

功能：判断此 [IPAddress](net_package_classes.md#class-ipaddress) 对象是不是 IPv6 地址。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回 true 表示是 IPv6 地址，否则返回 false。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    let result = IPAddress.parse("2001:250:1006:dff0:4913:2aa5:8075:7c10").isIPv6()
    println(result)
}
```

运行结果：

```text
true
```

### func isLinkLocal()

```cangjie
public open func isLinkLocal(): Bool
```

功能：判断此 [IPAddress](net_package_classes.md#class-ipaddress) 对象是不是链路本地地址。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回 true 表示是链路本地地址，否则返回 false。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 169.254.0.0 ~ 169.254.255.255
    let result1 = IPAddress.parse("169.254.0.1").isLinkLocal()
    // fe80::/10
    let result2 = IPAddress.parse("fe80::1").isLinkLocal()
    println(result1)
    println(result2)
}
```

运行结果：

```text
true
true
```

### func isLoopback()

```cangjie
public open func isLoopback(): Bool
```

功能：判断此 [IPAddress](net_package_classes.md#class-ipaddress) 对象是不是环回地址。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回 true 表示是环回地址，否则返回 false。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    let result1 = IPAddress.parse("127.0.0.1").isLoopback()
    let result2 = IPAddress.parse("::1").isLoopback()
    println(result1)
    println(result2)
}
```

运行结果：

```text
true
true
```

### func isMulticast()

```cangjie
public open func isMulticast(): Bool
```

功能：判断此 [IPAddress](net_package_classes.md#class-ipaddress) 对象是不是多播地址。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回 true 表示是多播地址，否则返回 false。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // IPv4多播地址示例
    let multicastV4: IPAddress = IPAddress.parse("224.0.0.1")
    let normalV4: IPAddress = IPAddress.parse("192.168.1.2")

    // IPv6多播地址示例
    let multicastV6: IPAddress = IPAddress.parse("ff02::1")
    let normalV6: IPAddress = IPAddress.parse("2001:0250:1006:dff0:4913:2aa5:8075:7c10")

    println("224.0.0.1是多播地址: ${multicastV4.isMulticast()}")
    println("192.168.1.2是多播地址: ${normalV4.isMulticast()}")
    println("ff02::1是多播地址: ${multicastV6.isMulticast()}")
    println("2001:0250:1006:dff0:4913:2aa5:8075:7c10是多播地址: ${normalV6.isMulticast()}")
}
```

运行结果：

```text
224.0.0.1是多播地址: true
192.168.1.2是多播地址: false
ff02::1是多播地址: true
2001:0250:1006:dff0:4913:2aa5:8075:7c10是多播地址: false
```

### func isPrivate()

```cangjie
public open func isPrivate(): Bool
```

功能：判断此 [IPAddress](net_package_classes.md#class-ipaddress) 对象是不是私有地址。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回 true 表示是私有地址，否则返回 false。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // IPv4私有地址示例
    let privateV4_1: IPAddress = IPAddress.parse("192.168.1.2")
    let privateV4_2: IPAddress = IPAddress.parse("10.0.0.1")
    let privateV4_3: IPAddress = IPAddress.parse("172.16.0.1")
    let publicV4: IPAddress = IPAddress.parse("8.8.8.8")

    // IPv6私有地址示例 (ULA - Unique Local Address)
    let privateV6: IPAddress = IPAddress.parse("fd00::1")
    let publicV6: IPAddress = IPAddress.parse("2001:4860:4860::8888")

    println("192.168.1.2是私有地址: ${privateV4_1.isPrivate()}")
    println("10.0.0.1是私有地址: ${privateV4_2.isPrivate()}")
    println("172.16.0.1是私有地址: ${privateV4_3.isPrivate()}")
    println("8.8.8.8是私有地址: ${publicV4.isPrivate()}")
    println("fd00::1是私有地址: ${privateV6.isPrivate()}")
    println("2001:4860:4860::8888是私有地址: ${publicV6.isPrivate()}")
}
```

运行结果：

```text
192.168.1.2是私有地址: true
10.0.0.1是私有地址: true
172.16.0.1是私有地址: true
8.8.8.8是私有地址: false
fd00::1是私有地址: true
2001:4860:4860::8888是私有地址: false
```

### func isUnspecified()

```cangjie
public open func isUnspecified(): Bool
```

功能：判断此 [IPAddress](net_package_classes.md#class-ipaddress) 对象是不是“未指定” IP 地址。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回 true 表示是“未指定” IP 地址，否则返回 false。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    let result1 = IPAddress.parse("0.0.0.0").isUnspecified()
    let result2 = IPAddress.parse("::").isUnspecified()
    println(result1)
    println(result2)
}
```

运行结果：

```text
true
true
```

### func writeBigEndian(Array\<Byte>)

```cangjie
public open func writeBigEndian(buffer: Array<Byte>): Int64
```

功能：返回此 [IPAddress](net_package_classes.md#class-ipaddress) 对象以大端序的方式写入字节数组中。

参数：

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 缓冲区，用于存放待写入的数据。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 写入的数据的字节数。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当 buffer 太小，不足以写入 [IPv4Address](net_package_classes.md#class-ipv4address) 或 [IPv6Address](net_package_classes.md#class-ipv6address) 值时，抛出异常。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    let buffer = Array<Byte>(128, repeat: 0)
    let expectV4: Array<Byte> = [0xC0, 0xA8, 0x1, 0x2]
    let expectV6: Array<Byte> = [0x20, 0x01, 0x02, 0x50, 0x10, 0x06, 0xdf, 0xf0, 0x49, 0x13, 0x2a, 0xa5, 0x80, 0x75,
        0x7c, 0x10]
    let v4: IPAddress = IPAddress.parse("192.168.1.2")
    let v6: IPAddress = IPAddress.parse("2001:0250:1006:dff0:4913:2aa5:8075:7c10")
    var len = v4.writeBigEndian(buffer)
    println(buffer[..len] == expectV4)
    len = v6.writeBigEndian(buffer)
    println(buffer[..len] == expectV6)
}
```

运行结果：

```text
true
true
```

### operator func !=(IPAddress)

```cangjie
public operator func !=(other: IPAddress): Bool
```

功能：判断两个 [IPAddress](net_package_classes.md#class-ipaddress) 对象是否不等。

参数：

- other: [IPAddress](net_package_classes.md#class-ipaddress) - 参与比较的 [IPAddress](net_package_classes.md#class-ipaddress) 对象。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 如果两个 [IPAddress](net_package_classes.md#class-ipaddress) 对象不等，则返回 `true`；否则，返回 `false`。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    let ip1: IPAddress = IPAddress.parse("192.168.1.2")
    let ip2: IPAddress = IPAddress.parse("192.168.1.2")
    let ip3: IPAddress = IPAddress.parse("192.168.1.3")

    println("ip1 != ip2: ${ip1 != ip2}")
    println("ip1 != ip3: ${ip1 != ip3}")

    let ipv6_1: IPAddress = IPAddress.parse("2001:0250:1006:dff0:4913:2aa5:8075:7c10")
    let ipv6_2: IPAddress = IPAddress.parse("2001:0250:1006:dff0:4913:2aa5:8075:7c10")
    let ipv6_3: IPAddress = IPAddress.parse("2001:0250:1006:dff0:4913:2aa5:8075:7c11")

    println("ipv6_1 != ipv6_2: ${ipv6_1 != ipv6_2}")
    println("ipv6_1 != ipv6_3: ${ipv6_1 != ipv6_3}")
}
```

运行结果：

```text
ip1 != ip2: false
ip1 != ip3: true
ipv6_1 != ipv6_2: false
ipv6_1 != ipv6_3: true
```

### operator func ==(IPAddress)

```cangjie
public operator func ==(other: IPAddress): Bool
```

功能：判断两个 [IPAddress](net_package_classes.md#class-ipaddress) 对象是否相等。

参数：

- other: [IPAddress](net_package_classes.md#class-ipaddress) - 参与比较的 [IPAddress](net_package_classes.md#class-ipaddress) 对象。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 如果两个 [IPAddress](net_package_classes.md#class-ipaddress) 对象相等，则返回 `true`；否则，返回 `false`。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    let ip1: IPAddress = IPAddress.parse("192.168.1.2")
    let ip2: IPAddress = IPAddress.parse("192.168.1.2")
    let ip3: IPAddress = IPAddress.parse("192.168.1.3")

    println("ip1 == ip2: ${ip1 == ip2}")
    println("ip1 == ip3: ${ip1 == ip3}")

    let ipv6_1: IPAddress = IPAddress.parse("2001:0250:1006:dff0:4913:2aa5:8075:7c10")
    let ipv6_2: IPAddress = IPAddress.parse("2001:0250:1006:dff0:4913:2aa5:8075:7c10")
    let ipv6_3: IPAddress = IPAddress.parse("2001:0250:1006:dff0:4913:2aa5:8075:7c11")

    println("ipv6_1 == ipv6_2: ${ipv6_1 == ipv6_2}")
    println("ipv6_1 == ipv6_3: ${ipv6_1 == ipv6_3}")
}
```

运行结果：

```text
ip1 == ip2: true
ip1 == ip3: false
ipv6_1 == ipv6_2: true
ipv6_1 == ipv6_3: false
```

## class IPPrefix

```cangjie
sealed abstract class IPPrefix <: Equatable<IPPrefix> & Hashable & ToString
```

功能：这个类表示一个 IP 前缀，即一个连续的 IP 地址块，边界为 2 的幂（也称为“IP 子网”）。

一个 IP 前缀由两条信息指定：

- 起始 IP 地址（IPv4 或 IPv6）。这是前缀的第一个 IP 地址。
- 前缀长度。这通过指定 IP 地址中的位数来指定前缀的长度，从网络字节顺序中的最高有效位开始，对于前缀中的所有地址都是恒定的。

父类型：

- [Equatable](../../core/core_package_api/core_package_interfaces.md#interface-equatablet)\<[IPPrefix](#class-ipprefix)>
- [Hashable](../../core/core_package_api/core_package_interfaces.md#interface-hashable)
- [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring)

### prop address

```cangjie
public prop address: IPAddress
```

功能：获取构造当前 [IPPrefix](net_package_classes.md#class-ipprefix) 对象时的 [IPAddress](net_package_classes.md#class-ipaddress) 地址。

类型：[IPAddress](net_package_classes.md#class-ipaddress)

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    let v4: IPPrefix = IPPrefix.parse("192.168.1.2/24")
    println("v4 address: ${v4.address}")
}
```

运行结果：

```text
v4 address: 192.168.1.2
```

### prop prefixLength

```cangjie
public prop prefixLength: UInt8
```

功能：获取前缀长度。

类型：[UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8)

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    let v4: IPPrefix = IPPrefix.parse("192.168.1.2/24")
    println("v4 prefixLength: ${v4.prefixLength}")
}
```

运行结果：

```text
v4 prefixLength: 24
```

### static func parse(String)

```cangjie
public static func parse(s: String): IPPrefix
```

功能：将 IP 协议的 Socket 字符串转换为 [IPPrefix](net_package_classes.md#class-ipprefix) 对象。

参数：

- s: [String](../../core/core_package_api/core_package_structs.md#struct-string) - IP 协议的 Socket 字符串。

返回值：

- [IPPrefix](net_package_classes.md#class-ipprefix) - [IPPrefix](net_package_classes.md#class-ipprefix) 对象。

异常：

- [IllegalFormatException](../../core/core_package_api/core_package_exceptions.md#class-illegalformatexception) - 如果不是合法字符串，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    let v4: IPPrefix = IPPrefix.parse("192.168.1.2/24")
    let v6: IPPrefix = IPPrefix.parse("2001:0250:1006:dff0:4913:2aa5:8075:7c10/32")
    println("IPv4前缀: ${v4}")
    println("IPv6前缀: ${v6}")
}
```

运行结果：

```text
IPv4前缀: 192.168.1.2/24
IPv6前缀: 2001:250:1006:dff0:4913:2aa5:8075:7c10/32
```

### static func tryParse(String)

```cangjie
public static func tryParse(s: String): ?IPPrefix
```

功能：将 IP 协议的 Socket 字符串转换为 [IPPrefix](net_package_classes.md#class-ipprefix) 对象，如果不是合法字符串，则返回 `None`。

参数：

- s: [String](../../core/core_package_api/core_package_structs.md#struct-string) - IP 协议的 Socket 字符串。

返回值：

- ?[IPPrefix](net_package_classes.md#class-ipprefix) - ?[IPPrefix](net_package_classes.md#class-ipprefix) 对象。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    let v4: ?IPPrefix = IPPrefix.tryParse("192.168.1.2/24")
    let v6: ?IPPrefix = IPPrefix.tryParse("2001:0250:1006:dff0:4913:2aa5:8075:7c10/32")
    println("IPv4前缀: ${v4}")
    println("IPv6前缀: ${v6}")
}
```

运行结果：

```text
IPv4前缀: Some(192.168.1.2/24)
IPv6前缀: Some(2001:250:1006:dff0:4913:2aa5:8075:7c10/32)
```

### func broadcast()

```cangjie
public open func broadcast(): IPAddress
```

功能：返回此 [IPPrefix](net_package_classes.md#class-ipprefix) 地址的广播地址。

返回值：

- [IPAddress](net_package_classes.md#class-ipaddress) - 此 [IPPrefix](net_package_classes.md#class-ipprefix) 地址的广播地址。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    let prefix: IPPrefix = IPPrefix.parse("192.168.1.2/24")
    let broadcast: IPAddress = prefix.broadcast()
    println("广播地址: ${broadcast}")
}
```

运行结果：

```text
广播地址: 192.168.1.255
```

### func contains(IPAddress)

```cangjie
public func contains(other: IPAddress): Bool
```

功能：此 [IPPrefix](net_package_classes.md#class-ipprefix) 地址是否包含指定的 [IPAddress](net_package_classes.md#class-ipaddress) 地址。

参数：

- other: [IPAddress](net_package_classes.md#class-ipaddress) - 指定的 [IPAddress](net_package_classes.md#class-ipaddress) 地址。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回 true 表示包含指定的 [IPAddress](net_package_classes.md#class-ipaddress) 地址，false 表示不包含。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    let prefix: IPPrefix = IPPrefix.parse("192.168.1.0/24")
    let ip1: IPAddress = IPAddress.parse("192.168.1.100")
    let ip2: IPAddress = IPAddress.parse("192.168.2.100")

    println("前缀 ${prefix} 包含IP ${ip1}: ${prefix.contains(ip1)}")
    println("前缀 ${prefix} 包含IP ${ip2}: ${prefix.contains(ip2)}")
}
```

运行结果：

```text
前缀 192.168.1.0/24 包含IP 192.168.1.100: true
前缀 192.168.1.0/24 包含IP 192.168.2.100: false
```

### func contains(IPPrefix)

```cangjie
public func contains(other: IPPrefix): Bool
```

功能：此 [IPPrefix](net_package_classes.md#class-ipprefix) 地址是否包含指定的 [IPPrefix](net_package_classes.md#class-ipprefix) 地址。

参数：

- other: [IPPrefix](net_package_classes.md#class-ipprefix) - 指定的 [IPPrefix](net_package_classes.md#class-ipprefix) 地址。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回 true 表示包含指定的 [IPPrefix](net_package_classes.md#class-ipprefix) 地址，false 表示不包含。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    let prefix1: IPPrefix = IPPrefix.parse("192.168.0.0/16")
    let prefix2: IPPrefix = IPPrefix.parse("192.168.1.0/24")
    let prefix3: IPPrefix = IPPrefix.parse("10.0.0.0/8")

    println("前缀 ${prefix1} 包含前缀 ${prefix2}: ${prefix1.contains(prefix2)}")
    println("前缀 ${prefix1} 包含前缀 ${prefix3}: ${prefix1.contains(prefix3)}")
}
```

运行结果：

```text
前缀 192.168.0.0/16 包含前缀 192.168.1.0/24: true
前缀 192.168.0.0/16 包含前缀 10.0.0.0/8: false
```

### func hostmask()

```cangjie
public open func hostmask(): IPAddress
```

功能：返回此 [IPPrefix](net_package_classes.md#class-ipprefix) 地址的主机网络掩码地址。

返回值：

- [IPAddress](net_package_classes.md#class-ipaddress) - 此 [IPPrefix](net_package_classes.md#class-ipprefix) 地址的主机网络掩码地址。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    let prefix: IPPrefix = IPPrefix.parse("192.168.1.2/24")
    let hostmask: IPAddress = prefix.hostmask()
    println("主机掩码: ${hostmask}")
}
```

运行结果：

```text
主机掩码: 0.0.0.255
```

### func masked()

```cangjie
public open func masked(): IPPrefix
```

功能：返回此 [IPPrefix](net_package_classes.md#class-ipprefix) 地址根据前缀长度进行掩码后的 [IPPrefix](net_package_classes.md#class-ipprefix) 地址，比如 `192.168.12.34/16` 返回 `192.168.0.0/16`；`fc00::1:2:3:4/16` 返回 `fc00::/16`。

返回值：

- [IPPrefix](net_package_classes.md#class-ipprefix) - 此 [IPPrefix](net_package_classes.md#class-ipprefix) 地址根据前缀长度进行掩码后的 [IPPrefix](net_package_classes.md#class-ipprefix) 地址。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    let prefix: IPPrefix = IPPrefix.parse("192.168.1.100/24")
    let masked: IPPrefix = prefix.masked()
    println("掩码后的前缀: ${masked}")

    let prefixV6: IPPrefix = IPPrefix.parse("fc00::1:2:3:4/16")
    let maskedV6: IPPrefix = prefixV6.masked()
    println("掩码后的IPv6前缀: ${maskedV6}")
}
```

运行结果：

```text
掩码后的前缀: 192.168.1.0/24
掩码后的IPv6前缀: fc00::/16
```

### func netmask()

```cangjie
public open func netmask(): IPAddress
```

功能：返回此 [IPPrefix](net_package_classes.md#class-ipprefix) 地址的网络掩码地址。

返回值：

- [IPAddress](net_package_classes.md#class-ipaddress) - 此 [IPPrefix](net_package_classes.md#class-ipprefix) 地址的网络掩码地址。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    let prefix: IPPrefix = IPPrefix.parse("192.168.1.2/24")
    let netmask: IPAddress = prefix.netmask()
    println("网络掩码: ${netmask}")
}
```

运行结果：

```text
网络掩码: 255.255.255.0
```

### func network()

```cangjie
public open func network(): IPAddress
```

功能：返回此 [IPPrefix](net_package_classes.md#class-ipprefix) 地址的网络地址。

返回值：

- [IPAddress](net_package_classes.md#class-ipaddress) - 此 [IPPrefix](net_package_classes.md#class-ipprefix) 地址的网络地址。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    let prefix: IPPrefix = IPPrefix.parse("192.168.1.100/24")
    let network: IPAddress = prefix.network()
    println("网络地址: ${network}")
}
```

运行结果：

```text
网络地址: 192.168.1.0
```

### func overlaps(IPPrefix)

```cangjie
public func overlaps(other: IPPrefix): Bool
```

功能：此 [IPPrefix](net_package_classes.md#class-ipprefix) 地址是不是和指定的 [IPPrefix](net_package_classes.md#class-ipprefix) 地址有重叠。

参数：

- other: [IPPrefix](net_package_classes.md#class-ipprefix) - 指定的 [IPPrefix](net_package_classes.md#class-ipprefix) 地址。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回 true 表示和指定的 [IPPrefix](net_package_classes.md#class-ipprefix) 地址有重叠，false 表示没有重叠。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    let prefix1: IPPrefix = IPPrefix.parse("192.168.1.0/24")
    let prefix2: IPPrefix = IPPrefix.parse("192.168.1.128/25")
    let prefix3: IPPrefix = IPPrefix.parse("10.0.0.0/8")

    println("前缀 ${prefix1} 与前缀 ${prefix2} 重叠: ${prefix1.overlaps(prefix2)}")
    println("前缀 ${prefix1} 与前缀 ${prefix3} 重叠: ${prefix1.overlaps(prefix3)}")
}
```

运行结果：

```text
前缀 192.168.1.0/24 与前缀 192.168.1.128/25 重叠: true
前缀 192.168.1.0/24 与前缀 10.0.0.0/8 重叠: false
```

### func toString()

```cangjie
public func toString(): String
```

功能：返回当前 [IPPrefix](net_package_classes.md#class-ipprefix)  的文本表示字符串。

返回值：

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - 当前 [IPPrefix](net_package_classes.md#class-ipprefix) 的文本表示字符串，比如 `192.168.0.0/16` 或 `fc00::/16`。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    let v4: IPPrefix = IPAddress.parse("192.168.1.2").getPrefix(24)
    let v6: IPPrefix = IPAddress.parse("2001:0250:1006:dff0:4913:2aa5:8075:7c10").getPrefix(32)
    println("IPv4前缀: ${v4}")
    println("IPv6前缀: ${v6}")
}
```

运行结果：

```text
IPv4前缀: 192.168.1.2/24
IPv6前缀: 2001:250:1006:dff0:4913:2aa5:8075:7c10/32
```

### operator func !=(IPPrefix)

```cangjie
public operator func !=(other: IPPrefix): Bool
```

功能：判断两个 [IPPrefix](net_package_classes.md#class-ipprefix) 对象是否不等。

参数：

- other: [IPPrefix](net_package_classes.md#class-ipprefix) - 参与比较的 [IPPrefix](net_package_classes.md#class-ipprefix) 对象。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 如果两个 [IPPrefix](net_package_classes.md#class-ipprefix) 对象不等，则返回 `true`；否则，返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    let prefix1: IPPrefix = IPPrefix.parse("192.168.1.0/24")
    let prefix2: IPPrefix = IPPrefix.parse("192.168.1.0/24")
    let prefix3: IPPrefix = IPPrefix.parse("192.168.2.0/24")

    println("prefix1 != prefix2: ${prefix1 != prefix2}")
    println("prefix1 != prefix3: ${prefix1 != prefix3}")
}
```

运行结果：

```text
prefix1 != prefix2: false
prefix1 != prefix3: true
```

### operator func ==(IPPrefix)

```cangjie
public operator func ==(other: IPPrefix): Bool
```

功能：判断两个 [IPPrefix](net_package_classes.md#class-ipprefix) 对象是否相等。

参数：

- other: [IPPrefix](net_package_classes.md#class-ipprefix) - 参与比较的 [IPPrefix](net_package_classes.md#class-ipprefix) 对象。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 如果两个 [IPPrefix](net_package_classes.md#class-ipprefix) 对象相等，则返回 `true`；否则，返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    let prefix1: IPPrefix = IPPrefix.parse("192.168.1.0/24")
    let prefix2: IPPrefix = IPPrefix.parse("192.168.1.0/24")
    let prefix3: IPPrefix = IPPrefix.parse("192.168.2.0/24")

    println("prefix1 == prefix2: ${prefix1 == prefix2}")
    println("prefix1 == prefix3: ${prefix1 == prefix3}")
}
```

运行结果：

```text
prefix1 == prefix2: true
prefix1 == prefix3: false
```

## class IPSocketAddress

```cangjie
public class IPSocketAddress <: SocketAddress & Equatable<IPSocketAddress>{
    public init(address: Array<Byte>, port: UInt16)
    public init(address: String, port: UInt16)
    public init(address: IPAddress, port: UInt16)
}
```

功能：此类实现了 IP 协议 Socket 地址（IP 地址+端口号）。它提供了一个不可变的对象，用于 Socket  的绑定、连接或作为返回值。

父类型：

- [SocketAddress](#class-socketaddress)
- [Equatable](../../core/core_package_api/core_package_interfaces.md#interface-equatablet)\<[IPSocketAddress](#class-ipsocketaddress)>

### prop address

```cangjie
public prop address: IPAddress
```

功能：获取当前 [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) 对象的 IP 地址。

类型：[IPAddress](net_package_classes.md#class-ipaddress)

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    let socketAddrV4 = IPSocketAddress.parse("192.168.1.2:8080")
    let socketAddrV6 = IPSocketAddress.parse("[2001:0250:1006:dff0:4913:2aa5:8075:7c10]:8080")

    println("IPv4地址: ${socketAddrV4.address}")
    println("IPv6地址: ${socketAddrV6.address}")
}
```

运行结果：

```text
IPv4地址: 192.168.1.2
IPv6地址: 2001:250:1006:dff0:4913:2aa5:8075:7c10
```

### prop family

```cangjie
public prop family: AddressFamily
```

功能：获取当前 [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) 对象的地址族。

类型：[AddressFamily](net_package_structs.md#struct-addressfamily)

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    let socketAddrV4 = IPSocketAddress.parse("192.168.1.2:8080")
    let socketAddrV6 = IPSocketAddress.parse("[2001:0250:1006:dff0:4913:2aa5:8075:7c10]:8080")

    println("IPv4地址族: ${socketAddrV4.family}")
    println("IPv6地址族: ${socketAddrV6.family}")
}
```

运行结果：

```text
IPv4地址族: INET
IPv6地址族: INET6
```

### prop port

```cangjie
public prop port: UInt16
```

功能：获取当前 [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) 对象的端口。

类型：[UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16)

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    let socketAddrV4 = IPSocketAddress.parse("192.168.1.2:8080")
    let socketAddrV6 = IPSocketAddress.parse("[2001:0250:1006:dff0:4913:2aa5:8075:7c10]:8080")

    println("IPv4端口: ${socketAddrV4.port}")
    println("IPv6端口: ${socketAddrV6.port}")
}
```

运行结果：

```text
IPv4端口: 8080
IPv6端口: 8080
```

### prop size

```cangjie
public prop size: Int64
```

功能：获取当前 [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) 对象的原始字节长度。

类型：[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    let socketAddrV4 = IPSocketAddress.parse("192.168.1.2:8080")
    let socketAddrV6 = IPSocketAddress.parse("[2001:0250:1006:dff0:4913:2aa5:8075:7c10]:8080")

    println("IPv4 Socket地址大小: ${socketAddrV4.size}")
    println("IPv6 Socket地址大小: ${socketAddrV6.size}")
}
```

运行结果：

```text
IPv4 Socket地址大小: 16
IPv6 Socket地址大小: 28
```

### init(Array\<Byte>, UInt16)

```cangjie
public init(address: Array<Byte>, port: UInt16)
```

功能：根据大端序 [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> 表示的 IP 地址和本机序 [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) 端口构造 [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) 地址。

参数：

- address: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)>  - 大端序 IP 地址。
- port: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 本机序端口。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 如果 address 不合法，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    // IPv4地址: 192.168.1.2 对应的大端序字节数组
    let ipv4Bytes = [192u8, 168u8, 1u8, 2u8]
    let port = 8080u16

    // 使用字节数组和端口创建IPSocketAddress
    let socketAddr = IPSocketAddress(ipv4Bytes, port)

    println("IPv4 Socket地址: ${socketAddr}")
    println("IP地址: ${socketAddr.address}")
    println("端口: ${socketAddr.port}")
}
```

运行结果：

```text
IPv4 Socket地址: 192.168.1.2:8080
IP地址: 192.168.1.2
端口: 8080
```

### init(IPAddress, UInt16)

```cangjie
public init(address: IPAddress, port: UInt16)
```

功能：根据 [IPAddress](net_package_classes.md#class-ipaddress) 对象和 本机序 [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) 端口构造 [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) 地址。

参数：

- address: [IPAddress](net_package_classes.md#class-ipaddress) - [IPAddress](net_package_classes.md#class-ipaddress) 对象。
- port: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 本机序端口。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    // 创建IPAddress对象
    let ipv4Address = IPAddress.parse("192.168.1.2")
    let ipv6Address = IPAddress.parse("2001:0250:1006:dff0:4913:2aa5:8075:7c10")

    // 使用IPAddress对象和端口创建IPSocketAddress
    let socketAddrV4 = IPSocketAddress(ipv4Address, 8080u16)
    let socketAddrV6 = IPSocketAddress(ipv6Address, 8080u16)

    println("IPv4 Socket地址: ${socketAddrV4}")
    println("IPv4地址: ${socketAddrV4.address}")
    println("IPv4端口: ${socketAddrV4.port}")

    println("IPv6 Socket地址: ${socketAddrV6}")
    println("IPv6地址: ${socketAddrV6.address}")
    println("IPv6端口: ${socketAddrV6.port}")
}
```

运行结果：

```text
IPv4 Socket地址: 192.168.1.2:8080
IPv4地址: 192.168.1.2
IPv4端口: 8080
IPv6 Socket地址: [2001:250:1006:dff0:4913:2aa5:8075:7c10]:8080
IPv6地址: 2001:250:1006:dff0:4913:2aa5:8075:7c10
IPv6端口: 8080
```

### init(String, UInt16)

```cangjie
public init(address: String, port: UInt16)
```

功能：根据字符串表示的 IP 地址和 本机序 [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) 端口构造 [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) 地址。

参数：

- address: [String](../../core/core_package_api/core_package_structs.md#struct-string) - IP 地址字符串。
- port: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 本机序端口。

异常：

- [IllegalFormatException](../../core/core_package_api/core_package_exceptions.md#class-illegalformatexception) - 如果传入的 IP 地址不合法，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    // 使用字符串IP地址和端口创建IPSocketAddress
    let socketAddrV4 = IPSocketAddress("192.168.1.2", 8080u16)
    let socketAddrV6 = IPSocketAddress("2001:0250:1006:dff0:4913:2aa5:8075:7c10", 8080u16)

    println("IPv4 Socket地址: ${socketAddrV4}")
    println("IPv4地址: ${socketAddrV4.address}")
    println("IPv4端口: ${socketAddrV4.port}")

    println("IPv6 Socket地址: ${socketAddrV6}")
    println("IPv6地址: ${socketAddrV6.address}")
    println("IPv6端口: ${socketAddrV6.port}")
}
```

运行结果：

```text
IPv4 Socket地址: 192.168.1.2:8080
IPv4地址: 192.168.1.2
IPv4端口: 8080
IPv6 Socket地址: [2001:250:1006:dff0:4913:2aa5:8075:7c10]:8080
IPv6地址: 2001:250:1006:dff0:4913:2aa5:8075:7c10
IPv6端口: 8080
```

### static func parse(String)

```cangjie
public static func parse(s: String): IPSocketAddress
```

功能：将 IP 协议的 Socket 字符串转换为 [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) 对象。

参数：

- s: [String](../../core/core_package_api/core_package_structs.md#struct-string) - IP 协议的 Socket 字符串。

返回值：

- [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) - [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) 对象。

异常：

- [IllegalFormatException](../../core/core_package_api/core_package_exceptions.md#class-illegalformatexception) - 入参需要是合法的 socket 地址，比如 192.168.0.0:80 或 [fc00::1]:8080，否则抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    let v4: IPSocketAddress = IPSocketAddress.parse("192.168.1.2:8080")
    let v6: IPSocketAddress = IPSocketAddress.parse("[2001:0250:1006:dff0:4913:2aa5:8075:7c10]:8080")
    println("v4.address: ${v4.address}")
    println("v4.port: ${v4.port}")
    println("v6.address: ${v6.address}")
    println("v6.port: ${v6.port}")
    println("v4: ${v4}")
    println("v6: ${v6}")
}
```

运行结果：

```text
v4.address: 192.168.1.2
v4.port: 8080
v6.address: 2001:250:1006:dff0:4913:2aa5:8075:7c10
v6.port: 8080
v4: 192.168.1.2:8080
v6: [2001:250:1006:dff0:4913:2aa5:8075:7c10]:8080
```

### static func tryParse(String)

```cangjie
public static func tryParse(s: String): ?IPSocketAddress
```

功能：将 IP 协议的 Socket 字符串转换为 [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) 对象，如果不是合法字符串，则返回 `None`。

参数：

- s: [String](../../core/core_package_api/core_package_structs.md#struct-string) - IP 协议的 Socket 字符串。

返回值：

- ?[IPSocketAddress](net_package_classes.md#class-ipsocketaddress) - ?[IPSocketAddress](net_package_classes.md#class-ipsocketaddress) 对象。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    let v4: ?IPSocketAddress = IPSocketAddress.tryParse("192.168.1.2:8080")
    let v6: ?IPSocketAddress = IPSocketAddress.tryParse("[2001:0250:1006:dff0:4913:2aa5:8075:7c10]:8080")
    println("v4: ${v4}")
    println("v6: ${v6}")
}
```

运行结果：

```text
v4: Some(192.168.1.2:8080)
v6: Some([2001:250:1006:dff0:4913:2aa5:8075:7c10]:8080)
```

### func getAddressBytes()

```cangjie
public func getAddressBytes(): Array<Byte>
```

功能：返回此 [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) 对象的原始地址的 [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> 表示，内容布局与 `sockaddr_in` 或 `sockaddr_in6` 一致。

返回值：

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) 对象的原始地址的 [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> 表示。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    // 创建IPSocketAddress对象
    let socketAddrV4 = IPSocketAddress.parse("192.168.1.2:8080")
    let socketAddrV6 = IPSocketAddress.parse("[2001:0250:1006:dff0:4913:2aa5:8075:7c10]:8080")

    // 获取地址字节
    let v4Bytes = socketAddrV4.getAddressBytes()
    let v6Bytes = socketAddrV6.getAddressBytes()

    println("IPv4地址字节: ${v4Bytes}")
    println("IPv6地址字节: ${v6Bytes}")
}
```

运行结果：

```text
IPv4地址字节: [2, 0, 31, 144, 192, 168, 1, 2, 0, 0, 0, 0, 0, 0, 0, 0]
IPv6地址字节: [10, 0, 31, 144, 0, 0, 0, 0, 32, 1, 2, 80, 16, 6, 223, 240, 73, 19, 42, 165, 128, 117, 124, 16, 0, 0, 0, 0]
```

### func hashCode()

```cangjie
public func hashCode(): Int64
```

功能：获取 `hashcode` 值。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - `hashcode` 值。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    // 创建IPSocketAddress对象
    let socketAddrV4 = IPSocketAddress.parse("192.168.1.2:8080")
    let socketAddrV6 = IPSocketAddress.parse("[2001:0250:1006:dff0:4913:2aa5:8075:7c10]:8080")

    // 获取hashCode
    let v4HashCode = socketAddrV4.hashCode()
    let v6HashCode = socketAddrV6.hashCode()

    println("IPv4 Socket地址hashCode: ${v4HashCode}")
    println("IPv6 Socket地址hashCode: ${v6HashCode}")
}
```

运行结果：

```text
IPv4 Socket地址hashCode: -756920342309184036
IPv6 Socket地址hashCode: -6218076271351699500
```

### func isIPv4()

```cangjie
public func isIPv4(): Bool
```

功能：判断此 [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) 对象是不是 IPv4 Socket 地址。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回 true 表示是 IPv4 地址，否则返回 false。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    // 创建IPSocketAddress对象
    let socketAddrV4 = IPSocketAddress.parse("192.168.1.2:8080")
    let socketAddrV6 = IPSocketAddress.parse("[2001:0250:1006:dff0:4913:2aa5:8075:7c10]:8080")

    // 检查是否为IPv4地址
    let isV4 = socketAddrV4.isIPv4()
    let isV6 = socketAddrV6.isIPv4()

    println("192.168.1.2:8080 是IPv4地址: ${isV4}")
    println("[2001:0250:1006:dff0:4913:2aa5:8075:7c10]:8080 是IPv4地址: ${isV6}")
}
```

运行结果：

```text
192.168.1.2:8080 是IPv4地址: true
[2001:0250:1006:dff0:4913:2aa5:8075:7c10]:8080 是IPv4地址: false
```

### func isIPv6()

```cangjie
public func isIPv6(): Bool
```

功能：判断此 [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) 对象是不是 IPv6 Socket 地址。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回 true 表示是 IPv6 地址，否则返回 false。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    // 创建IPSocketAddress对象
    let socketAddrV4 = IPSocketAddress.parse("192.168.1.2:8080")
    let socketAddrV6 = IPSocketAddress.parse("[2001:0250:1006:dff0:4913:2aa5:8075:7c10]:8080")

    // 检查是否为IPv6地址
    let isV4 = socketAddrV4.isIPv6()
    let isV6 = socketAddrV6.isIPv6()

    println("192.168.1.2:8080 是IPv6地址: ${isV4}")
    println("[2001:0250:1006:dff0:4913:2aa5:8075:7c10]:8080 是IPv6地址: ${isV6}")
}
```

运行结果：

```text
192.168.1.2:8080 是IPv6地址: false
[2001:0250:1006:dff0:4913:2aa5:8075:7c10]:8080 是IPv6地址: true
```

### func toString()

```cangjie
public func toString(): String
```

功能：返回当前 [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) 的文本表示字符串。

返回值：

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - 当前 [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) 的文本表示字符串，比如 `192.168.1.2:8080` 或 `[fc00::/16]:8080` 。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    let v4: IPSocketAddress = IPSocketAddress.parse("192.168.1.2:8080")
    let v6: IPSocketAddress = IPSocketAddress.parse("[2001:0250:1006:dff0:4913:2aa5:8075:7c10]:8080")
    println("v4: ${v4}")
    println("v6: ${v6}")
}
```

运行结果：

```text
v4: 192.168.1.2:8080
v6: [2001:250:1006:dff0:4913:2aa5:8075:7c10]:8080
```

### operator func !=(IPSocketAddress)

```cangjie
public operator func !=(other: IPSocketAddress): Bool
```

功能：判断两个 [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) 对象是否不等。

参数：

- other: [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) - 参与比较的 [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) 对象。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 如果两个 [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) 对象不等，则返回 `true`；否则，返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    // 创建IPSocketAddress对象
    let socketAddr1 = IPSocketAddress.parse("192.168.1.2:8080")
    let socketAddr2 = IPSocketAddress.parse("192.168.1.2:8080")
    let socketAddr3 = IPSocketAddress.parse("192.168.1.3:8080")

    // 比较IPSocketAddress对象是否不等
    let isNotEqual1 = socketAddr1 != socketAddr2
    let isNotEqual2 = socketAddr1 != socketAddr3

    println("socketAddr1 != socketAddr2: ${isNotEqual1}")
    println("socketAddr1 != socketAddr3: ${isNotEqual2}")
}
```

运行结果：

```text
socketAddr1 != socketAddr2: false
socketAddr1 != socketAddr3: true
```

### operator func ==(IPSocketAddress)

```cangjie
public operator func ==(other: IPSocketAddress): Bool
```

功能：判断两个 [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) 对象是否相等。

参数：

- other: [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) - 参与比较的 [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) 对象。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 如果两个 [IPSocketAddress](net_package_classes.md#class-ipsocketaddress) 对象相等，则返回 `true`；否则，返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    // 创建IPSocketAddress对象
    let socketAddr1 = IPSocketAddress.parse("192.168.1.2:8080")
    let socketAddr2 = IPSocketAddress.parse("192.168.1.2:8080")
    let socketAddr3 = IPSocketAddress.parse("192.168.1.3:8080")

    // 比较IPSocketAddress对象是否相等
    let isEqual1 = socketAddr1 == socketAddr2
    let isEqual2 = socketAddr1 == socketAddr3

    println("socketAddr1 == socketAddr2: ${isEqual1}")
    println("socketAddr1 == socketAddr3: ${isEqual2}")
}
```

运行结果：

```text
socketAddr1 == socketAddr2: true
socketAddr1 == socketAddr3: false
```

## class IPv4Address

```cangjie
public class IPv4Address <: IPAddress & ToString & Equatable<IPv4Address> & LessOrEqual<IPv4Address> {
    public static let localhost: IPv4Address = IPv4Address(0x7F, 0, 0, 0x01)
    public static let unspecified: IPv4Address = IPv4Address(0, 0, 0, 0)
    public static let broadcast: IPv4Address = IPv4Address(0xFF, 0xFF, 0xFF, 0xFF)
    public init(bits: UInt32)
    public init(a: Byte, b: Byte, c: Byte, d: Byte)
}
```

功能：此类表示 Internet 协议版本 4（IPv4）地址。由 [RFC 790](https://datatracker.ietf.org/doc/html/rfc790)、[RFC 1918](https://datatracker.ietf.org/doc/html/rfc1918) 和 [RFC 2365](https://datatracker.ietf.org/doc/html/rfc2365) 定义。

父类型：

- [IPAddress](#class-ipaddress)
- [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring)
- [Equatable](../../core/core_package_api/core_package_interfaces.md#interface-equatablet)\<[IPv4Address](#class-ipv4address)>
- [LessOrEqual](../../core/core_package_api/core_package_interfaces.md#interface-lessorequalt)\<[IPv4Address](#class-ipv4address)>

### static let broadcast

```cangjie
public static let broadcast: IPv4Address = IPv4Address(0xFF, 0xFF, 0xFF, 0xFF)
```

功能：返回 [IPv4Address](net_package_classes.md#class-ipv4address) 的广播地址：`255.255.255.255`。

类型：[IPv4Address](net_package_classes.md#class-ipv4address)

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    let broadcast = IPv4Address.broadcast
    println("broadcast: ${broadcast}")
}
```

运行结果：

```text
broadcast: 255.255.255.255
```

### static let localhost

```cangjie
public static let localhost: IPv4Address = IPv4Address(0x7F, 0, 0, 0x01)
```

功能：返回 [IPv4Address](net_package_classes.md#class-ipv4address) 的 `localhost` 地址：`127.0.0.1`。

类型：[IPv4Address](net_package_classes.md#class-ipv4address)

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    let localhost = IPv4Address.localhost
    println("localhost: ${localhost}")
}
```

运行结果：

```text
localhost: 127.0.0.1
```

### static let unspecified

```cangjie
public static let unspecified: IPv4Address = IPv4Address(0, 0, 0, 0)
```

功能：返回表示未指定的 [IPv4Address](net_package_classes.md#class-ipv4address) 地址：`0.0.0.0`，这对应于其他语言中的常量 `INADDR_ANY`。

类型：[IPv4Address](net_package_classes.md#class-ipv4address)

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    let unspecified = IPv4Address.unspecified
    println("unspecified: ${unspecified}")
}
```

运行结果：

```text
unspecified: 0.0.0.0
```

### init(Byte, Byte, Byte, Byte)

```cangjie
public init(a: Byte, b: Byte, c: Byte, d: Byte)
```

功能：根据 4 个 8-bit 字节构造 [IPv4Address](net_package_classes.md#class-ipv4address) 地址对象，文本将表示为 `a.b.c.d`。

参数：

- a: [Byte](../../core/core_package_api/core_package_types.md#type-byte) - 8-bit 字节。
- b: [Byte](../../core/core_package_api/core_package_types.md#type-byte) - 8-bit 字节。
- c: [Byte](../../core/core_package_api/core_package_types.md#type-byte) - 8-bit 字节。
- d: [Byte](../../core/core_package_api/core_package_types.md#type-byte) - 8-bit 字节。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    // 使用4个字节创建IPv4Address对象
    let ipv4Addr = IPv4Address(192u8, 168u8, 1u8, 2u8)

    println("IPv4地址: ${ipv4Addr}")
}
```

运行结果：

```text
IPv4地址: 192.168.1.2
```

### init(UInt32)

```cangjie
public init(bits: UInt32)
```

功能：根据本机字节序 [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) 值构造 [IPv4Address](net_package_classes.md#class-ipv4address) 地址。

参数：

- bits: [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 本机字节序 [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) 值。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    // 使用UInt32值创建IPv4Address对象
    let ipv4Addr = IPv4Address(0xC0A80102u32) // 192.168.1.2

    println("IPv4地址: ${ipv4Addr}")
}
```

运行结果：

```text
IPv4地址: 192.168.1.2
```

### static func readBigEndian(Array\<Byte>)

```cangjie
public static func readBigEndian(buffer: Array<Byte>): IPv4Address
```

功能：从字节数组中以大端序的方式读取一个 [IPv4Address](net_package_classes.md#class-ipv4address) 对象。

参数：

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 缓冲区，用于存放待读取的数据。

返回值：

- [IPv4Address](net_package_classes.md#class-ipv4address) - [IPv4Address](net_package_classes.md#class-ipv4address) 对象。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当 buffer 太小，不足以读出 [IPv4Address](net_package_classes.md#class-ipv4address) 值时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    // 创建一个包含IPv4地址的大端序字节数组
    let buffer = [192u8, 168u8, 1u8, 2u8]

    // 从字节数组中读取IPv4Address对象
    let ipv4Addr = IPv4Address.readBigEndian(buffer)

    println("从字节数组读取的IPv4地址: ${ipv4Addr}")
}
```

运行结果：

```text
从字节数组读取的IPv4地址: 192.168.1.2
```

### func getPrefix(UInt8)

```cangjie
public func getPrefix(prefixLen: UInt8): IPPrefix
```

功能：将 [IPv4Address](net_package_classes.md#class-ipv4address) 地址根据指定的网络前缀长度创建一个网络前缀对象。

参数：

- prefixLen: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 网络前缀长度，必须 \>= 0 且 <= 32。

返回值：

- [IPPrefix](net_package_classes.md#class-ipprefix) - 网络前缀对象。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 如果 prefixLen 大小超出范围，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    // 创建一个IPv4Address对象
    let ipv4Addr = IPv4Address(192u8, 168u8, 1u8, 2u8)

    // 根据指定的网络前缀长度创建网络前缀对象
    let prefix = ipv4Addr.getPrefix(24u8)

    println("IPv4地址: ${ipv4Addr}")
    println("网络前缀: ${prefix}")
}
```

运行结果：

```text
IPv4地址: 192.168.1.2
网络前缀: 192.168.1.2/24
```

### func isBroadcast()

```cangjie
public func isBroadcast(): Bool
```

功能：判断此 [IPv4Address](net_package_classes.md#class-ipv4address) 对象是不是广播地址。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回 true 表示是广播地址，否则返回 false。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    // 创建一个广播地址
    let broadcastAddr = IPv4Address.broadcast

    // 创建一个普通地址
    let normalAddr = IPv4Address(192u8, 168u8, 1u8, 2u8)

    // 检查是否为广播地址
    let isBroadcast1 = broadcastAddr.isBroadcast()
    let isBroadcast2 = normalAddr.isBroadcast()

    println("255.255.255.255是广播地址: ${isBroadcast1}")
    println("192.168.1.2是广播地址: ${isBroadcast2}")
}
```

运行结果：

```text
255.255.255.255是广播地址: true
192.168.1.2是广播地址: false
```

### func isGlobalUnicast()

```cangjie
public func isGlobalUnicast(): Bool
```

功能：判断此 [IPv4Address](net_package_classes.md#class-ipv4address) 对象是不是全局单播地址。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回 true 表示是全局单播地址，否则返回 false。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    // 创建一个全局单播地址
    let globalAddr = IPv4Address(8u8, 8u8, 8u8, 8u8) // 8.8.8.8 (Google DNS)

    // 创建一个私有地址
    let privateAddr = IPv4Address(192u8, 168u8, 1u8, 2u8)

    // 检查是否为全局单播地址
    let isGlobal1 = globalAddr.isGlobalUnicast()
    let isGlobal2 = privateAddr.isGlobalUnicast()

    println("8.8.8.8是全局单播地址: ${isGlobal1}")
    println("192.168.1.2是全局单播地址: ${isGlobal2}")
}
```

运行结果：

```text
8.8.8.8是全局单播地址: true
192.168.1.2是全局单播地址: false
```

### func isLinkLocal()

```cangjie
public func isLinkLocal(): Bool
```

功能：判断此 [IPv4Address](net_package_classes.md#class-ipv4address) 对象是不是链路本地地址。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回 true 表示是链路本地地址，否则返回 false。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    // 创建一个链路本地地址 (169.254.x.x)
    let linkLocalAddr = IPv4Address(169u8, 254u8, 1u8, 2u8)

    // 创建一个普通地址
    let normalAddr = IPv4Address(192u8, 168u8, 1u8, 2u8)

    // 检查是否为链路本地地址
    let isLinkLocal1 = linkLocalAddr.isLinkLocal()
    let isLinkLocal2 = normalAddr.isLinkLocal()

    println("169.254.1.2是链路本地地址: ${isLinkLocal1}")
    println("192.168.1.2是链路本地地址: ${isLinkLocal2}")
}
```

运行结果：

```text
169.254.1.2是链路本地地址: true
192.168.1.2是链路本地地址: false
```

### func isLoopback()

```cangjie
public func isLoopback(): Bool
```

功能：判断此 [IPv4Address](net_package_classes.md#class-ipv4address) 对象是不是环回地址。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回 true 表示是环回地址，否则返回 false。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    // 创建一个环回地址
    let loopbackAddr = IPv4Address.localhost

    // 创建一个普通地址
    let normalAddr = IPv4Address(192u8, 168u8, 1u8, 2u8)

    // 检查是否为环回地址
    let isLoopback1 = loopbackAddr.isLoopback()
    let isLoopback2 = normalAddr.isLoopback()

    println("127.0.0.1是环回地址: ${isLoopback1}")
    println("192.168.1.2是环回地址: ${isLoopback2}")
}
```

运行结果：

```text
127.0.0.1是环回地址: true
192.168.1.2是环回地址: false
```

### func isMulticast()

```cangjie
public func isMulticast(): Bool
```

功能：判断此 [IPv4Address](net_package_classes.md#class-ipv4address) 对象是不是多播地址。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回 true 表示是多播地址，否则返回 false。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    // 创建一个多播地址 (224.0.0.1)
    let multicastAddr = IPv4Address(224u8, 0u8, 0u8, 1u8)

    // 创建一个普通地址
    let normalAddr = IPv4Address(192u8, 168u8, 1u8, 2u8)

    // 检查是否为多播地址
    let isMulticast1 = multicastAddr.isMulticast()
    let isMulticast2 = normalAddr.isMulticast()

    println("224.0.0.1是多播地址: ${isMulticast1}")
    println("192.168.1.2是多播地址: ${isMulticast2}")
}
```

运行结果：

```text
224.0.0.1是多播地址: true
192.168.1.2是多播地址: false
```

### func isPrivate()

```cangjie
public func isPrivate(): Bool
```

功能：判断此 [IPv4Address](net_package_classes.md#class-ipv4address) 对象是不是私有地址。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回 true 表示是私有地址，否则返回 false。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    // 创建一个私有地址 (192.168.x.x)
    let privateAddr = IPv4Address(192u8, 168u8, 1u8, 2u8)

    // 创建一个公网地址
    let publicAddr = IPv4Address(8u8, 8u8, 8u8, 8u8) // Google DNS

    // 检查是否为私有地址
    let isPrivate1 = privateAddr.isPrivate()
    let isPrivate2 = publicAddr.isPrivate()

    println("192.168.1.2是私有地址: ${isPrivate1}")
    println("8.8.8.8是私有地址: ${isPrivate2}")
}
```

运行结果：

```text
192.168.1.2是私有地址: true
8.8.8.8是私有地址: false
```

### func isUnspecified()

```cangjie
public func isUnspecified(): Bool
```

功能：判断此 [IPv4Address](net_package_classes.md#class-ipv4address) 对象是不是“未指定” IP 地址。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回 true 表示是“未指定” IP 地址，否则返回 false。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    // 创建一个未指定地址
    let unspecifiedAddr = IPv4Address.unspecified

    // 创建一个普通地址
    let normalAddr = IPv4Address(192u8, 168u8, 1u8, 2u8)

    // 检查是否为未指定地址
    let isUnspecified1 = unspecifiedAddr.isUnspecified()
    let isUnspecified2 = normalAddr.isUnspecified()

    println("0.0.0.0是未指定地址: ${isUnspecified1}")
    println("192.168.1.2是未指定地址: ${isUnspecified2}")
}
```

运行结果：

```text
0.0.0.0是未指定地址: true
192.168.1.2是未指定地址: false
```

### func toBits()

```cangjie
public func toBits(): UInt32
```

功能：此 [IPv4Address](net_package_classes.md#class-ipv4address) 地址转换为本机字节序的 [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) 值。

返回值：

- [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 本机字节序的 [UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) 值。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    // 创建一个IPv4地址
    let ipv4Addr = IPv4Address(192u8, 168u8, 1u8, 2u8)

    // 将IPv4地址转换为UInt32值
    let bits = ipv4Addr.toBits()

    println("IPv4地址: ${ipv4Addr}")
    println("对应的UInt32值: ${bits}")
}
```

运行结果：

```text
IPv4地址: 192.168.1.2
对应的UInt32值: 3232235778
```

### func toIPv6Compatible()

```cangjie
public func toIPv6Compatible(): IPv6Address
```

功能：此 [IPv4Address](net_package_classes.md#class-ipv4address) 地址转换为 IPv4 兼容的 [IPv6Address](net_package_classes.md#class-ipv4address) 地址。`a.b.c.d` 变为 `::a.b.c.d`。

返回值：

- [IPv6Address](net_package_classes.md#class-ipv6address) - [IPv6Address](net_package_classes.md#class-ipv6address) 对象。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    // 创建一个IPv4地址
    let ipv4Addr = IPv4Address(192u8, 168u8, 1u8, 2u8)

    // 将IPv4地址转换为IPv6兼容地址
    let ipv6Compatible = ipv4Addr.toIPv6Compatible()

    println("IPv4地址: ${ipv4Addr}")
    println("IPv6兼容地址: ${ipv6Compatible}")
}
```

运行结果：

```text
IPv4地址: 192.168.1.2
IPv6兼容地址: ::c0a8:102
```

### func toIPv6Mapped()

```cangjie
public func toIPv6Mapped(): IPv6Address
```

功能：此 [IPv4Address](net_package_classes.md#class-ipv4address) 地址转换为 IPv4 映射的 [IPv6Address](net_package_classes.md#class-ipv4address) 地址。`a.b.c.d` 变为 `::ffff:a.b.c.d`。

返回值：

- [IPv6Address](net_package_classes.md#class-ipv6address) - [IPv6Address](net_package_classes.md#class-ipv6address) 对象。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    // 创建一个IPv4地址
    let ipv4Addr = IPv4Address(192u8, 168u8, 1u8, 2u8)

    // 将IPv4地址转换为IPv6映射地址
    let ipv6Mapped = ipv4Addr.toIPv6Mapped()

    println("IPv4地址: ${ipv4Addr}")
    println("IPv6映射地址: ${ipv6Mapped}")
}
```

运行结果：

```text
IPv4地址: 192.168.1.2
IPv6映射地址: ::ffff:192.168.1.2
```

### func toString()

```cangjie
public func toString(): String
```

功能：返回当前 [IPv4Address](net_package_classes.md#class-ipv4address)  的文本表示字符串。

返回值：

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - 当前 [IPv4Address](net_package_classes.md#class-ipv4address) 的文本表示字符串，比如 `a.b.c.d`。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    // 创建一个IPv4地址
    let ipv4Addr = IPv4Address(192u8, 168u8, 1u8, 2u8)

    // 获取IPv4地址的字符串表示
    let addrString = ipv4Addr.toString()

    println("IPv4地址对象: ${ipv4Addr}")
    println("字符串表示: ${addrString}")
}
```

运行结果：

```text
IPv4地址对象: 192.168.1.2
字符串表示: 192.168.1.2
```

### func writeBigEndian(Array\<Byte>)

```cangjie
public func writeBigEndian(buffer: Array<Byte>): Int64
```

功能：此 [IPv4Address](net_package_classes.md#class-ipv4address) 对象以大端序的方式写入字节数组中。

参数：

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 缓冲区，用于存放待写入的数据。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 写入的数据的字节数。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当 buffer 太小，不足以写入 [IPv4Address](net_package_classes.md#class-ipv4address) 值时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    // 创建一个IPv4地址
    let ipv4Addr = IPv4Address(192u8, 168u8, 1u8, 2u8)

    // 创建一个字节数组缓冲区
    var buffer = [0u8, 0u8, 0u8, 0u8]

    // 将IPv4地址以大端序方式写入字节数组
    let bytesWritten = ipv4Addr.writeBigEndian(buffer)

    println("IPv4地址: ${ipv4Addr}")
    println("写入的字节数: ${bytesWritten}")
    println("字节数组内容: ${buffer}")
}
```

运行结果：

```text
IPv4地址: 192.168.1.2
写入的字节数: 4
字节数组内容: [192, 168, 1, 2]
```

### operator func !=(IPv4Address)

```cangjie
public operator func !=(other: IPv4Address): Bool
```

功能：判断两个 [IPv4Address](net_package_classes.md#class-ipv4address) 对象是否不等。

参数：

- other: [IPv4Address](net_package_classes.md#class-ipv4address) - 参与比较的 [IPv4Address](net_package_classes.md#class-ipv4address) 对象。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 如果两个 [IPv4Address](net_package_classes.md#class-ipv4address) 对象不等，则返回 `true`；否则，返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    // 创建两个相同的IPv4地址
    let addr1 = IPv4Address(192u8, 168u8, 1u8, 2u8)
    let addr2 = IPv4Address(192u8, 168u8, 1u8, 2u8)

    // 创建一个不同的IPv4地址
    let addr3 = IPv4Address(192u8, 168u8, 1u8, 3u8)

    // 比较IPv4地址是否不等
    let result1 = addr1 != addr2
    let result2 = addr1 != addr3

    println("${addr1} != ${addr2}: ${result1}")
    println("${addr1} != ${addr3}: ${result2}")
}
```

运行结果：

```text
192.168.1.2 != 192.168.1.2: false
192.168.1.2 != 192.168.1.3: true
```

### operator func <=(IPv4Address)

```cangjie
public operator func <=(other: IPv4Address): Bool
```

功能：判断本 [IPv4Address](net_package_classes.md#class-ipv4address) 对象是否小于等于被比较的 [IPv4Address](net_package_classes.md#class-ipv4address) 对象。

参数：

- other: [IPv4Address](net_package_classes.md#class-ipv4address) - 被比较的 [IPv4Address](net_package_classes.md#class-ipv4address) 对象。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 如果本 [IPv4Address](net_package_classes.md#class-ipv4address) 对象小于等于被比较的 [IPv4Address](net_package_classes.md#class-ipv4address) 对象，则返回 `true`；否则，返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    // 创建两个IPv4地址
    let addr1 = IPv4Address(192u8, 168u8, 1u8, 2u8) // 192.168.1.2
    let addr2 = IPv4Address(192u8, 168u8, 1u8, 10u8) // 192.168.1.10
    let addr3 = IPv4Address(192u8, 168u8, 1u8, 2u8) // 192.168.1.2

    // 比较IPv4地址
    let result1 = addr1 <= addr2
    let result2 = addr2 <= addr1
    let result3 = addr1 <= addr3

    println("${addr1} <= ${addr2}: ${result1}")
    println("${addr2} <= ${addr1}: ${result2}")
    println("${addr1} <= ${addr3}: ${result3}")
}
```

运行结果：

```text
192.168.1.2 <= 192.168.1.10: true
192.168.1.10 <= 192.168.1.2: false
192.168.1.2 <= 192.168.1.2: true
```

### operator func ==(IPv4Address)

```cangjie
public operator func ==(other: IPv4Address): Bool
```

功能：判断两个 [IPv4Address](net_package_classes.md#class-ipv4address) 对象是否相等。

参数：

- other: [IPv4Address](net_package_classes.md#class-ipv4address) - 参与比较的 [IPv4Address](net_package_classes.md#class-ipv4address) 对象。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 如果两个 [IPv4Address](net_package_classes.md#class-ipv4address) 对象相等，则返回 `true`；否则，返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    // 创建两个相同的IPv4地址
    let addr1 = IPv4Address(192u8, 168u8, 1u8, 2u8)
    let addr2 = IPv4Address(192u8, 168u8, 1u8, 2u8)

    // 创建一个不同的IPv4地址
    let addr3 = IPv4Address(192u8, 168u8, 1u8, 3u8)

    // 比较IPv4地址是否相等
    let result1 = addr1 == addr2
    let result2 = addr1 == addr3

    println("${addr1} == ${addr2}: ${result1}")
    println("${addr1} == ${addr3}: ${result2}")
}
```

运行结果：

```text
192.168.1.2 == 192.168.1.2: true
192.168.1.2 == 192.168.1.3: false
```

## class IPv6Address

```cangjie
public class IPv6Address <: IPAddress & ToString & Equatable<IPv6Address> & LessOrEqual<IPv6Address> {
    public static let localhost: IPv6Address = IPv6Address(0u16, 0, 0, 0, 0, 0, 0, 1)
    public static let unspecified: IPv6Address = IPv6Address(0u16, 0, 0, 0, 0, 0, 0, 0)
    public init(octets: Array<Byte>, scopeId!: ?UInt32 = None)
    public init(a: UInt16, b: UInt16, c: UInt16, d: UInt16, e: UInt16, f: UInt16, g: UInt16, h: UInt16, scopeId!: ?UInt32 = None)
}
```

功能：此类表示 Internet 协议版本 6 （IPv6）地址。由 [RFC4291](https://datatracker.ietf.org/doc/html/rfc4291)、[RFC5952](https://datatracker.ietf.org/doc/html/rfc5952)、[RFC4007](https://datatracker.ietf.org/doc/html/rfc4007) 定义。

父类型：

- [IPAddress](#class-ipaddress)
- [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring)
- [Equatable](../../core/core_package_api/core_package_interfaces.md#interface-equatablet)\<[IPv6Address](#class-ipv6address)>
- [LessOrEqual](../../core/core_package_api/core_package_interfaces.md#interface-lessorequalt)\<[IPv6Address](#class-ipv6address)>

### static let localhost

```cangjie
public static let localhost: IPv6Address = IPv6Address(0u16, 0, 0, 0, 0, 0, 0, 1)
```

功能：返回 [IPv6Address](net_package_classes.md#class-ipv6address) 的 `localhost` 地址：`::1`。

类型：[IPv6Address](net_package_classes.md#class-ipv6address)

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    let ipv6Addr = IPv6Address.localhost
    println("IPv6地址: ${ipv6Addr}")
}
```

运行结果：

```text
IPv6地址: ::1
```

### static let unspecified

```cangjie
public static let unspecified: IPv6Address = IPv6Address(0u16, 0, 0, 0, 0, 0, 0, 0)
```

功能：返回表示未指定的 [IPv6Address](net_package_classes.md#class-ipv6address) 地址：`::`，这对应于其他语言中的常量 `INADDR_ANY`。

类型：[IPv6Address](net_package_classes.md#class-ipv6address)

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    let ipv6Addr = IPv6Address.unspecified
    println("IPv6地址: ${ipv6Addr}")
}
```

运行结果：

```text
IPv6地址: ::
```

### prop scopeId

```cangjie
public prop scopeId: ?UInt32
```

功能：获取默认范围 ID。

类型：[Option](../../core/core_package_api/core_package_enums.md#enum-optiont)\<[UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32)>

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 创建一个不带范围ID的IPv6地址
    let ipv6AddrWithoutScope = IPv6Address(0u16, 0, 0, 0, 0, 0, 0, 1)

    // 获取范围ID
    let scopeId = ipv6AddrWithoutScope.scopeId

    println("IPv6地址: ${ipv6AddrWithoutScope}")
    println("范围ID: ${scopeId}")
}
```

运行结果：

```text
IPv6地址: ::1
范围ID: None
```

### init(Array\<Byte>, ?UInt32)

```cangjie
public init(octets: Array<Byte>, scopeId!: ?UInt32 = None)
```

功能：根据大端序 [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> 构造 [IPv6Address](net_package_classes.md#class-ipv6address) 地址。

参数：

- octets: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 大端序字节数组。
- scopeId!: ?[UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 范围 ID。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 如果 octets 长度小于 16，抛出异常。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 创建一个包含IPv6地址的大端序字节数组 (::1 的字节数组表示)
    let bytes: Array<Byte> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]

    // 使用字节数组创建IPv6地址
    let ipv6Addr = IPv6Address(bytes)

    println("字节数组: ${bytes}")
    println("IPv6地址: ${ipv6Addr}")
}
```

运行结果：

```text
字节数组: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]
IPv6地址: ::1
```

### init(UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, UInt16, ?UInt32)

```cangjie
public init(a: UInt16, b: UInt16, c: UInt16, d: UInt16, e: UInt16, f: UInt16, g: UInt16, h: UInt16, scopeId!: ?UInt32 = None)
```

功能：根据 8 个 16-bit 分段构造 [IPv6Address](net_package_classes.md#class-ipv6address) 地址对象，文本将表示为 `a:b:c:d:e:f:g:h%scopeId`。

参数：

- a: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 16-bit 分段。
- b: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 16-bit 分段。
- c: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 16-bit 分段。
- d: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 16-bit 分段。
- e: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 16-bit 分段。
- f: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 16-bit 分段。
- g: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 16-bit 分段。
- h: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 16-bit 分段。
- scopeId!: ?[UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 范围 ID。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 使用8个16-bit分段创建IPv6地址 (::1 的表示)
    let ipv6Addr = IPv6Address(0u16, 0u16, 0u16, 0u16, 0u16, 0u16, 0u16, 1u16)

    println("IPv6地址: ${ipv6Addr}")
}
```

运行结果：

```text
IPv6地址: ::1
```

### static func readBigEndian(Array\<Byte>)

```cangjie
public static func readBigEndian(buffer: Array<Byte>): IPv6Address
```

功能：从字节数组中以大端序的方式读取一个 [IPv6Address](net_package_classes.md#class-ipv6address) 对象。

参数：

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 缓冲区，用于存放待读取的数据。

返回值：

- [IPv6Address](net_package_classes.md#class-ipv6address) - [IPv6Address](net_package_classes.md#class-ipv6address) 对象。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当 buffer 太小，不足以读出 [IPv6Address](net_package_classes.md#class-ipv6address) 值时，抛出异常。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 创建一个包含IPv6地址的大端序字节数组 (::1 的字节数组表示)
    let bytes: Array<Byte> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]

    // 从字节数组中读取IPv6地址
    let ipv6Addr = IPv6Address.readBigEndian(bytes)

    println("字节数组: ${bytes}")
    println("IPv6地址: ${ipv6Addr}")
}
```

运行结果：

```text
字节数组: [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1]
IPv6地址: ::1
```

### func getPrefix(UInt8)

```cangjie
public func getPrefix(prefixLen: UInt8): IPPrefix
```

功能：此 [IPv6Address](net_package_classes.md#class-ipv6address) 地址对象根据指定的网络前缀长度创建一个网络前缀对象。

参数：

- prefixLen: [UInt8](../../core/core_package_api/core_package_intrinsics.md#uint8) - 网络前缀长度，必须 \>= 0 且 <= 128。

返回值：

- [IPPrefix](net_package_classes.md#class-ipprefix) - 网络前缀对象。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 如果 prefixLen 大小超出范围，抛出异常。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 创建一个IPv6地址
    let ipv6Addr = IPv6Address(0x2001u16, 0xdb8u16, 0x1u16, 0x2u16, 0xffffu16, 0xffffu16, 0xffffu16, 0xffffu16)

    // 根据指定的网络前缀长度创建网络前缀对象
    let prefix = ipv6Addr.getPrefix(64u8)

    println("IPv6地址: ${ipv6Addr}")
    println("网络前缀: ${prefix}")
}
```

运行结果：

```text
IPv6地址: 2001:db8:1:2:ffff:ffff:ffff:ffff
网络前缀: 2001:db8:1:2:ffff:ffff:ffff:ffff/64
```

### func isGlobalUnicast()

```cangjie
public func isGlobalUnicast(): Bool
```

功能：判断此 [IPv6Address](net_package_classes.md#class-ipv6address) 对象是不是全局单播地址。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回 true 表示是全局单播地址，否则返回 false。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 创建一个全局单播IPv6地址
    let globalAddr = IPv6Address(0x2001u16, 0xdb8u16, 0x1u16, 0x2u16, 0xffffu16, 0xffffu16, 0xffffu16, 0xffffu16)

    // 创建一个环回地址
    let loopbackAddr = IPv6Address(0u16, 0u16, 0u16, 0u16, 0u16, 0u16, 0u16, 1u16)

    // 检查是否为全局单播地址
    let isGlobal1 = globalAddr.isGlobalUnicast()
    let isGlobal2 = loopbackAddr.isGlobalUnicast()

    println("2001:db8:1:2:ffff:ffff:ffff:ffff是全局单播地址: ${isGlobal1}")
    println("::1是全局单播地址: ${isGlobal2}")
}
```

运行结果：

```text
2001:db8:1:2:ffff:ffff:ffff:ffff是全局单播地址: true
::1是全局单播地址: false
```

### func isIPv4Mapped()

```cangjie
public func isIPv4Mapped(): Bool
```

功能：判断此 [IPv6Address](net_package_classes.md#class-ipv6address) 对象是不是 IPv4 映射地址。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回 true 表示是 IPv4 映射地址，否则返回 false。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 创建一个IPv4映射的IPv6地址 (::ffff:192.168.1.2)
    let ipv4MappedAddr = IPv6Address(0u16, 0u16, 0u16, 0u16, 0u16, 0xffffu16, 0xc0a8u16, 0x102u16)

    // 创建一个普通IPv6地址
    let normalAddr = IPv6Address(0x2001u16, 0xdb8u16, 0x1u16, 0x2u16, 0xffffu16, 0xffffu16, 0xffffu16, 0xffffu16)

    // 检查是否为IPv4映射地址
    let isMapped1 = ipv4MappedAddr.isIPv4Mapped()
    let isMapped2 = normalAddr.isIPv4Mapped()

    println("::ffff:192.168.1.2是IPv4映射地址: ${isMapped1}")
    println("2001:db8:1:2:ffff:ffff:ffff:ffff是IPv4映射地址: ${isMapped2}")
}
```

运行结果：

```text
::ffff:192.168.1.2是IPv4映射地址: true
2001:db8:1:2:ffff:ffff:ffff:ffff是IPv4映射地址: false
```

### func isLinkLocal()

```cangjie
public func isLinkLocal(): Bool
```

功能：判断此 [IPv6Address](net_package_classes.md#class-ipv6address) 对象是不是链路本地地址。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回 true 表示是链路本地地址，否则返回 false。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 创建一个链路本地IPv6地址 (fe80::1)
    let linkLocalAddr = IPv6Address(0xfe80u16, 0u16, 0u16, 0u16, 0u16, 0u16, 0u16, 1u16)

    // 创建一个普通IPv6地址
    let normalAddr = IPv6Address(0x2001u16, 0xdb8u16, 0x1u16, 0x2u16, 0xffffu16, 0xffffu16, 0xffffu16, 0xffffu16)

    // 检查是否为链路本地地址
    let isLinkLocal1 = linkLocalAddr.isLinkLocal()
    let isLinkLocal2 = normalAddr.isLinkLocal()

    println("fe80::1是链路本地地址: ${isLinkLocal1}")
    println("2001:db8:1:2:ffff:ffff:ffff:ffff是链路本地地址: ${isLinkLocal2}")
}
```

运行结果：

```text
fe80::1是链路本地地址: true
2001:db8:1:2:ffff:ffff:ffff:ffff是链路本地地址: false
```

### func isLoopback()

```cangjie
public func isLoopback(): Bool
```

功能：判断此 [IPv6Address](net_package_classes.md#class-ipv6address) 对象是不是环回地址。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回 true 表示是环回地址，否则返回 false。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 创建一个环回IPv6地址
    let loopbackAddr = IPv6Address(0u16, 0u16, 0u16, 0u16, 0u16, 0u16, 0u16, 1u16)

    // 创建一个普通IPv6地址
    let normalAddr = IPv6Address(0x2001u16, 0xdb8u16, 0x1u16, 0x2u16, 0xffffu16, 0xffffu16, 0xffffu16, 0xffffu16)

    // 检查是否为环回地址
    let isLoopback1 = loopbackAddr.isLoopback()
    let isLoopback2 = normalAddr.isLoopback()

    println("::1是环回地址: ${isLoopback1}")
    println("2001:db8:1:2:ffff:ffff:ffff:ffff是环回地址: ${isLoopback2}")
}
```

运行结果：

```text
::1是环回地址: true
2001:db8:1:2:ffff:ffff:ffff:ffff是环回地址: false
```

### func isMulticast()

```cangjie
public func isMulticast(): Bool
```

功能：判断此 [IPv6Address](net_package_classes.md#class-ipv6address) 对象是不是多播地址。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回 true 表示是多播地址，否则返回 false。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 创建一个多播IPv6地址 (ff02::1)
    let multicastAddr = IPv6Address(0xff02u16, 0u16, 0u16, 0u16, 0u16, 0u16, 0u16, 1u16)

    // 创建一个普通IPv6地址
    let normalAddr = IPv6Address(0x2001u16, 0xdb8u16, 0x1u16, 0x2u16, 0xffffu16, 0xffffu16, 0xffffu16, 0xffffu16)

    // 检查是否为多播地址
    let isMulticast1 = multicastAddr.isMulticast()
    let isMulticast2 = normalAddr.isMulticast()

    println("ff02::1是多播地址: ${isMulticast1}")
    println("2001:db8:1:2:ffff:ffff:ffff:ffff是多播地址: ${isMulticast2}")
}
```

运行结果：

```text
ff02::1是多播地址: true
2001:db8:1:2:ffff:ffff:ffff:ffff是多播地址: false
```

### func isPrivate()

```cangjie
public func isPrivate(): Bool
```

功能：判断此 [IPv6Address](net_package_classes.md#class-ipv6address) 对象是不是私有地址。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回 true 表示是私有地址，否则返回 false。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 创建一个私有IPv6地址 (fc00::1)
    let privateAddr = IPv6Address(0xfc00u16, 0u16, 0u16, 0u16, 0u16, 0u16, 0u16, 1u16)

    // 创建一个全局单播IPv6地址
    let globalAddr = IPv6Address(0x2001u16, 0xdb8u16, 0x1u16, 0x2u16, 0xffffu16, 0xffffu16, 0xffffu16, 0xffffu16)

    // 检查是否为私有地址
    let isPrivate1 = privateAddr.isPrivate()
    let isPrivate2 = globalAddr.isPrivate()

    println("fc00::1是私有地址: ${isPrivate1}")
    println("2001:db8:1:2:ffff:ffff:ffff:ffff是私有地址: ${isPrivate2}")
}
```

运行结果：

```text
fc00::1是私有地址: true
2001:db8:1:2:ffff:ffff:ffff:ffff是私有地址: false
```

### func isTeredo()

```cangjie
public func isTeredo(): Bool
```

功能：判断此 [IPv6Address](net_package_classes.md#class-ipv6address) 对象是不是 `Teredo` 地址。`Teredo` 前缀为 `2001::/32`。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回 true 表示是 `Teredo` 地址，否则返回 false。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 创建一个Teredo IPv6地址 (2001::1)
    let teredoAddr = IPv6Address(0x2001u16, 0u16, 0u16, 0u16, 0u16, 0u16, 0u16, 1u16)

    // 创建一个普通IPv6地址
    let normalAddr = IPv6Address(0x2002u16, 0xdb8u16, 0x1u16, 0x2u16, 0xffffu16, 0xffffu16, 0xffffu16, 0xffffu16)

    // 检查是否为Teredo地址
    let isTeredo1 = teredoAddr.isTeredo()
    let isTeredo2 = normalAddr.isTeredo()

    println("2001::1是Teredo地址: ${isTeredo1}")
    println("2002:db8:1:2:ffff:ffff:ffff:ffff是Teredo地址: ${isTeredo2}")
}
```

运行结果：

```text
2001::1是Teredo地址: true
2002:db8:1:2:ffff:ffff:ffff:ffff是Teredo地址: false
```

### func isUnspecified()

```cangjie
public func isUnspecified(): Bool
```

功能：判断此 [IPv6Address](net_package_classes.md#class-ipv6address) 对象是不是“未指定” IP 地址。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回 true 表示是“未指定” IP 地址，否则返回 false。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 创建一个未指定的IPv6地址
    let unspecifiedAddr = IPv6Address(0u16, 0u16, 0u16, 0u16, 0u16, 0u16, 0u16, 0u16)

    // 创建一个普通IPv6地址
    let normalAddr = IPv6Address(0x2001u16, 0xdb8u16, 0x1u16, 0x2u16, 0xffffu16, 0xffffu16, 0xffffu16, 0xffffu16)

    // 检查是否为未指定地址
    let isUnspecified1 = unspecifiedAddr.isUnspecified()
    let isUnspecified2 = normalAddr.isUnspecified()

    println("::是未指定地址: ${isUnspecified1}")
    println("2001:db8:1:2:ffff:ffff:ffff:ffff是未指定地址: ${isUnspecified2}")
}
```

运行结果：

```text
::是未指定地址: true
2001:db8:1:2:ffff:ffff:ffff:ffff是未指定地址: false
```

### func scope(?UInt32)

```cangjie
public func scope(scopeId: ?UInt32): IPv6Address
```

功能：使用本 [IPv6Address](net_package_classes.md#class-ipv6address) 对象的地址值和指定的范围 ID 转换为新的 [IPv6Address](net_package_classes.md#class-ipv6address) 对象，如果指定的范围 ID 为 None，则去除已有的范围 ID。

参数：

- scopeId: ?[UInt32](../../core/core_package_api/core_package_intrinsics.md#uint32) - 范围 ID。

返回值：

- [IPv6Address](net_package_classes.md#class-ipv6address) - 转换后的 [IPv6Address](net_package_classes.md#class-ipv6address) 对象。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 创建一个IPv6地址
    let ipv6Addr = IPv6Address(0u16, 0u16, 0u16, 0u16, 0u16, 0u16, 0u16, 1u16)

    // 为IPv6地址添加范围ID
    let scopedAddr = ipv6Addr.scope(Some(5u32))

    // 移除范围ID
    let unscopedAddr = scopedAddr.scope(None)

    println("原始IPv6地址: ${ipv6Addr}")
    println("带范围ID的地址: ${scopedAddr}")
    println("移除范围ID的地址: ${unscopedAddr}")
}
```

运行结果：

```text
原始IPv6地址: ::1
带范围ID的地址: ::1%5
移除范围ID的地址: ::1
```

### func toIPv4()

```cangjie
public func toIPv4(): ?IPv4Address
```

功能：此 [IPv6Address](net_package_classes.md#class-ipv6address) 地址转换为 IPv4 兼容的 [IPv4Address](net_package_classes.md#class-ipv4address) 地址。比如 `::a.b.c.d` 和 `::ffff:a.b.c.d` 转成 `a.b.c.d`；  `::1` 转成 `0.0.0.1`. 所有不以全零或 `::ffff` 开头的地址将返回 `None`。

返回值：

- ?[IPv4Address](net_package_classes.md#class-ipv4address) - ?[IPv4Address](net_package_classes.md#class-ipv4address) 值。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 创建一个IPv4映射的IPv6地址 (::ffff:192.168.1.2)
    let ipv6MappedAddr = IPv6Address(0u16, 0u16, 0u16, 0u16, 0u16, 0xffffu16, 0xc0a8u16, 0x102u16)

    // 创建一个普通IPv6地址
    let normalAddr = IPv6Address(0x2001u16, 0xdb8u16, 0x1u16, 0x2u16, 0xffffu16, 0xffffu16, 0xffffu16, 0xffffu16)

    // 将IPv6地址转换为IPv4地址
    let ipv4Addr1 = ipv6MappedAddr.toIPv4()
    let ipv4Addr2 = normalAddr.toIPv4()

    println("IPv6映射地址: ${ipv6MappedAddr}")
    println("转换后的IPv4地址: ${ipv4Addr1}")
    println("普通IPv6地址: ${normalAddr}")
    println("转换后的IPv4地址: ${ipv4Addr2}")
}
```

运行结果：

```text
IPv6映射地址: ::ffff:192.168.1.2
转换后的IPv4地址: Some(192.168.1.2)
普通IPv6地址: 2001:db8:1:2:ffff:ffff:ffff:ffff
转换后的IPv4地址: None
```

### func toIPv4Mapped()

```cangjie
public func toIPv4Mapped(): ?IPv4Address
```

功能：此 [IPv6Address](net_package_classes.md#class-ipv6address) 地址转换为 IPv4 映射的 [IPv4Address](net_package_classes.md#class-ipv4address) 地址。比如 `::ffff:a.b.c.d` 转换为 `a.b.c.d`， 所有不以 `::ffff` 开头的地址将返回 `None`。

返回值：

- ?[IPv4Address](net_package_classes.md#class-ipv4address) - ?[IPv4Address](net_package_classes.md#class-ipv4address) 值。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 创建一个IPv4映射的IPv6地址 (::ffff:192.168.1.2)
    let ipv6MappedAddr = IPv6Address(0u16, 0u16, 0u16, 0u16, 0u16, 0xffffu16, 0xc0a8u16, 0x102u16)

    // 创建一个普通IPv6地址
    let normalAddr = IPv6Address(0x2001u16, 0xdb8u16, 0x1u16, 0x2u16, 0xffffu16, 0xffffu16, 0xffffu16, 0xffffu16)

    // 将IPv6地址转换为IPv4映射地址
    let ipv4Mapped1 = ipv6MappedAddr.toIPv4Mapped()
    let ipv4Mapped2 = normalAddr.toIPv4Mapped()

    println("IPv6映射地址: ${ipv6MappedAddr}")
    println("转换后的IPv4映射地址: ${ipv4Mapped1}")
    println("普通IPv6地址: ${normalAddr}")
    println("转换后的IPv4映射地址: ${ipv4Mapped2}")
}
```

运行结果：

```text
IPv6映射地址: ::ffff:192.168.1.2
转换后的IPv4映射地址: Some(192.168.1.2)
普通IPv6地址: 2001:db8:1:2:ffff:ffff:ffff:ffff
转换后的IPv4映射地址: None
```

### func toString()

```cangjie
public func toString(): String
```

功能：返回当前 [IPv6Address](net_package_classes.md#class-ipv6address)  的文本表示字符串。

返回值：

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - 当前 [IPv6Address](net_package_classes.md#class-ipv6address) 的文本表示字符串，比如 `2001:db8:1:2:ffff:ffff:ffff:ffff`。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 创建一个IPv6地址
    let ipv6Addr = IPv6Address(0x2001u16, 0xdb8u16, 0x1u16, 0x2u16, 0xffffu16, 0xffffu16, 0xffffu16, 0xffffu16)

    // 获取IPv6地址的字符串表示
    let addrString = ipv6Addr.toString()

    println("IPv6地址对象: ${ipv6Addr}")
    println("字符串表示: ${addrString}")
}
```

运行结果：

```text
IPv6地址对象: 2001:db8:1:2:ffff:ffff:ffff:ffff
字符串表示: 2001:db8:1:2:ffff:ffff:ffff:ffff
```

### func writeBigEndian(Array\<Byte>)

```cangjie
public func writeBigEndian(buffer: Array<Byte>): Int64
```

功能：返回此 [IPv6Address](net_package_classes.md#class-ipv6address) 对象以大端序的方式写入字节数组中。

参数：

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 缓冲区，用于存放待写入的数据。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 写入的数据的字节数。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当 buffer 太小，不足以写入 [IPv6Address](net_package_classes.md#class-ipv6address) 值时，抛出异常。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 创建一个IPv6地址
    let ipv6Addr = IPv6Address(0x2001u16, 0xdb8u16, 0x1u16, 0x2u16, 0xffffu16, 0xffffu16, 0xffffu16, 0xffffu16)

    // 创建一个字节数组缓冲区
    var buffer: Array<Byte> = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

    // 将IPv6地址以大端序方式写入字节数组
    let bytesWritten = ipv6Addr.writeBigEndian(buffer)

    println("IPv6地址: ${ipv6Addr}")
    println("写入的字节数: ${bytesWritten}")
    println("字节数组内容: ${buffer}")
}
```

运行结果：

```text
IPv6地址: 2001:db8:1:2:ffff:ffff:ffff:ffff
写入的字节数: 16
字节数组内容: [32, 1, 13, 184, 0, 1, 0, 2, 255, 255, 255, 255, 255, 255, 255, 255]
```

### operator func !=(IPv6Address)

```cangjie
public operator func !=(other: IPv6Address): Bool
```

功能：判断两个 [IPv6Address](net_package_classes.md#class-ipv6address) 对象是否不等。

参数：

- other: [IPv6Address](net_package_classes.md#class-ipv6address) - 参与比较的 [IPv6Address](net_package_classes.md#class-ipv6address) 对象。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 如果两个 [IPv6Address](net_package_classes.md#class-ipv6address) 对象不等，则返回 `true`；否则，返回 `false`。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 创建两个相同的IPv6地址
    let addr1 = IPv6Address(0x2001u16, 0xdb8u16, 0x1u16, 0x2u16, 0xffffu16, 0xffffu16, 0xffffu16, 0xffffu16)
    let addr2 = IPv6Address(0x2001u16, 0xdb8u16, 0x1u16, 0x2u16, 0xffffu16, 0xffffu16, 0xffffu16, 0xffffu16)

    // 创建一个不同的IPv6地址
    let addr3 = IPv6Address(0x2001u16, 0xdb8u16, 0x1u16, 0x2u16, 0xffffu16, 0xffffu16, 0xffffu16, 0xfffeu16)

    // 比较IPv6地址是否不等
    let result1 = addr1 != addr2
    let result2 = addr1 != addr3

    println("${addr1} != ${addr2}: ${result1}")
    println("${addr1} != ${addr3}: ${result2}")
}
```

运行结果：

```text
2001:db8:1:2:ffff:ffff:ffff:ffff != 2001:db8:1:2:ffff:ffff:ffff:ffff: false
2001:db8:1:2:ffff:ffff:ffff:ffff != 2001:db8:1:2:ffff:ffff:ffff:fffe: true
```

### operator func <=(IPv6Address)

```cangjie
public operator func <=(other: IPv6Address): Bool
```

功能：判断本 [IPv6Address](net_package_classes.md#class-ipv6address) 对象是否小于等于被比较的 [IPv6Address](net_package_classes.md#class-ipv6address)  对象。

参数：

- other: [IPv6Address](net_package_classes.md#class-ipv6address) - 参与比较的 [IPv6Address](net_package_classes.md#class-ipv6address) 对象。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 如果本 [IPv6Address](net_package_classes.md#class-ipv6address) 对象小于等于被比较的 [IPv6Address](net_package_classes.md#class-ipv6address) 对象，则返回 `true`；否则，返回 `false`。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 创建两个IPv6地址
    let addr1 = IPv6Address(0x2001u16, 0xdb8u16, 0x1u16, 0x2u16, 0xffffu16, 0xffffu16, 0xffffu16, 0xffffu16)
    let addr2 = IPv6Address(0x2001u16, 0xdb8u16, 0x1u16, 0x2u16, 0xffffu16, 0xffffu16, 0xffffu16, 0xfffeu16)
    let addr3 = IPv6Address(0x2001u16, 0xdb8u16, 0x1u16, 0x2u16, 0xffffu16, 0xffffu16, 0xffffu16, 0xffffu16)

    // 比较IPv6地址
    let result1 = addr1 <= addr2
    let result2 = addr2 <= addr1
    let result3 = addr1 <= addr3

    println("${addr1} <= ${addr2}: ${result1}")
    println("${addr2} <= ${addr1}: ${result2}")
    println("${addr1} <= ${addr3}: ${result3}")
}
```

运行结果：

```text
2001:db8:1:2:ffff:ffff:ffff:ffff <= 2001:db8:1:2:ffff:ffff:ffff:fffe: false
2001:db8:1:2:ffff:ffff:ffff:fffe <= 2001:db8:1:2:ffff:ffff:ffff:ffff: true
2001:db8:1:2:ffff:ffff:ffff:ffff <= 2001:db8:1:2:ffff:ffff:ffff:ffff: true
```

### operator func ==(IPv6Address)

```cangjie
public operator func ==(other: IPv6Address): Bool
```

功能：判断两个 [IPv6Address](net_package_classes.md#class-ipv6address) 对象是否相等。

参数：

- other: [IPv6Address](net_package_classes.md#class-ipv6address) - 参与比较的 [IPv6Address](net_package_classes.md#class-ipv6address) 对象。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 如果两个 [IPv6Address](net_package_classes.md#class-ipv6address) 对象相等，则返回 `true`；否则，返回 `false`。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 创建两个相同的IPv6地址
    let addr1 = IPv6Address(0x2001u16, 0xdb8u16, 0x1u16, 0x2u16, 0xffffu16, 0xffffu16, 0xffffu16, 0xffffu16)
    let addr2 = IPv6Address(0x2001u16, 0xdb8u16, 0x1u16, 0x2u16, 0xffffu16, 0xffffu16, 0xffffu16, 0xffffu16)

    // 创建一个不同的IPv6地址
    let addr3 = IPv6Address(0x2001u16, 0xdb8u16, 0x1u16, 0x2u16, 0xffffu16, 0xffffu16, 0xffffu16, 0xfffeu16)

    // 比较IPv6地址是否相等
    let result1 = addr1 == addr2
    let result2 = addr1 == addr3

    println("${addr1} == ${addr2}: ${result1}")
    println("${addr1} == ${addr3}: ${result2}")
}
```

运行结果：

```text
2001:db8:1:2:ffff:ffff:ffff:ffff == 2001:db8:1:2:ffff:ffff:ffff:ffff: true
2001:db8:1:2:ffff:ffff:ffff:ffff == 2001:db8:1:2:ffff:ffff:ffff:fffe: false
```

## class RawSocket

```cangjie
public class RawSocket {
    public init(domain: SocketDomain, `type`: SocketType, protocol: ProtocolType)
}
```

功能：[RawSocket](net_package_classes.md#class-rawsocket) 提供了套接字的基本功能。

可以访问特定通信域（domain）、类型（type）和协议（protocol）组合的套接字。Socket 包已经提供了 TCP、 UDP 等常用网络协议的支持，因此，该类型适用于其他类型的网络编程需求。

> **注意：**
>
> - 当前 [RawSocket](net_package_classes.md#class-rawsocket) 已经验证的功能包括 TCP、UDP、UDS 以及 ICMP 协议套接字，其他类型使用上可能存在预期之外的问题。
> - 此外，由于接口的开放性，可以使用 `connect` 再 `listen` 的组合，部分场景可能存在预期外的问题。建议开发者使用时遵循正常的调用逻辑，避免产生问题。

### prop localAddr <sup>(deprecated)</sup>

```cangjie
public prop localAddr: RawAddress
```

功能：获取当前 [RawSocket](net_package_classes.md#class-rawsocket) 实例的本地地址。

> **注意：**
>
> 未来版本即将废弃，使用 [localAddress](#prop-localaddress) 替代。

类型：[RawAddress](net_package_structs.md#struct-rawaddress)

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当前 [RawSocket](net_package_classes.md#class-rawsocket) 实例已经关闭，或无法获取本地地址时，抛出异常。

示例：
<!-- run -->

```cangjie
import std.net.*

main() {
    let socket = RawSocket(SocketDomain.IPV4, SocketType.DATAGRAM, ProtocolType.UDP)

    // 获取只读属性localAddr（已废弃）
    // 注意：此属性已废弃，建议使用localAddress
    let localAddr = socket.localAddr
}
```

### prop localAddress

```cangjie
public prop localAddress: RawAddress
```

功能：获取当前 [RawSocket](net_package_classes.md#class-rawsocket) 实例的本地地址。

类型：[RawAddress](net_package_structs.md#struct-rawaddress)

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当前 [RawSocket](net_package_classes.md#class-rawsocket) 实例已经关闭，或无法获取本地地址时，抛出异常。

示例：
<!-- run -->

```cangjie
import std.net.*

main() {
    let socket = RawSocket(SocketDomain.IPV4, SocketType.DATAGRAM, ProtocolType.UDP)

    // 获取只读属性localAddress
    let localAddress = socket.localAddress
}
```

### prop readTimeout

```cangjie
public mut prop readTimeout: ?Duration
```

功能：获取或设置当前 [RawSocket](net_package_classes.md#class-rawsocket) 实例的读超时时间。

类型：?[Duration](../../core/core_package_api/core_package_structs.md#struct-duration)

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当前 [RawSocket](net_package_classes.md#class-rawsocket) 实例已经关闭时，抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当设置的读超时时间为负时，抛出异常。

示例：
<!-- run -->

```cangjie
import std.net.*

main() {
    let socket = RawSocket(SocketDomain.IPV4, SocketType.DATAGRAM, ProtocolType.UDP)

    // 设置可读写属性readTimeout
    socket.readTimeout = 1000 * Duration.millisecond

    // 获取可读写属性readTimeout
    let readTimeout = socket.readTimeout
}
```

### prop remoteAddr <sup>(deprecated)</sup>

```cangjie
public prop remoteAddr: RawAddress
```

功能：获取当前 [RawSocket](net_package_classes.md#class-rawsocket) 实例的对端地址。

> **注意：**
>
> 未来版本即将废弃，使用 [remoteAddress](#prop-remoteaddress) 替代。

类型：[RawAddress](net_package_structs.md#struct-rawaddress)

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当前 [RawSocket](net_package_classes.md#class-rawsocket) 实例已经关闭，或无法获取对端地址时，抛出异常。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 初始化服务器和客户端的TCP套接字（IPv6协议）
    let serverSocket = RawSocket(SocketDomain.IPV6, SocketType.STREAM, ProtocolType.TCP)
    let clientSocket = RawSocket(SocketDomain.IPV6, SocketType.STREAM, ProtocolType.TCP)

    try {
        // 构建IPv6地址结构的字节数组（共28字节）
        let addressBytes = Array<Byte>(28, repeat: 0)
        addressBytes[0..2] = [10, 0] // 地址族：AF_INET6（IPv6）
        addressBytes[2..4] = [60, 101] // 端口号（网络字节序）
        addressBytes[18..24] = [255, 255, 127, 0, 0, 1] // IPv6地址（嵌入IPv4回环地址127.0.0.1）

        // 封装地址信息
        let serverAddress = RawAddress(addressBytes)

        // 服务器绑定地址并开始监听
        serverSocket.bind(serverAddress) // 如果出现 "Address already in use" 可以注释这行再执行一次，可以立刻释放端口
        serverSocket.listen(100)

        // 启动客户端连接并发送消息（异步执行）
        spawn {
            clientSocket.connect(serverAddress)
            let sendData: Array<Byte> = "Hello, cangjie server.".toArray()
            clientSocket.send(sendData, 0)
        }

        // 等待客户端连接（预留2秒时间）
        sleep(Duration.second * 2)

        // 服务器接受连接并接收消息
        var acceptedClientSocket = serverSocket.accept(timeout: Duration.Zero)
        let receiveBuffer = Array<Byte>(100, repeat: 0) // 接收缓冲区（100字节）
        let receivedSize = acceptedClientSocket.receive(receiveBuffer, 0)
        let receivedMessage = String.fromUtf8(receiveBuffer.slice(0, receivedSize))

        // 打印客户端地址和接收的消息
        println(clientSocket.remoteAddr.addr)
        println("Received message: ${receivedMessage}")
    } finally {
        // 确保套接字关闭，释放资源
        clientSocket.close()
        serverSocket.close()
    }
}
```

运行结果：

```text
[10, 0, 60, 101, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 127, 0, 0, 1, 0, 0, 0, 0]
Received message: Hello, cangjie server.
```

### prop remoteAddress

```cangjie
public prop remoteAddress: RawAddress
```

功能：获取当前 [RawSocket](net_package_classes.md#class-rawsocket) 实例的对端地址。

类型：[RawAddress](net_package_structs.md#struct-rawaddress)

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当前 [RawSocket](net_package_classes.md#class-rawsocket) 实例已经关闭，或无法获取对端地址时，抛出异常。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 初始化服务器和客户端的TCP套接字（IPv6协议）
    let serverSocket = RawSocket(SocketDomain.IPV6, SocketType.STREAM, ProtocolType.TCP)
    let clientSocket = RawSocket(SocketDomain.IPV6, SocketType.STREAM, ProtocolType.TCP)

    try {
        // 构建IPv6地址结构的字节数组（共28字节）
        let addressBytes = Array<Byte>(28, repeat: 0)
        addressBytes[0..2] = [10, 0] // 地址族：AF_INET6（IPv6）
        addressBytes[2..4] = [60, 101] // 端口号（网络字节序）
        addressBytes[18..24] = [255, 255, 127, 0, 0, 1] // IPv6地址（嵌入IPv4回环地址127.0.0.1）

        // 封装地址信息
        let serverAddress = RawAddress(addressBytes)

        // 服务器绑定地址并开始监听
        serverSocket.bind(serverAddress) // 如果出现 "Address already in use" 可以注释这行再执行一次，可以立刻释放端口
        serverSocket.listen(100)

        // 启动客户端连接并发送消息（异步执行）
        spawn {
            clientSocket.connect(serverAddress)
            let sendData: Array<Byte> = "Hello, cangjie server.".toArray()
            clientSocket.send(sendData, 0)
        }

        // 等待客户端连接（预留2秒时间）
        sleep(Duration.second * 2)

        // 服务器接受连接并接收消息
        var acceptedClientSocket = serverSocket.accept(timeout: Duration.Zero)
        let receiveBuffer = Array<Byte>(100, repeat: 0) // 接收缓冲区（100字节）
        let receivedSize = acceptedClientSocket.receive(receiveBuffer, 0)
        let receivedMessage = String.fromUtf8(receiveBuffer.slice(0, receivedSize))

        // 打印客户端地址和接收的消息
        println(clientSocket.remoteAddress.addr)
        println("Received message: ${receivedMessage}")
    } finally {
        // 确保套接字关闭，释放资源
        clientSocket.close()
        serverSocket.close()
    }
}
```

运行结果：

```text
[10, 0, 60, 101, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 255, 255, 127, 0, 0, 1, 0, 0, 0, 0]
Received message: Hello, cangjie server.
```

### prop writeTimeout

```cangjie
public mut prop writeTimeout: ?Duration
```

功能：获取或设置当前 [RawSocket](net_package_classes.md#class-rawsocket) 实例的写入超时时间。

类型：?[Duration](../../core/core_package_api/core_package_structs.md#struct-duration)

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当前 [RawSocket](net_package_classes.md#class-rawsocket) 实例已经关闭时，抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当设置的写入超时时间为负时，抛出异常。

示例：
<!-- run -->

```cangjie
import std.net.*

main() {
    let socket = RawSocket(SocketDomain.IPV4, SocketType.DATAGRAM, ProtocolType.UDP)

    // 设置可读写属性writeTimeout
    socket.writeTimeout = 1000 * Duration.millisecond

    // 获取可读写属性writeTimeout
    let writeTimeout = socket.writeTimeout
}
```

### init(SocketDomain, SocketType, ProtocolType)

```cangjie
public init(domain: SocketDomain, `type`: SocketType, protocol: ProtocolType)
```

功能：创建特定通信域、类型、协议组合的套接字。

参数：

- domain: [SocketDomain](net_package_structs.md#struct-socketdomain) - 通信域。
- \`type`: [SocketType](net_package_structs.md#struct-sockettype) - 套接字类型。
- protocol: [ProtocolType](net_package_structs.md#struct-protocoltype) - 协议类型。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当通信域、类型、协议组合无法创建套接字时，抛出异常。

示例：
<!-- run -->

```cangjie
import std.net.*

main() {
    let socket = RawSocket(SocketDomain.IPV4, SocketType.DATAGRAM, ProtocolType.UDP)
}
```

### func accept(?Duration)

```cangjie
public func accept(timeout!: ?Duration = None): RawSocket
```

功能：接收当前 [RawSocket](net_package_classes.md#class-rawsocket) 实例监听时挂起连接队列上的第一个连接请求，返回一个用于通信的 [RawSocket](net_package_classes.md#class-rawsocket)。

参数：

- timeout!: ?[Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - 等待连接请求的最大时间，默认值 `None` 表示一直等待。

返回值：

- [RawSocket](net_package_classes.md#class-rawsocket) - 用于通信的新 [RawSocket](net_package_classes.md#class-rawsocket) 实例。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当前 [RawSocket](net_package_classes.md#class-rawsocket) 实例已经关闭，或接收失败时，抛出异常。
- [SocketTimeoutException](net_package_exceptions.md#class-sockettimeoutexception) - 当等待超时时，抛出异常。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 初始化服务器和客户端的TCP套接字（IPv6协议）
    let serverSocket = RawSocket(SocketDomain.IPV6, SocketType.STREAM, ProtocolType.TCP)
    let clientSocket = RawSocket(SocketDomain.IPV6, SocketType.STREAM, ProtocolType.TCP)

    try {
        // 构建IPv6地址结构的字节数组（共28字节）
        let addressBytes = Array<Byte>(28, repeat: 0)
        addressBytes[0..2] = [10, 0] // 地址族：AF_INET6（IPv6）
        addressBytes[2..4] = [60, 101] // 端口号（网络字节序）
        addressBytes[18..24] = [255, 255, 127, 0, 0, 1] // IPv6地址（嵌入IPv4回环地址127.0.0.1）

        // 封装地址信息
        let serverAddress = RawAddress(addressBytes)

        // 服务器绑定地址并开始监听
        serverSocket.bind(serverAddress) // 如果出现 "Address already in use" 可以注释这行再执行一次，可以立刻释放端口
        serverSocket.listen(100)

        // 启动客户端连接并发送消息（异步执行）
        spawn {
            clientSocket.connect(serverAddress)
            let sendData: Array<Byte> = "Hello, cangjie server.".toArray()
            clientSocket.send(sendData, 0)
        }

        // 等待客户端连接（预留2秒时间）
        sleep(Duration.second * 2)

        // 服务器接受连接并接收消息
        var acceptedClientSocket = serverSocket.accept(timeout: Duration.Zero)
        let receiveBuffer = Array<Byte>(100, repeat: 0) // 接收缓冲区（100字节）
        let receivedSize = acceptedClientSocket.receive(receiveBuffer, 0)
        let receivedMessage = String.fromUtf8(receiveBuffer.slice(0, receivedSize))

        // 打印接收的消息
        println("Received message: ${receivedMessage}")
    } finally {
        // 确保套接字关闭，释放资源
        clientSocket.close()
        serverSocket.close()
    }
}
```

运行结果：

```text
Received message: Hello, cangjie server.
```

### func bind(RawAddress)

```cangjie
public func bind(addr: RawAddress): Unit
```

功能：将当前 [RawSocket](net_package_classes.md#class-rawsocket) 实例与指定的套接字地址进行绑定。

参数：

- addr: [RawAddress](net_package_structs.md#struct-rawaddress) - 套接字地址。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当前 [RawSocket](net_package_classes.md#class-rawsocket) 实例已经关闭，或绑定失败时，抛出异常。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 初始化服务器和客户端的TCP套接字（IPv6协议）
    let serverSocket = RawSocket(SocketDomain.IPV6, SocketType.STREAM, ProtocolType.TCP)
    let clientSocket = RawSocket(SocketDomain.IPV6, SocketType.STREAM, ProtocolType.TCP)

    try {
        // 构建IPv6地址结构的字节数组（共28字节）
        let addressBytes = Array<Byte>(28, repeat: 0)
        addressBytes[0..2] = [10, 0] // 地址族：AF_INET6（IPv6）
        addressBytes[2..4] = [60, 101] // 端口号（网络字节序）
        addressBytes[18..24] = [255, 255, 127, 0, 0, 1] // IPv6地址（嵌入IPv4回环地址127.0.0.1）

        // 封装地址信息
        let serverAddress = RawAddress(addressBytes)

        // 服务器绑定地址并开始监听
        serverSocket.bind(serverAddress) // 如果出现 "Address already in use" 可以注释这行再执行一次，可以立刻释放端口
        serverSocket.listen(100)

        // 启动客户端连接并发送消息（异步执行）
        spawn {
            clientSocket.connect(serverAddress)
            let sendData: Array<Byte> = "Hello, cangjie server.".toArray()
            clientSocket.send(sendData, 0)
        }

        // 等待客户端连接（预留2秒时间）
        sleep(Duration.second * 2)

        // 服务器接受连接并接收消息
        var acceptedClientSocket = serverSocket.accept(timeout: Duration.Zero)
        let receiveBuffer = Array<Byte>(100, repeat: 0) // 接收缓冲区（100字节）
        let receivedSize = acceptedClientSocket.receive(receiveBuffer, 0)
        let receivedMessage = String.fromUtf8(receiveBuffer.slice(0, receivedSize))

        // 打印接收的消息
        println("Received message: ${receivedMessage}")
    } finally {
        // 确保套接字关闭，释放资源
        clientSocket.close()
        serverSocket.close()
    }
}
```

运行结果：

```text
Received message: Hello, cangjie server.
```

### func close()

```cangjie
public func close(): Unit
```

功能：关闭当前 [RawSocket](net_package_classes.md#class-rawsocket) 实例。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 初始化服务器和客户端的TCP套接字（IPv6协议）
    let serverSocket = RawSocket(SocketDomain.IPV6, SocketType.STREAM, ProtocolType.TCP)
    let clientSocket = RawSocket(SocketDomain.IPV6, SocketType.STREAM, ProtocolType.TCP)

    try {
        // 构建IPv6地址结构的字节数组（共28字节）
        let addressBytes = Array<Byte>(28, repeat: 0)
        addressBytes[0..2] = [10, 0] // 地址族：AF_INET6（IPv6）
        addressBytes[2..4] = [60, 101] // 端口号（网络字节序）
        addressBytes[18..24] = [255, 255, 127, 0, 0, 1] // IPv6地址（嵌入IPv4回环地址127.0.0.1）

        // 封装地址信息
        let serverAddress = RawAddress(addressBytes)

        // 服务器绑定地址并开始监听
        serverSocket.bind(serverAddress) // 如果出现 "Address already in use" 可以注释这行再执行一次，可以立刻释放端口
        serverSocket.listen(100)

        // 启动客户端连接并发送消息（异步执行）
        spawn {
            clientSocket.connect(serverAddress)
            let sendData: Array<Byte> = "Hello, cangjie server.".toArray()
            clientSocket.send(sendData, 0)
        }

        // 等待客户端连接（预留2秒时间）
        sleep(Duration.second * 2)

        // 服务器接受连接并接收消息
        var acceptedClientSocket = serverSocket.accept(timeout: Duration.Zero)
        let receiveBuffer = Array<Byte>(100, repeat: 0) // 接收缓冲区（100字节）
        let receivedSize = acceptedClientSocket.receive(receiveBuffer, 0)
        let receivedMessage = String.fromUtf8(receiveBuffer.slice(0, receivedSize))

        // 打印接收的消息
        println("Received message: ${receivedMessage}")
    } finally {
        // 确保套接字关闭，释放资源
        clientSocket.close()
        serverSocket.close()
    }
}
```

运行结果：

```text
Received message: Hello, cangjie server.
```

### func connect(RawAddress, ?Duration)

```cangjie
public func connect(addr: RawAddress, timeout!: ?Duration = None): Unit
```

功能：向目标地址发送连接请求。

参数：

- addr: [RawAddress](net_package_structs.md#struct-rawaddress) - 发送连接请求的目标地址。
- timeout!: ?[Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - 等待连接接收的最大时间，默认值 `None` 表示一直等待。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当前实例已经关闭，或连接失败时，抛出异常。
- [SocketTimeoutException](net_package_exceptions.md#class-sockettimeoutexception) - 当等待超时时，抛出异常。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 初始化服务器和客户端的TCP套接字（IPv6协议）
    let serverSocket = RawSocket(SocketDomain.IPV6, SocketType.STREAM, ProtocolType.TCP)
    let clientSocket = RawSocket(SocketDomain.IPV6, SocketType.STREAM, ProtocolType.TCP)

    try {
        // 构建IPv6地址结构的字节数组（共28字节）
        let addressBytes = Array<Byte>(28, repeat: 0)
        addressBytes[0..2] = [10, 0] // 地址族：AF_INET6（IPv6）
        addressBytes[2..4] = [60, 101] // 端口号（网络字节序）
        addressBytes[18..24] = [255, 255, 127, 0, 0, 1] // IPv6地址（嵌入IPv4回环地址127.0.0.1）

        // 封装地址信息
        let serverAddress = RawAddress(addressBytes)

        // 服务器绑定地址并开始监听
        serverSocket.bind(serverAddress) // 如果出现 "Address already in use" 可以注释这行再执行一次，可以立刻释放端口
        serverSocket.listen(100)

        // 启动客户端连接并发送消息（异步执行）
        spawn {
            clientSocket.connect(serverAddress)
            let sendData: Array<Byte> = "Hello, cangjie server.".toArray()
            clientSocket.send(sendData, 0)
        }

        // 等待客户端连接（预留2秒时间）
        sleep(Duration.second * 2)

        // 服务器接受连接并接收消息
        var acceptedClientSocket = serverSocket.accept(timeout: Duration.Zero)
        let receiveBuffer = Array<Byte>(100, repeat: 0) // 接收缓冲区（100字节）
        let receivedSize = acceptedClientSocket.receive(receiveBuffer, 0)
        let receivedMessage = String.fromUtf8(receiveBuffer.slice(0, receivedSize))

        // 打印接收的消息
        println("Received message: ${receivedMessage}")
    } finally {
        // 确保套接字关闭，释放资源
        clientSocket.close()
        serverSocket.close()
    }
}
```

运行结果：

```text
Received message: Hello, cangjie server.
```

### func getSocketOption(Int32, Int32, CPointer\<Byte>, CPointer\<Int32>)

```cangjie
public unsafe func getSocketOption(level: Int32, option: Int32, value: CPointer<Byte>, len: CPointer<Int32>): Unit
```

功能：获取套接字选项的值。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。
- value: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 套接字选项值。
- len: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[Int32](../../core/core_package_api/core_package_intrinsics.md#int32)> - 套接字选项值的长度。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当前 [RawSocket](net_package_classes.md#class-rawsocket) 实例已经关闭，或获取套接字选项失败时，抛出异常。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 初始化IPv4 TCP服务器套接字
    let tcpServerSocket = RawSocket(SocketDomain.IPV4, SocketType.STREAM, ProtocolType.TCP)

    // 设置SO_REUSEADDR选项（允许端口复用）
    let reuseAddrEnableValue: Array<Byte> = [1, 0, 0, 0]
    let enableValuePtr = unsafe { acquireArrayRawData(reuseAddrEnableValue) }.pointer
    unsafe {
        tcpServerSocket.setSocketOption(
            OptionLevel.SOCKET,
            OptionName.SO_REUSEADDR,
            enableValuePtr,
            Int32(reuseAddrEnableValue.size)
        )
    }
    unsafe { releaseArrayRawData(acquireArrayRawData(reuseAddrEnableValue)) } // 释放设置值的指针资源

    // 准备获取套接字选项值
    let optionValue: Array<Byte> = [0, 0, 0, 0]
    let valuePtr = unsafe { acquireArrayRawData(optionValue) }.pointer // 对应getSocketOption的value参数

    // 长度指针
    var lenPtr: CPointer<Int32> = LibC.malloc<Int32>(count: 1) // 对应getSocketOption的len参数
    unsafe { lenPtr.write(10) } // 初始化长度（需≥选项值实际字节数）

    // 调用getSocketOption获取选项值
    unsafe {
        tcpServerSocket.getSocketOption(
            OptionLevel.SOCKET,
            OptionName.SO_REUSEADDR,
            valuePtr,
            lenPtr
        )
    }
    unsafe { releaseArrayRawData(acquireArrayRawData(optionValue)) } // 释放缓冲区指针资源

    // 读取并打印指针实际返回的值
    let actualLen = unsafe { lenPtr.read() } // 从lenPtr获取实际长度值
    unsafe { LibC.free(lenPtr) } // 释放长度指针内存
    println("套接字选项值: ${optionValue}")
    println("套接字选项值的长度: ${actualLen}")

    // 关闭套接字释放资源
    tcpServerSocket.close()
}
```

运行结果：

```text
套接字选项值: [1, 0, 0, 0]
套接字选项值的长度: 4
```

### func listen(Int32)

```cangjie
public func listen(backlog: Int32): Unit
```

功能：监听当前 [RawSocket](net_package_classes.md#class-rawsocket) 实例绑定的地址。

参数：

- backlog: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 等待队列增长的最大长度。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当前 [RawSocket](net_package_classes.md#class-rawsocket) 实例已经关闭，或监听失败时，抛出异常。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 初始化服务器和客户端的TCP套接字（IPv6协议）
    let serverSocket = RawSocket(SocketDomain.IPV6, SocketType.STREAM, ProtocolType.TCP)
    let clientSocket = RawSocket(SocketDomain.IPV6, SocketType.STREAM, ProtocolType.TCP)

    try {
        // 构建IPv6地址结构的字节数组（共28字节）
        let addressBytes = Array<Byte>(28, repeat: 0)
        addressBytes[0..2] = [10, 0] // 地址族：AF_INET6（IPv6）
        addressBytes[2..4] = [60, 101] // 端口号（网络字节序）
        addressBytes[18..24] = [255, 255, 127, 0, 0, 1] // IPv6地址（嵌入IPv4回环地址127.0.0.1）

        // 封装地址信息
        let serverAddress = RawAddress(addressBytes)

        // 服务器绑定地址并开始监听
        serverSocket.bind(serverAddress) // 如果出现 "Address already in use" 可以注释这行再执行一次，可以立刻释放端口
        serverSocket.listen(100)

        // 启动客户端连接并发送消息（异步执行）
        spawn {
            clientSocket.connect(serverAddress)
            let sendData: Array<Byte> = "Hello, cangjie server.".toArray()
            clientSocket.send(sendData, 0)
        }

        // 等待客户端连接（预留2秒时间）
        sleep(Duration.second * 2)

        // 服务器接受连接并接收消息
        var acceptedClientSocket = serverSocket.accept(timeout: Duration.Zero)
        let receiveBuffer = Array<Byte>(100, repeat: 0) // 接收缓冲区（100字节）
        let receivedSize = acceptedClientSocket.receive(receiveBuffer, 0)
        let receivedMessage = String.fromUtf8(receiveBuffer.slice(0, receivedSize))

        // 打印接收的消息
        println("Received message: ${receivedMessage}")
    } finally {
        // 确保套接字关闭，释放资源
        clientSocket.close()
        serverSocket.close()
    }
}
```

运行结果：

```text
Received message: Hello, cangjie server.
```

### func receive(Array\<Byte>, Int32)

```cangjie
public func receive(buffer: Array<Byte>, flags: Int32): Int64
```

功能：接收来自连接对端发送的数据。

参数：

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 存储接收数据的数组。
- flags: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 指定函数行为的标志。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 数据长度。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当前实例已经关闭，或接收数据失败时，抛出异常。
- [SocketTimeoutException](net_package_exceptions.md#class-sockettimeoutexception) - 当超过指定的读取超时时间时，抛出异常。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 初始化服务器和客户端的TCP套接字（IPv6协议）
    let serverSocket = RawSocket(SocketDomain.IPV6, SocketType.STREAM, ProtocolType.TCP)
    let clientSocket = RawSocket(SocketDomain.IPV6, SocketType.STREAM, ProtocolType.TCP)

    try {
        // 构建IPv6地址结构的字节数组（共28字节）
        let addressBytes = Array<Byte>(28, repeat: 0)
        addressBytes[0..2] = [10, 0] // 地址族：AF_INET6（IPv6）
        addressBytes[2..4] = [60, 101] // 端口号（网络字节序）
        addressBytes[18..24] = [255, 255, 127, 0, 0, 1] // IPv6地址（嵌入IPv4回环地址127.0.0.1）

        // 封装地址信息
        let serverAddress = RawAddress(addressBytes)

        // 服务器绑定地址并开始监听
        serverSocket.bind(serverAddress) // 如果出现 "Address already in use" 可以注释这行再执行一次，可以立刻释放端口
        serverSocket.listen(100)

        // 启动客户端连接并发送消息（异步执行）
        spawn {
            clientSocket.connect(serverAddress)
            let sendData: Array<Byte> = "Hello, cangjie server.".toArray()
            clientSocket.send(sendData, 0)
        }

        // 等待客户端连接（预留2秒时间）
        sleep(Duration.second * 2)

        // 服务器接受连接并接收消息
        var acceptedClientSocket = serverSocket.accept(timeout: Duration.Zero)
        let receiveBuffer = Array<Byte>(100, repeat: 0) // 接收缓冲区（100字节）
        let receivedSize = acceptedClientSocket.receive(receiveBuffer, 0)
        let receivedMessage = String.fromUtf8(receiveBuffer.slice(0, receivedSize))

        // 打印接收的消息
        println("Received message: ${receivedMessage}")
    } finally {
        // 确保套接字关闭，释放资源
        clientSocket.close()
        serverSocket.close()
    }
}
```

运行结果：

```text
Received message: Hello, cangjie server.
```

### func receiveFrom(Array\<Byte>, Int32)

```cangjie
public func receiveFrom(buffer: Array<Byte>, flags: Int32): (RawAddress, Int64)
```

功能：接收来自其他 [RawSocket](net_package_classes.md#class-rawsocket) 实例的数据。

参数：

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 存储接收数据的数组。
- flags: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 指定函数行为的标志。

返回值：

- ([RawAddress](net_package_structs.md#struct-rawaddress), [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)) - 数据来源的地址和数据长度。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当前实例已经关闭，或接收数据失败时，抛出异常。
- [SocketTimeoutException](net_package_exceptions.md#class-sockettimeoutexception) - 当超过指定的读取超时时间时，抛出异常。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 明确区分UDP服务端和客户端套接字
    let udpServerSocket = RawSocket(SocketDomain.IPV4, SocketType.DATAGRAM, ProtocolType.UDP)
    let udpClientSocket = RawSocket(SocketDomain.IPV4, SocketType.DATAGRAM, ProtocolType.UDP)

    try {
        // 清晰表达"服务器绑定的地址"
        let serverBindAddress = RawAddress([2, 0, 39, 40, 127, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0])
        udpServerSocket.bind(serverBindAddress)

        // 异步发送逻辑：明确"发送的数据"和目标地址
        spawn {
            let clientSendData: Array<Byte> = "Hello, cangjie server.".toArray()
            udpClientSocket.sendTo(serverBindAddress, clientSendData, 0)
        }

        // 接收逻辑：区分"接收缓冲区"、"接收大小"和"接收的消息"
        let receiveBuffer = Array<Byte>(100, repeat: 0)
        let (_, receivedSize) = udpServerSocket.receiveFrom(receiveBuffer, 0)
        let receivedMessage = String.fromUtf8(receiveBuffer.slice(0, receivedSize))

        println("Received message: ${receivedMessage}")
    } finally {
        // 释放资源
        udpClientSocket.close()
        udpServerSocket.close()
    }
}
```

运行结果：

```text
Received message: Hello, cangjie server.
```

### func send(Array\<Byte>, Int32)

```cangjie
public func send(buffer: Array<Byte>, flags: Int32): Unit
```

功能：向连接的对端发送数据。

参数：

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 数据。
- flags: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 指定函数行为的标志。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当前实例已经关闭，或发送数据失败时，抛出异常。
- [SocketTimeoutException](net_package_exceptions.md#class-sockettimeoutexception) - 当超过指定的写入超时时间时，抛出异常。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 初始化服务器和客户端的TCP套接字（IPv6协议）
    let serverSocket = RawSocket(SocketDomain.IPV6, SocketType.STREAM, ProtocolType.TCP)
    let clientSocket = RawSocket(SocketDomain.IPV6, SocketType.STREAM, ProtocolType.TCP)

    try {
        // 构建IPv6地址结构的字节数组（共28字节）
        let addressBytes = Array<Byte>(28, repeat: 0)
        addressBytes[0..2] = [10, 0] // 地址族：AF_INET6（IPv6）
        addressBytes[2..4] = [60, 101] // 端口号（网络字节序）
        addressBytes[18..24] = [255, 255, 127, 0, 0, 1] // IPv6地址（嵌入IPv4回环地址127.0.0.1）

        // 封装地址信息
        let serverAddress = RawAddress(addressBytes)

        // 服务器绑定地址并开始监听
        serverSocket.bind(serverAddress) // 如果出现 "Address already in use" 可以注释这行再执行一次，可以立刻释放端口
        serverSocket.listen(100)

        // 启动客户端连接并发送消息（异步执行）
        spawn {
            clientSocket.connect(serverAddress)
            let sendData: Array<Byte> = "Hello, cangjie server.".toArray()
            clientSocket.send(sendData, 0)
        }

        // 等待客户端连接（预留2秒时间）
        sleep(Duration.second * 2)

        // 服务器接受连接并接收消息
        var acceptedClientSocket = serverSocket.accept(timeout: Duration.Zero)
        let receiveBuffer = Array<Byte>(100, repeat: 0) // 接收缓冲区（100字节）
        let receivedSize = acceptedClientSocket.receive(receiveBuffer, 0)
        let receivedMessage = String.fromUtf8(receiveBuffer.slice(0, receivedSize))

        // 打印接收的消息
        println("Received message: ${receivedMessage}")
    } finally {
        // 确保套接字关闭，释放资源
        clientSocket.close()
        serverSocket.close()
    }
}
```

运行结果：

```text
Received message: Hello, cangjie server.
```

### func sendTo(RawAddress, Array\<Byte>, Int32)

```cangjie
public func sendTo(addr: RawAddress, buffer: Array<Byte>, flags: Int32): Unit
```

功能：向目标地址发送数据。若 [RawSocket](net_package_classes.md#class-rawsocket) 是 `DATAGRAM` 类型，发送的数据包大小不允许超过 65507 字节。

参数：

- addr: [RawAddress](net_package_structs.md#struct-rawaddress) - 发送数据的目标地址。
- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 数据。
- flags: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 指定函数行为的标志。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当前实例已经关闭、发送数据失败或者 macOS 平台下 `connect` 被调用后调用 `sendTo` 时，抛出异常。
- [SocketTimeoutException](net_package_exceptions.md#class-sockettimeoutexception) - 当超过指定的写入超时时间时，抛出异常。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 明确区分UDP服务端和客户端套接字
    let udpServerSocket = RawSocket(SocketDomain.IPV4, SocketType.DATAGRAM, ProtocolType.UDP)
    let udpClientSocket = RawSocket(SocketDomain.IPV4, SocketType.DATAGRAM, ProtocolType.UDP)

    try {
        // 清晰表达"服务器绑定的地址"
        let serverBindAddress = RawAddress([2, 0, 39, 40, 127, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0])
        udpServerSocket.bind(serverBindAddress)

        // 异步发送逻辑：明确"发送的数据"和目标地址
        spawn {
            let clientSendData: Array<Byte> = "Hello, cangjie server.".toArray()
            udpClientSocket.sendTo(serverBindAddress, clientSendData, 0)
        }

        // 接收逻辑：区分"接收缓冲区"、"接收大小"和"接收的消息"
        let receiveBuffer = Array<Byte>(100, repeat: 0)
        let (_, receivedSize) = udpServerSocket.receiveFrom(receiveBuffer, 0)
        let receivedMessage = String.fromUtf8(receiveBuffer.slice(0, receivedSize))

        println("Received message: ${receivedMessage}")
    } finally {
        // 释放资源
        udpClientSocket.close()
        udpServerSocket.close()
    }
}
```

运行结果：

```text
Received message: Hello, cangjie server.
```

### func setSocketOption(Int32, Int32, CPointer\<Byte>, Int32)

```cangjie
public unsafe func setSocketOption(level: Int32, option: Int32, value: CPointer<Byte>, len: Int32): Unit
```

功能：设置套接字选项。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。
- value: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 套接字选项值。
- len: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - 套接字选项值的长度。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当前 [RawSocket](net_package_classes.md#class-rawsocket) 实例已经关闭，或设置套接字选项失败时，抛出异常。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    // 初始化IPv4 TCP服务器套接字
    let tcpServerSocket = RawSocket(SocketDomain.IPV4, SocketType.STREAM, ProtocolType.TCP)

    // 设置SO_REUSEADDR选项（允许端口复用）
    let reuseAddrEnableValue: Array<Byte> = [1, 0, 0, 0]
    let enableValuePtr = unsafe { acquireArrayRawData(reuseAddrEnableValue) }.pointer
    unsafe {
        tcpServerSocket.setSocketOption(
            OptionLevel.SOCKET,
            OptionName.SO_REUSEADDR,
            enableValuePtr,
            Int32(reuseAddrEnableValue.size)
        )
    }
    unsafe { releaseArrayRawData(acquireArrayRawData(reuseAddrEnableValue)) } // 释放设置值的指针资源

    // 准备获取套接字选项值
    let optionValue: Array<Byte> = [0, 0, 0, 0]
    let valuePtr = unsafe { acquireArrayRawData(optionValue) }.pointer // 对应getSocketOption的value参数

    // 长度指针
    var lenPtr: CPointer<Int32> = LibC.malloc<Int32>(count: 1) // 对应getSocketOption的len参数
    unsafe { lenPtr.write(10) } // 初始化长度（需≥选项值实际字节数）

    // 调用getSocketOption获取选项值
    unsafe {
        tcpServerSocket.getSocketOption(
            OptionLevel.SOCKET,
            OptionName.SO_REUSEADDR,
            valuePtr,
            lenPtr
        )
    }
    unsafe { releaseArrayRawData(acquireArrayRawData(optionValue)) } // 释放缓冲区指针资源

    // 读取并打印指针实际返回的值
    let actualLen = unsafe { lenPtr.read() } // 从lenPtr获取实际长度值
    unsafe { LibC.free(lenPtr) } // 释放长度指针内存
    println("套接字选项值: ${optionValue}")
    println("套接字选项值的长度: ${actualLen}")

    // 关闭套接字释放资源
    tcpServerSocket.close()
}
```

运行结果：

```text
套接字选项值: [1, 0, 0, 0]
套接字选项值的长度: 4
```

## class SocketAddress

```cangjie
sealed abstract class SocketAddress <: ToString & Equatable<SocketAddress> & Hashable
```

功能：此类表示协议无关的 Socket 地址。它提供了一个不可变的对象，用于 Socket  的绑定、连接或作为返回值。

父类型：

- [ToString](../../core/core_package_api/core_package_interfaces.md#interface-tostring)
- [Equatable](../../core/core_package_api/core_package_interfaces.md#interface-equatablet)\<[SocketAddress](#class-socketaddress)>
- [Hashable](../../core/core_package_api/core_package_interfaces.md#interface-hashable)

### prop family

```cangjie
public prop family: AddressFamily
```

功能：当前 [SocketAddress](net_package_classes.md#class-socketaddress) 对象的地址族。

类型：[AddressFamily](net_package_structs.md#struct-addressfamily)

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    // 抽象类不可实例化，选择子类进行实例化
    let socketAddrV4: SocketAddress = IPSocketAddress.parse("192.168.1.2:8080")
    let socketAddrV6: SocketAddress = IPSocketAddress.parse("[2001:0250:1006:dff0:4913:2aa5:8075:7c10]:8080")

    println("IPv4地址族: ${socketAddrV4.family}")
    println("IPv6地址族: ${socketAddrV6.family}")
}
```

运行结果：

```text
IPv4地址族: INET
IPv6地址族: INET6
```

### prop size

```cangjie
public prop size: Int64
```

功能：当前 [SocketAddress](net_package_classes.md#class-socketaddress) 对象的原始字节长度。

类型：[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    // 抽象类不可实例化，选择子类进行实例化
    let socketAddrV4: SocketAddress = IPSocketAddress.parse("192.168.1.2:8080")
    let socketAddrV6: SocketAddress = IPSocketAddress.parse("[2001:0250:1006:dff0:4913:2aa5:8075:7c10]:8080")

    println("IPv4 Socket地址大小: ${socketAddrV4.size}")
    println("IPv6 Socket地址大小: ${socketAddrV6.size}")
}
```

运行结果：

```text
IPv4 Socket地址大小: 16
IPv6 Socket地址大小: 28
```

### func getAddressBytes()

```cangjie
public func getAddressBytes(): Array<Byte>
```

功能：返回此 [SocketAddress](net_package_classes.md#class-socketaddress) 对象的原始 IP 地址。

返回值：

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 原始 IP 地址的 [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> 表示。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    // 抽象类不可实例化，选择子类进行实例化
    let socketAddrV4: SocketAddress = IPSocketAddress.parse("192.168.1.2:8080")
    let socketAddrV6: SocketAddress = IPSocketAddress.parse("[2001:0250:1006:dff0:4913:2aa5:8075:7c10]:8080")

    // 获取地址字节
    let v4Bytes = socketAddrV4.getAddressBytes()
    let v6Bytes = socketAddrV6.getAddressBytes()

    println("IPv4地址字节: ${v4Bytes}")
    println("IPv6地址字节: ${v6Bytes}")
}
```

运行结果：

```text
IPv4地址字节: [2, 0, 31, 144, 192, 168, 1, 2, 0, 0, 0, 0, 0, 0, 0, 0]
IPv6地址字节: [10, 0, 31, 144, 0, 0, 0, 0, 32, 1, 2, 80, 16, 6, 223, 240, 73, 19, 42, 165, 128, 117, 124, 16, 0, 0, 0, 0]
```

### operator func !=(SocketAddress)

```cangjie
public operator func !=(other: SocketAddress): Bool
```

功能：判断两个 [SocketAddress](net_package_classes.md#class-socketaddress) 对象是否不等。

参数：

- other: [SocketAddress](net_package_classes.md#class-socketaddress) - 参与比较的 [SocketAddress](net_package_classes.md#class-socketaddress) 对象。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 如果两个 [SocketAddress](net_package_classes.md#class-socketaddress) 对象不等，则返回 `true`；否则，返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    // 抽象类不可实例化，选择子类进行实例化
    let socketAddr1: SocketAddress = IPSocketAddress.parse("192.168.1.2:8080")
    let socketAddr2: SocketAddress = IPSocketAddress.parse("192.168.1.2:8080")
    let socketAddr3: SocketAddress = IPSocketAddress.parse("192.168.1.3:8080")

    // 比较IPSocketAddress对象是否不等
    let isNotEqual1 = socketAddr1 != socketAddr2
    let isNotEqual2 = socketAddr1 != socketAddr3

    println("socketAddr1 != socketAddr2: ${isNotEqual1}")
    println("socketAddr1 != socketAddr3: ${isNotEqual2}")
}
```

运行结果：

```text
socketAddr1 != socketAddr2: false
socketAddr1 != socketAddr3: true
```

### operator func ==(SocketAddress)

```cangjie
public operator func ==(other: SocketAddress): Bool
```

功能：判断两个 [SocketAddress](net_package_classes.md#class-socketaddress) 对象是否相等。

参数：

- other: [SocketAddress](net_package_classes.md#class-socketaddress) - 参与比较的 [SocketAddress](net_package_classes.md#class-socketaddress) 对象。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 如果两个 [SocketAddress](net_package_classes.md#class-socketaddress) 对象相等，则返回 `true`；否则，返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.net.*

main() {
    // 抽象类不可实例化，选择子类进行实例化
    let socketAddr1: SocketAddress = IPSocketAddress.parse("192.168.1.2:8080")
    let socketAddr2: SocketAddress = IPSocketAddress.parse("192.168.1.2:8080")
    let socketAddr3: SocketAddress = IPSocketAddress.parse("192.168.1.3:8080")

    // 比较IPSocketAddress对象是否相等
    let isEqual1 = socketAddr1 == socketAddr2
    let isEqual2 = socketAddr1 == socketAddr3

    println("socketAddr1 == socketAddr2: ${isEqual1}")
    println("socketAddr1 == socketAddr3: ${isEqual2}")
}
```

运行结果：

```text
socketAddr1 == socketAddr2: true
socketAddr1 == socketAddr3: false
```

## class TcpServerSocket

```cangjie
public class TcpServerSocket <: ServerSocket {
    public init(bindAt!: UInt16)
    public init(bindAt!: SocketAddress)
}
```

功能：监听 TCP 连接的服务端。

套接字被创建后，可通过属性和 `setSocketOptionXX` 接口配置属性。
启动监听需要调用 `bind()` 将套接字绑定到本地端口。`accept()` 接口将接受 TCP 连接，阻塞等待连接，若队列中已有连接，则可立即返回。
套接字需要通过 close 显式关闭。

父类型：

- [ServerSocket](net_package_interfaces.md#interface-serversocket)

### prop backlogSize

```cangjie
public mut prop backlogSize: Int64
```

功能：设置和读取 `backlog` 大小。

仅可在调用 `bind` 前调用，否则将抛出异常。
变量是否生效取决于系统行为。

类型：[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当在 `bind` 后调用时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let server = TcpServerSocket(bindAt: 3333)
    println("backlogSize before setting: ${server.backlogSize}")
    server.backlogSize = 10
    println("backlogSize after setting: ${server.backlogSize}")
    return 0
}
```

运行结果：

```text
backlogSize before setting: 1024
backlogSize after setting: 10
```

### prop bindToDevice

```cangjie
public mut prop bindToDevice: ?String
```

功能：设置和读取绑定网卡。

类型：?[String](../../core/core_package_api/core_package_structs.md#struct-string)

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let server = TcpServerSocket(bindAt: 3333)
    println("bindToDevice before setting: ${server.bindToDevice}")
    server.bindToDevice = "device"
    println("bindToDevice after setting: ${server.bindToDevice}")
    return 0
}
```

运行结果：

```text
bindToDevice before setting: None
bindToDevice after setting: Some(device)
```

### prop localAddress

```cangjie
public override prop localAddress: SocketAddress
```

功能：读取 `Socket` 将要或已经被绑定的本地地址。

类型：[SocketAddress](net_package_classes.md#class-socketaddress)

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `Socket` 已经被关闭时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let socketAddress: SocketAddress = IPSocketAddress.parse("127.0.0.1:8080")
    let server = TcpServerSocket(bindAt: socketAddress)
    println("localAddress: ${server.localAddress}")
    return 0
}
```

运行结果：

```text
localAddress: 127.0.0.1:8080
```

### prop receiveBufferSize

```cangjie
public mut prop receiveBufferSize: Int64
```

功能：设置和读取 `SO_RCVBUF` 属性。

类型：[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当 `size` 小于等于 0 时，抛出异常。
- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `Socket` 已关闭时，抛出异常。

示例：

<!-- run -->
```cangjie
import std.net.*

main(): Int64 {
    let server = TcpServerSocket(bindAt: 3333)
    println("receiveBufferSize before setting: ${server.receiveBufferSize}")
    server.receiveBufferSize = 8192
    println("receiveBufferSize after setting: ${server.receiveBufferSize}")
    return 0
}
```

可能的运行结果：

```text
receiveBufferSize before setting: 131072
receiveBufferSize after setting: 16384
```

### prop reuseAddress

```cangjie
public mut prop reuseAddress: Bool
```

功能：设置和读取 `SO_REUSEADDR` 属性，默认设置为 `true`。

属性生效后的行为取决于系统，使用前，请参阅不同系统针对此属性 `SO_REUSEADDR/SOCK_REUSEADDR` 的说明文档。

类型：[Bool](../../core/core_package_api/core_package_intrinsics.md#bool)

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let server = TcpServerSocket(bindAt: 3334)
    println("reuseAddress before setting: ${server.reuseAddress}")
    server.reuseAddress = false
    println("reuseAddress after setting: ${server.reuseAddress}")
    return 0
}
```

运行结果：

```text
reuseAddress before setting: true
reuseAddress after setting: false
```

### prop reusePort

```cangjie
public mut prop reusePort: Bool
```

功能：设置和读取 `SO_REUSEPORT` 属性。

仅可在绑定前被修改。
属性默认及配置生效后的行为取决于系统，使用前，请参阅不同系统针对此属性 `SO_REUSEPORT` 的说明文档。
同时开启 `SO_REUSEADDR/SO_REUSEPORT` 会导致不可预知的系统错误，用户需谨慎配置值。

> **注意：**
>
> 不支持平台：Windows。

类型：[Bool](../../core/core_package_api/core_package_intrinsics.md#bool)

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - Windows 上不支持此类型，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let server = TcpServerSocket(bindAt: 3335)
    println("reusePort before setting: ${server.reusePort}")
    server.reusePort = true
    println("reusePort after setting: ${server.reusePort}")
    return 0
}
```

运行结果：

```text
reusePort before setting: false
reusePort after setting: true
```

### prop sendBufferSize

```cangjie
public mut prop sendBufferSize: Int64
```

功能：设置和读取 `SO_SNDBUF` 属性。

类型：[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当 `size` 小于等于 0 时，抛出异常。
- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `Socket` 已关闭时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let server = TcpServerSocket(bindAt: 3336)
    println("sendBufferSize before setting: ${server.sendBufferSize}")
    server.sendBufferSize = 4096
    println("sendBufferSize after setting: ${server.sendBufferSize}")
    return 0
}
```

可能的运行结果：

```text
sendBufferSize before setting: 16384
sendBufferSize after setting: 8192
```

### init(SocketAddress)

```cangjie
public init(bindAt!: SocketAddress)
```

功能：创建一个 [TcpServerSocket](net_package_classes.md#class-tcpserversocket) 实例，尚未绑定，因此客户端无法连接。

参数：

- bindAt!: [SocketAddress](net_package_classes.md#class-socketaddress) - 指定本地绑定地址，端口号设置为 0 表示随机绑定空闲的本地地址。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let socketAddress: SocketAddress = IPSocketAddress.parse("127.0.0.1:8080")
    let server = TcpServerSocket(bindAt: socketAddress)
    println("Server created with address: ${server.localAddress}")
    return 0
}
```

运行结果：

```text
Server created with address: 127.0.0.1:8080
```

### init(UInt16)

```cangjie
public init(bindAt!: UInt16)
```

功能：创建一个 [TcpServerSocket](net_package_classes.md#class-tcpserversocket) 实例，尚未绑定，因此客户端无法连接。

参数：

- bindAt!: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 指定本地绑定端口，0 表示随机绑定空闲的本地端口。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let server = TcpServerSocket(bindAt: 8081)
    println("Server created with port: ${server.localAddress}")
    return 0
}
```

运行结果：

```text
Server created with port: 0.0.0.0:8081
```

### func accept()

```cangjie
public override func accept(): TcpSocket
```

功能：监听或接受客户端连接。阻塞等待。

返回值：

- [TcpSocket](net_package_classes.md#class-tcpsocket) - 客户端套接字。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当因系统原因监听失败时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.sync.*

// 设置端口
let serverPort: UInt16 = 33333
// 同步计数器用于等待服务器启动
let serverStartCounter = SyncCounter(1)

func runTcpServer() {
    try (server = TcpServerSocket(bindAt: serverPort)) {
        server.bind()
        // 明确是服务器启动计数器递减
        serverStartCounter.dec()

        // 接收的客户端连接
        try (clientSocket = server.accept()) {
            // 接收数据的缓冲区
            let recvBuffer = Array<Byte>(10, repeat: 0)
            // 读取的字节数
            let readBytes = clientSocket.read(recvBuffer)

            println("Server read ${readBytes} bytes: ${recvBuffer}")
        }
    }
}

main(): Int64 {
    // 服务器启动的异步任务
    let serverTask = spawn {
        runTcpServer()
    }
    // 等待服务器启动完成（计数器归零）
    serverStartCounter.waitUntilZero()

    // 客户端连接的 socket
    try (client = TcpSocket("127.0.0.1", serverPort)) {
        client.connect()
        // 发送的数据直接写字面量
        client.write([1, 2, 3])
    }

    // 等待服务器任务完成
    serverTask.get()
    return 0
}
```

运行结果：

```text
Server read 3 bytes: [1, 2, 3, 0, 0, 0, 0, 0, 0, 0]
```

### func accept(?Duration)

```cangjie
public override func accept(timeout!: ?Duration): TcpSocket
```

功能：监听或接受客户端连接。

参数：

- timeout!: ?[Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - 超时时间。

返回值：

- [TcpSocket](net_package_classes.md#class-tcpsocket) - 客户端套接字。

异常：

- [SocketTimeoutException](net_package_exceptions.md#class-sockettimeoutexception) - 当连接超时，抛出异常。
- [SocketException](net_package_exceptions.md#class-socketexception) - 当因系统原因监听失败时，抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当超时时间小于 0 时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.sync.*

// 设置端口
let serverPort: UInt16 = 33334
// 同步计数器用于等待服务器启动
let serverStartCounter = SyncCounter(1)

func runTcpServer() {
    try (server = TcpServerSocket(bindAt: serverPort)) {
        server.bind()
        // 明确是服务器启动计数器递减
        serverStartCounter.dec()

        // 接收的客户端连接，设置5秒超时
        let timeout = Duration.second * 5
        try (clientSocket = server.accept(timeout: timeout)) {
            // 接收数据的缓冲区
            let recvBuffer = Array<Byte>(10, repeat: 0)
            // 读取的字节数
            let readBytes = clientSocket.read(recvBuffer)

            println("Server read ${readBytes} bytes: ${recvBuffer}")
        }
    }
}

main(): Int64 {
    // 服务器启动的异步任务
    let serverTask = spawn {
        runTcpServer()
    }
    // 等待服务器启动完成（计数器归零）
    serverStartCounter.waitUntilZero()

    // 客户端连接的 socket
    try (client = TcpSocket("127.0.0.1", serverPort)) {
        client.connect()
        // 发送的数据直接写字面量
        client.write([4, 5, 6])
    }

    // 等待服务器任务完成
    serverTask.get()
    return 0
}
```

运行结果：

```text
Server read 3 bytes: [4, 5, 6, 0, 0, 0, 0, 0, 0, 0]
```

### func bind()

```cangjie
public override func bind(): Unit
```

功能：绑定本地端口失败后需要 `close` 套接字，不支持多次重试。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当因系统原因绑定失败时，抛出异常。

示例：

<!-- run -->
```cangjie
import std.net.*

main(): Int64 {
    let server = TcpServerSocket(bindAt: 8082)
    server.bind()
    return 0
}
```

### func close()

```cangjie
public override func close(): Unit
```

功能：关闭套接字。接口允许多次调用。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let server = TcpServerSocket(bindAt: 8083)
    server.bind()
    println("Before close: ${server.isClosed()}")
    server.close()
    println("After close: ${server.isClosed()}")
    return 0
}
```

运行结果：

```text
Before close: false
After close: true
```

### func getSocketOption(Int32, Int32, CPointer\<Unit>, CPointer\<UIntNative>)

```cangjie
public func getSocketOption(
    level: Int32,
    option: Int32,
    value: CPointer<Unit>,
    valueLength: CPointer<UIntNative>
): Unit
```

功能：获取指定的套接字参数。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。
- value: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[Unit](../../core/core_package_api/core_package_intrinsics.md#unit)> - 参数值。
- valueLength: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[UIntNative](../../core/core_package_api/core_package_intrinsics.md#uintnative)> - 参数值长度。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `getsockopt` 返回失败时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

foreign {
    // 释放动态分配的内存
    func free(ptr: CPointer<Unit>): Unit
    // 分配指定大小的内存
    func malloc(size: UIntNative): CPointer<Unit>
}

// SO_REUSEADDR选项值的大小（Int32类型）
let SO_REUSEADDR_VALUE_SIZE: UIntNative = sizeOf<Int32>()

main() {
    let tcpServer = TcpServerSocket(bindAt: 8083)
    // 存储SO_REUSEADDR选项的获取结果（初始值-1表示未获取成功）
    var reuseAddrValue: Int32 = -1

    unsafe {
        // 为存储选项值分配内存
        let optionValueBuffer = malloc(SO_REUSEADDR_VALUE_SIZE)
        // 转换为Int32类型指针
        let int32Ptr = CPointer<Int32>(optionValueBuffer)

        // 存储选项值缓冲区的长度
        let bufferSizeArray = Array<UIntNative>(1, repeat: SO_REUSEADDR_VALUE_SIZE)
        // 获取数组的原始数据指针
        let bufferSizePtr = acquireArrayRawData(bufferSizeArray)

        try {
            // 获取SO_REUSEADDR选项值
            tcpServer.getSocketOption(
                OptionLevel.SOCKET,
                SocketOptions.SO_REUSEADDR,
                CPointer(int32Ptr),
                bufferSizePtr.pointer
            )
            // 读取选项值
            reuseAddrValue = int32Ptr.read()
        } finally {
            // 释放分配的内存和数组引用
            free(optionValueBuffer)
            releaseArrayRawData(bufferSizePtr)
        }
    }
    println("SO_REUSEADDR值: ${reuseAddrValue}")
}
```

运行结果：

```text
SO_REUSEADDR值: 1
```

### func getSocketOptionBool(Int32, Int32)

```cangjie
public func getSocketOptionBool(
    level: Int32,
    option: Int32
): Bool
```

功能：获取指定的套接字参数。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 指定的套接字参数。从 [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) 强转而来。`0 => false`，`非 0 => true`。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `getsockopt` 返回失败时或参数大小超过 [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) 的阈值时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let server = TcpServerSocket(bindAt: 8083)
    var nodelay = server.getSocketOptionBool(OptionLevel.TCP, OptionName.TCP_NODELAY)
    println("Nodelay before: ${nodelay}")
    server.setSocketOptionBool(OptionLevel.TCP, OptionName.TCP_NODELAY, true)
    nodelay = server.getSocketOptionBool(OptionLevel.TCP, OptionName.TCP_NODELAY)
    println("Nodelay after: ${nodelay}")
    return 0
}
```

运行结果：

```text
Nodelay before: false
Nodelay after: true
```

### func getSocketOptionIntNative(Int32, Int32)

```cangjie
public func getSocketOptionIntNative(
    level: Int32,
    option: Int32
): IntNative
```

功能：获取指定的套接字参数。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。

返回值：

- [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) - 获取的套接字参数值。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `getsockopt` 返回失败时或参数大小超过 [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) 的阈值时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let server = TcpServerSocket(bindAt: 8083)
    var nodelay = server.getSocketOptionIntNative(OptionLevel.TCP, OptionName.TCP_NODELAY)
    println("Nodelay before: ${nodelay}")
    server.setSocketOptionIntNative(OptionLevel.TCP, OptionName.TCP_NODELAY, 1)
    nodelay = server.getSocketOptionIntNative(OptionLevel.TCP, OptionName.TCP_NODELAY)
    println("Nodelay after: ${nodelay}")
    return 0
}
```

运行结果：

```text
Nodelay before: 0
Nodelay after: 1
```

### func isClosed()

```cangjie
public override func isClosed(): Bool
```

功能：检查套接字是否关闭。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 如果已经关闭，返回 `true`，否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let server = TcpServerSocket(bindAt: 8084)
    server.bind()
    println("Before close: ${server.isClosed()}")
    server.close()
    println("After close: ${server.isClosed()}")
    return 0
}
```

运行结果：

```text
Before close: false
After close: true
```

### func setSocketOption(Int32, Int32, CPointer\<Unit>, UIntNative)

```cangjie
public func setSocketOption(
    level: Int32,
    option: Int32,
    value: CPointer<Unit>,
    valueLength: UIntNative
): Unit
```

功能：设置指定的套接字参数。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。
- value: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[Unit](../../core/core_package_api/core_package_intrinsics.md#unit)> - 参数值。
- valueLength: [UIntNative](../../core/core_package_api/core_package_intrinsics.md#uintnative) - 参数值长度。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `setsockopt` 返回失败时，抛出异常。

示例：

<!-- run -->
```cangjie
import std.net.*

foreign {
    func free(ptr: CPointer<Unit>): Unit

    func malloc(size: UIntNative): CPointer<Unit>
}

// SO_REUSEADDR选项值（Int32类型）的内存大小
let SO_REUSEADDR_VALUE_SIZE: UIntNative = sizeOf<Int32>()

main() {
    let tcpServer = TcpServerSocket(bindAt: 8083)

    unsafe {
        // 为SO_REUSEADDR选项的值分配内存缓冲区
        let reuseAddrBuffer = malloc(SO_REUSEADDR_VALUE_SIZE)
        // 转换为Int32类型指针，专门用于操作SO_REUSEADDR的选项值
        let reuseAddrPtr = CPointer<Int32>(reuseAddrBuffer)

        try {
            // 写入禁用SO_REUSEADDR的值（0表示禁用）
            reuseAddrPtr.write(0)
            // 设置套接字选项
            tcpServer.setSocketOption(
                OptionLevel.SOCKET,
                SocketOptions.SO_REUSEADDR,
                CPointer(reuseAddrPtr),
                SO_REUSEADDR_VALUE_SIZE
            )
        } finally {
            // 释放为选项值分配的缓冲区
            free(reuseAddrBuffer)
        }
    }
}
```

### func setSocketOptionBool(Int32, Int32, Bool)

```cangjie
public func setSocketOptionBool(
    level: Int32,
    option: Int32,
    value: Bool
): Unit
```

功能：设置指定的套接字参数。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。
- value: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 参数值。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `setsockopt` 返回失败时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let server = TcpServerSocket(bindAt: 8083)
    var nodelay = server.getSocketOptionBool(OptionLevel.TCP, OptionName.TCP_NODELAY)
    println("Nodelay before: ${nodelay}")
    server.setSocketOptionBool(OptionLevel.TCP, OptionName.TCP_NODELAY, true)
    nodelay = server.getSocketOptionBool(OptionLevel.TCP, OptionName.TCP_NODELAY)
    println("Nodelay after: ${nodelay}")
    return 0
}
```

运行结果：

```text
Nodelay before: false
Nodelay after: true
```

### func setSocketOptionIntNative(Int32, Int32, IntNative)

```cangjie
public func setSocketOptionIntNative(
    level: Int32,
    option: Int32,
    value: IntNative
): Unit
```

功能：设置指定的套接字参数。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。
- value: [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) - 参数值。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `setsockopt` 返回失败时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let server = TcpServerSocket(bindAt: 8083)
    var nodelay = server.getSocketOptionIntNative(OptionLevel.TCP, OptionName.TCP_NODELAY)
    println("Nodelay before: ${nodelay}")
    server.setSocketOptionIntNative(OptionLevel.TCP, OptionName.TCP_NODELAY, 1)
    nodelay = server.getSocketOptionIntNative(OptionLevel.TCP, OptionName.TCP_NODELAY)
    println("Nodelay after: ${nodelay}")
    return 0
}
```

运行结果：

```text
Nodelay before: 0
Nodelay after: 1
```

### func toString()

```cangjie
public override func toString(): String
```

功能：返回当前 [TcpServerSocket](net_package_classes.md#class-tcpserversocket) 的状态信息。

返回值：

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - 包含当前 [TcpServerSocket](net_package_classes.md#class-tcpserversocket) 状态信息的字符串。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let server = TcpServerSocket(bindAt: 8085)
    println("toString: ${server.toString()}")
    return 0
}
```

运行结果：

```text
toString: TcpServerSocket(unconnected, unbound)
```

## class TcpSocket

```cangjie
public class TcpSocket <: StreamingSocket & Equatable<TcpSocket> & Hashable {
    public init(address: String, port: UInt16)
    public init(address: SocketAddress)
    public init(address: SocketAddress, localAddress!: ?SocketAddress)
}
```

功能：请求 TCP 连接的客户端。

当实例对象被创建后，可使用 `connect` 函数创建连接，并在结束时显式执行 `close` 操作。
该类型继承自 [StreamingSocket](net_package_interfaces.md#interface-streamingsocket)， 可参阅 [StreamingSocket](net_package_interfaces.md#interface-streamingsocket) 章节获取更多信息。

父类型：

- [StreamingSocket](net_package_interfaces.md#interface-streamingsocket)
- [Equatable](../../core/core_package_api/core_package_interfaces.md#interface-equatablet)\<[TcpSocket](#class-tcpsocket)>
- [Hashable](../../core/core_package_api/core_package_interfaces.md#interface-hashable)

### prop bindToDevice

```cangjie
public mut prop bindToDevice: ?String
```

功能：设置和读取绑定网卡。

类型：?[String](../../core/core_package_api/core_package_structs.md#struct-string)

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let tcpSocket = TcpSocket("127.0.0.1", 3333)
    println("bindToDevice before setting: ${tcpSocket.bindToDevice}")
    tcpSocket.bindToDevice = "device"
    println("bindToDevice after setting: ${tcpSocket.bindToDevice}")
    return 0
}
```

运行结果：

```text
bindToDevice before setting: None
bindToDevice after setting: Some(device)
```

### prop keepAlive

```cangjie
public mut prop keepAlive: ?SocketKeepAliveConfig
```

功能：设置和读取保活属性，`None` 表示关闭保活。

用户未设置时将使用系统默认配置。设置此配置可能会被延迟或被系统忽略，取决于系统的处理能力。

类型：?[SocketKeepAliveConfig](net_package_structs.md#struct-socketkeepaliveconfig)

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.sync.*

// 设置端口
let serverPort: UInt16 = 33334
// 同步计数器用于等待服务器启动
let serverStartCounter = SyncCounter(1)

func runTcpServer() {
    try (server = TcpServerSocket(bindAt: serverPort)) {
        server.bind()
        // 明确是服务器启动计数器递减
        serverStartCounter.dec()

        try (clientSocket = server.accept()) {
            // 接收数据的缓冲区
            let recvBuffer = Array<Byte>(10, repeat: 0)
            // 读取的字节数
            let readBytes = clientSocket.read(recvBuffer)
            println("Server read ${readBytes} bytes: ${recvBuffer}")
            // 发送数据
            clientSocket.write([1u8, 2u8, 3u8])
        }
    }
}

main(): Int64 {
    // 服务器启动的异步任务
    let serverTask = spawn {
        runTcpServer()
    }
    // 等待服务器启动完成（计数器归零）
    serverStartCounter.waitUntilZero()

    // 客户端连接的 socket
    try (client = TcpSocket("127.0.0.1", serverPort)) {
        client.connect()
        // 设置保活选项
        client.keepAlive = SocketKeepAliveConfig()
        // 发送的数据直接写字面量
        client.write([4, 5, 6])

        // 客户端接收数据缓冲区
        let buffer = Array<Byte>(10, repeat: 0)
        let readBytes = client.read(buffer)
        println("Client read ${readBytes} bytes: ${buffer}")
        println("Client keepAlive: ${client.keepAlive}")
    }

    // 等待服务器任务完成
    serverTask.get()
    return 0
}
```

运行结果：

```text
Server read 3 bytes: [4, 5, 6, 0, 0, 0, 0, 0, 0, 0]
Client read 3 bytes: [1, 2, 3, 0, 0, 0, 0, 0, 0, 0]
Client keepAlive: Some(SocketKeepAliveConfig(idle: 45s, interval: 5s, count: 5))
```

### prop linger

```cangjie
public mut prop linger: ?Duration
```

功能：设置和读取 `SO_LINGER` 属性，默认值取决于系统，`None` 表示禁用此选项。

> **说明：**
>
> - 如果 `SO_LINGER` 被设置为 `Some(v)`，当套接字关闭时，如果还有等待的字节流，我们将在关闭连接前等待 `v` 时间，如果超过时间，字节流还未被发送，连接将会被异常终止（通过 RST 报文关闭）。
> - 如果 `SO_LINGER` 被设置为 `None`，当套接字关闭时，连接将被立即关闭，如果当前等待发送的字符，使用 FIN-ACK 关闭连接，当还有剩余待发送的字符时，使用 RST 关闭连接。

类型：?[Duration](../../core/core_package_api/core_package_structs.md#struct-duration)

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当超时时间小于 0 时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let tcpSocket = TcpSocket("127.0.0.1", 3333)
    println("linger before setting: ${tcpSocket.linger}")
    tcpSocket.linger = Duration.second * 5
    println("linger after setting: ${tcpSocket.linger}")
    return 0
}
```

运行结果：

```text
linger before setting: None
linger after setting: Some(5s)
```

### prop localAddress

```cangjie
public override prop localAddress: SocketAddress
```

功能：读取 `Socket` 将要或已经被绑定的本地地址。

类型：[SocketAddress](net_package_classes.md#class-socketaddress)

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `Socket` 已经被关闭或无可用的本地地址（本地地址未配置并且套接字未连接）时，抛出异常。

示例：

<!-- run -->
```cangjie
import std.net.*
import std.sync.*

// 设置端口
let serverPort: UInt16 = 33334
// 同步计数器用于等待服务器启动
let serverStartCounter = SyncCounter(1)

func runTcpServer() {
    try (server = TcpServerSocket(bindAt: serverPort)) {
        server.bind()
        // 明确是服务器启动计数器递减
        serverStartCounter.dec()

        try (clientSocket = server.accept()) {
            // 接收数据的缓冲区
            let recvBuffer = Array<Byte>(10, repeat: 0)
            // 读取的字节数
            let readBytes = clientSocket.read(recvBuffer)
            println("Server read ${readBytes} bytes: ${recvBuffer}")
            // 发送数据
            clientSocket.write([1u8, 2u8, 3u8])
        }
    }
}

main(): Int64 {
    // 服务器启动的异步任务
    let serverTask = spawn {
        runTcpServer()
    }
    // 等待服务器启动完成（计数器归零）
    serverStartCounter.waitUntilZero()

    // 客户端连接的 socket
    let socketAddress: SocketAddress = IPSocketAddress.parse("127.0.0.1:33334")
    try (client = TcpSocket(socketAddress, localAddress: IPSocketAddress.parse("127.0.0.2:0"))) {
        client.connect()
        // 打印客户端本地地址
        println("client local address: ${client.localAddress}")
        // 发送的数据直接写字面量
        client.write([4, 5, 6])

        // 客户端接收数据缓冲区
        let buffer = Array<Byte>(10, repeat: 0)
        let readBytes = client.read(buffer)
        println("Client read ${readBytes} bytes: ${buffer}")
    }

    // 等待服务器任务完成
    serverTask.get()
    return 0
}
```

可能的运行结果：

```text
client local address: 127.0.0.2:35079
Server read 3 bytes: [4, 5, 6, 0, 0, 0, 0, 0, 0, 0]
Client read 3 bytes: [1, 2, 3, 0, 0, 0, 0, 0, 0, 0]
```

### prop noDelay

```cangjie
public mut prop noDelay: Bool
```

功能：设置和读取 `TCP_NODELAY` 属性，默认为 `true`。

这个选项将禁用 Nagel 算法，所有写入字节被无延迟得转发。当属性设置为 `false` 时，Nagel 算法将在发包前引入延时时间。

类型：[Bool](../../core/core_package_api/core_package_intrinsics.md#bool)

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let tcpSocket = TcpSocket("127.0.0.1", 3333)
    println("noDelay before setting: ${tcpSocket.noDelay}")
    tcpSocket.noDelay = false
    println("noDelay after setting: ${tcpSocket.noDelay}")
    return 0
}
```

运行结果：

```text
noDelay before setting: true
noDelay after setting: false
```

### prop quickAcknowledge

```cangjie
public mut prop quickAcknowledge: Bool
```

功能：设置和读取 `TCP_QUICKACK` 属性，连接后默认为 `false`。

这个选项类似于 `noDelay`，但仅影响 TCP ACK 和第一次响应。

> **注意：**
>
> 不支持平台：Windows、macOS、iOS。

类型：[Bool](../../core/core_package_api/core_package_intrinsics.md#bool)

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let tcpSocket = TcpSocket("127.0.0.1", 3333)
    println("quickAcknowledge before setting: ${tcpSocket.quickAcknowledge}")
    tcpSocket.quickAcknowledge = false
    println("quickAcknowledge after setting: ${tcpSocket.quickAcknowledge}")
    return 0
}
```

运行结果：

```text
quickAcknowledge before setting: true
quickAcknowledge after setting: false
```

### prop readTimeout

```cangjie
public override mut prop readTimeout: ?Duration
```

功能：设置和读取读操作超时时间。

如果设置的时间过小将会设置为最小时钟周期值；过大时将设置为最大超时时间（2<sup>63</sup>-1 纳秒）；默认值为 `None`。

类型：?[Duration](../../core/core_package_api/core_package_structs.md#struct-duration)

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当超时时间小于 0 时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let tcpSocket = TcpSocket("127.0.0.1", 3333)
    println("readTimeout before setting: ${tcpSocket.readTimeout}")
    tcpSocket.readTimeout = Duration.second * 10
    println("readTimeout after setting: ${tcpSocket.readTimeout}")
    return 0
}
```

运行结果：

```text
readTimeout before setting: None
readTimeout after setting: Some(10s)
```

### prop receiveBufferSize

```cangjie
public mut prop receiveBufferSize: Int64
```

功能：设置和读取 `SO_RCVBUF` 属性，提供一种方式指定收包缓冲区大小。选项的生效情况取决于系统。

类型：[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当 `size` 小于等于 0 时，抛出异常。
- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `Socket` 已关闭时，抛出异常。

示例：

<!-- run -->
```cangjie
import std.net.*

main(): Int64 {
    let tcpSocket = TcpSocket("127.0.0.1", 3333)
    println("receiveBufferSize before setting: ${tcpSocket.receiveBufferSize}")
    tcpSocket.receiveBufferSize = 8192
    println("receiveBufferSize after setting: ${tcpSocket.receiveBufferSize}")
    return 0
}
```

可能的运行结果：

```text
receiveBufferSize before setting: 131072
receiveBufferSize after setting: 16384
```

### prop remoteAddress

```cangjie
public override prop remoteAddress: SocketAddress
```

功能：读取 `Socket` 已经或将要连接的远端地址。

类型：[SocketAddress](net_package_classes.md#class-socketaddress)

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `Socket` 未连接或已经被关闭时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.sync.*

// 设置端口
let serverPort: UInt16 = 33336
// 同步计数器用于等待服务器启动
let serverStartCounter = SyncCounter(1)

func runTcpServer() {
    try (server = TcpServerSocket(bindAt: serverPort)) {
        server.bind()
        // 明确是服务器启动计数器递减
        serverStartCounter.dec()

        try (clientSocket = server.accept()) {
            // 接收数据的缓冲区
            let recvBuffer = Array<Byte>(10, repeat: 0)
            // 读取的字节数
            let readBytes = clientSocket.read(recvBuffer)
            println("Server read ${readBytes} bytes: ${recvBuffer}")
        }
    }
}

main(): Int64 {
    // 服务器启动的异步任务
    let serverTask = spawn {
        runTcpServer()
    }
    // 等待服务器启动完成（计数器归零）
    serverStartCounter.waitUntilZero()

    // 客户端连接的 socket
    try (client = TcpSocket("127.0.0.1", serverPort)) {
        client.connect()
        println("Remote address: ${client.remoteAddress}")
        // 发送的数据直接写字面量
        client.write([4, 5, 6])
    }

    // 等待服务器任务完成
    serverTask.get()
    return 0
}
```

运行结果：

```text
Remote address: 127.0.0.1:33336
Server read 3 bytes: [4, 5, 6, 0, 0, 0, 0, 0, 0, 0]
```

### prop sendBufferSize

```cangjie
public mut prop sendBufferSize: Int64
```

功能：设置和读取 `SO_SNDBUF` 属性，提供一种方式指定发包缓冲区大小。选项的生效情况取决于系统。

类型：[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当 `size` 小于等于 0 时，抛出异常。
- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `Socket` 已关闭时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let tcpSocket = TcpSocket("127.0.0.1", 3333)
    println("sendBufferSize before setting: ${tcpSocket.sendBufferSize}")
    tcpSocket.sendBufferSize = 4096
    println("sendBufferSize after setting: ${tcpSocket.sendBufferSize}")
    return 0
}
```

运行结果：

```text
sendBufferSize before setting: 16384
sendBufferSize after setting: 8192
```

### prop writeTimeout

```cangjie
public override mut prop writeTimeout: ?Duration
```

功能：设置和读取写操作超时时间。

如果设置的时间过小将会设置为最小时钟周期值；过大时将设置为最大超时时间（2<sup>63</sup>-1 纳秒）；默认值为 `None`。

类型：?[Duration](../../core/core_package_api/core_package_structs.md#struct-duration)

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当超时时间小于 0 时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let tcpSocket = TcpSocket("127.0.0.1", 3333)
    println("writeTimeout before setting: ${tcpSocket.writeTimeout}")
    tcpSocket.writeTimeout = Duration.second * 15
    println("writeTimeout after setting: ${tcpSocket.writeTimeout}")
    return 0
}
```

运行结果：

```text
writeTimeout before setting: None
writeTimeout after setting: Some(15s)
```

### init(SocketAddress)

```cangjie
public init(address: SocketAddress)
```

功能：创建一个未连接的套接字。

参数：

- address: [SocketAddress](net_package_classes.md#class-socketaddress) - 即将要连接的地址。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `address` 参数不合法或者 Windows 平台下地址为全零地址时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let socketAddress: SocketAddress = IPSocketAddress.parse("127.0.0.1:8080")
    let tcpSocket = TcpSocket(socketAddress)
    println("TcpSocket created with address: ${tcpSocket}")
    return 0
}
```

运行结果：

```text
TcpSocket created with address: TcpSocket(unconnected, unbound)
```

### init(SocketAddress, ?SocketAddress)

```cangjie
public init(address: SocketAddress, localAddress!: ?SocketAddress)
```

功能：创建一个未连接的套接字，并且绑定到指定本地地址，本地地址为 `None` 时，将随机选定地址去绑定。

此接口当 `localAddress` 不为 `None` 时，将默认设置 `SO_REUSEADDR` 为 `true`，否则可能导致 "address already in use" 的错误。如果需要变更此配置，可以通过调用 setSocketOptionBool([SocketOptions](net_package_structs.md#struct-socketoptions).SOL_SOCKET, [SocketOptions](net_package_structs.md#struct-socketoptions).SO_REUSEADDR, false)。另外，本地地址和远端地址需要均为 IPv4。

参数：

- address: [SocketAddress](net_package_classes.md#class-socketaddress) - 即将要连接的地址。
- localAddress!: ?[SocketAddress](net_package_classes.md#class-socketaddress) - 绑定的本地地址。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `address` 参数不合法或者 Windows 平台下地址为全零地址时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let socketAddress: SocketAddress = IPSocketAddress.parse("127.0.0.1:8080")
    let tcpSocket = TcpSocket(socketAddress, localAddress: IPSocketAddress.parse("127.0.0.2:0"))
    println("TcpSocket created with address: ${tcpSocket}")
    return 0
}
```

运行结果：

```text
TcpSocket created with address: TcpSocket(unconnected, unbound)
```

### init(String, UInt16)

```cangjie
public init(address: String, port: UInt16)
```

功能：创建一个未连接的套接字。

参数：

- address: [String](../../core/core_package_api/core_package_structs.md#struct-string) - 即将要连接的地址。
- port: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 即将要连接的端口。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `address` 参数不合法或者 Windows 平台下地址为全零地址时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let tcpSocket = TcpSocket("127.0.0.1", 8080)
    println("TcpSocket created with address: ${tcpSocket}")
    return 0
}
```

运行结果：

```text
TcpSocket created with address: TcpSocket(unconnected, unbound)
```

### func close()

```cangjie
public func close(): Unit
```

功能：关闭套接字，所有操作除了 `close/isClosed` 之外，均不允许再调用。接口允许多次调用。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let tcpSocket = TcpSocket("127.0.0.1", 8080)
    println("Is socket closed before close(): ${tcpSocket.isClosed()}")
    tcpSocket.close()
    println("Is socket closed after close(): ${tcpSocket.isClosed()}")
    return 0
}
```

运行结果：

```text
Is socket closed before close(): false
Is socket closed after close(): true
```

### func connect(?Duration)

```cangjie
public func connect(timeout!: ?Duration = None): Unit
```

功能：连接远端套接字，会自动绑定本地地址，因此不需要进行额外的绑定操作。

参数：

- timeout!: ?[Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - 连接超时时间，`None` 表示无超时时间，并且连接操作无重试，当服务端拒绝连接时，将返回连接失败。并且此操作包含了绑定操作，因此无需重复调用 `bind` 接口。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当远端地址不合法或者连接超时时间小于 0 或者超时时间小于 0 时，抛出异常。
- [SocketException](net_package_exceptions.md#class-socketexception) - 当连接因系统原因（例如：套接字已关闭，没有访问权限，系统错误等）无法建立时，抛出异常。再次调用可能成功。
- [SocketTimeoutException](net_package_exceptions.md#class-sockettimeoutexception) - 当连接超时时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.sync.*

// 设置端口
let serverPort: UInt16 = 33334
// 同步计数器用于等待服务器启动
let serverStartCounter = SyncCounter(1)

func runTcpServer() {
    try (server = TcpServerSocket(bindAt: serverPort)) {
        server.bind()
        // 明确是服务器启动计数器递减
        serverStartCounter.dec()

        try (clientSocket = server.accept()) {
            // 接收数据的缓冲区
            let recvBuffer = Array<Byte>(10, repeat: 0)
            // 读取的字节数
            let readBytes = clientSocket.read(recvBuffer)
            println("Server read ${readBytes} bytes: ${recvBuffer}")
            // 发送数据
            clientSocket.write([1u8, 2u8, 3u8])
        }
    }
}

main(): Int64 {
    // 服务器启动的异步任务
    let serverTask = spawn {
        runTcpServer()
    }
    // 等待服务器启动完成（计数器归零）
    serverStartCounter.waitUntilZero()

    // 客户端连接的 socket
    try (client = TcpSocket("127.0.0.1", serverPort)) {
        client.connect()
        // 发送的数据直接写字面量
        client.write([4, 5, 6])

        // 客户端接收数据缓冲区
        let buffer = Array<Byte>(10, repeat: 0)
        let readBytes = client.read(buffer)
        println("Client read ${readBytes} bytes: ${buffer}")
    }

    // 等待服务器任务完成
    serverTask.get()
    return 0
}
```

运行结果：

```text
Server read 3 bytes: [4, 5, 6, 0, 0, 0, 0, 0, 0, 0]
Client read 3 bytes: [1, 2, 3, 0, 0, 0, 0, 0, 0, 0]
```

### func getSocketOption(Int32, Int32, CPointer\<Unit>, CPointer\<UIntNative>)

```cangjie
public func getSocketOption(
    level: Int32,
    option: Int32,
    value: CPointer<Unit>,
    valueLength: CPointer<UIntNative>
): Unit
```

功能：读取指定的套接字参数。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。
- value: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[Unit](../../core/core_package_api/core_package_intrinsics.md#unit)> - 参数值。
- valueLength: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[UIntNative](../../core/core_package_api/core_package_intrinsics.md#uintnative)> - 参数值长度。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `getsockopt` 返回失败时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

foreign {
    func free(ptr: CPointer<Unit>): Unit

    func malloc(size: UIntNative): CPointer<Unit>
}

// TCP_NODELAY选项值的大小（Int32类型）
let TCP_NODELAY_VALUE_SIZE: UIntNative = sizeOf<Int32>()

main() {
    let tcpSocket = TcpSocket("127.0.0.1", 8080)
    // 存储TCP_NODELAY选项的获取结果（初始值-1表示未获取成功）
    var tcpNoDelayValue: Int32 = -1

    unsafe {
        // 为存储选项值分配内存
        let optionValueBuffer = malloc(TCP_NODELAY_VALUE_SIZE)
        // 转换为Int32类型指针
        let int32Ptr = CPointer<Int32>(optionValueBuffer)

        // 存储选项值缓冲区的长度
        let bufferSizeArray = Array<UIntNative>(1, repeat: TCP_NODELAY_VALUE_SIZE)
        // 获取数组的原始数据指针
        let bufferSizePtr = acquireArrayRawData(bufferSizeArray)

        try {
            // 获取TCP_NODELAY选项值
            tcpSocket.getSocketOption(
                OptionLevel.TCP,
                SocketOptions.TCP_NODELAY,
                CPointer(int32Ptr),
                bufferSizePtr.pointer
            )
            // 读取选项值
            tcpNoDelayValue = int32Ptr.read()
        } finally {
            // 释放分配的内存和数组引用
            free(optionValueBuffer)
            releaseArrayRawData(bufferSizePtr)
        }
    }
    println("TCP_NODELAY值: ${tcpNoDelayValue}")
}
```

运行结果：

```text
TCP_NODELAY值: 1
```

### func getSocketOptionBool(Int32, Int32)

```cangjie
public func getSocketOptionBool(
    level: Int32,
    option: Int32
): Bool
```

功能：读取指定的套接字参数。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 指定的套接字参数。从 [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) 强转而来。`0 => false`，`非 0 => true`。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `getsockopt` 返回失败时或参数大小超过 [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) 的阈值时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let tcpSocket = TcpSocket("127.0.0.1", 8080)
    var nodelay = tcpSocket.getSocketOptionBool(OptionLevel.TCP, OptionName.TCP_NODELAY)
    println("Nodelay before: ${nodelay}")
    tcpSocket.setSocketOptionBool(OptionLevel.TCP, OptionName.TCP_NODELAY, false)
    nodelay = tcpSocket.getSocketOptionBool(OptionLevel.TCP, OptionName.TCP_NODELAY)
    println("Nodelay after: ${nodelay}")
    return 0
}
```

运行结果：

```text
Nodelay before: true
Nodelay after: false
```

### func getSocketOptionIntNative(Int32, Int32)

```cangjie
public func getSocketOptionIntNative(
    level: Int32,
    option: Int32
): IntNative
```

功能：读取指定的套接字参数。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。

返回值：

- [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) - 参数值。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `getsockopt` 返回失败时或参数大小超过 [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) 的阈值时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let tcpSocket = TcpSocket("127.0.0.1", 8080)
    var nodelay = tcpSocket.getSocketOptionIntNative(OptionLevel.TCP, OptionName.TCP_NODELAY)
    println("Nodelay before: ${nodelay}")
    tcpSocket.setSocketOptionIntNative(OptionLevel.TCP, OptionName.TCP_NODELAY, 0)
    nodelay = tcpSocket.getSocketOptionIntNative(OptionLevel.TCP, OptionName.TCP_NODELAY)
    println("Nodelay after: ${nodelay}")
    return 0
}
```

运行结果：

```text
Nodelay before: 1
Nodelay after: 0
```

### func hashCode()

```cangjie
public override func hashCode(): Int64
```

功能：获取当前 [TcpSocket](net_package_classes.md#class-tcpsocket) 实例的哈希值。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - [TcpSocket](net_package_classes.md#class-tcpsocket) 实例的哈希值。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let tcpSocket = TcpSocket("127.0.0.1", 8080)
    println("Hash code of TcpSocket: ${tcpSocket.hashCode()}")
    return 0
}
```

运行结果：

```text
Hash code of TcpSocket: 1
```

### func isClosed()

```cangjie
public func isClosed(): Bool
```

功能：判断套接字是否通过调用 `close` 显式关闭。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 套接字是否已经调用 `close` 显式关闭。是则返回 `true`；否则返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let tcpSocket = TcpSocket("127.0.0.1", 8080)
    println("Is socket closed before close(): ${tcpSocket.isClosed()}")
    tcpSocket.close()
    println("Is socket closed after close(): ${tcpSocket.isClosed()}")
    return 0
}
```

运行结果：

```text
Is socket closed before close(): false
Is socket closed after close(): true
```

### func read(Array\<Byte>)

```cangjie
public override func read(buffer: Array<Byte>): Int64
```

功能：读取报文。超时情况按 `readTimeout` 决定，详见 `readTimeout`。

> **说明：**
>
> - 由于系统底层接口差异，如果连接被对端关闭，`read` 和 `write` 接口的行为也有相应的差异。
> - Windows 系统上，对端关闭连接后，如果本端调用一次 `write`，会导致清空缓冲区内容，在此基础上再调用 `read` 会抛出连接关闭异常。
> - Linux/macOS 系统上，对端关闭连接后，先调用 `write` 再调用 `read` 函数仍会读出缓冲区中的内容。

参数：

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 存储读出数据的缓冲区。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 读取的数据长度。当对端关闭连接或本端套接字已通过 `close` 关闭时，返回 `0`。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `buffer` 大小为 0 或者因系统原因读取失败时，抛出异常。
- [SocketTimeoutException](net_package_exceptions.md#class-sockettimeoutexception) - 当读取超时时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.sync.*

// 设置端口
let serverPort: UInt16 = 33334
// 同步计数器用于等待服务器启动
let serverStartCounter = SyncCounter(1)

func runTcpServer() {
    try (server = TcpServerSocket(bindAt: serverPort)) {
        server.bind()
        // 明确是服务器启动计数器递减
        serverStartCounter.dec()

        try (clientSocket = server.accept()) {
            // 接收数据的缓冲区
            let recvBuffer = Array<Byte>(10, repeat: 0)
            // 读取的字节数
            let readBytes = clientSocket.read(recvBuffer)
            println("Server read ${readBytes} bytes: ${recvBuffer}")
            // 发送数据
            clientSocket.write([1u8, 2u8, 3u8])
        }
    }
}

main(): Int64 {
    // 服务器启动的异步任务
    let serverTask = spawn {
        runTcpServer()
    }
    // 等待服务器启动完成（计数器归零）
    serverStartCounter.waitUntilZero()

    // 客户端连接的 socket
    try (client = TcpSocket("127.0.0.1", serverPort)) {
        client.connect()
        // 发送的数据直接写字面量
        client.write([4, 5, 6])

        // 客户端接收数据缓冲区
        let buffer = Array<Byte>(10, repeat: 0)
        let readBytes = client.read(buffer)
        println("Client read ${readBytes} bytes: ${buffer}")
    }

    // 等待服务器任务完成
    serverTask.get()
    return 0
}
```

运行结果：

```text
Server read 3 bytes: [4, 5, 6, 0, 0, 0, 0, 0, 0, 0]
Client read 3 bytes: [1, 2, 3, 0, 0, 0, 0, 0, 0, 0]
```

### func setSocketOption(Int32, Int32, CPointer\<Unit>, UIntNative)

```cangjie
public func setSocketOption(
    level: Int32,
    option: Int32,
    value: CPointer<Unit>,
    valueLength: UIntNative
): Unit
```

功能：设置指定的套接字参数。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。
- value: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[Unit](../../core/core_package_api/core_package_intrinsics.md#unit)> - 参数值。
- valueLength: [UIntNative](../../core/core_package_api/core_package_intrinsics.md#uintnative) - 参数值长度。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `setsockopt` 返回失败时，抛出异常。

示例：

<!-- run -->
```cangjie
import std.net.*

foreign {
    func free(ptr: CPointer<Unit>): Unit

    func malloc(size: UIntNative): CPointer<Unit>
}

// TCP_NODELAY选项值（Int32类型）的内存大小
let TCP_NODELAY_VALUE_SIZE: UIntNative = sizeOf<Int32>()

main() {
    let tcpSocket = TcpSocket("127.0.0.1", 8080)
    unsafe {
        // 为TCP_NODELAY选项的值分配内存缓冲区
        let tcpNodelayBuffer = malloc(TCP_NODELAY_VALUE_SIZE)
        // 转换为Int32类型指针，专门用于操作TCP_NODELAY的选项值
        let tcpNodelayPtr = CPointer<Int32>(tcpNodelayBuffer)

        try {
            // 写入禁用TCP_NODELAY的值（0表示禁用）
            tcpNodelayPtr.write(0)
            // 设置套接字选项
            tcpSocket.setSocketOption(
                OptionLevel.TCP,
                SocketOptions.TCP_NODELAY,
                CPointer(tcpNodelayPtr),
                TCP_NODELAY_VALUE_SIZE
            )
        } finally {
            // 释放为选项值分配的缓冲区
            free(tcpNodelayBuffer)
        }
    }
}
```

### func setSocketOptionBool(Int32, Int32, Bool)

```cangjie
public func setSocketOptionBool(
    level: Int32,
    option: Int32,
    value: Bool
): Unit
```

功能：设置指定的套接字参数。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。
- value: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 参数值。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `setsockopt` 返回失败时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let tcpSocket = TcpSocket("127.0.0.1", 8080)
    var nodelay = tcpSocket.getSocketOptionBool(OptionLevel.TCP, OptionName.TCP_NODELAY)
    println("Nodelay before: ${nodelay}")
    tcpSocket.setSocketOptionBool(OptionLevel.TCP, OptionName.TCP_NODELAY, false)
    nodelay = tcpSocket.getSocketOptionBool(OptionLevel.TCP, OptionName.TCP_NODELAY)
    println("Nodelay after: ${nodelay}")
    return 0
}
```

运行结果：

```text
Nodelay before: true
Nodelay after: false
```

### func setSocketOptionIntNative(Int32, Int32, IntNative)

```cangjie
public func setSocketOptionIntNative(
    level: Int32,
    option: Int32,
    value: IntNative
): Unit
```

功能：设置指定的套接字参数。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。
- value: [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) - 参数值。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `setsockopt` 返回失败时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let tcpSocket = TcpSocket("127.0.0.1", 8080)
    var nodelay = tcpSocket.getSocketOptionIntNative(OptionLevel.TCP, OptionName.TCP_NODELAY)
    println("Nodelay before: ${nodelay}")
    tcpSocket.setSocketOptionIntNative(OptionLevel.TCP, OptionName.TCP_NODELAY, 0)
    nodelay = tcpSocket.getSocketOptionIntNative(OptionLevel.TCP, OptionName.TCP_NODELAY)
    println("Nodelay after: ${nodelay}")
    return 0
}
```

运行结果：

```text
Nodelay before: 1
Nodelay after: 0
```

### func toString()

```cangjie
public override func toString(): String
```

功能：返回当前 [TcpSocket](net_package_classes.md#class-tcpsocket) 的状态信息。

返回值：

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - 包含当前 [TcpSocket](net_package_classes.md#class-tcpsocket) 状态信息的字符串。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let tcpSocket = TcpSocket("127.0.0.1", 8080)
    println("TcpSocket toString: ${tcpSocket.toString()}")
    return 0
}
```

运行结果：

```text
TcpSocket toString: TcpSocket(unconnected, unbound)
```

### func write(Array\<Byte>)

```cangjie
public override func write(payload: Array<Byte>): Unit
```

功能：写入报文。超时情况按 `writeTimeout` 决定，详见 `writeTimeout`。

参数：

- payload: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 存储写入数据的缓冲区。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `buffer` 大小为 0 或者当因系统原因写入失败时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.sync.*

// 设置端口
let serverPort: UInt16 = 33334
// 同步计数器用于等待服务器启动
let serverStartCounter = SyncCounter(1)

func runTcpServer() {
    try (server = TcpServerSocket(bindAt: serverPort)) {
        server.bind()
        // 明确是服务器启动计数器递减
        serverStartCounter.dec()

        try (clientSocket = server.accept()) {
            // 接收数据的缓冲区
            let recvBuffer = Array<Byte>(10, repeat: 0)
            // 读取的字节数
            let readBytes = clientSocket.read(recvBuffer)
            println("Server read ${readBytes} bytes: ${recvBuffer}")
            // 发送数据
            clientSocket.write([1u8, 2u8, 3u8])
        }
    }
}

main(): Int64 {
    // 服务器启动的异步任务
    let serverTask = spawn {
        runTcpServer()
    }
    // 等待服务器启动完成（计数器归零）
    serverStartCounter.waitUntilZero()

    // 客户端连接的 socket
    try (client = TcpSocket("127.0.0.1", serverPort)) {
        client.connect()
        // 发送的数据直接写字面量
        client.write([4, 5, 6])

        // 客户端接收数据缓冲区
        let buffer = Array<Byte>(10, repeat: 0)
        let readBytes = client.read(buffer)
        println("Client read ${readBytes} bytes: ${buffer}")
    }

    // 等待服务器任务完成
    serverTask.get()
    return 0
}
```

运行结果：

```text
Server read 3 bytes: [4, 5, 6, 0, 0, 0, 0, 0, 0, 0]
Client read 3 bytes: [1, 2, 3, 0, 0, 0, 0, 0, 0, 0]
```

### operator func !=(TcpSocket)

```cangjie
public override operator func !=(other: TcpSocket): Bool
```

功能：判断两个 [TcpSocket](net_package_classes.md#class-tcpsocket) 实例是否不等。

参数：

- other: [TcpSocket](net_package_classes.md#class-tcpsocket) - 参与比较的 [TcpSocket](net_package_classes.md#class-tcpsocket) 实例。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 如果两个 [TcpSocket](net_package_classes.md#class-tcpsocket) 实例不等，则返回 `true`；否则，返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let tcpSocket1 = TcpSocket("127.0.0.1", 8080)
    let tcpSocket2 = TcpSocket("127.0.0.1", 8080)
    let tcpSocket3 = tcpSocket1

    println("tcpSocket1 != tcpSocket2: ${tcpSocket1 != tcpSocket2}")
    println("tcpSocket1 != tcpSocket3: ${tcpSocket1 != tcpSocket3}")
    return 0
}
```

运行结果：

```text
tcpSocket1 != tcpSocket2: true
tcpSocket1 != tcpSocket3: false
```

### operator func ==(TcpSocket)

```cangjie
public override operator func ==(other: TcpSocket): Bool
```

功能：判断两个 [TcpSocket](net_package_classes.md#class-tcpsocket) 实例是否相等。

参数：

- other: [TcpSocket](net_package_classes.md#class-tcpsocket) - 参与比较的 [TcpSocket](net_package_classes.md#class-tcpsocket) 实例。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 如果两个 [TcpSocket](net_package_classes.md#class-tcpsocket) 实例相等，则返回 `true`；否则，返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let tcpSocket1 = TcpSocket("127.0.0.1", 8080)
    let tcpSocket2 = TcpSocket("127.0.0.1", 8080)
    let tcpSocket3 = tcpSocket1

    println("tcpSocket1 == tcpSocket2: ${tcpSocket1 == tcpSocket2}")
    println("tcpSocket1 == tcpSocket3: ${tcpSocket1 == tcpSocket3}")
    return 0
}
```

运行结果：

```text
tcpSocket1 == tcpSocket2: false
tcpSocket1 == tcpSocket3: true
```

## class UdpSocket

```cangjie
public class UdpSocket <: DatagramSocket {
    public init(bindAt!: UInt16)
    public init(bindAt!: SocketAddress)
}
```

功能：提供 udp 报文通信。

`UdpSocket` 创建实例后，需要调用 `bind()` 绑定，可在不与远端建连的前提下接受报文。`UdpSocket` 也可以通过 `connect()/disconnect()` 接口进行建连。UDP 协议要求传输报文大小不可超过 64KB 。
`UdpSocket` 需要被显式 `close()` 。可参见 [DatagramSocket](net_package_interfaces.md#interface-datagramsocket) 获取更多信息。

父类型：

- [DatagramSocket](net_package_interfaces.md#interface-datagramsocket)

### prop localAddress

```cangjie
public override prop localAddress: SocketAddress
```

功能：读取 `Socket` 将要或已经被绑定的本地地址。

类型：[SocketAddress](net_package_classes.md#class-socketaddress)

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `Socket` 已经被关闭或无可用的本地地址（本地地址未配置并且套接字未连接）时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.sync.*

main(): Int64 {
    // 设置端口
    let serverPort: UInt16 = 33335
    // 同步计数器用于等待服务器启动
    let serverStartCounter = SyncCounter(1)

    func runUdpServer() {
        try (server = UdpSocket(bindAt: serverPort)) {
            server.bind()
            // 明确是服务器启动计数器递减
            serverStartCounter.dec()

            // 接收的客户端数据，设置5秒超时
            let timeout = Duration.second * 5
            server.receiveTimeout = timeout

            // 接收数据的缓冲区
            let recvBuffer = Array<Byte>(10, repeat: 0)
            // 接收数据
            let (senderAddress, readBytes) = server.receiveFrom(recvBuffer)
            println("Server received ${readBytes} bytes from ${senderAddress}: ${recvBuffer}")

            // 发送数据回客户端
            server.sendTo(senderAddress, [1u8, 2u8, 3u8])
        }
    }

    // 服务器启动的异步任务
    let serverTask = spawn {
        runUdpServer()
    }
    // 等待服务器启动完成（计数器归零）
    serverStartCounter.waitUntilZero()

    // 客户端连接的 socket
    try (client = UdpSocket(bindAt: 33336)) {
        client.bind()
        println("Client local address: ${client.localAddress}")

        // 发送的数据直接写字面量
        let serverAddress = IPSocketAddress.parse("127.0.0.1:${serverPort}")
        client.sendTo(serverAddress, [4, 5, 6])

        // 客户端接收数据缓冲区
        let buffer = Array<Byte>(10, repeat: 0)
        let (senderAddress, readBytes) = client.receiveFrom(buffer)
        println("Client received ${readBytes} bytes from ${senderAddress}: ${buffer}")
    }

    // 等待服务器任务完成
    serverTask.get()
    return 0
}
```

运行结果：

```text
Client local address: 0.0.0.0:33336
Server received 3 bytes from 127.0.0.1:33336: [4, 5, 6, 0, 0, 0, 0, 0, 0, 0]
Client received 3 bytes from 127.0.0.1:33335: [1, 2, 3, 0, 0, 0, 0, 0, 0, 0]
```

### prop receiveBufferSize

```cangjie
public mut prop receiveBufferSize: Int64
```

功能：设置和读取 `SO_RCVBUF` 属性。

类型：[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当 `size` 小于等于 0 时，抛出异常。
- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `Socket` 已关闭时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let udpSocket = UdpSocket(bindAt: 33336)
    println("receiveBufferSize before setting: ${udpSocket.receiveBufferSize}")
    udpSocket.receiveBufferSize = 8192
    println("receiveBufferSize after setting: ${udpSocket.receiveBufferSize}")
    return 0
}
```

运行结果：

```text
receiveBufferSize before setting: 212992
receiveBufferSize after setting: 16384
```

### prop receiveTimeout

```cangjie
public override mut prop receiveTimeout: ?Duration
```

功能：设置和读取 `receive/receiveFrom` 操作超时时间。

如果设置的时间过小将会设置为最小时钟周期值；过大时将设置为最大超时时间（2<sup>63</sup>-1 纳秒）；默认值为 `None`。

类型：?[Duration](../../core/core_package_api/core_package_structs.md#struct-duration)

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当超时时间小于 0 时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let udpSocket = UdpSocket(bindAt: 33337)
    println("receiveTimeout before setting: ${udpSocket.receiveTimeout}")
    udpSocket.receiveTimeout = Duration.second * 10
    println("receiveTimeout after setting: ${udpSocket.receiveTimeout}")
    return 0
}
```

运行结果：

```text
receiveTimeout before setting: None
receiveTimeout after setting: Some(10s)
```

### prop remoteAddress

```cangjie
public override prop remoteAddress: ?SocketAddress
```

功能：读取 `Socket` 已经连接的远端地址，当 `Socket` 未连接时返回 `None`。

类型：?[SocketAddress](net_package_classes.md#class-socketaddress)

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `Socket` 已经被关闭时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.sync.*

main(): Int64 {
    // 设置端口
    let serverPort: UInt16 = 33338
    // 同步计数器用于等待服务器启动
    let serverStartCounter = SyncCounter(1)

    func runUdpServer() {
        try (server = UdpSocket(bindAt: serverPort)) {
            server.bind()
            // 明确是服务器启动计数器递减
            serverStartCounter.dec()

            // 接收的客户端数据，设置5秒超时
            let timeout = Duration.second * 5
            server.receiveTimeout = timeout

            // 接收数据的缓冲区
            let recvBuffer = Array<Byte>(10, repeat: 0)
            // 接收数据
            let (senderAddress, readBytes) = server.receiveFrom(recvBuffer)
            println("Server received ${readBytes} bytes from ${senderAddress}: ${recvBuffer}")

            // 发送数据回客户端
            server.sendTo(senderAddress, [1u8, 2u8, 3u8])
        }
    }

    // 服务器启动的异步任务
    let serverTask = spawn {
        runUdpServer()
    }
    // 等待服务器启动完成（计数器归零）
    serverStartCounter.waitUntilZero()

    // 客户端连接的 socket
    try (client = UdpSocket(bindAt: 33339)) {
        client.bind()

        // 连接到服务器
        let serverAddress = IPSocketAddress.parse("127.0.0.1:${serverPort}")
        client.connect(serverAddress)
        println("Client remote address: ${client.remoteAddress}")

        // 发送的数据直接写字面量
        client.send([4, 5, 6])

        // 客户端接收数据缓冲区
        let buffer = Array<Byte>(10, repeat: 0)
        let readBytes = client.receive(buffer)
        println("Client received ${readBytes} bytes: ${buffer}")
    }

    // 等待服务器任务完成
    serverTask.get()
    return 0
}
```

运行结果：

```text
Client remote address: Some(127.0.0.1:33338)
Server received 3 bytes from 127.0.0.1:33339: [4, 5, 6, 0, 0, 0, 0, 0, 0, 0]
Client received 3 bytes: [1, 2, 3, 0, 0, 0, 0, 0, 0, 0]
```

### prop reuseAddress

```cangjie
public mut prop reuseAddress: Bool
```

功能：设置和读取 `SO_REUSEADDR` 属性。

属性默认以及生效后的行为取决于系统，使用前，请参阅不同系统针对此属性 `SO_REUSEADDR/SOCK_REUSEADDR` 的说明文档。

类型：[Bool](../../core/core_package_api/core_package_intrinsics.md#bool)

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let udpSocket = UdpSocket(bindAt: 33339)
    println("reuseAddress before setting: ${udpSocket.reuseAddress}")
    udpSocket.reuseAddress = true
    println("reuseAddress after setting: ${udpSocket.reuseAddress}")
    return 0
}
```

运行结果：

```text
reuseAddress before setting: false
reuseAddress after setting: true
```

### prop reusePort

```cangjie
public mut prop reusePort: Bool
```

功能：设置和读取 `SO_REUSEPORT` 属性。

属性默认以及配置生效后的行为取决于系统，使用前，请参阅不同系统针对此属性 `SO_REUSEPORT` 的说明文档。

> **注意：**
>
> 不支持平台：Windows。

类型：[Bool](../../core/core_package_api/core_package_intrinsics.md#bool)

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - Windows 上不支持此类型，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let udpSocket = UdpSocket(bindAt: 33340)
    println("reusePort before setting: ${udpSocket.reusePort}")
    udpSocket.reusePort = true
    println("reusePort after setting: ${udpSocket.reusePort}")
    return 0
}
```

运行结果：

```text
reusePort before setting: false
reusePort after setting: true
```

### prop sendBufferSize

```cangjie
public mut prop sendBufferSize: Int64
```

功能：设置和读取 `SO_SNDBUF` 属性。

类型：[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当 `size` 小于等于 0 时，抛出异常。
- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `Socket` 已关闭时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let udpSocket = UdpSocket(bindAt: 33341)
    println("sendBufferSize before setting: ${udpSocket.sendBufferSize}")
    udpSocket.sendBufferSize = 4096
    println("sendBufferSize after setting: ${udpSocket.sendBufferSize}")
    return 0
}
```

运行结果：

```text
sendBufferSize before setting: 212992
sendBufferSize after setting: 8192
```

### prop sendTimeout

```cangjie
public override mut prop sendTimeout: ?Duration
```

功能：设置和读取 `send/sendTo` 操作超时时间。

如果设置的时间过小将会设置为最小时钟周期值；过大时将设置为最大超时时间（2<sup>63</sup>-1 纳秒）；默认值为 `None`。

类型：?[Duration](../../core/core_package_api/core_package_structs.md#struct-duration)

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let udpSocket = UdpSocket(bindAt: 33342)
    println("sendTimeout before setting: ${udpSocket.sendTimeout}")
    udpSocket.sendTimeout = Duration.second * 15
    println("sendTimeout after setting: ${udpSocket.sendTimeout}")
    return 0
}
```

运行结果：

```text
sendTimeout before setting: None
sendTimeout after setting: Some(15s)
```

### init(SocketAddress)

```cangjie
public init(bindAt!: SocketAddress)
```

功能：创建一个未绑定的 `UdpSocket` 实例。

参数：

- bindAt!: [SocketAddress](net_package_classes.md#class-socketaddress) - 绑定地址及端口。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当超时时间小于 0 时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let socketAddress: SocketAddress = IPSocketAddress.parse("127.0.0.1:8080")
    let udpSocket = UdpSocket(bindAt: socketAddress)
    udpSocket.bind()
    println("UdpSocket created with address: ${udpSocket}")
    udpSocket.close()
    return 0
}
```

运行结果：

```text
UdpSocket created with address: UdpSocket(bound at 127.0.0.1:8080)
```

### init(UInt16)

```cangjie
public init(bindAt!: UInt16)
```

功能：创建一个未绑定的 `UdpSocket` 实例。

参数：

- bindAt!: [UInt16](../../core/core_package_api/core_package_intrinsics.md#uint16) - 绑定端口。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let udpSocket = UdpSocket(bindAt: 8080)
    udpSocket.bind()
    println("UdpSocket created with address: ${udpSocket}")
    udpSocket.close()
    return 0
}
```

运行结果：

```text
UdpSocket created with address: UdpSocket(bound at 0.0.0.0:8080)
```

### func bind()

```cangjie
public func bind(): Unit
```

功能：绑定本地端口失败后需要 `close` 套接字，不支持多次重试。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当因系统原因绑定失败时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let udpSocket = UdpSocket(bindAt: 33343)
    udpSocket.bind()
    println("UdpSocket bound successfully")
    println("Local address: ${udpSocket.localAddress}")
    udpSocket.close()
    return 0
}
```

运行结果：

```text
UdpSocket bound successfully
Local address: 0.0.0.0:33343
```

### func close()

```cangjie
public override func close(): Unit
```

功能：关闭套接字，所有操作除了 `close/isClosed` 之外，均不允许再调用。接口允许多次调用。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let udpSocket = UdpSocket(bindAt: 33344)
    udpSocket.bind()
    println("UdpSocket bound successfully")
    println("Is closed before close: ${udpSocket.isClosed()}")
    udpSocket.close()
    println("Is closed after close: ${udpSocket.isClosed()}")
    return 0
}
```

运行结果：

```text
UdpSocket bound successfully
Is closed before close: false
Is closed after close: true
```

### func connect(SocketAddress)

```cangjie
public func connect(remote: SocketAddress): Unit
```

功能：连接特定远端地址，可通过 `disconnect` 撤销配置。

仅接受该远端地址的报文。必须在调用 `bind` 后执行。此操作执行后，端口将开始接收 ICMP 报文，若收到异常报文后，可能导致 `send/sendTo` 执行失败。

参数：

- remote: [SocketAddress](net_package_classes.md#class-socketaddress) - 远端地址。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当远端地址不合法时，抛出异常。
- [SocketException](net_package_exceptions.md#class-socketexception) - 当端口未绑定、连接因系统原因无法建立或者 Windows 平台下远端地址为全零地址时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.sync.*

main(): Int64 {
    // 设置端口
    let serverPort: UInt16 = 33345
    // 同步计数器用于等待服务器启动
    let serverStartCounter = SyncCounter(1)

    func runUdpServer() {
        try (server = UdpSocket(bindAt: serverPort)) {
            server.bind()
            // 明确是服务器启动计数器递减
            serverStartCounter.dec()

            // 接收的客户端数据，设置5秒超时
            let timeout = Duration.second * 5
            server.receiveTimeout = timeout

            // 接收数据的缓冲区
            let recvBuffer = Array<Byte>(10, repeat: 0)
            // 接收数据
            let (senderAddress, readBytes) = server.receiveFrom(recvBuffer)
            println("Server received ${readBytes} bytes from ${senderAddress}: ${recvBuffer}")

            // 发送数据回客户端
            server.sendTo(senderAddress, [1u8, 2u8, 3u8])
        }
    }

    // 服务器启动的异步任务
    let serverTask = spawn {
        runUdpServer()
    }
    // 等待服务器启动完成（计数器归零）
    serverStartCounter.waitUntilZero()

    // 客户端连接的 socket
    try (client = UdpSocket(bindAt: 33346)) {
        client.bind()

        // 连接到服务器
        let serverAddress = IPSocketAddress.parse("127.0.0.1:${serverPort}")
        client.connect(serverAddress)
        println("Client remote address after connect: ${client.remoteAddress}")

        // 发送的数据直接写字面量
        client.send([4, 5, 6])

        // 客户端接收数据缓冲区
        let buffer = Array<Byte>(10, repeat: 0)
        let readBytes = client.receive(buffer)
        println("Client received ${readBytes} bytes: ${buffer}")
    }

    // 等待服务器任务完成
    serverTask.get()
    return 0
}
```

运行结果：

```text
Client remote address after connect: Some(127.0.0.1:33345)
Server received 3 bytes from 127.0.0.1:33346: [4, 5, 6, 0, 0, 0, 0, 0, 0, 0]
Client received 3 bytes: [1, 2, 3, 0, 0, 0, 0, 0, 0, 0]
```

### func disconnect()

```cangjie
public func disconnect(): Unit
```

功能：停止连接。取消仅收取特定对端报文。可在 `connect` 前调用，可多次调用。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.sync.*

main(): Int64 {
    // 设置端口
    let serverPort: UInt16 = 33346
    // 同步计数器用于等待服务器启动
    let serverStartCounter = SyncCounter(1)

    func runUdpServer() {
        try (server = UdpSocket(bindAt: serverPort)) {
            server.bind()
            // 明确是服务器启动计数器递减
            serverStartCounter.dec()

            // 接收的客户端数据，设置5秒超时
            let timeout = Duration.second * 5
            server.receiveTimeout = timeout

            // 接收数据的缓冲区
            let recvBuffer = Array<Byte>(10, repeat: 0)
            // 接收数据
            let (senderAddress, readBytes) = server.receiveFrom(recvBuffer)
            println("Server received ${readBytes} bytes from ${senderAddress}: ${recvBuffer}")

            // 发送数据回客户端
            server.sendTo(senderAddress, [1u8, 2u8, 3u8])
        }
    }

    // 服务器启动的异步任务
    let serverTask = spawn {
        runUdpServer()
    }
    // 等待服务器启动完成（计数器归零）
    serverStartCounter.waitUntilZero()

    // 客户端连接的 socket
    try (client = UdpSocket(bindAt: 33347)) {
        client.bind()

        // 连接到服务器
        let serverAddress = IPSocketAddress.parse("127.0.0.1:${serverPort}")
        client.connect(serverAddress)
        println("Client remote address after connect: ${client.remoteAddress}")

        // 发送的数据直接写字面量
        client.send([4, 5, 6])

        // 客户端接收数据缓冲区
        let buffer = Array<Byte>(10, repeat: 0)
        let readBytes = client.receive(buffer)
        println("Client received ${readBytes} bytes: ${buffer}")

        // 断开连接
        client.disconnect()
        println("Client disconnected successfully")
    }

    // 等待服务器任务完成
    serverTask.get()
    return 0
}
```

运行结果：

```text
Client remote address after connect: Some(127.0.0.1:33346)
Server received 3 bytes from 127.0.0.1:33347: [4, 5, 6, 0, 0, 0, 0, 0, 0, 0]
Client received 3 bytes: [1, 2, 3, 0, 0, 0, 0, 0, 0, 0]
Client disconnected successfully
```

### func getSocketOption(Int32, Int32, CPointer\<Unit>, CPointer\<UIntNative>)

```cangjie
public func getSocketOption(
    level: Int32,
    option: Int32,
    value: CPointer<Unit>,
    valueLength: CPointer<UIntNative>
): Unit
```

功能：获取指定的套接字参数。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。
- value: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[Unit](../../core/core_package_api/core_package_intrinsics.md#unit)> - 参数值。
- valueLength: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[UIntNative](../../core/core_package_api/core_package_intrinsics.md#uintnative)> - 参数值长度。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `getsockopt` 返回失败时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

foreign {
    func free(ptr: CPointer<Unit>): Unit

    func malloc(size: UIntNative): CPointer<Unit>
}

// SO_REUSEADDR选项值的大小（Int32类型）
let SO_REUSEADDR_VALUE_SIZE: UIntNative = sizeOf<Int32>()

main(): Int64 {
    let udpSocket = UdpSocket(bindAt: 33347)
    udpSocket.bind()
    // 存储SO_REUSEADDR选项的获取结果（初始值-1表示未获取成功）
    var reuseAddrValue: Int32 = -1

    unsafe {
        // 为存储选项值分配内存
        let optionValueBuffer = malloc(SO_REUSEADDR_VALUE_SIZE)
        // 转换为Int32类型指针
        let int32Ptr = CPointer<Int32>(optionValueBuffer)

        // 存储选项值缓冲区的长度
        let bufferSizeArray = Array<UIntNative>(1, repeat: SO_REUSEADDR_VALUE_SIZE)
        // 获取数组的原始数据指针
        let bufferSizePtr = acquireArrayRawData(bufferSizeArray)

        try {
            // 获取SO_REUSEADDR选项值
            udpSocket.getSocketOption(
                OptionLevel.SOCKET,
                SocketOptions.SO_REUSEADDR,
                CPointer(int32Ptr),
                bufferSizePtr.pointer
            )
            // 读取选项值
            reuseAddrValue = int32Ptr.read()
        } finally {
            // 释放分配的内存和数组引用
            free(optionValueBuffer)
            releaseArrayRawData(bufferSizePtr)
        }
    }
    println("SO_REUSEADDR值: ${reuseAddrValue}")
    udpSocket.close()
    return 0
}
```

运行结果：

```text
SO_REUSEADDR值: 0
```

### func getSocketOptionBool(Int32, Int32)

```cangjie
public func getSocketOptionBool(
    level: Int32,
    option: Int32
): Bool
```

功能：获取指定的套接字参数。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 指定的套接字参数。从 [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) 强转而来。`0 => false`，`非 0 => true`。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `getsockopt` 返回失败时或参数大小超过 [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) 的阈值时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let udpSocket = UdpSocket(bindAt: 33348)
    udpSocket.bind()
    var reuseAddr = udpSocket.getSocketOptionBool(OptionLevel.SOCKET, SocketOptions.SO_REUSEADDR)
    println("ReuseAddr before: ${reuseAddr}")
    udpSocket.setSocketOptionBool(OptionLevel.SOCKET, SocketOptions.SO_REUSEADDR, true)
    reuseAddr = udpSocket.getSocketOptionBool(OptionLevel.SOCKET, SocketOptions.SO_REUSEADDR)
    println("ReuseAddr after: ${reuseAddr}")
    udpSocket.close()
    return 0
}
```

运行结果：

```text
ReuseAddr before: false
ReuseAddr after: true
```

### func getSocketOptionIntNative(Int32, Int32)

```cangjie
public func getSocketOptionIntNative(
    level: Int32,
    option: Int32
): IntNative
```

功能：获取指定的套接字参数。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。

返回值：

- [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) - 指定的套接字参数值。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `getsockopt` 返回失败时或参数大小超过 [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) 的阈值时抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let udpSocket = UdpSocket(bindAt: 33349)
    udpSocket.bind()
    var reuseAddr = udpSocket.getSocketOptionIntNative(OptionLevel.SOCKET, SocketOptions.SO_REUSEADDR)
    println("ReuseAddr before: ${reuseAddr}")
    udpSocket.setSocketOptionIntNative(OptionLevel.SOCKET, SocketOptions.SO_REUSEADDR, 1)
    reuseAddr = udpSocket.getSocketOptionIntNative(OptionLevel.SOCKET, SocketOptions.SO_REUSEADDR)
    println("ReuseAddr after: ${reuseAddr}")
    udpSocket.close()
    return 0
}
```

运行结果：

```text
ReuseAddr before: 0
ReuseAddr after: 1
```

### func isClosed()

```cangjie
public override func isClosed(): Bool
```

功能：判断套接字是否通过调用 `close` 显式关闭。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 如果该套接字已调用 `close` 显示关闭，则返回 `true`；否则，返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let udpSocket = UdpSocket(bindAt: 33350)
    udpSocket.bind()
    println("Is socket closed before close(): ${udpSocket.isClosed()}")
    udpSocket.close()
    println("Is socket closed after close(): ${udpSocket.isClosed()}")
    return 0
}
```

运行结果：

```text
Is socket closed before close(): false
Is socket closed after close(): true
```

### func receive(Array\<Byte>)

```cangjie
public func receive(buffer: Array<Byte>): Int64
```

功能：从 `connect` 连接到的地址收取报文。

参数：

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 存储收取到的报文的地址。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 收取到的报文大小。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当前实例已经关闭，或接收数据失败时，抛出异常。
- [SocketTimeoutException](net_package_exceptions.md#class-sockettimeoutexception) - 当超过指定的读取超时时间时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.sync.*

main(): Int64 {
    // 设置端口
    let serverPort: UInt16 = 33351
    // 同步计数器用于等待服务器启动
    let serverStartCounter = SyncCounter(1)

    func runUdpServer() {
        try (server = UdpSocket(bindAt: serverPort)) {
            server.bind()
            // 明确是服务器启动计数器递减
            serverStartCounter.dec()

            // 接收的客户端数据，设置5秒超时
            let timeout = Duration.second * 5
            server.receiveTimeout = timeout

            // 接收数据的缓冲区
            let recvBuffer = Array<Byte>(10, repeat: 0)
            // 接收数据
            let (senderAddress, readBytes) = server.receiveFrom(recvBuffer)
            println("Server received ${readBytes} bytes from ${senderAddress}: ${recvBuffer}")

            // 发送数据回客户端
            server.sendTo(senderAddress, [1u8, 2u8, 3u8])
        }
    }

    // 服务器启动的异步任务
    let serverTask = spawn {
        runUdpServer()
    }
    // 等待服务器启动完成（计数器归零）
    serverStartCounter.waitUntilZero()

    // 客户端连接的 socket
    try (client = UdpSocket(bindAt: 33352)) {
        client.bind()

        // 连接到服务器
        let serverAddress = IPSocketAddress.parse("127.0.0.1:${serverPort}")
        client.connect(serverAddress)
        println("Client remote address after connect: ${client.remoteAddress}")

        // 发送的数据直接写字面量
        client.send([4, 5, 6])

        // 客户端接收数据缓冲区
        let buffer = Array<Byte>(10, repeat: 0)
        let readBytes = client.receive(buffer)
        println("Client received ${readBytes} bytes: ${buffer}")
    }

    // 等待服务器任务完成
    serverTask.get()
    return 0
}
```

运行结果：

```text
Client remote address after connect: Some(127.0.0.1:33351)
Server received 3 bytes from 127.0.0.1:33352: [4, 5, 6, 0, 0, 0, 0, 0, 0, 0]
Client received 3 bytes: [1, 2, 3, 0, 0, 0, 0, 0, 0, 0]
```

### func receiveFrom(Array\<Byte>)

```cangjie
public override func receiveFrom(buffer: Array<Byte>): (SocketAddress, Int64)
```

功能：接收报文。

参数：

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 存储收取到报文的缓冲区地址。

返回值：

- ([SocketAddress](net_package_classes.md#class-socketaddress), [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)) - 收取到的报文的发送端地址，及实际收取到的报文大小，可能为 0 或者大于参数 `buffer` 的大小。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当前实例已经关闭，或接收数据失败时，抛出异常。
- [SocketTimeoutException](net_package_exceptions.md#class-sockettimeoutexception) - 当超过指定的读取超时时间时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.sync.*

main(): Int64 {
    // 设置端口
    let serverPort: UInt16 = 33352
    // 同步计数器用于等待服务器启动
    let serverStartCounter = SyncCounter(1)

    func runUdpServer() {
        try (server = UdpSocket(bindAt: serverPort)) {
            server.bind()
            // 明确是服务器启动计数器递减
            serverStartCounter.dec()

            // 接收的客户端数据，设置5秒超时
            let timeout = Duration.second * 5
            server.receiveTimeout = timeout

            // 接收数据的缓冲区
            let recvBuffer = Array<Byte>(10, repeat: 0)
            // 接收数据
            let (senderAddress, readBytes) = server.receiveFrom(recvBuffer)
            println("Server received ${readBytes} bytes from ${senderAddress}: ${recvBuffer}")

            // 发送数据回客户端
            server.sendTo(senderAddress, [1u8, 2u8, 3u8])
        }
    }

    // 服务器启动的异步任务
    let serverTask = spawn {
        runUdpServer()
    }
    // 等待服务器启动完成（计数器归零）
    serverStartCounter.waitUntilZero()

    // 客户端连接的 socket
    try (client = UdpSocket(bindAt: 33353)) {
        client.bind()

        // 发送的数据直接写字面量
        let serverAddress = IPSocketAddress.parse("127.0.0.1:${serverPort}")
        client.sendTo(serverAddress, [4, 5, 6])

        // 客户端接收数据缓冲区
        let buffer = Array<Byte>(10, repeat: 0)
        let (senderAddress, readBytes) = client.receiveFrom(buffer)
        println("Client received ${readBytes} bytes from ${senderAddress}: ${buffer}")
    }

    // 等待服务器任务完成
    serverTask.get()
    return 0
}
```

运行结果：

```text
Server received 3 bytes from 127.0.0.1:33353: [4, 5, 6, 0, 0, 0, 0, 0, 0, 0]
Client received 3 bytes from 127.0.0.1:33352: [1, 2, 3, 0, 0, 0, 0, 0, 0, 0]
```

### func send(Array\<Byte>)

```cangjie
public func send(payload: Array<Byte>): Unit
```

功能：发送报文到 `connect` 连接到的地址。

参数：

- payload: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 发送报文内容。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `payload` 的大小超出系统限制或者系统发送失败（例如：当 `connect` 被调用，并且收到异常 ICMP 报文时，发送失败）时，抛出异常。
- [SocketTimeoutException](net_package_exceptions.md#class-sockettimeoutexception) - 当超过指定的写入超时时间时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.sync.*

main(): Int64 {
    // 设置端口
    let serverPort: UInt16 = 33353
    // 同步计数器用于等待服务器启动
    let serverStartCounter = SyncCounter(1)

    func runUdpServer() {
        try (server = UdpSocket(bindAt: serverPort)) {
            server.bind()
            // 明确是服务器启动计数器递减
            serverStartCounter.dec()

            // 接收的客户端数据，设置5秒超时
            let timeout = Duration.second * 5
            server.receiveTimeout = timeout

            // 接收数据的缓冲区
            let recvBuffer = Array<Byte>(10, repeat: 0)
            // 接收数据
            let (senderAddress, readBytes) = server.receiveFrom(recvBuffer)
            println("Server received ${readBytes} bytes from ${senderAddress}: ${recvBuffer}")

            // 发送数据回客户端
            server.sendTo(senderAddress, [1u8, 2u8, 3u8])
        }
    }

    // 服务器启动的异步任务
    let serverTask = spawn {
        runUdpServer()
    }
    // 等待服务器启动完成（计数器归零）
    serverStartCounter.waitUntilZero()

    // 客户端连接的 socket
    try (client = UdpSocket(bindAt: 33354)) {
        client.bind()

        // 连接到服务器
        let serverAddress = IPSocketAddress.parse("127.0.0.1:${serverPort}")
        client.connect(serverAddress)
        println("Client remote address after connect: ${client.remoteAddress}")

        // 发送的数据直接写字面量
        client.send([4, 5, 6])

        // 客户端接收数据缓冲区
        let buffer = Array<Byte>(10, repeat: 0)
        let readBytes = client.receive(buffer)
        println("Client received ${readBytes} bytes: ${buffer}")
    }

    // 等待服务器任务完成
    serverTask.get()
    return 0
}
```

运行结果：

```text
Client remote address after connect: Some(127.0.0.1:33353)
Server received 3 bytes from 127.0.0.1:33354: [4, 5, 6, 0, 0, 0, 0, 0, 0, 0]
Client received 3 bytes: [1, 2, 3, 0, 0, 0, 0, 0, 0, 0]
```

### func sendTo(SocketAddress, Array\<Byte>)

```cangjie
public override func sendTo(recipient: SocketAddress, payload: Array<Byte>): Unit
```

功能：发送报文。当没有足够的缓冲区空间时可能会被阻塞。

参数：

- recipient: [SocketAddress](net_package_classes.md#class-socketaddress) - 发送的对端地址。
- payload: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 发送报文内容。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `payload` 的大小超出系统限制、系统发送失败（例如：当 `connect` 被调用，并且收到异常 ICMP 报文时，发送失败）、Windows 平台下远端地址为全零地址或者 macOS 平台下 `connect` 被调用后调用 `sendTo` 时，抛出异常。
- [SocketTimeoutException](net_package_exceptions.md#class-sockettimeoutexception) - 当超过指定的写入超时时间时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.sync.*

main(): Int64 {
    // 设置端口
    let serverPort: UInt16 = 33354
    // 同步计数器用于等待服务器启动
    let serverStartCounter = SyncCounter(1)

    func runUdpServer() {
        try (server = UdpSocket(bindAt: serverPort)) {
            server.bind()
            // 明确是服务器启动计数器递减
            serverStartCounter.dec()

            // 接收的客户端数据，设置5秒超时
            let timeout = Duration.second * 5
            server.receiveTimeout = timeout

            // 接收数据的缓冲区
            let recvBuffer = Array<Byte>(10, repeat: 0)
            // 接收数据
            let (senderAddress, readBytes) = server.receiveFrom(recvBuffer)
            println("Server received ${readBytes} bytes from ${senderAddress}: ${recvBuffer}")

            // 发送数据回客户端
            server.sendTo(senderAddress, [1u8, 2u8, 3u8])
        }
    }

    // 服务器启动的异步任务
    let serverTask = spawn {
        runUdpServer()
    }
    // 等待服务器启动完成（计数器归零）
    serverStartCounter.waitUntilZero()

    // 客户端连接的 socket
    try (client = UdpSocket(bindAt: 33355)) {
        client.bind()

        // 发送的数据直接写字面量
        let serverAddress = IPSocketAddress.parse("127.0.0.1:${serverPort}")
        client.sendTo(serverAddress, [4, 5, 6])

        // 客户端接收数据缓冲区
        let buffer = Array<Byte>(10, repeat: 0)
        let (senderAddress, readBytes) = client.receiveFrom(buffer)
        println("Client received ${readBytes} bytes from ${senderAddress}: ${buffer}")
    }

    // 等待服务器任务完成
    serverTask.get()
    return 0
}
```

运行结果：

```text
Server received 3 bytes from 127.0.0.1:33355: [4, 5, 6, 0, 0, 0, 0, 0, 0, 0]
Client received 3 bytes from 127.0.0.1:33354: [1, 2, 3, 0, 0, 0, 0, 0, 0, 0]
```

### func setSocketOption(Int32, Int32, CPointer\<Unit>, UIntNative)

```cangjie
public func setSocketOption(
    level: Int32,
    option: Int32,
    value: CPointer<Unit>,
    valueLength: UIntNative
): Unit
```

功能：设置指定的套接字参数。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。
- value: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[Unit](../../core/core_package_api/core_package_intrinsics.md#unit)> - 参数值。
- valueLength: [UIntNative](../../core/core_package_api/core_package_intrinsics.md#uintnative) - 参数值长度。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `setsockopt` 返回失败时，抛出异常。

示例：

<!-- run -->
```cangjie
import std.net.*

foreign {
    func free(ptr: CPointer<Unit>): Unit

    func malloc(size: UIntNative): CPointer<Unit>
}

// SO_REUSEADDR选项值（Int32类型）的内存大小
let SO_REUSEADDR_VALUE_SIZE: UIntNative = sizeOf<Int32>()

main(): Int64 {
    let udpSocket = UdpSocket(bindAt: 33355)
    udpSocket.bind()
    unsafe {
        // 为SO_REUSEADDR选项的值分配内存缓冲区
        let reuseAddrBuffer = malloc(SO_REUSEADDR_VALUE_SIZE)
        // 转换为Int32类型指针，专门用于操作SO_REUSEADDR的选项值
        let reuseAddrPtr = CPointer<Int32>(reuseAddrBuffer)

        try {
            // 写入启用SO_REUSEADDR的值（1表示启用）
            reuseAddrPtr.write(1)
            // 设置套接字选项
            udpSocket.setSocketOption(
                OptionLevel.SOCKET,
                SocketOptions.SO_REUSEADDR,
                CPointer(reuseAddrPtr),
                SO_REUSEADDR_VALUE_SIZE
            )
        } finally {
            // 释放为选项值分配的缓冲区
            free(reuseAddrBuffer)
        }
    }
    println("SO_REUSEADDR option set successfully")
    udpSocket.close()
    return 0
}
```

### func setSocketOptionBool(Int32, Int32, Bool)

```cangjie
public func setSocketOptionBool(
    level: Int32,
    option: Int32,
    value: Bool
): Unit
```

功能：设置指定的套接字参数。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。
- value: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 参数值。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `setsockopt` 返回失败时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let udpSocket = UdpSocket(bindAt: 33356)
    println("ReuseAddr before: ${udpSocket.reuseAddress}")
    udpSocket.setSocketOptionBool(OptionLevel.SOCKET, SocketOptions.SO_REUSEADDR, true)
    println("ReuseAddr after: ${udpSocket.reuseAddress}")
    return 0
}
```

运行结果：

```text
ReuseAddr before: false
ReuseAddr after: true
```

### func setSocketOptionIntNative(Int32, Int32, IntNative)

```cangjie
public func setSocketOptionIntNative(
    level: Int32,
    option: Int32,
    value: IntNative
): Unit
```

功能：设置指定的套接字参数。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。
- value: [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) - 参数值。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `setsockopt` 返回失败时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let udpSocket = UdpSocket(bindAt: 33357)
    println("ReuseAddr before: ${udpSocket.reuseAddress}")
    udpSocket.setSocketOptionIntNative(OptionLevel.SOCKET, SocketOptions.SO_REUSEADDR, 1)
    println("ReuseAddr after: ${udpSocket.reuseAddress}")
    return 0
}
```

运行结果：

```text
ReuseAddr before: false
ReuseAddr after: true
```

### func toString()

```cangjie
public override func toString(): String
```

功能：返回当前 [UdpSocket](net_package_classes.md#class-udpsocket) 的状态信息。

返回值：

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - 包含当前 [UdpSocket](net_package_classes.md#class-udpsocket) 状态信息的字符串。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let udpSocket = UdpSocket(bindAt: 33358)
    udpSocket.bind()
    println("UdpSocket toString: ${udpSocket.toString()}")
    udpSocket.close()
    return 0
}
```

运行结果：

```text
UdpSocket toString: UdpSocket(bound at 0.0.0.0:33358)
```

## class UnixDatagramSocket

```cangjie
public class UnixDatagramSocket <: DatagramSocket {
    public init(bindAt!: String)
    public init(bindAt!: SocketAddress)
}
```

功能：提供基于数据包的主机通讯能力。

[UnixDatagramSocket](net_package_classes.md#class-unixdatagramsocket) 实例创建后，应当显式调用 `bind()` 接口绑定。`Unix` 数据包套接字不需要连接，不需要与远端握手多次。不过用户也可以通过 `connect/disconnect` 接口与远端建连和断连。
不同于 UDP，UDS 没有数据包大小限制，限制来源于操作系统和接口实现。
套接字资源需要用 `close` 接口显式回收。可参阅 [DatagramSocket](net_package_interfaces.md#interface-datagramsocket) 获取更多信息。

> **注意：**
>
> 不支持平台：Windows。

父类型：

- [DatagramSocket](net_package_interfaces.md#interface-datagramsocket)

### prop localAddress

```cangjie
public override prop localAddress: SocketAddress
```

功能：读取 `socket` 将要或已经绑定的本地地址。

> **注意：**
>
> 不支持平台：Windows。

类型：[SocketAddress](net_package_classes.md#class-socketaddress)

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `socket` 已经关闭时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let socketAddress = UnixSocketAddress("socketPath")

    // 使用SocketAddress初始化UnixDatagramSocket
    let socket = UnixDatagramSocket(bindAt: socketAddress)
    println("Socket created to: ${socket.localAddress}")
    return 0
}
```

运行结果：

```text
Socket created to: socketPath
```

### prop receiveBufferSize

```cangjie
public mut prop receiveBufferSize: Int64
```

功能：设置和读取 `SO_RCVBUF` 属性，提供一种方式指定发包缓冲区大小。选项的生效情况取决于系统。

> **注意：**
>
> 不支持平台：Windows。

类型：[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当 `size` 小于等于 0 时，抛出异常。
- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `Socket` 已关闭时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let socket = UnixDatagramSocket(bindAt: "socketPath")
    println("Receive buffer size before setting: ${socket.receiveBufferSize}")
    socket.receiveBufferSize = 8192
    println("Receive buffer size after setting: ${socket.receiveBufferSize}")
    return 0
}
```

运行结果：

```text
Receive buffer size before setting: 212992
Receive buffer size after setting: 16384
```

### prop receiveTimeout

```cangjie
public override mut prop receiveTimeout: ?Duration
```

功能：设置和读取 `receive/receiveFrom` 操作超时时间。

如果设置的时间过小将会设置为最小时钟周期值；过大时将设置为最大超时时间（2<sup>63</sup>-1 纳秒）；默认值为 `None`。

> **注意：**
>
> 不支持平台：Windows。

类型：?[Duration](../../core/core_package_api/core_package_structs.md#struct-duration)

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当超时时间小于 0 时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let socket = UnixDatagramSocket(bindAt: "socketPath")
    println("Receive timeout before setting: ${socket.receiveTimeout}")
    socket.receiveTimeout = Duration.second * 10
    println("Receive timeout after setting: ${socket.receiveTimeout}")
    return 0
}
```

运行结果：

```text
Receive timeout before setting: None
Receive timeout after setting: Some(10s)
```

### prop remoteAddress

```cangjie
public override prop remoteAddress: ?SocketAddress
```

功能：读取 `Socket` 已经连接的远端地址，当 `Socket` 未连接时返回 `None`。

> **注意：**
>
> 不支持平台：Windows。

类型：?[SocketAddress](net_package_classes.md#class-socketaddress)

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `Socket` 已经被关闭时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.fs.*
import std.random.*
import std.env.*
import std.sync.*

// 创建临时套接字路径
func createTempSocketPath(): String {
    let tempDir: Path = getTempDirectory()
    let randomSuffix: String = Random().nextUInt64().toString()
    return tempDir.join("tmp_socket_${randomSuffix}").toString()
}

// 协调两个线程同时进行
let serverReadyBarrier = Barrier(2)

// 运行Unix域数据报服务器
func runUnixDatagramServer(serverSocketPath: String) {
    try (serverSocket = UnixDatagramSocket(bindAt: serverSocketPath)) {
        serverSocket.bind()
        serverReadyBarrier.wait()

        let receiveBuffer = Array<Byte>(3, repeat: 0)
        let (_, bytesRead) = serverSocket.receiveFrom(receiveBuffer)
        println("Server received ${bytesRead} bytes: ${receiveBuffer}")
    }
}

main(): Int64 {
    // 创建临时套接字路径
    let clientSocketPath = createTempSocketPath()
    let serverSocketPath = createTempSocketPath()

    let serverSpawn = spawn {
        runUnixDatagramServer(serverSocketPath)
    }

    // 等待服务器准备就绪
    serverReadyBarrier.wait()

    try (clientSocket = UnixDatagramSocket(bindAt: clientSocketPath)) {
        clientSocket.bind()
        clientSocket.connect(serverSocketPath)
        println(
            "Is equal to server socket path?: ${clientSocket.remoteAddress.getOrThrow().toString() == serverSocketPath}")
        let testData: Array<Byte> = [1, 2, 3]
        clientSocket.send(testData)
    }

    // 等待服务器完成
    serverSpawn.get()
    return 0
}
```

运行结果：

```text
Is equal to server socket path?: true
Server received 3 bytes: [1, 2, 3]
```

### prop sendBufferSize

```cangjie
public mut prop sendBufferSize: Int64
```

功能：设置和读取 `SO_SNDBUF` 属性，提供一种方式指定发包缓冲区大小。选项的生效情况取决于系统。

> **注意：**
>
> 不支持平台：Windows。

类型：[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当 `size` 小于等于 0 时，抛出异常。
- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `Socket` 已关闭时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let socket = UnixDatagramSocket(bindAt: "socketPath")
    println("Send buffer size before setting: ${socket.sendBufferSize}")
    socket.sendBufferSize = 8192
    println("Send buffer size after setting: ${socket.sendBufferSize}")
    return 0
}
```

运行结果：

```text
Send buffer size before setting: 212992
Send buffer size after setting: 16384
```

### prop sendTimeout

```cangjie
public override mut prop sendTimeout: ?Duration
```

功能：设置和读取 `send/sendTo` 操作超时时间。

如果设置的时间过小将会设置为最小时钟周期值；过大时将设置为最大超时时间（2<sup>63</sup>-1 纳秒）；默认值为 `None`。

> **注意：**
>
> 不支持平台：Windows。

类型：?[Duration](../../core/core_package_api/core_package_structs.md#struct-duration)

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当超时时间小于 0 时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let socket = UnixDatagramSocket(bindAt: "socketPath")
    println("Send timeout before setting: ${socket.sendTimeout}")
    socket.sendTimeout = Duration.second * 5
    println("Send timeout after setting: ${socket.sendTimeout}")
    return 0
}
```

运行结果：

```text
Send timeout before setting: None
Send timeout after setting: Some(5s)
```

### init(SocketAddress)

```cangjie
public init(bindAt!: SocketAddress)
```

功能：创建一个未连接的 [UnixDatagramSocket](net_package_classes.md#class-unixdatagramsocket) 实例。

此文件类型可通过 [isSock](../../posix/posix_package_api/posix_package_funcs.md#func-issockstring-deprecated)() 判断是否存在，可通过 [unlink](../../posix/posix_package_api/posix_package_funcs.md#func-unlinkstring-deprecated)() 接口删除。

> **注意：**
>
> 不支持平台：Windows。

参数：

- bindAt!: [SocketAddress](net_package_classes.md#class-socketaddress) - 连接的套接字地址。地址应当不存在，在 `bind` 时会创建。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当路径为空或已存在时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let socketAddress = UnixSocketAddress("socketPath")

    // 使用SocketAddress初始化UnixDatagramSocket
    let socket = UnixDatagramSocket(bindAt: socketAddress)
    println("Socket created to: ${socket.localAddress}")
    return 0
}
```

运行结果：

```text
Socket created to: socketPath
```

### init(String)

```cangjie
public init(bindAt!: String)
```

功能：创建一个未连接的 [UnixDatagramSocket](net_package_classes.md#class-unixdatagramsocket) 实例。

此文件类型可通过 [isSock](../../posix/posix_package_api/posix_package_funcs.md#func-issockstring-deprecated)() 判断是否存在，可通过 [unlink](../../posix/posix_package_api/posix_package_funcs.md#func-unlinkstring-deprecated)() 接口删除。

> **注意：**
>
> 不支持平台：Windows。

参数：

- bindAt!: [String](../../core/core_package_api/core_package_structs.md#struct-string) - 连接的文件地址。文件地址应当不存在，在 `bind` 时会创建。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当文件地址不合法时，抛出异常。
- [SocketException](net_package_exceptions.md#class-socketexception) - 当文件地址为空或已存在时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    // 使用String初始化UnixDatagramSocket
    let socket = UnixDatagramSocket(bindAt: "socketPath")
    println("Socket created to: ${socket.localAddress}")
    return 0
}
```

运行结果：

```text
Socket created to: socketPath
```

### func bind()

```cangjie
public func bind(): Unit
```

功能：绑定一个 `Unix datagram` 套接字，并创建监听队列。

此接口自动在本地地址中创建一个套接字文件，如该文件已存在则会绑定失败。此文件类型可通过 [isSock](../../posix/posix_package_api/posix_package_funcs.md#func-issockstring-deprecated) 判断是否存在，可通过 [unlink](../../posix/posix_package_api/posix_package_funcs.md#func-unlinkstring-deprecated)() 接口删除，失败后需要 `close` 套接字，不支持多次重试。

> **注意：**
>
> 不支持平台：Windows。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当文件地址已存在，或文件创建失败时，抛出异常。

示例：

<!-- run -->
```cangjie
import std.net.*
import std.fs.*
import std.random.*
import std.env.*

// 创建临时套接字路径
func createTempSocketPath(): String {
    let tempDir: Path = getTempDirectory()
    let randomSuffix: String = Random().nextUInt64().toString()
    return tempDir.join("tmp_socket_${randomSuffix}").toString()
}

main(): Int64 {
    let socketPath = createTempSocketPath()

    let socket = UnixDatagramSocket(bindAt: socketPath)
    // 绑定套接字到地址
    socket.bind()
    socket.close()
    return 0
}
```

### func close()

```cangjie
public override func close(): Unit
```

功能：关闭套接字，所有操作除了 `close/isClosed` 之外，均不允许再调用。接口允许多次调用。

> **注意：**
>
> 不支持平台：Windows。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.fs.*
import std.random.*
import std.env.*

// 创建临时套接字路径
func createTempSocketPath(): String {
    let tempDir: Path = getTempDirectory()
    let randomSuffix: String = Random().nextUInt64().toString()
    return tempDir.join("tmp_socket_${randomSuffix}").toString()
}

main(): Int64 {
    let socketPath = createTempSocketPath()

    let socket = UnixDatagramSocket(bindAt: socketPath)
    socket.bind()
    println("Socket is closed before close(): ${socket.isClosed()}")

    // 关闭套接字
    socket.close()
    println("Socket is closed after close(): ${socket.isClosed()}")

    return 0
}
```

运行结果：

```text
Socket is closed before close(): false
Socket is closed after close(): true
```

### func connect(SocketAddress)

```cangjie
public func connect(remote: SocketAddress): Unit
```

功能：连接特定远端地址，可通过 `disconnect` 撤销配置。

仅接受该远端地址的报文。默认执行 `bind`，因此不需额外调用 `bind`。此操作执行后，端口将开始接收 ICMP 报文，若收到异常报文后，可能导致 `send/sendTo` 执行失败。

> **注意：**
>
> 不支持平台：Windows。

参数：

- remote: [SocketAddress](net_package_classes.md#class-socketaddress) - 远端套接字地址。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当地址未绑定时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.fs.*
import std.random.*
import std.env.*
import std.sync.*

// 创建临时套接字路径
func createTempSocketPath(): String {
    let tempDir: Path = getTempDirectory()
    let randomSuffix: String = Random().nextUInt64().toString()
    return tempDir.join("tmp_socket_${randomSuffix}").toString()
}

// 协调两个线程同时进行
let serverReadyBarrier = Barrier(2)

// 运行Unix域数据报服务器
func runUnixDatagramServer(serverSocketPath: String) {
    try (serverSocket = UnixDatagramSocket(bindAt: serverSocketPath)) {
        serverSocket.bind()
        serverReadyBarrier.wait()

        let receiveBuffer = Array<Byte>(3, repeat: 0)
        let (_, bytesRead) = serverSocket.receiveFrom(receiveBuffer)
        println("Server received ${bytesRead} bytes: ${receiveBuffer}")
    }
}

main(): Int64 {
    // 创建临时套接字路径
    let clientSocketPath = createTempSocketPath()
    let serverSocketPath = createTempSocketPath()

    let serverSpawn = spawn {
        runUnixDatagramServer(serverSocketPath)
    }

    // 等待服务器准备就绪
    serverReadyBarrier.wait()

    try (clientSocket = UnixDatagramSocket(bindAt: clientSocketPath)) {
        clientSocket.bind()
        // 使用SocketAddress连接到服务器
        let serverSocketAddress = UnixSocketAddress(serverSocketPath)
        clientSocket.connect(serverSocketAddress)

        let testData: Array<Byte> = [1, 2, 3]
        clientSocket.send(testData)
    }

    // 等待服务器完成
    serverSpawn.get()
    return 0
}
```

运行结果：

```text
Server received 3 bytes: [1, 2, 3]
```

### func connect(String)

```cangjie
public func connect(remotePath: String): Unit
```

功能：连接特定远端地址，可通过 `disconnect` 撤销配置。

仅接受该远端地址的报文。必须在 `bind` 后调用。此操作执行后，端口将开始接收 ICMP 报文，若收到异常报文后，可能导致 `send/sendTo` 执行失败。

> **注意：**
>
> 不支持平台：Windows。

参数：

- remotePath: [String](../../core/core_package_api/core_package_structs.md#struct-string) - 远端文件地址。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当地址未绑定时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.sync.*
import std.fs.*
import std.random.*
import std.env.*

// 协调两个线程同时进行
let serverReadyBarrier = Barrier(2)

// 创建临时套接字路径
func createTempSocketPath(): String {
    let tempDir: Path = getTempDirectory()
    let randomSuffix: String = Random().nextUInt64().toString()
    return tempDir.join("tmp_socket_${randomSuffix}").toString()
}

// 运行Unix域数据报服务器
func runUnixDatagramServer(serverSocketPath: String) {
    try (serverSocket = UnixDatagramSocket(bindAt: serverSocketPath)) {
        serverSocket.bind()
        serverReadyBarrier.wait()

        let receiveBuffer = Array<Byte>(3, repeat: 0)
        let (_, bytesRead) = serverSocket.receiveFrom(receiveBuffer)

        println("Server received data from senderAddr with ${bytesRead} bytes: ${receiveBuffer}")
    }
}

main(): Int64 {
    // 创建临时套接字路径
    let clientSocketPath = createTempSocketPath()
    let serverSocketPath = createTempSocketPath()

    let serverSpawn = spawn {
        runUnixDatagramServer(serverSocketPath)
    }

    // 等待服务器准备就绪
    serverReadyBarrier.wait()

    try (clientSocket = UnixDatagramSocket(bindAt: clientSocketPath)) {
        clientSocket.sendTimeout = Duration.second * 2
        clientSocket.bind()
        clientSocket.connect(serverSocketPath)

        let testData: Array<Byte> = [1, 2, 3]
        clientSocket.send(testData)
    }
    // 等待服务器完成
    serverSpawn.get()
    return 0
}
```

运行结果：

```text
Server received data from senderAddr with 3 bytes: [1, 2, 3]
```

### func disconnect()

```cangjie
public func disconnect(): Unit
```

功能：停止连接。取消仅收取特定对端报文。可在 `connect` 前调用，可多次调用。

> **注意：**
>
> 不支持平台：Windows。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当未绑定时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.fs.*
import std.random.*
import std.env.*
import std.sync.*

// 创建临时套接字路径
func createTempSocketPath(): String {
    let tempDir: Path = getTempDirectory()
    let randomSuffix: String = Random().nextUInt64().toString()
    return tempDir.join("tmp_socket_${randomSuffix}").toString()
}

// 协调两个线程同时进行
let serverReadyBarrier = Barrier(2)

// 运行Unix域数据报服务器
func runUnixDatagramServer(serverSocketPath: String) {
    try (serverSocket = UnixDatagramSocket(bindAt: serverSocketPath)) {
        serverSocket.bind()
        serverReadyBarrier.wait()

        // 设置接收超时
        serverSocket.receiveTimeout = Duration.second * 3
        let receiveBuffer = Array<Byte>(6, repeat: 0)

        try {
            let (_, bytesRead) = serverSocket.receiveFrom(receiveBuffer)
            println("Server received ${bytesRead} bytes: ${receiveBuffer}")
        } catch (e: Exception) {
            println("Error receiving data: ${e.message}")
        }
    }
}

main(): Int64 {
    // 创建临时套接字路径
    let clientSocketPath = createTempSocketPath()
    let serverSocketPath = createTempSocketPath()

    let serverSpawn = spawn {
        runUnixDatagramServer(serverSocketPath)
    }

    // 等待服务器准备就绪
    serverReadyBarrier.wait()

    try (clientSocket = UnixDatagramSocket(bindAt: clientSocketPath)) {
        clientSocket.bind()
        // 连接
        clientSocket.connect(serverSocketPath)
        // 断开连接
        clientSocket.disconnect()
        println("Disconnected from server")

        try {
            // 发送第一批数据
            let testData1: Array<Byte> = [1, 2, 3]
            clientSocket.send(testData1)
        } catch (e: Exception) {
            println("Error sending data: ${e.message}")
        }
    }

    // 等待服务器完成
    serverSpawn.get()
    return 0
}
```

运行结果：

```text
Disconnected from server
Error sending data: Socket is not connected.
Error receiving data: Failed to read data: read data timeout.
```

### func getSocketOption(Int32, Int32, CPointer\<Unit>, CPointer\<UIntNative>)

```cangjie
public func getSocketOption(
    level: Int32,
    option: Int32,
    value: CPointer<Unit>,
    valueLength: CPointer<UIntNative>
): Unit
```

功能：获取指定的套接字参数。

> **注意：**
>
> 不支持平台：Windows。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。
- value: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[Unit](../../core/core_package_api/core_package_intrinsics.md#unit)> - 参数值。
- valueLength: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<UIntNative> - 参数值长度。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `getsockopt` 返回失败时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.fs.*
import std.random.*
import std.env.*

// 创建临时套接字路径
func createTempSocketPath(): String {
    let tempDir: Path = getTempDirectory()
    let randomSuffix: String = Random().nextUInt64().toString()
    return tempDir.join("tmp_socket_${randomSuffix}").toString()
}

foreign {
    func free(ptr: CPointer<Unit>): Unit

    func malloc(size: UIntNative): CPointer<Unit>
}

// SO_REUSEADDR选项值的大小（Int32类型）
let SO_REUSEADDR_VALUE_SIZE: UIntNative = sizeOf<Int32>()

main(): Int64 {
    let serverSocketPath = createTempSocketPath()
    let unixDatagramSocket = UnixDatagramSocket(bindAt: serverSocketPath)
    unixDatagramSocket.bind()
    // 存储SO_REUSEADDR选项的获取结果（初始值-1表示未获取成功）
    var reuseAddrValue: Int32 = -1

    unsafe {
        // 为存储选项值分配内存
        let optionValueBuffer = malloc(SO_REUSEADDR_VALUE_SIZE)
        // 转换为Int32类型指针
        let int32Ptr = CPointer<Int32>(optionValueBuffer)

        // 存储选项值缓冲区的长度
        let bufferSizeArray = Array<UIntNative>(1, repeat: SO_REUSEADDR_VALUE_SIZE)
        // 获取数组的原始数据指针
        let bufferSizePtr = acquireArrayRawData(bufferSizeArray)

        try {
            // 获取SO_REUSEADDR选项值
            unixDatagramSocket.getSocketOption(
                OptionLevel.SOCKET,
                OptionName.SO_REUSEADDR,
                CPointer(int32Ptr),
                bufferSizePtr.pointer
            )
            // 读取选项值
            reuseAddrValue = int32Ptr.read()
        } finally {
            // 释放分配的内存和数组引用
            free(optionValueBuffer)
            releaseArrayRawData(bufferSizePtr)
        }
    }
    println("SO_REUSEADDR值: ${reuseAddrValue}")
    unixDatagramSocket.close()
    return 0
}
```

运行结果：

```text
SO_REUSEADDR值: 0
```

### func getSocketOptionBool(Int32, Int32)

```cangjie
public func getSocketOptionBool(
    level: Int32,
    option: Int32
): Bool
```

功能：获取指定的套接字参数。从 [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) 强转而来。`0 => false，非 0 => true`。

> **注意：**
>
> 不支持平台：Windows。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回指定的套接字参数值。从 [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) 强转而来。`0 => false，非 0 => true`。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `getsockopt` 返回失败时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.fs.*
import std.random.*
import std.env.*

// 创建临时套接字路径
func createTempSocketPath(): String {
    let tempDir: Path = getTempDirectory()
    let randomSuffix: String = Random().nextUInt64().toString()
    return tempDir.join("tmp_socket_${randomSuffix}").toString()
}

main(): Int64 {
    let socketPath = createTempSocketPath()

    try (socket = UnixDatagramSocket(bindAt: socketPath)) {
        socket.bind()

        // 获取SO_REUSEADDR选项布尔值
        let reuseAddrValue = socket.getSocketOptionBool(OptionLevel.SOCKET, OptionName.SO_REUSEADDR)
        println("SO_REUSEADDR value before setting: ${reuseAddrValue}")
        socket.setSocketOptionBool(OptionLevel.SOCKET, OptionName.SO_REUSEADDR, true)
        println(
            "SO_REUSEADDR value after setting: ${socket.getSocketOptionBool(OptionLevel.SOCKET, OptionName.SO_REUSEADDR)}")
    }
    return 0
}
```

运行结果：

```text
SO_REUSEADDR value before setting: false
SO_REUSEADDR value after setting: true
```

### func getSocketOptionIntNative(Int32, Int32)

```cangjie
public func getSocketOptionIntNative(
    level: Int32,
    option: Int32
): IntNative
```

功能：获取指定的套接字参数。

> **注意：**
>
> 不支持平台：Windows。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。

返回值：

- [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) - 返回指定的套接字参数值。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `getsockopt` 返回失败时或参数大小超过 [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) 的阈值时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.fs.*
import std.random.*
import std.env.*

// 创建临时套接字路径
func createTempSocketPath(): String {
    let tempDir: Path = getTempDirectory()
    let randomSuffix: String = Random().nextUInt64().toString()
    return tempDir.join("tmp_socket_${randomSuffix}").toString()
}

main(): Int64 {
    let socketPath = createTempSocketPath()

    try (socket = UnixDatagramSocket(bindAt: socketPath)) {
        socket.bind()

        // 获取SO_REUSEADDR选项值
        let reuseAddrValue = socket.getSocketOptionIntNative(OptionLevel.SOCKET, OptionName.SO_REUSEADDR)
        println("SO_REUSEADDR value before setting: ${reuseAddrValue}")
        socket.setSocketOptionIntNative(OptionLevel.SOCKET, OptionName.SO_REUSEADDR, 1)
        println(
            "SO_REUSEADDR value after setting: ${socket.getSocketOptionIntNative(OptionLevel.SOCKET, OptionName.SO_REUSEADDR)}")
    }
    return 0
}
```

运行结果：

```text
SO_REUSEADDR value before setting: 0
SO_REUSEADDR value after setting: 1
```

### func isClosed()

```cangjie
public override func isClosed(): Bool
```

功能：判断套接字是否通过调用 `close` 显式关闭。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回套接字是否已经通过调用 `close` 显式关闭。是则返回 `true`；否则，返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.fs.*
import std.random.*
import std.env.*

// 创建临时套接字路径
func createTempSocketPath(): String {
    let tempDir: Path = getTempDirectory()
    let randomSuffix: String = Random().nextUInt64().toString()
    return tempDir.join("tmp_socket_${randomSuffix}").toString()
}

main(): Int64 {
    let socketPath = createTempSocketPath()

    let socket = UnixDatagramSocket(bindAt: socketPath)
    socket.bind()
    println("Is socket closed before close(): ${socket.isClosed()}")

    socket.close()
    println("Is socket closed after close(): ${socket.isClosed()}")

    return 0
}
```

运行结果：

```text
Is socket closed before close(): false
Is socket closed after close(): true
```

### func receive(Array\<Byte>)

```cangjie
public func receive(buffer: Array<Byte>): Int64
```

功能：从 `connect` 连接到的地址收取报文。

> **注意：**
>
> 不支持平台：Windows。

参数：

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 存储收取到的报文的地址。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 收取到的报文大小。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当前实例已经关闭，或接收数据失败时，抛出异常。
- [SocketTimeoutException](net_package_exceptions.md#class-sockettimeoutexception) - 当超过指定的读取超时时间时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.fs.*
import std.random.*
import std.env.*
import std.sync.*

// 创建临时套接字路径
func createTempSocketPath(): String {
    let tempDir: Path = getTempDirectory()
    let randomSuffix: String = Random().nextUInt64().toString()
    return tempDir.join("tmp_socket_${randomSuffix}").toString()
}

// 协调两个线程同时进行
let readyBarrier = Barrier(2)

// 运行Unix域数据报服务器
func runUnixDatagramServer(serverSocketPath: String, clientSocketPath: String) {
    try (serverSocket = UnixDatagramSocket(bindAt: serverSocketPath)) {
        serverSocket.bind()
        // 等待客户端准备好
        readyBarrier.wait()

        // 连接到客户端
        serverSocket.connect(clientSocketPath)

        // 接收客户端的数据（使用receive而不是receiveFrom）
        let recvBuffer = Array<Byte>(10, repeat: 0)
        let readBytes = serverSocket.receive(recvBuffer)
        println("Server received ${readBytes} bytes: ${recvBuffer}")

        // 发送数据回客户端
        serverSocket.send([1u8, 2u8, 3u8])
    }
}

main(): Int64 {
    // 创建临时套接字路径
    let clientSocketPath = createTempSocketPath()
    let serverSocketPath = createTempSocketPath()

    // 启动服务器线程
    let serverTask = spawn {
        runUnixDatagramServer(serverSocketPath, clientSocketPath)
    }

    // 客户端连接的 socket
    try (clientSocket = UnixDatagramSocket(bindAt: clientSocketPath)) {
        clientSocket.bind()
        // 等待服务器准备好
        readyBarrier.wait()

        // 连接到服务器
        clientSocket.connect(serverSocketPath)

        // 发送数据到服务器
        clientSocket.send([4, 5, 6])

        // 接收服务器返回的数据（使用receive而不是receiveFrom）
        let buffer = Array<Byte>(10, repeat: 0)
        let readBytes = clientSocket.receive(buffer)
        println("Client received ${readBytes} bytes: ${buffer}")
    }

    // 等待服务器任务完成
    serverTask.get()
    return 0
}
```

运行结果：

```text
Server received 3 bytes: [4, 5, 6, 0, 0, 0, 0, 0, 0, 0]
Client received 3 bytes: [1, 2, 3, 0, 0, 0, 0, 0, 0, 0]
```

### func receiveFrom(Array\<Byte>)

```cangjie
public override func receiveFrom(buffer: Array<Byte>): (SocketAddress, Int64)
```

功能：收取报文。

> **注意：**
>
> 不支持平台：Windows。

参数：

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 存储收取到报文的地址。

返回值：

- ([SocketAddress](net_package_classes.md#class-socketaddress), [Int64](../../core/core_package_api/core_package_intrinsics.md#int64)) - 收取到的报文的发送端地址，及实际收取到的报文大小，可能为 0 或者大于参数 `buffer` 的大小。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当前实例已经关闭，或接收数据失败时，抛出异常。
- [SocketTimeoutException](net_package_exceptions.md#class-sockettimeoutexception) - 当超过指定的读取超时时间时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.fs.*
import std.random.*
import std.env.*
import std.sync.*

// 创建临时套接字路径
func createTempSocketPath(): String {
    let tempDir: Path = getTempDirectory()
    let randomSuffix: String = Random().nextUInt64().toString()
    return tempDir.join("tmp_socket_${randomSuffix}").toString()
}

// 协调两个线程同时进行
let serverReadyBarrier = Barrier(2)

// 运行Unix域数据报服务器
func runUnixDatagramServer(serverSocketPath: String) {
    try (serverSocket = UnixDatagramSocket(bindAt: serverSocketPath)) {
        serverSocket.bind()
        // 通知客户端已准备好
        serverReadyBarrier.wait()

        // 接收客户端的数据（使用receiveFrom而不是receive）
        let recvBuffer = Array<Byte>(10, repeat: 0)
        let (senderAddress, readBytes) = serverSocket.receiveFrom(recvBuffer)
        println("Server received ${readBytes} bytes: ${recvBuffer}")
        // 发送数据回客户端
        serverSocket.sendTo(senderAddress, [1u8, 2u8, 3u8])
    }
}

main(): Int64 {
    // 创建临时套接字路径
    let clientSocketPath = createTempSocketPath()
    let serverSocketPath = createTempSocketPath()

    // 启动服务器线程
    let serverTask = spawn {
        runUnixDatagramServer(serverSocketPath)
    }

    // 等待服务器准备就绪
    serverReadyBarrier.wait()

    // 客户端连接的 socket
    try (clientSocket = UnixDatagramSocket(bindAt: clientSocketPath)) {
        clientSocket.bind()

        // 发送数据到服务器
        let serverAddress = UnixSocketAddress(serverSocketPath)
        clientSocket.sendTo(serverAddress, [4, 5, 6])

        // 接收服务器返回的数据（使用receiveFrom而不是receive）
        let buffer = Array<Byte>(10, repeat: 0)
        let (_, readBytes) = clientSocket.receiveFrom(buffer)
        println("Client received ${readBytes} bytes: ${buffer}")
    }

    // 等待服务器任务完成
    serverTask.get()
    return 0
}
```

运行结果：

```text
Server received 3 bytes: [4, 5, 6, 0, 0, 0, 0, 0, 0, 0]
Client received 3 bytes: [1, 2, 3, 0, 0, 0, 0, 0, 0, 0]
```

### func send(Array\<Byte>)

```cangjie
public func send(payload: Array<Byte>): Unit
```

功能：发送报文到 `connect` 连接到的地址。

> **注意：**
>
> 不支持平台：Windows。

参数：

- payload: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 发送报文内容。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `payload` 的大小超出系统限制或者系统发送失败时，抛出异常。
- [SocketTimeoutException](net_package_exceptions.md#class-sockettimeoutexception) - 当超过指定的写入超时时间时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.sync.*
import std.fs.*
import std.random.*
import std.env.*

// 协调两个线程同时进行
let serverReadyBarrier = Barrier(2)

// 创建临时套接字路径
func createTempSocketPath(): String {
    let tempDir: Path = getTempDirectory()
    let randomSuffix: String = Random().nextUInt64().toString()
    return tempDir.join("tmp_socket_${randomSuffix}").toString()
}

// 运行Unix域数据报服务器
func runUnixDatagramServer(serverSocketPath: String) {
    try (serverSocket = UnixDatagramSocket(bindAt: serverSocketPath)) {
        serverSocket.bind()
        serverReadyBarrier.wait()

        let receiveBuffer = Array<Byte>(3, repeat: 0)
        let (_, bytesRead) = serverSocket.receiveFrom(receiveBuffer)

        println("Server received data from senderAddr with ${bytesRead} bytes: ${receiveBuffer}")
    }
}

main(): Int64 {
    // 创建临时套接字路径
    let clientSocketPath = createTempSocketPath()
    let serverSocketPath = createTempSocketPath()

    let serverSpawn = spawn {
        runUnixDatagramServer(serverSocketPath)
    }

    // 等待服务器准备就绪
    serverReadyBarrier.wait()

    try (clientSocket = UnixDatagramSocket(bindAt: clientSocketPath)) {
        clientSocket.sendTimeout = Duration.second * 2
        clientSocket.bind()
        clientSocket.connect(serverSocketPath)

        let testData: Array<Byte> = [1, 2, 3]
        clientSocket.send(testData)
    }
    // 等待服务器完成
    serverSpawn.get()
    return 0
}
```

运行结果：

```text
Server received data from senderAddr with 3 bytes: [1, 2, 3]
```

### func sendTo(SocketAddress, Array\<Byte>)

```cangjie
public override func sendTo(recipient: SocketAddress, payload: Array<Byte>): Unit
```

功能：发送报文。当没有足够的缓冲区空间时可能会被阻塞。

> **注意：**
>
> 不支持平台：Windows。

参数：

- recipient: [SocketAddress](net_package_classes.md#class-socketaddress) - 发送的对端地址。
- payload: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 发送报文内容。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `payload` 的大小超出系统限制、系统发送失败（例如：当 `connect` 被调用，并且收到异常 ICMP 报文时，发送将失败）或者 macOS 平台下 `connect` 被调用后调用 `sendTo` 时，抛出异常。
- [SocketTimeoutException](net_package_exceptions.md#class-sockettimeoutexception) - 当超过指定的写入超时时间时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.fs.*
import std.random.*
import std.env.*
import std.sync.*

// 创建临时套接字路径
func createTempSocketPath(): String {
    let tempDir: Path = getTempDirectory()
    let randomSuffix: String = Random().nextUInt64().toString()
    return tempDir.join("tmp_socket_${randomSuffix}").toString()
}

// 协调两个线程同时进行
let serverReadyBarrier = Barrier(2)

// 运行Unix域数据报服务器
func runUnixDatagramServer(serverSocketPath: String) {
    try (serverSocket = UnixDatagramSocket(bindAt: serverSocketPath)) {
        serverSocket.bind()
        // 通知客户端已准备好
        serverReadyBarrier.wait()

        // 接收客户端的数据
        let recvBuffer = Array<Byte>(10, repeat: 0)
        let (senderAddress, readBytes) = serverSocket.receiveFrom(recvBuffer)
        println("Server received ${readBytes} bytes: ${recvBuffer}")

        // 发送数据回客户端（使用sendTo而不是send）
        serverSocket.sendTo(senderAddress, [1u8, 2u8, 3u8])
    }
}

main(): Int64 {
    // 创建临时套接字路径
    let clientSocketPath = createTempSocketPath()
    let serverSocketPath = createTempSocketPath()

    // 启动服务器线程
    let serverTask = spawn {
        runUnixDatagramServer(serverSocketPath)
    }

    // 等待服务器准备就绪
    serverReadyBarrier.wait()

    // 客户端连接的 socket
    try (clientSocket = UnixDatagramSocket(bindAt: clientSocketPath)) {
        clientSocket.bind()

        // 发送数据到服务器（使用sendTo而不是send）
        let serverAddress = UnixSocketAddress(serverSocketPath)
        clientSocket.sendTo(serverAddress, [4, 5, 6])

        // 接收服务器返回的数据
        let buffer = Array<Byte>(10, repeat: 0)
        let (_, readBytes) = clientSocket.receiveFrom(buffer)
        println("Client received ${readBytes} bytes: ${buffer}")
    }

    // 等待服务器任务完成
    serverTask.get()
    return 0
}
```

运行结果：

```text
Server received 3 bytes: [4, 5, 6, 0, 0, 0, 0, 0, 0, 0]
Client received 3 bytes: [1, 2, 3, 0, 0, 0, 0, 0, 0, 0]
```

### func setSocketOption(Int32, Int32, CPointer\<Unit>, UIntNative)

```cangjie
public func setSocketOption(
    level: Int32,
    option: Int32,
    value: CPointer<Unit>,
    valueLength: UIntNative
): Unit
```

功能：设置指定的套接字参数。

> **注意：**
>
> 不支持平台：Windows。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。
- value: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[Unit](../../core/core_package_api/core_package_intrinsics.md#unit)> - 参数值。
- valueLength: [UIntNative](../../core/core_package_api/core_package_intrinsics.md#uintnative) - 参数值长度。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `setsockopt` 返回失败时，抛出异常。

示例：

<!-- run -->
```cangjie
import std.net.*
import std.fs.*
import std.random.*
import std.env.*

// 创建临时套接字路径
func createTempSocketPath(): String {
    let tempDir: Path = getTempDirectory()
    let randomSuffix: String = Random().nextUInt64().toString()
    return tempDir.join("tmp_socket_${randomSuffix}").toString()
}

foreign {
    func free(ptr: CPointer<Unit>): Unit

    func malloc(size: UIntNative): CPointer<Unit>
}

// SO_REUSEADDR选项值（Int32类型）的内存大小
let SO_REUSEADDR_VALUE_SIZE: UIntNative = sizeOf<Int32>()

main(): Int64 {
    let serverSocketPath = createTempSocketPath()
    let unixDatagramSocket = UnixDatagramSocket(bindAt: serverSocketPath)
    unixDatagramSocket.bind()
    unsafe {
        // 为SO_REUSEADDR选项的值分配内存缓冲区
        let reuseAddrBuffer = malloc(SO_REUSEADDR_VALUE_SIZE)
        // 转换为Int32类型指针，专门用于操作SO_REUSEADDR的选项值
        let reuseAddrPtr = CPointer<Int32>(reuseAddrBuffer)

        try {
            // 写入启用SO_REUSEADDR的值（1表示启用）
            reuseAddrPtr.write(1)
            // 设置套接字选项
            unixDatagramSocket.setSocketOption(
                OptionLevel.SOCKET,
                OptionName.SO_REUSEADDR,
                CPointer(reuseAddrPtr),
                SO_REUSEADDR_VALUE_SIZE
            )
        } finally {
            // 释放为选项值分配的缓冲区
            free(reuseAddrBuffer)
        }
    }
    unixDatagramSocket.close()
    return 0
}
```

### func setSocketOptionBool(Int32, Int32, Bool)

```cangjie
public func setSocketOptionBool(
    level: Int32,
    option: Int32,
    value: Bool
): Unit
```

功能：设置指定的套接字参数。

> **注意：**
>
> 不支持平台：Windows。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。
- value: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 参数值。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `setsockopt` 返回失败时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.fs.*
import std.random.*
import std.env.*

// 创建临时套接字路径
func createTempSocketPath(): String {
    let tempDir: Path = getTempDirectory()
    let randomSuffix: String = Random().nextUInt64().toString()
    return tempDir.join("tmp_socket_${randomSuffix}").toString()
}

main(): Int64 {
    let socketPath = createTempSocketPath()

    try (socket = UnixDatagramSocket(bindAt: socketPath)) {
        socket.bind()

        // 获取SO_REUSEADDR选项布尔值
        let reuseAddrValue = socket.getSocketOptionBool(OptionLevel.SOCKET, OptionName.SO_REUSEADDR)
        println("SO_REUSEADDR value before setting: ${reuseAddrValue}")
        socket.setSocketOptionBool(OptionLevel.SOCKET, OptionName.SO_REUSEADDR, true)
        println(
            "SO_REUSEADDR value after setting: ${socket.getSocketOptionBool(OptionLevel.SOCKET, OptionName.SO_REUSEADDR)}")
    }
    return 0
}
```

运行结果：

```text
SO_REUSEADDR value before setting: false
SO_REUSEADDR value after setting: true
```

### func setSocketOptionIntNative(Int32, Int32, IntNative)

```cangjie
public func setSocketOptionIntNative(
    level: Int32,
    option: Int32,
    value: IntNative
): Unit
```

功能：设置指定的套接字参数。

> **注意：**
>
> 不支持平台：Windows。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。
- value: [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) - 参数值。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `setsockopt` 返回失败时抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.fs.*
import std.random.*
import std.env.*

// 创建临时套接字路径
func createTempSocketPath(): String {
    let tempDir: Path = getTempDirectory()
    let randomSuffix: String = Random().nextUInt64().toString()
    return tempDir.join("tmp_socket_${randomSuffix}").toString()
}

main(): Int64 {
    let socketPath = createTempSocketPath()

    try (socket = UnixDatagramSocket(bindAt: socketPath)) {
        socket.bind()

        // 获取SO_REUSEADDR选项值
        let reuseAddrValue = socket.getSocketOptionIntNative(OptionLevel.SOCKET, OptionName.SO_REUSEADDR)
        println("SO_REUSEADDR value before setting: ${reuseAddrValue}")
        socket.setSocketOptionIntNative(OptionLevel.SOCKET, OptionName.SO_REUSEADDR, 1)
        println(
            "SO_REUSEADDR value after setting: ${socket.getSocketOptionIntNative(OptionLevel.SOCKET, OptionName.SO_REUSEADDR)}")
    }
    return 0
}
```

运行结果：

```text
SO_REUSEADDR value before setting: 0
SO_REUSEADDR value after setting: 1
```

### func toString()

```cangjie
public override func toString(): String
```

功能：返回当前 `UDS` 的状态信息。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - 包含当前 `UDS` 状态信息的字符串。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    let socket = UnixDatagramSocket(bindAt: "socketPath")
    // 获取套接字的字符串表示
    let socketString = socket.toString()
    println("Socket toString: ${socketString}")
    return 0
}
```

运行结果：

```text
Socket toString: UnixDatagramSocket(unconnected, unbound)
```

## class UnixServerSocket

```cangjie
public class UnixServerSocket <: ServerSocket {
    public init(bindAt!: String)
    public init(bindAt!: SocketAddress)
}
```

功能：提供基于双工流的主机通讯服务端。

[UnixServerSocket](net_package_classes.md#class-unixserversocket) 监听连接，创建后可以通过属性和 `setSocketOptionXX` 接口配置属性值。需要调用 `bind()` 接口绑定本地地址开始监听连接。可以通过 `accept()` 接口接受连接。

> **注意：**
>
> 不支持平台：Windows。

父类型：

- [ServerSocket](net_package_interfaces.md#interface-serversocket)

### prop backlogSize

```cangjie
public mut prop backlogSize: Int64
```

功能：设置和读取 `backlog` 大小。仅可在调用 `bind` 前调用，否则将抛出异常。
变量是否生效取决于系统行为。

> **注意：**
>
> 不支持平台：Windows。

类型：[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当在 `bind` 后调用，将抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

// 定义Unix域套接字的文件路径
let SOCKET_PATH = "tmpsock"

main(): Int64 {
    // 创建Unix服务器套接字实例
    let serverSocket = UnixServerSocket(bindAt: SOCKET_PATH)
    println("Backlog size before setting: ${serverSocket.backlogSize}")
    serverSocket.backlogSize = 128
    println("Backlog size after setting: ${serverSocket.backlogSize}")
    return 0
}
```

运行结果：

```text
Backlog size before setting: 1024
Backlog size after setting: 128
```

### prop localAddress

```cangjie
public override prop localAddress: SocketAddress
```

功能：读取 `Socket` 将要或已经被绑定的本地地址。

> **注意：**
>
> 不支持平台：Windows。

类型：[SocketAddress](net_package_classes.md#class-socketaddress)

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `Socket` 已经被关闭时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

// 定义Unix域套接字的文件路径
let SOCKET_PATH = "tmpsock"

main(): Int64 {
    let serverSocket = UnixServerSocket(bindAt: SOCKET_PATH)
    println("Local address: ${serverSocket.localAddress}")
    return 0
}
```

运行结果：

```text
Local address: tmpsock
```

### prop receiveBufferSize

```cangjie
public mut prop receiveBufferSize: Int64
```

功能：设置和读取 `SO_RCVBUF` 属性。

> **注意：**
>
> 不支持平台：Windows。

类型：[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当 `size` 小于等于 0 时，抛出异常。
- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `Socket` 已关闭时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

// 定义Unix域套接字的文件路径
let SOCKET_PATH = "tmpsock"

main(): Int64 {
    let serverSocket = UnixServerSocket(bindAt: SOCKET_PATH)
    println("Receive buffer size before setting: ${serverSocket.receiveBufferSize}")
    serverSocket.receiveBufferSize = 8192
    println("Receive buffer size after setting: ${serverSocket.receiveBufferSize}")
    return 0
}
```

运行结果：

```text
Receive buffer size before setting: 212992
Receive buffer size after setting: 16384
```

### prop sendBufferSize

```cangjie
public mut prop sendBufferSize: Int64
```

功能：设置和读取 `SO_SNDBUF` 属性。

> **注意：**
>
> 不支持平台：Windows。

类型：[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当 `size` 小于等于 0 时，抛出异常。
- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `Socket` 已关闭时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

// 定义Unix域套接字的文件路径
let SOCKET_PATH = "tmpsock"

main(): Int64 {
    let serverSocket = UnixServerSocket(bindAt: SOCKET_PATH)
    println("Send buffer size before setting: ${serverSocket.sendBufferSize}")
    serverSocket.sendBufferSize = 8192
    println("Send buffer size after setting: ${serverSocket.sendBufferSize}")
    return 0
}
```

运行结果：

```text
Send buffer size before setting: 212992
Send buffer size after setting: 16384
```

### init(SocketAddress)

```cangjie
public init(bindAt!: SocketAddress)
```

功能：创建一个未连接的 [UnixServerSocket](net_package_classes.md#class-unixserversocket) 实例。

> **注意：**
>
> 不支持平台：Windows。

参数：

- bindAt!: [SocketAddress](net_package_classes.md#class-socketaddress) - 连接的套接字地址。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.fs.*

// 定义Unix域套接字的文件路径
let SOCKET_PATH = "tmpsock"

main(): Int64 {
    // 使用SocketAddress初始化UnixServerSocket
    let socketAddress = UnixSocketAddress(SOCKET_PATH)
    let serverSocket = UnixServerSocket(bindAt: socketAddress)

    // 读取localAddress
    println("Server socket initialized at: ${serverSocket.localAddress}")
    return 0
}
```

运行结果：

```text
Server socket initialized at: tmpsock
```

### init(String)

```cangjie
public init(bindAt!: String)
```

功能：创建一个未连接的 [UnixServerSocket](net_package_classes.md#class-unixserversocket) 实例。

此文件类型可通过 [isSock](../../posix/posix_package_api/posix_package_funcs.md#func-issockstring-deprecated) 判断是否存在，可通过 [unlink](../../posix/posix_package_api/posix_package_funcs.md#func-unlinkstring-deprecated)() 接口删除。

> **注意：**
>
> 不支持平台：Windows。

参数：

- bindAt!: [String](../../core/core_package_api/core_package_structs.md#struct-string) - 连接的文件地址。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当文件地址不合法时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

// 定义Unix域套接字的文件路径
let SOCKET_PATH = "tmpsock"

main(): Int64 {
    // 使用String初始化UnixServerSocket
    let serverSocket = UnixServerSocket(bindAt: SOCKET_PATH)
    // 读取localAddress
    println("Server socket initialized at: ${serverSocket.localAddress}")
    return 0
}
```

运行结果：

```text
Server socket initialized at: tmpsock
```

### func accept()

```cangjie
public override func accept(): UnixSocket
```

功能：等待接受一个客户端的连接，或从队列中读取连接。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- [UnixSocket](net_package_classes.md#class-unixsocket) - 连接的客户端套接字。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.sync.*
import std.fs.*

// 定义Unix域套接字的文件路径
let SOCKET_PATH = "tmpsock"
// 初始化屏障，用于协调主线程和服务器线程的同步（需要等待2个线程）
let barrier = Barrier(2)

// 定义Unix域套接字服务器的执行函数
func runUnixServer() {
    // 创建Unix服务器套接字实例，绑定到指定路径，自动执行 close 函数
    try (serverSocket = UnixServerSocket(bindAt: SOCKET_PATH)) {
        // 将服务器套接字绑定到文件系统路径
        serverSocket.bind()
        // 通知主线程服务器已准备就绪
        barrier.wait()

        // 阻塞等待客户端连接，接受连接后创建客户端通信实例
        try (client = serverSocket.accept()) {
            // 向客户端发送"hello"字符串（转换为字节数组）
            client.write("hello".toArray())
        }
    }
}

main(): Int64 {
    // 启动前清理残留的套接字文件（避免绑定失败）
    removeIfExists(SOCKET_PATH)

    // 启动新线程运行服务器函数，返回Future对象用于等待线程结束
    let fut = spawn {
        runUnixServer()
    }

    // 等待服务器完成初始化并绑定端口
    barrier.wait()

    // 创建Unix客户端套接字实例，连接到指定路径
    try (socket = UnixSocket(SOCKET_PATH)) {
        // 连接到服务器端套接字
        socket.connect()

        // 创建5字节的缓冲区，初始值为0，用于接收服务器数据
        let buf = Array<Byte>(5, repeat: 0)
        // 从套接字读取数据到缓冲区，返回实际读取的字节数
        let readBytes = socket.read(buf)

        // 打印接收到的字节数、原始字节数据和UTF-8字符串
        println("Client received ${readBytes} bytes: ${buf}, ${String.fromUtf8(buf)}")
    }

    // 等待服务器线程执行完成
    fut.get()
    // 程序结束后清理套接字文件
    removeIfExists(SOCKET_PATH)
    return 0
}
```

运行结果：

```text
Client received 5 bytes: [104, 101, 108, 108, 111], hello
```

### func accept(?Duration)

```cangjie
public override func accept(timeout!: ?Duration): UnixSocket
```

功能：等待接受一个客户端的连接，或从队列中读取连接。

> **注意：**
>
> 不支持平台：Windows。

参数：

- timeout!: ?[Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - 超时时间。

返回值：

- [UnixSocket](net_package_classes.md#class-unixsocket) - 连接的客户端套接字。

异常：

- [SocketTimeoutException](net_package_exceptions.md#class-sockettimeoutexception) - 当连接超时时，抛出异常。
- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当超时时间小于 0 时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.sync.*
import std.fs.*

// 定义Unix域套接字的文件路径
let SOCKET_PATH = "tmpsock"
// 初始化屏障，用于协调主线程和服务器线程的同步（需要等待2个线程）
let barrier = Barrier(2)

// 定义Unix域套接字服务器的执行函数
func runUnixServer() {
    // 创建Unix服务器套接字实例，绑定到指定路径，自动执行 close 函数
    try (serverSocket = UnixServerSocket(bindAt: SOCKET_PATH)) {
        // 将服务器套接字绑定到文件系统路径
        serverSocket.bind()
        // 通知主线程服务器已准备就绪
        barrier.wait()

        // 阻塞等待客户端连接，接受连接后创建客户端通信实例，超时抛出异常
        try (client = serverSocket.accept(timeout: Duration.second * 2)) {
        // 不做任何事情
        } catch (e: SocketTimeoutException) {
            println("${e.message}")
        }
    }
}

main(): Int64 {
    // 启动前清理残留的套接字文件（避免绑定失败）
    removeIfExists(SOCKET_PATH)

    // 启动新线程运行服务器函数，返回Future对象用于等待线程结束
    let fut = spawn {
        runUnixServer()
    }

    // 等待服务器完成初始化并绑定端口
    barrier.wait()

    // 此处不进行服务器连接，故意超时

    // 等待服务器线程执行完成
    fut.get()

    // 程序结束后清理套接字文件
    removeIfExists(SOCKET_PATH)
    return 0
}
```

运行结果：

```text
Failed to accept: accept timeout.
```

### func bind()

```cangjie
public override func bind(): Unit
```

功能：绑定一个 `Unix domain` 套接字，并创建监听队列。

此接口自动在本地地址中创建一个套接字文件，如该文件已存在则会绑定失败。此文件类型可通过 [isSock](../../posix/posix_package_api/posix_package_funcs.md#func-issockstring-deprecated) 接口判断是否存在，可通过 [unlink](../../posix/posix_package_api/posix_package_funcs.md#func-unlinkstring-deprecated)() 接口删除，失败后需要 `close` 套接字，不支持多次重试。

> **注意：**
>
> 不支持平台：Windows。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当因系统原因绑定失败时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.fs.*

// 定义Unix域套接字的文件路径
let SOCKET_PATH = "tmpsock"

main(): Int64 {
    // 启动前清理残留的套接字文件（避免绑定失败）
    removeIfExists(SOCKET_PATH)

    // 创建Unix服务器套接字实例
    let serverSocket = UnixServerSocket(bindAt: SOCKET_PATH)

    // 绑定套接字
    serverSocket.bind()

    // 读取localAddress
    println("Server socket bound to: ${serverSocket.localAddress}")

    // 清理
    serverSocket.close()
    removeIfExists(SOCKET_PATH)

    return 0
}
```

运行结果：

```text
Server socket bound to: tmpsock
```

### func close()

```cangjie
public override func close(): Unit
```

功能：关闭套接字，该套接字的所有操作除了 `close/isClosed` 之外，均不允许再调用。此接口允许多次调用。

> **注意：**
>
> 不支持平台：Windows。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.fs.*

// 定义Unix域套接字的文件路径
let SOCKET_PATH = "tmpsock"

main(): Int64 {
    // 启动前清理残留的套接字文件（避免绑定失败）
    removeIfExists(SOCKET_PATH)

    // 创建Unix服务器套接字实例
    let serverSocket = UnixServerSocket(bindAt: SOCKET_PATH)

    // 绑定套接字
    serverSocket.bind()

    // 读取localAddress
    println("Server socket bound to: ${serverSocket.localAddress}")

    // 关闭套接字
    serverSocket.close()

    // 检查套接字是否已关闭
    println("Server socket is closed: ${serverSocket.isClosed()}")

    // 清理
    removeIfExists(SOCKET_PATH)

    return 0
}
```

运行结果：

```text
Server socket bound to: tmpsock
Server socket is closed: true
```

### func getSocketOption(Int32, Int32, CPointer\<Unit>, CPointer\<UIntNative>)

```cangjie
public func getSocketOption(
    level: Int32,
    option: Int32,
    value: CPointer<Unit>,
    valueLength: CPointer<UIntNative>
): Unit
```

功能：获取指定的套接字参数。

> **注意：**
>
> 不支持平台：Windows。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。
- value: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[Unit](../../core/core_package_api/core_package_intrinsics.md#unit)> - 参数值。
- valueLength: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[UIntNative](../../core/core_package_api/core_package_intrinsics.md#uintnative)> - 参数值长度。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `getsockopt` 返回失败时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

// 定义Unix域套接字的文件路径
let SOCKET_PATH = "tmpsock"

foreign {
    func free(ptr: CPointer<Unit>): Unit

    func malloc(size: UIntNative): CPointer<Unit>
}

// SO_REUSEADDR选项值的大小（Int32类型）
let SO_REUSEADDR_VALUE_SIZE: UIntNative = sizeOf<Int32>()

main(): Int64 {
    // 创建Unix服务器套接字实例
    let serverSocket = UnixServerSocket(bindAt: SOCKET_PATH)
    // 存储SO_REUSEADDR选项的获取结果（初始值-1表示未获取成功）
    var reuseAddrValue: Int32 = -1

    unsafe {
        // 为存储选项值分配内存
        let optionValueBuffer = malloc(SO_REUSEADDR_VALUE_SIZE)
        // 转换为Int32类型指针
        let int32Ptr = CPointer<Int32>(optionValueBuffer)

        // 存储选项值缓冲区的长度
        let bufferSizeArray = Array<UIntNative>(1, repeat: SO_REUSEADDR_VALUE_SIZE)
        // 获取数组的原始数据指针
        let bufferSizePtr = acquireArrayRawData(bufferSizeArray)

        try {
            // 获取SO_REUSEADDR选项值
            serverSocket.getSocketOption(
                OptionLevel.SOCKET,
                OptionName.SO_REUSEADDR,
                CPointer(int32Ptr),
                bufferSizePtr.pointer
            )
            // 读取选项值
            reuseAddrValue = int32Ptr.read()
        } finally {
            // 释放分配的内存和数组引用
            free(optionValueBuffer)
            releaseArrayRawData(bufferSizePtr)
        }
    }
    println("SO_REUSEADDR值: ${reuseAddrValue}")
    return 0
}
```

运行结果：

```text
SO_REUSEADDR值: 0
```

### func getSocketOptionBool(Int32, Int32)

```cangjie
public func getSocketOptionBool(
    level: Int32,
    option: Int32
): Bool
```

功能：获取指定的套接字参数。从 [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) 强转而来。`0 => false，非 0 => true`。

> **注意：**
>
> 不支持平台：Windows。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回指定的套接字参数。从 [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) 强转而来。`0 => false，非 0 => true`。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `getsockopt` 返回失败时或参数大小超过 [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) 的阈值时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

// 定义Unix域套接字的文件路径
let SOCKET_PATH = "tmpsock"

main(): Int64 {
    let socket = UnixServerSocket(bindAt: SOCKET_PATH)
    // 获取SO_REUSEADDR选项布尔值
    let reuseAddrValue = socket.getSocketOptionBool(OptionLevel.SOCKET, OptionName.SO_REUSEADDR)
    println("SO_REUSEADDR value before setting: ${reuseAddrValue}")
    socket.setSocketOptionBool(OptionLevel.SOCKET, OptionName.SO_REUSEADDR, true)
    println(
        "SO_REUSEADDR value after setting: ${socket.getSocketOptionBool(OptionLevel.SOCKET, OptionName.SO_REUSEADDR)}")
    return 0
}
```

运行结果：

```text
SO_REUSEADDR value before setting: false
SO_REUSEADDR value after setting: true
```

### func getSocketOptionIntNative(Int32, Int32)

```cangjie
public func getSocketOptionIntNative(
    level: Int32,
    option: Int32
): IntNative
```

功能：获取返回值为整型的套接字参数。

> **注意：**
>
> 不支持平台：Windows。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。

返回值：

- [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) - 指定的套接字参数值。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `getsockopt` 返回失败时或参数大小超过 [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) 的阈值时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

// 定义Unix域套接字的文件路径
let SOCKET_PATH = "tmpsock"

main(): Int64 {
    let socket = UnixServerSocket(bindAt: SOCKET_PATH)
    // 获取SO_REUSEADDR选项布尔值
    let reuseAddrValue = socket.getSocketOptionIntNative(OptionLevel.SOCKET, OptionName.SO_REUSEADDR)
    println("SO_REUSEADDR value before setting: ${reuseAddrValue}")
    socket.setSocketOptionIntNative(OptionLevel.SOCKET, OptionName.SO_REUSEADDR, 1)
    println(
        "SO_REUSEADDR value after setting: ${socket.getSocketOptionIntNative(OptionLevel.SOCKET, OptionName.SO_REUSEADDR)}")
    return 0
}
```

运行结果：

```text
SO_REUSEADDR value before setting: 0
SO_REUSEADDR value after setting: 1
```

### func isClosed()

```cangjie
public override func isClosed(): Bool
```

功能：判断套接字是否通过调用 `close` 显式关闭。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 如果套接字是通过调用 `close` 显式关闭，则返回 true；否则，返回 false。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.fs.*

// 定义Unix域套接字的文件路径
let SOCKET_PATH = "tmpsock"

main(): Int64 {
    // 启动前清理残留的套接字文件（避免绑定失败）
    removeIfExists(SOCKET_PATH)

    // 创建Unix服务器套接字实例
    let serverSocket = UnixServerSocket(bindAt: SOCKET_PATH)

    // 检查套接字是否已关闭（初始状态）
    println("Server socket is closed (initial): ${serverSocket.isClosed()}")

    // 绑定套接字
    serverSocket.bind()

    // 读取localAddress
    println("Server socket bound to: ${serverSocket.localAddress}")

    // 检查套接字是否已关闭（绑定后）
    println("Server socket is closed (after bind): ${serverSocket.isClosed()}")

    // 关闭套接字
    serverSocket.close()

    // 检查套接字是否已关闭（关闭后）
    println("Server socket is closed (after close): ${serverSocket.isClosed()}")

    // 清理
    removeIfExists(SOCKET_PATH)

    return 0
}
```

运行结果：

```text
Server socket is closed (initial): false
Server socket bound to: tmpsock
Server socket is closed (after bind): false
Server socket is closed (after close): true
```

### func setSocketOption(Int32, Int32, CPointer\<Unit>, UIntNative)

```cangjie
public func setSocketOption(
    level: Int32,
    option: Int32,
    value: CPointer<Unit>,
    valueLength: UIntNative
): Unit
```

功能：设置返回值为整型的套接字参数。

> **注意：**
>
> 不支持平台：Windows。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。
- value: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[Unit](../../core/core_package_api/core_package_intrinsics.md#unit)> - 参数值。
- valueLength: [UIntNative](../../core/core_package_api/core_package_intrinsics.md#uintnative) - 参数值长度。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `setsockopt` 返回失败时，抛出异常。

示例：

<!-- run -->
```cangjie
import std.net.*

// 定义Unix域套接字的文件路径
let SOCKET_PATH = "tmpsock"

foreign {
    func free(ptr: CPointer<Unit>): Unit

    func malloc(size: UIntNative): CPointer<Unit>
}

// SO_REUSEADDR选项值的大小（Int32类型）
let SO_REUSEADDR_VALUE_SIZE: UIntNative = sizeOf<Int32>()

main(): Int64 {
    // 创建Unix服务器套接字实例
    let serverSocket = UnixServerSocket(bindAt: SOCKET_PATH)
    unsafe {
        // 为SO_REUSEADDR选项的值分配内存缓冲区
        let reuseAddrBuffer = malloc(SO_REUSEADDR_VALUE_SIZE)
        // 转换为Int32类型指针，专门用于操作SO_REUSEADDR的选项值
        let reuseAddrPtr = CPointer<Int32>(reuseAddrBuffer)

        try {
            // 写入启用SO_REUSEADDR的值（1表示启用）
            reuseAddrPtr.write(1)
            // 设置套接字选项
            serverSocket.setSocketOption(
                OptionLevel.SOCKET,
                OptionName.SO_REUSEADDR,
                CPointer(reuseAddrPtr),
                SO_REUSEADDR_VALUE_SIZE
            )
        } finally {
            // 释放为选项值分配的缓冲区
            free(reuseAddrBuffer)
        }
    }
    return 0
}
```

### func setSocketOptionBool(Int32, Int32, Bool)

```cangjie
public func setSocketOptionBool(
    level: Int32,
    option: Int32,
    value: Bool
): Unit
```

功能：设置指定的套接字参数。

> **注意：**
>
> 不支持平台：Windows。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。
- value: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 参数值。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `setsockopt` 返回失败时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

// 定义Unix域套接字的文件路径
let SOCKET_PATH = "tmpsock"

main(): Int64 {
    let socket = UnixServerSocket(bindAt: SOCKET_PATH)
    // 获取SO_REUSEADDR选项布尔值
    let reuseAddrValue = socket.getSocketOptionBool(OptionLevel.SOCKET, OptionName.SO_REUSEADDR)
    println("SO_REUSEADDR value before setting: ${reuseAddrValue}")
    socket.setSocketOptionBool(OptionLevel.SOCKET, OptionName.SO_REUSEADDR, true)
    println(
        "SO_REUSEADDR value after setting: ${socket.getSocketOptionBool(OptionLevel.SOCKET, OptionName.SO_REUSEADDR)}")
    return 0
}
```

运行结果：

```text
SO_REUSEADDR value before setting: false
SO_REUSEADDR value after setting: true
```

### func setSocketOptionIntNative(Int32, Int32, IntNative)

```cangjie
public func setSocketOptionIntNative(
    level: Int32,
    option: Int32,
    value: IntNative
): Unit
```

功能：设置指定的套接字参数。

> **注意：**
>
> 不支持平台：Windows。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。
- value: [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) - 参数值。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `setsockopt` 返回失败时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

// 定义Unix域套接字的文件路径
let SOCKET_PATH = "tmpsock"

main(): Int64 {
    let socket = UnixServerSocket(bindAt: SOCKET_PATH)
    // 获取SO_REUSEADDR选项布尔值
    let reuseAddrValue = socket.getSocketOptionIntNative(OptionLevel.SOCKET, OptionName.SO_REUSEADDR)
    println("SO_REUSEADDR value before setting: ${reuseAddrValue}")
    socket.setSocketOptionIntNative(OptionLevel.SOCKET, OptionName.SO_REUSEADDR, 1)
    println(
        "SO_REUSEADDR value after setting: ${socket.getSocketOptionIntNative(OptionLevel.SOCKET, OptionName.SO_REUSEADDR)}")
    return 0
}
```

运行结果：

```text
SO_REUSEADDR value before setting: 0
SO_REUSEADDR value after setting: 1
```

### func toString()

```cangjie
public override func toString(): String
```

功能：返回当前 [UnixServerSocket](net_package_classes.md#class-unixserversocket) 的状态信息。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - 包含当前 [UnixServerSocket](net_package_classes.md#class-unixserversocket) 状态信息的字符串。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.fs.*

// 定义Unix域套接字的文件路径
let SOCKET_PATH = "tmpsock"

main(): Int64 {
    // 启动前清理残留的套接字文件（避免绑定失败）
    removeIfExists(SOCKET_PATH)

    // 创建Unix服务器套接字实例
    let serverSocket = UnixServerSocket(bindAt: SOCKET_PATH)

    // 打印初始状态
    println("Server socket initial state: ${serverSocket.toString()}")

    // 绑定套接字
    serverSocket.bind()

    // 打印绑定后的状态
    println("Server socket state after bind: ${serverSocket.toString()}")

    // 关闭套接字
    serverSocket.close()

    // 打印关闭后的状态
    println("Server socket state after close: ${serverSocket.toString()}")

    // 清理
    removeIfExists(SOCKET_PATH)

    return 0
}
```

运行结果：

```text
Server socket initial state: UnixServerSocket(unconnected, unbound)
Server socket state after bind: UnixServerSocket(bound at tmpsock)
Server socket state after close: UnixServerSocket(closed)
```

## class UnixSocket

```cangjie
public class UnixSocket <: StreamingSocket {
    public init(path: String, localPath!: ?String = None)
    public init(address: SocketAddress, localAddress!: ?SocketAddress = None)
}
```

功能：提供基于双工流的主机通讯客户端。

[UnixSocket](net_package_classes.md#class-unixsocket) 实例创建后应调用 `connect()` 接口创建连接，并且在结束时显式调用 `close()` 回收资源。可参阅 [StreamingSocket](net_package_interfaces.md#interface-streamingsocket) 获取更多信息。

> **注意：**
>
> 不支持平台：Windows。

父类型：

- [StreamingSocket](net_package_interfaces.md#interface-streamingsocket)

### prop localAddress

```cangjie
public override prop localAddress: SocketAddress
```

功能：读取 `Socket` 将要或已经被绑定的本地地址。

> **注意：**
>
> 不支持平台：Windows。

类型：[SocketAddress](net_package_classes.md#class-socketaddress)

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `Socket` 已经被关闭或无可用的本地地址（本地地址未配置并且套接字未连接）时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

// 定义Unix域套接字的文件路径
let SERVER_SOCKET_PATH = "serversock"
let CLIENT_SOCKET_PATH = "clientsock"

main(): Int64 {
    // 创建Unix客户端套接字实例
    let clientSocket = UnixSocket(SERVER_SOCKET_PATH, localPath: CLIENT_SOCKET_PATH)
    println("Local address: ${clientSocket.localAddress}")
    return 0
}
```

运行结果：

```text
Local address: clientsock
```

### prop readTimeout

```cangjie
public override mut prop readTimeout: ?Duration
```

功能：设置和读取读操作超时时间。

如果设置的时间过小将会设置为最小时钟周期值，过大时将设置为 `None`，默认值为 `None`。

> **注意：**
>
> 不支持平台：Windows。

类型：?[Duration](../../core/core_package_api/core_package_structs.md#struct-duration)

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当超时时间小于 0 时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

// 定义Unix域套接字的文件路径
let SERVER_SOCKET_PATH = "serversock"

main(): Int64 {
    // 创建Unix客户端套接字实例
    let clientSocket = UnixSocket(SERVER_SOCKET_PATH)
    println("readTimeout before setting: ${clientSocket.readTimeout}")
    clientSocket.readTimeout = Duration.second * 3
    println("readTimeout after setting: ${clientSocket.readTimeout}")
    return 0
}
```

运行结果：

```text
readTimeout before setting: None
readTimeout after setting: Some(3s)
```

### prop receiveBufferSize

```cangjie
public mut prop receiveBufferSize: Int64
```

功能：设置和读取 `SO_RCVBUF` 属性。

> **注意：**
>
> 不支持平台：Windows。

类型：[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当 `size` 小于等于 0 时，抛出异常。
- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `Socket` 已关闭时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

// 定义Unix域套接字的文件路径
let SERVER_SOCKET_PATH = "serversock"

main(): Int64 {
    // 创建Unix客户端套接字实例
    let clientSocket = UnixSocket(SERVER_SOCKET_PATH)
    println("receiveBufferSize before setting: ${clientSocket.receiveBufferSize}")
    clientSocket.receiveBufferSize = 8192
    println("receiveBufferSize after setting: ${clientSocket.receiveBufferSize}")
    return 0
}
```

运行结果：

```text
receiveBufferSize before setting: 212992
receiveBufferSize after setting: 16384
```

### prop remoteAddress

```cangjie
public override prop remoteAddress: SocketAddress
```

功能：读取 `Socket` 已经或将要连接的远端地址。

> **注意：**
>
> 不支持平台：Windows。

类型：[SocketAddress](net_package_classes.md#class-socketaddress)

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `Socket` 未连接或已经被关闭时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.sync.*
import std.fs.*

// 定义Unix域套接字的文件路径
let SOCKET_PATH = "tmpsock"
// 初始化屏障，用于协调主线程和服务器线程的同步（需要等待2个线程）
let barrier = Barrier(2)

// 定义Unix域套接字服务器的执行函数
func runUnixServer() {
    // 创建Unix服务器套接字实例，绑定到指定路径，自动执行 close 函数
    try (serverSocket = UnixServerSocket(bindAt: SOCKET_PATH)) {
        // 将服务器套接字绑定到文件系统路径
        serverSocket.bind()
        // 通知主线程服务器已准备就绪
        barrier.wait()

        // 阻塞等待客户端连接，接受连接后创建客户端通信实例
        try (client = serverSocket.accept()) {
            // 不做任何事情
        }
    }
}

main(): Int64 {
    // 启动前清理残留的套接字文件（避免绑定失败）
    removeIfExists(SOCKET_PATH)

    // 启动新线程运行服务器函数，返回Future对象用于等待线程结束
    let fut = spawn {
        runUnixServer()
    }

    // 等待服务器完成初始化并绑定端口
    barrier.wait()

    // 创建Unix客户端套接字实例，连接到指定路径
    try (socket = UnixSocket(SOCKET_PATH)) {
        // 连接到服务器端套接字
        socket.connect()

        // 读取remoteAddress
        println("Remote address: ${socket.remoteAddress}")
    }

    // 等待服务器线程执行完成
    fut.get()
    // 程序结束后清理套接字文件
    removeIfExists(SOCKET_PATH)
    return 0
}
```

运行结果：

```text
Remote address: tmpsock
```

### prop sendBufferSize

```cangjie
public mut prop sendBufferSize: Int64
```

功能：设置和读取 `SO_SNDBUF` 属性。

> **注意：**
>
> 不支持平台：Windows。

类型：[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当 `size` 小于等于 0 时，抛出异常。
- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `Socket` 已关闭时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

// 定义Unix域套接字的文件路径
let SERVER_SOCKET_PATH = "serversock"

main(): Int64 {
    // 创建Unix客户端套接字实例
    let clientSocket = UnixSocket(SERVER_SOCKET_PATH)
    println("sendBufferSize before setting: ${clientSocket.sendBufferSize}")
    clientSocket.sendBufferSize = 8192
    println("sendBufferSize after setting: ${clientSocket.sendBufferSize}")
    return 0
}
```

运行结果：

```text
sendBufferSize before setting: 212992
sendBufferSize after setting: 16384
```

### prop writeTimeout

```cangjie
public override mut prop writeTimeout: ?Duration
```

功能：设置和读取写操作超时时间。

如果设置的时间过小将会设置为最小时钟周期值；过大时将设置为最大超时时间（2<sup>63</sup>-1 纳秒）；默认值为 `None`。

> **注意：**
>
> 不支持平台：Windows。

类型：?[Duration](../../core/core_package_api/core_package_structs.md#struct-duration)

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当超时时间小于 0 时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

// 定义Unix域套接字的文件路径
let SERVER_SOCKET_PATH = "serversock"

main(): Int64 {
    // 创建Unix客户端套接字实例
    let clientSocket = UnixSocket(SERVER_SOCKET_PATH)
    println("writeTimeout before setting: ${clientSocket.writeTimeout}")
    clientSocket.writeTimeout = Duration.second * 3
    println("writeTimeout after setting: ${clientSocket.writeTimeout}")
    return 0
}
```

运行结果：

```text
writeTimeout before setting: None
writeTimeout after setting: Some(3s)
```

### init(SocketAddress, ?SocketAddress)

```cangjie
public init(address: SocketAddress, localAddress!: ?SocketAddress = None)
```

功能：创建一个未连接的 [UnixSocket](net_package_classes.md#class-unixsocket) 实例。

> **注意：**
>
> 不支持平台：Windows。

参数：

- address: [SocketAddress](net_package_classes.md#class-socketaddress) - 连接的套接字地址。
- localAddress!: ?[SocketAddress](net_package_classes.md#class-socketaddress) - 需要 bind 的本地套接字地址；默认值为 `None`。

示例：

<!-- verify -->
```cangjie
import std.net.*

// 定义Unix域套接字的文件路径
let SERVER_SOCKET_PATH = "serversock"
let CLIENT_SOCKET_PATH = "clientsock"

main(): Int64 {
    // 使用SocketAddress初始化UnixSocket
    let serverAddress = UnixSocketAddress(SERVER_SOCKET_PATH)
    let localAddress = UnixSocketAddress(CLIENT_SOCKET_PATH)
    let clientSocket = UnixSocket(serverAddress, localAddress: localAddress)
    println("Client socket created with remote address: ${serverAddress} and local address: ${localAddress}")
    return 0
}
```

运行结果：

```text
Client socket created with remote address: serversock and local address: clientsock
```

### init(String, ?String)

```cangjie
public init(path: String, localPath!: ?String = None)
```

功能：创建一个未连接的 [UnixSocket](net_package_classes.md#class-unixsocket) 实例。

此文件类型可通过 [isSock](../../posix/posix_package_api/posix_package_funcs.md#func-issockstring-deprecated) 判断是否存在，可通过 [unlink](../../posix/posix_package_api/posix_package_funcs.md#func-unlinkstring-deprecated)() 接口删除。

> **注意：**
>
> 不支持平台：Windows。

参数：

- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) - 连接的文件地址。
- localPath!: ?[String](../../core/core_package_api/core_package_structs.md#struct-string) - 需要 bind 的本地套接字地址路径；默认值为 `None`。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当文件地址不合法时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

// 定义Unix域套接字的文件路径
let SERVER_SOCKET_PATH = "serversock"
let CLIENT_SOCKET_PATH = "clientsock"

main(): Int64 {
    // 使用String初始化UnixSocket
    let clientSocket = UnixSocket(SERVER_SOCKET_PATH, localPath: CLIENT_SOCKET_PATH)
    println("Client socket created with remote path: ${SERVER_SOCKET_PATH} and local path: ${CLIENT_SOCKET_PATH}")
    return 0
}
```

运行结果：

```text
Client socket created with remote path: serversock and local path: clientsock
```

### func close()

```cangjie
public func close(): Unit
```

功能：关闭套接字，所有操作除了 `close/isClosed` 之外，均不允许再调用。接口允许多次调用。

> **注意：**
>
> 不支持平台：Windows。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.sync.*
import std.fs.*

// 定义Unix域套接字的文件路径
let SOCKET_PATH = "tmpsock"
// 初始化屏障，用于协调主线程和服务器线程的同步（需要等待2个线程）
let barrier = Barrier(2)

// 定义Unix域套接字服务器的执行函数
func runUnixServer() {
    // 创建Unix服务器套接字实例，绑定到指定路径，自动执行 close 函数
    try (serverSocket = UnixServerSocket(bindAt: SOCKET_PATH)) {
        // 将服务器套接字绑定到文件系统路径
        serverSocket.bind()
        // 通知主线程服务器已准备就绪
        barrier.wait()

        // 阻塞等待客户端连接，接受连接后创建客户端通信实例
        try (client = serverSocket.accept()) {
            // 不做任何事情
        }
    }
}

main(): Int64 {
    // 启动前清理残留的套接字文件（避免绑定失败）
    removeIfExists(SOCKET_PATH)

    // 启动新线程运行服务器函数，返回Future对象用于等待线程结束
    let fut = spawn {
        runUnixServer()
    }

    // 等待服务器完成初始化并绑定端口
    barrier.wait()

    // 创建Unix客户端套接字实例，连接到指定路径，手动close，暂时不采用 try-with-resources 表达式（该表达式会自动close）
    let socket = UnixSocket(SOCKET_PATH)
    // 连接到服务器端套接字
    socket.connect()

    // 检查套接字是否已关闭
    socket.isClosed()
    println("Socket is closed: ${socket.isClosed()}")

    socket.close()
    println("Socket is closed: ${socket.isClosed()}")

    // 等待服务器线程执行完成
    fut.get()
    // 程序结束后清理套接字文件
    removeIfExists(SOCKET_PATH)
    return 0
}
```

运行结果：

```text
Socket is closed: false
Socket is closed: true
```

### func connect(?Duration)

```cangjie
public func connect(timeout!: ?Duration = None): Unit
```

功能：建立远端连接，对端拒绝时连接失败，会自动绑定本地地址，因此不需要进行额外的绑定操作。

> **注意：**
>
> 不支持平台：Windows。

参数：

- timeout!: ?[Duration](../../core/core_package_api/core_package_structs.md#struct-duration) - 超时时间，`None` 表示无超时时间。Unix 与 Tcp 不同，队列已满时，调用立即返回错误，而非重试阻塞等待。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 当远端地址不合法或者超时时间小于 0 时，抛出异常。
- [SocketException](net_package_exceptions.md#class-socketexception) - 当连接因系统原因无法建立时。抛出异常。
- [SocketTimeoutException](net_package_exceptions.md#class-sockettimeoutexception) - 当连接超时时。抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.sync.*
import std.fs.*

// 定义Unix域套接字的文件路径
let SOCKET_PATH = "tmpsock"
// 初始化屏障，用于协调主线程和服务器线程的同步（需要等待2个线程）
let barrier = Barrier(2)

// 定义Unix域套接字服务器的执行函数
func runUnixServer() {
    // 创建Unix服务器套接字实例，绑定到指定路径，自动执行 close 函数
    try (serverSocket = UnixServerSocket(bindAt: SOCKET_PATH)) {
        // 将服务器套接字绑定到文件系统路径
        serverSocket.bind()
        // 通知主线程服务器已准备就绪
        barrier.wait()

        // 阻塞等待客户端连接，接受连接后创建客户端通信实例
        try (client = serverSocket.accept()) {
            client.write("hello".toArray())
        }
    }
}

main(): Int64 {
    // 启动前清理残留的套接字文件（避免绑定失败）
    removeIfExists(SOCKET_PATH)

    // 启动新线程运行服务器函数，返回Future对象用于等待线程结束
    let fut = spawn {
        runUnixServer()
    }

    // 等待服务器完成初始化并绑定端口
    barrier.wait()

    // 创建Unix客户端套接字实例，连接到指定路径
    try (socket = UnixSocket(SOCKET_PATH)) {
        // 连接到服务器端套接字，设置超时时间为3秒
        socket.connect(timeout: Duration.second * 3)

        let buf = Array<Byte>(5, repeat: 0)
        let readBytes = socket.read(buf)

        // 打印接收到的字节数、原始字节数据和UTF-8字符串
        println("Client received ${readBytes} bytes: ${buf}, ${String.fromUtf8(buf)}")
    }

    // 等待服务器线程执行完成
    fut.get()
    // 程序结束后清理套接字文件
    removeIfExists(SOCKET_PATH)
    return 0
}
```

运行结果：

```text
Client received 5 bytes: [104, 101, 108, 108, 111], hello
```

### func getSocketOption(Int32, Int32, CPointer\<Unit>, CPointer\<UIntNative>)

```cangjie
public func getSocketOption(
    level: Int32,
    option: Int32,
    value: CPointer<Unit>,
    valueLength: CPointer<UIntNative>
): Unit
```

功能：获取指定的套接字参数。

> **注意：**
>
> 不支持平台：Windows。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。
- value: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[Unit](../../core/core_package_api/core_package_intrinsics.md#unit)> - 参数值。
- valueLength: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[UIntNative](../../core/core_package_api/core_package_intrinsics.md#uintnative)> - 参数值长度。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `getsockopt` 返回失败时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

// 定义Unix域套接字的文件路径
let SOCKET_PATH = "tmpsock"

foreign {
    func free(ptr: CPointer<Unit>): Unit

    func malloc(size: UIntNative): CPointer<Unit>
}

// SO_REUSEADDR选项值的大小（Int32类型）
let SO_REUSEADDR_VALUE_SIZE: UIntNative = sizeOf<Int32>()

main(): Int64 {
    // 创建Unix客户端套接字实例
    let clientSocket = UnixSocket(SOCKET_PATH)
    // 存储SO_REUSEADDR选项的获取结果（初始值-1表示未获取成功）
    var reuseAddrValue: Int32 = -1

    unsafe {
        // 为存储选项值分配内存
        let optionValueBuffer = malloc(SO_REUSEADDR_VALUE_SIZE)
        // 转换为Int32类型指针
        let int32Ptr = CPointer<Int32>(optionValueBuffer)

        // 存储选项值缓冲区的长度
        let bufferSizeArray = Array<UIntNative>(1, repeat: SO_REUSEADDR_VALUE_SIZE)
        // 获取数组的原始数据指针
        let bufferSizePtr = acquireArrayRawData(bufferSizeArray)

        try {
            // 获取SO_REUSEADDR选项值
            clientSocket.getSocketOption(
                OptionLevel.SOCKET,
                OptionName.SO_REUSEADDR,
                CPointer(int32Ptr),
                bufferSizePtr.pointer
            )
            // 读取选项值
            reuseAddrValue = int32Ptr.read()
        } finally {
            // 释放分配的内存和数组引用
            free(optionValueBuffer)
            releaseArrayRawData(bufferSizePtr)
        }
    }
    println("SO_REUSEADDR值: ${reuseAddrValue}")
    return 0
}
```

运行结果：

```text
SO_REUSEADDR值: 0
```

### func getSocketOptionBool(Int32, Int32)

```cangjie
public func getSocketOptionBool(
    level: Int32,
    option: Int32
): Bool
```

功能：获取指定的套接字参数。

> **注意：**
>
> 不支持平台：Windows。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回指定的套接字参数值。从 [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) 强转而来。`0 => false`，`非 0 => true`。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `getsockopt` 返回失败时或参数大小超过 [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) 的阈值时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

// 定义Unix域套接字的文件路径
let SOCKET_PATH = "tmpsock"

main(): Int64 {
    let socket = UnixSocket(SOCKET_PATH)
    // 获取SO_REUSEADDR选项布尔值
    let reuseAddrValue = socket.getSocketOptionBool(OptionLevel.SOCKET, OptionName.SO_REUSEADDR)
    println("SO_REUSEADDR value before setting: ${reuseAddrValue}")
    socket.setSocketOptionBool(OptionLevel.SOCKET, OptionName.SO_REUSEADDR, true)
    println(
        "SO_REUSEADDR value after setting: ${socket.getSocketOptionBool(OptionLevel.SOCKET, OptionName.SO_REUSEADDR)}")
    return 0
}
```

运行结果：

```text
SO_REUSEADDR value before setting: false
SO_REUSEADDR value after setting: true
```

### func getSocketOptionIntNative(Int32, Int32)

```cangjie
public func getSocketOptionIntNative(
    level: Int32,
    option: Int32
): IntNative
```

功能：获取指定的套接字参数。

> **注意：**
>
> 不支持平台：Windows。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。

返回值：

- [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) - 指定的套接字参数值。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `getsockopt` 返回失败时或参数大小超过 [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) 的阈值时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

// 定义Unix域套接字的文件路径
let SOCKET_PATH = "tmpsock"

main(): Int64 {
    let socket = UnixSocket(SOCKET_PATH)
    // 获取SO_REUSEADDR选项布尔值
    let reuseAddrValue = socket.getSocketOptionIntNative(OptionLevel.SOCKET, OptionName.SO_REUSEADDR)
    println("SO_REUSEADDR value before setting: ${reuseAddrValue}")
    socket.setSocketOptionIntNative(OptionLevel.SOCKET, OptionName.SO_REUSEADDR, 1)
    println(
        "SO_REUSEADDR value after setting: ${socket.getSocketOptionIntNative(OptionLevel.SOCKET, OptionName.SO_REUSEADDR)}")
    return 0
}
```

运行结果：

```text
SO_REUSEADDR value before setting: 0
SO_REUSEADDR value after setting: 1
```

### func isClosed()

```cangjie
public func isClosed(): Bool
```

功能：判断套接字是否通过调用 `close` 显式关闭。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 返回套接字是否已经调用 `close` 显示关闭。是则返回 `true`；否则，返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.sync.*
import std.fs.*

// 定义Unix域套接字的文件路径
let SOCKET_PATH = "tmpsock"
// 初始化屏障，用于协调主线程和服务器线程的同步（需要等待2个线程）
let barrier = Barrier(2)

// 定义Unix域套接字服务器的执行函数
func runUnixServer() {
    // 创建Unix服务器套接字实例，绑定到指定路径，自动执行 close 函数
    try (serverSocket = UnixServerSocket(bindAt: SOCKET_PATH)) {
        // 将服务器套接字绑定到文件系统路径
        serverSocket.bind()
        // 通知主线程服务器已准备就绪
        barrier.wait()

        // 阻塞等待客户端连接，接受连接后创建客户端通信实例
        try (client = serverSocket.accept()) {
            // 不做任何事情
        }
    }
}

main(): Int64 {
    // 启动前清理残留的套接字文件（避免绑定失败）
    removeIfExists(SOCKET_PATH)

    // 启动新线程运行服务器函数，返回Future对象用于等待线程结束
    let fut = spawn {
        runUnixServer()
    }

    // 等待服务器完成初始化并绑定端口
    barrier.wait()

    // 创建Unix客户端套接字实例，连接到指定路径，手动close，暂时不采用 try-with-resources 表达式（该表达式会自动close）
    let socket = UnixSocket(SOCKET_PATH)
    // 连接到服务器端套接字
    socket.connect()

    // 检查套接字是否已关闭
    socket.isClosed()
    println("Socket is closed: ${socket.isClosed()}")

    socket.close()
    println("Socket is closed: ${socket.isClosed()}")

    // 等待服务器线程执行完成
    fut.get()
    // 程序结束后清理套接字文件
    removeIfExists(SOCKET_PATH)
    return 0
}
```

运行结果：

```text
Socket is closed: false
Socket is closed: true
```

### func read(Array\<Byte>)

```cangjie
public override func read(buffer: Array<Byte>): Int64
```

功能：读取报文。超时情况按 `readTimeout` 决定，详见 `readTimeout`。

> **注意：**
>
> 不支持平台：Windows。

参数：

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 读取的数据存储变量。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - 读取的数据长度。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `buffer` 大小为 0 或者因系统原因读取失败时，抛出异常。
- [SocketTimeoutException](net_package_exceptions.md#class-sockettimeoutexception) - 当读取超时时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.sync.*
import std.fs.*

// 定义Unix域套接字的文件路径
let SOCKET_PATH = "tmpsock"
// 初始化屏障，用于协调主线程和服务器线程的同步（需要等待2个线程）
let barrier = Barrier(2)

// 定义Unix域套接字服务器的执行函数
func runUnixServer() {
    // 创建Unix服务器套接字实例，绑定到指定路径，自动执行 close 函数
    try (serverSocket = UnixServerSocket(bindAt: SOCKET_PATH)) {
        // 将服务器套接字绑定到文件系统路径
        serverSocket.bind()
        // 通知主线程服务器已准备就绪
        barrier.wait()

        // 阻塞等待客户端连接，接受连接后创建客户端通信实例
        try (client = serverSocket.accept()) {
            // 向客户端发送"hello"字符串（转换为字节数组）
            client.write("hello".toArray())
        }
    }
}

main(): Int64 {
    // 启动前清理残留的套接字文件（避免绑定失败）
    removeIfExists(SOCKET_PATH)

    // 启动新线程运行服务器函数，返回Future对象用于等待线程结束
    let fut = spawn {
        runUnixServer()
    }

    // 等待服务器完成初始化并绑定端口
    barrier.wait()

    // 创建Unix客户端套接字实例，连接到指定路径
    try (socket = UnixSocket(SOCKET_PATH)) {
        // 连接到服务器端套接字
        socket.connect()

        // 创建5字节的缓冲区，初始值为0，用于接收服务器数据
        let buf = Array<Byte>(5, repeat: 0)
        // 从套接字读取数据到缓冲区，返回实际读取的字节数
        let readBytes = socket.read(buf)

        // 打印接收到的字节数、原始字节数据和UTF-8字符串
        println("Client received ${readBytes} bytes: ${buf}, ${String.fromUtf8(buf)}")
    }

    // 等待服务器线程执行完成
    fut.get()
    // 程序结束后清理套接字文件
    removeIfExists(SOCKET_PATH)
    return 0
}
```

运行结果：

```text
Client received 5 bytes: [104, 101, 108, 108, 111], hello
```

### func setSocketOption(Int32, Int32, CPointer\<Unit>, UIntNative)

```cangjie
public func setSocketOption(
    level: Int32,
    option: Int32,
    value: CPointer<Unit>,
    valueLength: UIntNative
): Unit
```

功能：设置指定的套接字参数。

> **注意：**
>
> 不支持平台：Windows。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。
- value: [CPointer](../../core/core_package_api/core_package_intrinsics.md#cpointert)\<[Unit](../../core/core_package_api/core_package_intrinsics.md#unit)> - 参数值。
- valueLength: [UIntNative](../../core/core_package_api/core_package_intrinsics.md#uintnative) - 参数值长度。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `setsockopt` 返回失败时，抛出异常。

示例：

<!-- run -->
```cangjie
import std.net.*

// 定义Unix域套接字的文件路径
let SOCKET_PATH = "tmpsock"

foreign {
    func free(ptr: CPointer<Unit>): Unit

    func malloc(size: UIntNative): CPointer<Unit>
}

// SO_REUSEADDR选项值的大小（Int32类型）
let SO_REUSEADDR_VALUE_SIZE: UIntNative = sizeOf<Int32>()

main(): Int64 {
    // 创建Unix客户端套接字实例
    let clientSocket = UnixSocket(SOCKET_PATH)
    unsafe {
        // 为SO_REUSEADDR选项的值分配内存缓冲区
        let reuseAddrBuffer = malloc(SO_REUSEADDR_VALUE_SIZE)
        // 转换为Int32类型指针，专门用于操作SO_REUSEADDR的选项值
        let reuseAddrPtr = CPointer<Int32>(reuseAddrBuffer)

        try {
            // 写入启用SO_REUSEADDR的值（1表示启用）
            reuseAddrPtr.write(1)
            // 设置套接字选项
            clientSocket.setSocketOption(
                OptionLevel.SOCKET,
                OptionName.SO_REUSEADDR,
                CPointer(reuseAddrPtr),
                SO_REUSEADDR_VALUE_SIZE
            )
        } finally {
            // 释放为选项值分配的缓冲区
            free(reuseAddrBuffer)
        }
    }
    return 0
}
```

### func setSocketOptionBool(Int32, Int32, Bool)

```cangjie
public func setSocketOptionBool(
    level: Int32,
    option: Int32,
    value: Bool
): Unit
```

功能：设置指定的套接字参数。

> **注意：**
>
> 不支持平台：Windows。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。
- value: [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 参数值。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `setsockopt` 返回失败时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

// 定义Unix域套接字的文件路径
let SOCKET_PATH = "tmpsock"

main(): Int64 {
    let socket = UnixSocket(SOCKET_PATH)
    // 获取SO_REUSEADDR选项布尔值
    let reuseAddrValue = socket.getSocketOptionBool(OptionLevel.SOCKET, OptionName.SO_REUSEADDR)
    println("SO_REUSEADDR value before setting: ${reuseAddrValue}")
    socket.setSocketOptionBool(OptionLevel.SOCKET, OptionName.SO_REUSEADDR, true)
    println(
        "SO_REUSEADDR value after setting: ${socket.getSocketOptionBool(OptionLevel.SOCKET, OptionName.SO_REUSEADDR)}")
    return 0
}
```

运行结果：

```text
SO_REUSEADDR value before setting: false
SO_REUSEADDR value after setting: true
```

### func setSocketOptionIntNative(Int32, Int32, IntNative)

```cangjie
public func setSocketOptionIntNative(
    level: Int32,
    option: Int32,
    value: IntNative
): Unit
```

功能：设置指定的套接字参数。

> **注意：**
>
> 不支持平台：Windows。

参数：

- level: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项级别](./net_package_structs.md#struct-optionlevel)。
- option: [Int32](../../core/core_package_api/core_package_intrinsics.md#int32) - [套接字选项名](./net_package_structs.md#struct-optionname)。
- value: [IntNative](../../core/core_package_api/core_package_intrinsics.md#intnative) - 参数值。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `setsockopt` 返回失败时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*

// 定义Unix域套接字的文件路径
let SOCKET_PATH = "tmpsock"

main(): Int64 {
    let socket = UnixSocket(SOCKET_PATH)
    // 获取SO_REUSEADDR选项布尔值
    let reuseAddrValue = socket.getSocketOptionIntNative(OptionLevel.SOCKET, OptionName.SO_REUSEADDR)
    println("SO_REUSEADDR value before setting: ${reuseAddrValue}")
    socket.setSocketOptionIntNative(OptionLevel.SOCKET, OptionName.SO_REUSEADDR, 1)
    println(
        "SO_REUSEADDR value after setting: ${socket.getSocketOptionIntNative(OptionLevel.SOCKET, OptionName.SO_REUSEADDR)}")
    return 0
}
```

运行结果：

```text
SO_REUSEADDR value before setting: 0
SO_REUSEADDR value after setting: 1
```

### func toString()

```cangjie
public override func toString(): String
```

功能：返回当前 [UnixSocket](net_package_classes.md#class-unixsocket) 的状态信息。

> **注意：**
>
> 不支持平台：Windows。

返回值：

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - 包含当前 [UnixSocket](net_package_classes.md#class-unixsocket) 状态信息的字符串。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.sync.*
import std.fs.*

// 定义Unix域套接字的文件路径
let SOCKET_PATH = "tmpsock"
// 初始化屏障，用于协调主线程和服务器线程的同步（需要等待2个线程）
let barrier = Barrier(2)

// 定义Unix域套接字服务器的执行函数
func runUnixServer() {
    // 创建Unix服务器套接字实例，绑定到指定路径，自动执行 close 函数
    try (serverSocket = UnixServerSocket(bindAt: SOCKET_PATH)) {
        // 将服务器套接字绑定到文件系统路径
        serverSocket.bind()
        // 通知主线程服务器已准备就绪
        barrier.wait()

        // 阻塞等待客户端连接，接受连接后创建客户端通信实例
        try (client = serverSocket.accept()) {
            // 不做任何事情
        }
    }
}

main(): Int64 {
    // 启动前清理残留的套接字文件（避免绑定失败）
    removeIfExists(SOCKET_PATH)

    // 启动新线程运行服务器函数，返回Future对象用于等待线程结束
    let fut = spawn {
        runUnixServer()
    }

    // 等待服务器完成初始化并绑定端口
    barrier.wait()

    // 创建Unix客户端套接字实例，连接到指定路径
    try (socket = UnixSocket(SOCKET_PATH)) {
        // 打印 UnixSocket
        println("Socket: ${socket.toString()}")
        // 连接到服务器端套接字
        socket.connect()

        // 打印 UnixSocket
        println("Socket: ${socket.toString()}")
    }

    // 等待服务器线程执行完成
    fut.get()
    // 程序结束后清理套接字文件
    removeIfExists(SOCKET_PATH)
    return 0
}
```

运行结果：

```text
Socket: UnixSocket(unconnected, unbound)
Socket: UnixSocket( -> tmpsock)
```

### func write(Array\<Byte>)

```cangjie
public override func write(buffer: Array<Byte>): Unit
```

功能：读取写入。超时情况按 `writeTimeout` 决定，详见 `writeTimeout`。

> **注意：**
>
> 不支持平台：Windows。

参数：

- buffer: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 写入的数据存储变量。

异常：

- [SocketException](net_package_exceptions.md#class-socketexception) - 当 `buffer` 大小为 0 时抛出异常，当因系统原因写入失败时，抛出异常。

示例：

<!-- verify -->
```cangjie
import std.net.*
import std.sync.*
import std.fs.*

// 定义Unix域套接字的文件路径
let SOCKET_PATH = "tmpsock"
// 初始化屏障，用于协调主线程和服务器线程的同步（需要等待2个线程）
let barrier = Barrier(2)

// 定义Unix域套接字服务器的执行函数
func runUnixServer() {
    // 创建Unix服务器套接字实例，绑定到指定路径，自动执行 close 函数
    try (serverSocket = UnixServerSocket(bindAt: SOCKET_PATH)) {
        // 将服务器套接字绑定到文件系统路径
        serverSocket.bind()
        // 通知主线程服务器已准备就绪
        barrier.wait()

        // 阻塞等待客户端连接，接受连接后创建客户端通信实例
        try (client = serverSocket.accept()) {
            // 读取客户端发送的数据
            let buffer = Array<Byte>(14, repeat: 0)
            let bytesRead = client.read(buffer)
            println("Server received ${bytesRead} bytes: ${String.fromUtf8(buffer)}")
        }
    }
}

main(): Int64 {
    // 启动前清理残留的套接字文件（避免绑定失败）
    removeIfExists(SOCKET_PATH)

    // 启动新线程运行服务器函数，返回Future对象用于等待线程结束
    let fut = spawn {
        runUnixServer()
    }

    // 等待服务器完成初始化并绑定端口
    barrier.wait()

    // 创建Unix客户端套接字实例，连接到指定路径
    try (socket = UnixSocket(SOCKET_PATH)) {
        // 连接到服务器端套接字
        socket.connect()

        // 发送数据到服务器
        let data = "Hello, server!".toArray()
        socket.write(data)
        println("Client sent data: ${String.fromUtf8(data)}")
    }

    // 等待服务器线程执行完成
    fut.get()
    // 程序结束后清理套接字文件
    removeIfExists(SOCKET_PATH)
    return 0
}
```

运行结果：

```text
Client sent data: Hello, server!
Server received 14 bytes: Hello, server!
```

## class UnixSocketAddress

```cangjie
public class UnixSocketAddress <: SocketAddress & Equatable<UnixSocketAddress> {
    public init(path: Array<Byte>)
    public init(path: String)
}
```

功能：此类实现了 Unix Domain Socket 地址，Unix Domain Socket 地址封装了 Unix Domain Socket 绑定或连接到的文件系统路径，路径长度不可超过 108。

如果路径是空字符串，那么表示它是 `unnamed` 地址，如果路径以 `\0` 开头，那么它是 `abstract` 地址。路径中间不可包含 `\0`。

父类型：

- [SocketAddress](#class-socketaddress)
- [Equatable](../../core/core_package_api/core_package_interfaces.md#interface-equatablet)\<[UnixSocketAddress](#class-unixsocketaddress)>

### prop family

```cangjie
public prop family: AddressFamily
```

功能：获取当前 [UnixSocketAddress](net_package_classes.md#class-unixsocketaddress) 对象的地址族，总是 [AddressFamily.UNIX](net_package_structs.md#static-const-unix)。

类型：[AddressFamily](net_package_structs.md#struct-addressfamily)

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    // 创建UnixSocketAddress实例
    let address = UnixSocketAddress("/tmp/test.sock")

    // 获取并打印地址族
    println("Address family: ${address.family}")

    return 0
}
```

运行结果：

```text
Address family: UNIX
```

### prop size

```cangjie
public prop size: Int64
```

功能：获取当前 [UnixSocketAddress](net_package_classes.md#class-unixsocketaddress) 对象的原始字节长度。

类型：[Int64](../../core/core_package_api/core_package_intrinsics.md#int64)

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    // 创建UnixSocketAddress实例
    let address = UnixSocketAddress("/tmp/test.sock")

    // 获取并打印地址大小
    println("Address size: ${address.size}")

    return 0
}
```

运行结果：

```text
Address size: 16
```

### init(Array\<Byte>)

```cangjie
public init(path: Array<Byte>)
```

功能：根据 [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> 表示的文件系统路径构造 [UnixSocketAddress](net_package_classes.md#class-unixsocketaddress) 地址。

参数：

- path: [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)>  - 文件系统路径字节数组。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 如果 address 不合法，抛出异常。

示例：

<!-- run -->
```cangjie
import std.net.*

main(): Int64 {
    // 创建路径字符串并转换为字节数组
    let path = "/tmp/test.sock"
    let pathBytes = path.toArray()

    // 使用字节数组初始化UnixSocketAddress
    let address = UnixSocketAddress(pathBytes)
    return 0
}
```

### init(String)

```cangjie
public init(path: String)
```

功能：根据字符串表示的文件系统路径构造 [UnixSocketAddress](net_package_classes.md#class-unixsocketaddress) 地址。

参数：

- path: [String](../../core/core_package_api/core_package_structs.md#struct-string) - 文件系统路径字符串。

异常：

- [IllegalArgumentException](../../core/core_package_api/core_package_exceptions.md#class-illegalargumentexception) - 如果 address 不合法，抛出异常。

示例：

<!-- run -->
```cangjie
import std.net.*

main(): Int64 {
    // 使用字符串初始化UnixSocketAddress
    let address = UnixSocketAddress("/tmp/test.sock")
    return 0
}
```

### func getAddressBytes()

```cangjie
public func getAddressBytes(): Array<Byte>
```

功能：返回此 [UnixSocketAddress](net_package_classes.md#class-unixsocketaddress) 对象的原始 IP 地址，内容布局与 `sockaddr_un` 形式一致。

返回值：

- [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> - 原始 IP 地址的 [Array](../../core/core_package_api/core_package_structs.md#struct-arrayt)\<[Byte](../../core/core_package_api/core_package_types.md#type-byte)> 表示。

示例：
<!-- verify -->

```cangjie
import std.net.*

main() {
    let udsa1_1: UnixSocketAddress = UnixSocketAddress("/tmp/server1.sock")
    println("getAddressBytes: ${udsa1_1.getAddressBytes()}")
}
```

运行结果：

```text
getAddressBytes: [1, 0, 47, 116, 109, 112, 47, 115, 101, 114, 118, 101, 114, 49, 46, 115, 111, 99, 107]
```

### func hashCode()

```cangjie
public func hashCode(): Int64
```

功能：获取 `hashcode` 值。

返回值：

- [Int64](../../core/core_package_api/core_package_intrinsics.md#int64) - `hashcode` 值。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    // 创建两个相同的UnixSocketAddress实例
    let address1 = UnixSocketAddress("/tmp/test.sock")
    let address2 = UnixSocketAddress("/tmp/test.sock")

    // 获取并打印它们的哈希码
    let hashCode1 = address1.hashCode()
    let hashCode2 = address2.hashCode()

    println("Address1 hash code: ${hashCode1}")
    println("Address2 hash code: ${hashCode2}")
    println("Hash codes are equal: ${hashCode1 == hashCode2}")

    // 创建一个不同的UnixSocketAddress实例
    let address3 = UnixSocketAddress("/tmp/different.sock")
    let hashCode3 = address3.hashCode()

    println("Address3 hash code: ${hashCode3}")
    println("Hash codes are different: ${hashCode1 != hashCode3}")

    return 0
}
```

运行结果：

```text
Address1 hash code: -2354592085984306885
Address2 hash code: -2354592085984306885
Hash codes are equal: true
Address3 hash code: 1641152762756665255
Hash codes are different: true
```

### func toString()

```cangjie
public func toString(): String
```

功能：返回当前 [UnixSocketAddress](net_package_classes.md#class-unixsocketaddress) 的文本表示字符串。

返回值：

- [String](../../core/core_package_api/core_package_structs.md#struct-string) - 当前 [UnixSocketAddress](net_package_classes.md#class-unixsocketaddress) 的文本表示字符串，比如 `/tmp/socket1` 。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    // 创建不同的UnixSocketAddress实例
    let address1 = UnixSocketAddress("/tmp/server1.sock")
    let address2 = UnixSocketAddress("/tmp/server1.sock".toArray())

    // 使用toString()方法并打印结果
    println("Address1 toString: ${address1.toString()}")
    println("Address2 toString: ${address2.toString()}")

    // 比较相同路径的地址
    println("Address1 equals Address2: ${address1.toString() == address2.toString()}")

    try {
        UnixSocketAddress("/tmp/server1\u{0}.sock")
    } catch (e: IllegalArgumentException) {
        println("Exception caught: ${e.message}")
    }
    return 0
}
```

运行结果：

```text
Address1 toString: /tmp/server1.sock
Address2 toString: /tmp/server1.sock
Address1 equals Address2: true
Exception caught: Unix domain socket path must not contain interior null bytes: '[47, 116, 109, 112, 47, 115, 101, 114, 118, 101, 114, 49, 0, 46, 115, 111, 99, 107]'.
```

### operator func !=(UnixSocketAddress)

```cangjie
public operator func !=(other: UnixSocketAddress): Bool
```

功能：判断两个 [UnixSocketAddress](net_package_classes.md#class-unixsocketaddress) 对象是否不等。

参数：

- other: [UnixSocketAddress](net_package_classes.md#class-unixsocketaddress) - 参与比较的 [UnixSocketAddress](net_package_classes.md#class-unixsocketaddress) 对象。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 如果两个 [UnixSocketAddress](net_package_classes.md#class-unixsocketaddress) 对象不等，则返回 `true`；否则，返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    // 创建两个相同的UnixSocketAddress实例
    let address1 = UnixSocketAddress("/tmp/test.sock")
    let address2 = UnixSocketAddress("/tmp/test.sock")

    // 使用!=操作符比较它们
    let areNotEqual = address1 != address2
    println("Address1 != Address2: ${areNotEqual}")

    // 创建一个不同的UnixSocketAddress实例
    let address3 = UnixSocketAddress("/tmp/different.sock")

    // 使用!=操作符比较不同的地址
    let areDifferent = address1 != address3
    println("Address1 != Address3: ${areDifferent}")

    return 0
}
```

运行结果：

```text
Address1 != Address2: false
Address1 != Address3: true
```

### operator func ==(UnixSocketAddress)

```cangjie
public operator func ==(other: UnixSocketAddress): Bool
```

功能：判断两个 [UnixSocketAddress](net_package_classes.md#class-unixsocketaddress) 对象是否相等。

参数：

- other: [UnixSocketAddress](net_package_classes.md#class-unixsocketaddress) - 参与比较的 [UnixSocketAddress](net_package_classes.md#class-unixsocketaddress) 对象。

返回值：

- [Bool](../../core/core_package_api/core_package_intrinsics.md#bool) - 如果两个 [UnixSocketAddress](net_package_classes.md#class-unixsocketaddress) 对象相等，则返回 `true`；否则，返回 `false`。

示例：

<!-- verify -->
```cangjie
import std.net.*

main(): Int64 {
    // 创建两个相同的UnixSocketAddress实例
    let address1 = UnixSocketAddress("/tmp/test.sock")
    let address2 = UnixSocketAddress("/tmp/test.sock")

    // 使用==操作符比较它们
    let areEqual = address1 == address2
    println("Address1 == Address2: ${areEqual}")

    // 创建一个不同的UnixSocketAddress实例
    let address3 = UnixSocketAddress("/tmp/different.sock")

    // 使用==操作符比较不同的地址
    let areDifferent = address1 == address3
    println("Address1 == Address3: ${areDifferent}")

    return 0
}
```

运行结果：

```text
Address1 == Address2: true
Address1 == Address3: false
```
