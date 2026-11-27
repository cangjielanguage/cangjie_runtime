# 接口

## interface ArkTSType

```cangjie
public interface ArkTSType {}
```

功能：所有 ArkTS 互操作类型的根接口，无成员。

编译器只按包名识别预置类型：只有声明在 `std.interop.arkts` 包中的 `ArkTSType` 是预置根接口；用户包自行实现 `ArkTSType` 不会获得预置类型的跨边界行为。

`ArkTSType` 出现在 `@ArkTS foreign` 签名位置（参数、返回值或嵌套位置）时，编译器拒绝该用法，并报告该类型的引用语义不可用。

带 `@ArkTS` 注解的类型不会隐式实现该接口。该类型的值不支持动态成员访问。
