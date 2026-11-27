# std.interop.arkts

## 功能介绍

interop.arkts 包只定义 ArkTS 互操作类型体系的根接口：

1. `ArkTSType`：所有 ArkTS 互操作类型的根接口，无成员。

该包由编译器识别：只有声明在 `std.interop.arkts` 包中的 `ArkTSType` 才会被当作预置的根接口；其它包中的同名声明按普通类型处理，不受影响。

`ArkTSType` 出现在 `@ArkTS foreign` 签名位置（参数、返回值或嵌套位置）时，编译器拒绝该用法并报告该类型的引用语义不可用。

构建产出并安装 `std.interop.arkts.cjo` 与静态库 `libcangjie-std-interop.arkts.a`。

## API 列表

### 接口

| 接口名 | 功能 |
| --- | --- |
| [ArkTSType](./interop_arkts_package_api/interop_arkts_package_interfaces.md#interface-arktstype) | 所有 ArkTS 互操作类型的根接口。 |
