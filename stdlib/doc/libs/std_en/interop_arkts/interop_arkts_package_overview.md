# std.interop.arkts

## Introduction

The interop.arkts package defines only the root interface of the ArkTS interop type system:

1. `ArkTSType`: the root interface of all ArkTS interop types, with no members.

The compiler recognises the interface by package: only an `ArkTSType` declared in `std.interop.arkts` is treated as the preset root interface; a declaration with the same name in another package is an ordinary type and is unaffected.

When `ArkTSType` appears in an `@ArkTS foreign` signature position (a parameter, the return value, or a nested position), the compiler rejects the usage and reports that the reference semantics of the type are unavailable.

The build produces and installs `std.interop.arkts.cjo` and the static library `libcangjie-std-interop.arkts.a`.

## API List

### Interfaces

| Interface | Description |
| --- | --- |
| [ArkTSType](./interop_arkts_package_api/interop_arkts_package_interfaces.md#interface-arktstype) | The root interface of all ArkTS interop types. |
