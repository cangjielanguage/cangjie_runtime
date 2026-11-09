# Interfaces

## interface ArkTSType

```cangjie
@ArkTS
public interface ArkTSType {}
```

Description: the root interface of all ArkTS interop types.

The design goal is a bidirectional mapping between this interface and the ArkTS `unknown` type: a value that satisfies the `ArkTSType` constraint can be assigned to a variable of this type. That mapping comes with AR-05/06.

Within AR-03, when an `ArkTSType` appears in an `@ArkTS foreign` signature position (a parameter, the return value, or a nested position), the compiler rejects the usage and reports that the reference semantics of that type is not available in this version.

The relation that types annotated with `@ArkTS` implicitly implement this interface also comes with AR-05/06 and is not guaranteed in this version. Values of this type do not support dynamic member access.
