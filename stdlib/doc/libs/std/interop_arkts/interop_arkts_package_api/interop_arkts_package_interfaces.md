# 接口

## interface ArkTSType

```cangjie
public interface ArkTSType {}
```

功能：所有 ArkTS 互操作类型的根接口。

设计目标是让该接口与 ArkTS 的 `unknown` 双向映射：满足 `ArkTSType` 约束的值可以赋给该类型的变量。该映射关系将在后续版本提供。

本版本只按包名识别预置类型，用户包自行实现 `ArkTSType` 不会获得预置类型的跨边界行为。

本版本内，`ArkTSType` 出现在 `@ArkTS foreign` 签名位置（参数、返回值或嵌套位置）时，编译器会拒绝该用法，并提示该类型的引用语义在当前版本不可用。

带 `@ArkTS` 注解的类型隐式实现该接口的关系将在后续版本提供，当前版本不保证。该类型的值不支持动态成员访问。
