# std.interop.arkts

## Introduction

The interop.arkts package provides the standard-library preset types for ArkTS interoperability, so that later versions can refer to them across the boundary in `@ArkTS` declarations (this version ships the declarations only; see the signature-position rule below):

1. `ArkTSType`: the root interface of all ArkTS interop types, by design mapped bidirectionally to the ArkTS `unknown` type;
2. `ArkTSArray<T>`: the Cangjie-side type of an ArkTS `Array<T>`/`T[]` object;
3. `ArkTSString`: the Cangjie-side type of an ArkTS `string`;
4. `ArkTSFunc<F>` and `ArkTSFuncWithThis<ThisT, F>`: the Cangjie-side types of ArkTS function values.

The compiler treats this package as a preset declaration package: `ArkTSArray`, `ArkTSString` and `ArkTSType` declared in `std.interop.arkts` are recognised as the preset external ArkTS types; declarations with the same names in other packages stay ordinary types and are unaffected.

This version ships the package as declarations only: the build produces and installs `std.interop.arkts.cjo` (and the LTO bitcode) but no linkable shared or static library; the library targets return when the member implementations land in a later release.

This version ships the preset declarations; the reference semantics and member-level conversion arrive in a later release and are not implemented yet. When one of the three preset types above (`ArkTSArray`, `ArkTSString` or `ArkTSType`) appears in an `@ArkTS foreign` signature position (a parameter, the return value, or a nested position), the compiler rejects the usage and reports that the reference semantics of that type is not available in this version. `ArkTSFunc` and `ArkTSFuncWithThis` are not among these three preset types and do not follow that path; their signature positions are rejected as ordinary unsupported types, with a position-specific message.

Cross-boundary runtime contract: interoplib (`ohos.ark_interop`) guarantees the rooting of temporary `JSValue` values and the translation of ArkTS exceptions into Cangjie exceptions; generated interop code does not insert explicit root operations or try-catch blocks. GC root registration and release, cross-language ownership, and thread constraints are defined in a later release and are not defined in this version.

## API List

### Interfaces

| Interface | Description |
| --- | --- |
| [ArkTSType](./interop_arkts_package_api/interop_arkts_package_interfaces.md#interface-arktstype) | The root interface of all ArkTS interop types. |

### Classes

| Class | Description |
| --- | --- |
| [ArkTSArray\<T>](./interop_arkts_package_api/interop_arkts_package_classes.md#class-arktsarrayt) | The Cangjie-side type of an ArkTS array object. |
| [ArkTSString](./interop_arkts_package_api/interop_arkts_package_classes.md#class-arktsstring) | The Cangjie-side type of an ArkTS string object. |
| [ArkTSFunc\<F>](./interop_arkts_package_api/interop_arkts_package_classes.md#class-arktsfuncf) | The Cangjie-side type of an ArkTS function value. |
| [ArkTSFuncWithThis\<ThisT, F>](./interop_arkts_package_api/interop_arkts_package_classes.md#class-arktsfuncwiththisthist-f) | The Cangjie-side type of an ArkTS function value with a `this` parameter. |
