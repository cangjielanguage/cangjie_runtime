# std.interop.arkts

## 功能介绍

interop.arkts 包提供 ArkTS 互操作的标准库预置类型，供后续版本在 `@ArkTS` 声明的跨边界签名中引用（本版本只交付声明，签名位用法见下）：

1. `ArkTSType`：所有 ArkTS 互操作类型的根接口，设计上与 ArkTS 的 `unknown` 双向映射；
2. `ArkTSArray<T>`：ArkTS `Array<T>`/`T[]` 对象的仓颉侧类型；
3. `ArkTSString`：ArkTS `string` 的仓颉侧类型；
4. `ArkTSFunc<F>`、`ArkTSFuncWithThis<ThisT, F>`：ArkTS 函数类型的仓颉侧类型。

该包由编译器作为预置声明包识别：声明在 `std.interop.arkts` 包中的 `ArkTSArray`、`ArkTSString`、`ArkTSType` 才会被当作预置的外部 ArkTS 类型；其它包中的同名声明仍按普通类型处理，不受影响。

本版本该包为声明-only：构建只产出并安装 `std.interop.arkts.cjo`（以及 LTO 位码），不提供可链接的共享库或静态库；成员实现将在后续版本提供，届时再恢复库目标。

本版本交付的是预置声明，引用语义与成员级转换尚未实现，将在后续版本提供。上述三个预置类型（`ArkTSArray`/`ArkTSString`/`ArkTSType`）出现在 `@ArkTS foreign` 签名位置（参数、返回值或嵌套位置）时，编译器会拒绝该用法，并提示该类型的引用语义在当前版本不可用。`ArkTSFunc`/`ArkTSFuncWithThis` 不属于上述三个预置类型，不走这条提示；它们的签名位按普通的不支持类型处理，参数位置与返回值位置都会被拒绝，并按位置给出提示。

跨边界运行时契约：临时 `JSValue` 的 rooting 与 ArkTS 异常到仓颉异常的翻译由 interoplib（`ohos.ark_interop`）保证；生成的互操作代码不额外插入显式的 root 操作，但会把跨边界调用包在 `try/catch (BusinessException)` 中：仅当异常码为库外部错误或 ArkTS 侧抛出时，才翻译为仓颉异常后重新抛出；其余 `BusinessException` 保留原类型、错误码与消息直接抛出。GC 根的登记与释放、跨语言所有权以及线程约束将在后续版本定义。

## API 列表

### 接口

| 接口名 | 功能 |
| --- | --- |
| [ArkTSType](./interop_arkts_package_api/interop_arkts_package_interfaces.md#interface-arktstype) | 所有 ArkTS 互操作类型的根接口。 |

### 类

| 类名 | 功能 |
| --- | --- |
| [ArkTSArray\<T\>](./interop_arkts_package_api/interop_arkts_package_classes.md#class-arktsarrayt) | ArkTS 数组对象的仓颉侧类型。 |
| [ArkTSString](./interop_arkts_package_api/interop_arkts_package_classes.md#class-arktsstring) | ArkTS 字符串对象的仓颉侧类型。 |
| [ArkTSFunc\<F\>](./interop_arkts_package_api/interop_arkts_package_classes.md#class-arktsfuncf) | ArkTS 函数值的仓颉侧类型。 |
| [ArkTSFuncWithThis\<ThisT, F\>](./interop_arkts_package_api/interop_arkts_package_classes.md#class-arktsfuncwiththisthist-f) | 带 `this` 参数的 ArkTS 函数值的仓颉侧类型。 |
