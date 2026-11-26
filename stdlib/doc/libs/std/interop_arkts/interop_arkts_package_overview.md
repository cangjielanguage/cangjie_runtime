# std.interop.arkts

## 功能介绍

interop.arkts 包提供 ArkTS 互操作的标准库预置类型，供在 `@ArkTS` 声明的跨边界签名中引用（本版本交付 `ArkTSArray<T>` 与 `ArkTSString` 的成员实现，签名位用法见下）：

1. `ArkTSType`：所有 ArkTS 互操作类型的根接口，设计上与 ArkTS 的 `unknown` 双向映射；
2. `ArkTSArray<T>`：ArkTS `Array<T>`/`T[]` 对象的仓颉侧类型；
3. `ArkTSString`：ArkTS `string` 的仓颉侧类型；
4. `ArkTSFunc<F>`、`ArkTSFuncWithThis<ThisT, F>`：ArkTS 函数类型的仓颉侧类型；
5. `ExternConversionException`：跨边界转换失败时抛出的具名异常，普通公开类，不属于上述预置外部 ArkTS 类型。

该包由编译器作为预置声明包识别：声明在 `std.interop.arkts` 包中的 `ArkTSArray`、`ArkTSString`、`ArkTSType` 才会被当作预置的外部 ArkTS 类型；其它包中的同名声明仍按普通类型处理，不受影响。

`ExternConversionException` 由本包宿主：编译器生成的预置包装体（属于本包）直接引用该类型而无需任何导入，`arkts.lang` 门面通过其 `public import std.interop.arkts.*` 把它再导出给应用；门面自身不声明该类型。把它声明在门面里会让预置包装体反过来导入 `arkts.lang`，而 `arkts.lang` 依赖本包，形成同包循环。注意 `std.core` 的 `Extern` 机制也有同名异常（`env != "ohos"` 时存在）：显式导入的本包/门面名字优先于隐式预导入的 `std.core`；编译器生成的代码始终以单成员导入加私有别名绑定，不受影响。

本版本交付成员实现：`ArkTSString` 的成员体由编译器在预置包装上生成，`ArkTSArray<T>` 的成员体由本包源码实现（编译器安装引用存储），构建产出并安装 `std.interop.arkts.cjo` 与静态库。`ArkTSType`/`ArkTSFuncWithThis` 保持声明形态；静态成员与其余设计成员将在后续版本提供，届时恢复库目标。

`ArkTSArray<T>` 与 `ArkTSString` 本版本交付引用语义与成员级转换：二者出现在 `@ArkTS foreign` 签名位置（参数、返回值或嵌套位置）时按预置包装映射，元素/内容转换分别走 `JSInteropType` 运行时契约与 `ctx.string` 构造。`ArkTSType` 的签名位映射仍未交付：它出现在上述位置时编译器会拒绝该用法，并提示该类型的引用语义在当前版本不可用。`ArkTSFunc`/`ArkTSFuncWithThis` 不属于上述三个预置类型，不走这条提示；它们的签名位按普通的不支持类型处理，参数位置与返回值位置都会被拒绝，并按位置给出提示。

跨边界运行时契约：临时 `JSValue` 的 rooting 与 ArkTS 异常到仓颉异常的翻译由 interoplib（`ohos.ark_interop`）保证；生成的互操作代码不额外插入显式的 root 操作，但会把跨边界调用包在 `try/catch (BusinessException)` 中：仅当异常码为库外部错误或 ArkTS 侧抛出时，才翻译为仓颉异常后重新抛出；其余 `BusinessException` 保留原类型、错误码与消息直接抛出。GC 根的登记与释放、跨语言所有权以及线程约束将在后续版本定义。

## API 列表

### 接口

| 接口名 | 功能 |
| --- | --- |
| [ArkTSType](./interop_arkts_package_api/interop_arkts_package_interfaces.md#interface-arktstype) | 所有 ArkTS 互操作类型的根接口。 |

### 类

| 类名 | 功能 |
| --- | --- |
| [ArkTSArray\<T>](./interop_arkts_package_api/interop_arkts_package_classes.md#class-arktsarrayt) | ArkTS 数组对象的仓颉侧类型。 |
| [ArkTSString](./interop_arkts_package_api/interop_arkts_package_classes.md#class-arktsstring) | ArkTS 字符串对象的仓颉侧类型。 |
| [ArkTSFunc\<F>](./interop_arkts_package_api/interop_arkts_package_classes.md#class-arktsfuncf) | ArkTS 函数值的仓颉侧类型。 |
| [ArkTSFuncWithThis\<ThisT, F>](./interop_arkts_package_api/interop_arkts_package_classes.md#class-arktsfuncwiththisthist-f) | 带 `this` 参数的 ArkTS 函数值的仓颉侧类型。 |
| [ExternConversionException](./interop_arkts_package_api/interop_arkts_package_classes.md#class-externconversionexception) | 跨边界转换失败时抛出的具名异常，经 `arkts.lang` 再导出。 |
