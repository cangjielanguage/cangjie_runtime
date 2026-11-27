# Interfaces

## interface ArkTSType

```cangjie
public interface ArkTSType {}
```

Description: the root interface of all ArkTS interop types, with no members.

The compiler recognizes the preset type by package name only: only an `ArkTSType` declared in `std.interop.arkts` is the preset root interface; a user package implementing `ArkTSType` gains no preset cross-boundary behavior.

When an `ArkTSType` appears in an `@ArkTS foreign` signature position (a parameter, the return value, or a nested position), the compiler rejects the usage and reports that the reference semantics of that type are unavailable.

Types annotated with `@ArkTS` do not implicitly implement this interface. Values of this type do not support dynamic member access.
