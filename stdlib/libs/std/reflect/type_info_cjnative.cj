/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.reflect

import std.collection.*
import std.sync.*

const UUID_OFFSET: Int64 = 24
let TYPE_INFO_CREATE_LOCK = Mutex()

class TypeTemplate {
    protected let _info: CPointer<Unit>
    init(info: CPointer<Unit>) {
        _info = info
    }

    static func get(typeinfoName: String): TypeTemplate {
        let replacedName = typeinfoName.replace("::", "/")
        let name = if (replacedName.contains(".")) {
            unsafe { LibC.mallocCString(replacedName) }
        } else {
            unsafe { LibC.mallocCString("std.core." + replacedName) }
        }
        let info = getTypeTemplate(name.getChars())
        unsafe { LibC.free(name) }
        TypeTemplate(info)
    }

    prop info: CPointer<Unit> {
        get() {
            _info
        }
    }
}

class TypeTemplateParser {
    var templates = ArrayList<String>()
    var data = ArrayList<ArrayList<String>>()
    var map = HashMap<String, CPointer<Unit>>()
    func parse(string: String): TypeInfo {
        let name = unsafe { string.rawData() }
        var idx = 0
        while (idx < name.size && name[idx] != b'<') {
            idx += 1
        }
        let templateName = String.fromUtf8(name[0..idx]).trimAscii()
        parseGenericString(name, idx + 1, name.size, templateName)
        for (i in 0..templates.size) {
            let tt = templates[i]
            let template = TypeTemplate.get(tt)
            if (template._info.isNull() || data.size <= i) {
                throw InfoNotFoundException("TypeInfo '${string}' not found.")
            }
            let genericParams = ArrayList<CPointer<Unit>>(data[i].size) {
                j =>
                    let typeStr = data[i][j]
                    if (typeStr.contains("<")) {
                        map.get(typeStr) ?? throw InfoNotFoundException("TypeInfo '${typeStr}' not found.")
                    } else {
                        TypeInfo.get(typeStr)._info
                    }
            }
            let info = getOrCreateTypeInfoForReflect(template.info, genericParams.toArray())
            if (info.isNull()) {
                throw InfoNotFoundException("Cannot find '${tt}'.")
            }
            let qualifiedName = tt + "<" + String.join(data[i].toArray(), delimiter: ",") + ">"
            map.add(qualifiedName, info)

            if (i == templates.size - 1) {
                return TypeInfo.getOrCreate(info)
            }
        }
        throw InfoNotFoundException("Cannot find '${name}'.")
    }

    func parseGenericString(name: Array<Byte>, begin: Int64, end: Int64, templateName: String): Int64 {
        if (begin >= end) {
            return end
        }
        var strs: ArrayList<String> = ArrayList<String>()
        var start = begin
        var idx = begin
        while (idx < end) {
            if (name[idx] == b'<') {
                let nestedTemplateName = String.fromUtf8(name[start..idx]).trimAscii()
                idx = parseGenericString(name, idx + 1, end, nestedTemplateName)
            } else if (name[idx] == b'>') {
                strs.add(String.fromUtf8(name[start..idx]).trimAscii())
                templates.add(templateName)
                data.add(strs)
                return idx
            } else if (name[idx] == b',') {
                strs.add(String.fromUtf8(name[start..idx]).trimAscii())
                start = idx + 1
            }
            idx += 1
        }
        return end
    }
}

class InheritedAndExtendedMembers {}

/**
 * Contains the reflective information that is common for classes, interfaces, structs and primitive types.
 */
sealed abstract class TypeInfo <: Equatable<TypeInfo> & Hashable & ToString {
    private static let CACHE = HashMap<String, TypeInfo>()
    // Pointer-keyed integer memo consulted while holding TYPE_INFO_CREATE_LOCK. Keyed by
    // the type-metadata address so a steady-state hit avoids the per-call uuid.toString()
    // allocation and String hashing of the string cache.
    //
    // COMPATIBILITY-SAFE: loaded TypeInfo metadata carries a monotonically allocated UUID at
    // UUID_OFFSET (see runtime/src/TypeInfoManager.cpp, tiMaxUUID). On a PTR_MEMO hit we re-read
    // that UUID and compare it with the value captured when the entry was inserted; a mismatch
    // means the metadata address was reused after an UnloadCJLibrary(dlclose)+reload, so the
    // cached wrapper is stale. We then invalidate EVERY cache entry that aliases it - the
    // pointer memo (PTR_MEMO / PTR_MEMO_UUID) and the string cache CACHE (keyed by the captured
    // uuid and by the qualified name) - so the normal path rebuilds a fresh wrapper from current
    // metadata instead of returning the stale one. This keeps the published
    // UnloadCJLibrary/unload-reload flow correct and preserves the performance win: a
    // steady-state hit only pays a 4-byte aligned native read + Int32 compare instead of
    // uuid.toString() + String hashing.
    //
    // A zero UUID can never prove identity and is never trusted. Runtime creation now assigns a
    // monotonic UUID to every instantiation (including generic CFuncs, which are registered by
    // CreatedTypeInfoImpl's IsCFunc branch), but metadata produced outside that path, or by an
    // older runtime, can still carry 0. Trusting it would let a reused address whose previous
    // occupant also had UUID 0 accept the stale wrapper (0 == 0). UUID 0 therefore always takes
    // the isGeneric/qualifiedName path, exactly as such types were resolved before this memo.
    //
    // Background: the metadata address is otherwise stable for the process lifetime for standard
    // Cangjie applications (no module unload; PackageInfo.load has no unload counterpart), so the
    // recheck almost always passes and the cache behaves exactly as before. If module unload is
    // ever made first-class, a PTR_MEMO/CACHE invalidation hook on the unload notification chain
    // is the alternative (stronger) fix; with both the pointer memo and the string cache
    // invalidated on a UUID mismatch, the recheck below neutralizes the correctness risk (silent
    // type confusion / use-after-free on address reuse) that an address reuse would otherwise
    // introduce.
    private static let PTR_MEMO = HashMap<UIntNative, TypeInfo>()
    // UUID captured alongside each PTR_MEMO entry, used to validate hits after address reuse.
    private static let PTR_MEMO_UUID = HashMap<UIntNative, Int32>()

    // this is a pointer to type metadata
    protected let _info: CPointer<Unit>
    var _qualifiedName: Option<String> = None
    var _name: Option<String> = None

    var _instanceFunctions: Option<Collection<InstanceFunctionInfo>> = None
    var _staticFunctions: Option<Collection<StaticFunctionInfo>> = None

    var _instanceProperties: Option<Collection<InstancePropertyInfo>> = None
    var _staticProperties: Option<Collection<StaticPropertyInfo>> = None

    var _annotations: Option<Collection<Annotation>> = None
    var _superInterfaces: Option<Collection<InterfaceTypeInfo>> = None
    var _modifiers: Option<Collection<ModifierInfo>> = None
    var typeTemplate: TypeTemplate = TypeTemplate(CPointer<Unit>())
    var genericParams: Array<TypeInfo> = Array<TypeInfo>()

    var _inheritedAndExtendedMembers: InheritedAndExtendedMembers = InheritedAndExtendedMembers()

    var _replacedName: Option<String> = None

    init(cp: CPointer<Unit>) {
        _info = cp
    }

    /**
     * Creates the certain type info by generic type T.
     */
    public static func of<T>(): TypeInfo {
        getOrCreate(getTypeByMangledName<T>())
    }

    /**
     * Creates the certain type info for incoming instance with 'Any' type.
     */
    public static func of(a: Any): TypeInfo {
        var ti = getTypeForAny(a)
        if ((isEnum(ti) || isFunction(ti)) && let sti <- getSuperTypeInfo(ti)) {
            if (!sti.isNull()) {
                ti = sti
            }
        }
        getOrCreate(ti)
    }

    /**
     * Creates the class type info for incoming instance with 'Object' type.
     */
    @Deprecated[message: "Use 'ClassTypeInfo.of(Object)' instead."]
    public static func of(a: Object): ClassTypeInfo {
        (getOrCreate(getObjClass(a)) as ClassTypeInfo) ?? throw InfoNotFoundException("TypeInfo not found.")
    }

    /**
     * Searches and creates the certain type info by incoming qualified name.
     * If no corresponding type information for incoming qualified name is found, the exception is thrown.
     */
    public static func get(qualifiedName: String): TypeInfo {
        if (qualifiedName.contains("/")) {
            throw InfoNotFoundException("TypeInfo '${qualifiedName}' not found.")
        }
        synchronized(TYPE_INFO_CREATE_LOCK) {
            let name = normalize(qualifiedName)
            if (let Some(ti) <- CACHE.get(name)) {
                return ti
            }

            if (let Some(ti) <- CACHE.get(qualifiedName)) {
                if (qualifiedName != name) {
                    CACHE.add(name, ti)
                }
                return ti
            }

            return if (!name.contains("<")) {
                let replacedName = name.replace("::", "/")
                let (realName, typeInfoPointer) = getInfoPointerByQualifiedName(replacedName)
                let newQualifiedName = realName.replace("std.core.", "")
                if (isGeneric(typeInfoPointer)) {
                    createGenericTypeInfo(typeInfoPointer, newQualifiedName)
                } else {
                    createConcreteTypeInfo(typeInfoPointer, newQualifiedName)
                }
            } else {
                TypeTemplateParser().parse(name.replace("std.core.", ""))
            }
        }
    }

    private static func stripStdCorePrefix(name: String): String {
        const prefix = "std.core."
        if (!name.contains(prefix)) {
            return name
        }

        let bytes = unsafe { name.rawData() }
        let prefixBytes = unsafe { prefix.rawData() }
        var out = ArrayList<Byte>()
        var idx: Int64 = 0
        while (idx < bytes.size) {
            if (hasPrefixAt(bytes, idx, prefixBytes) && (idx == 0 || isStdCoreBoundary(bytes[idx - 1]))) {
                idx += prefixBytes.size
                continue
            }
            out.add(bytes[idx])
            idx += 1
        }
        return String.fromUtf8(out.toArray())
    }

    private static func hasPrefixAt(bytes: Array<Byte>, start: Int64, prefix: Array<Byte>): Bool {
        if (start + prefix.size > bytes.size) {
            return false
        }
        var offset: Int64 = 0
        while (offset < prefix.size) {
            if (bytes[start + offset] != prefix[offset]) {
                return false
            }
            offset += 1
        }
        return true
    }

    private static func isStdCoreBoundary(ch: Byte): Bool {
        match (ch) {
            case b'<' => true
            case b'>' => true
            case b',' => true
            case b' ' => true
            case b'(' => true
            case b')' => true
            case b'[' => true
            case b']' => true
            case b':' => true
            case _ => false
        }
    }

    private static func normalize(qualifiedName: String): String {
        let (isPrimitive, _, _) = checkPrimitive(qualifiedName)
        // 1. primitive type should use mangled name to find type
        // 2. qualifiedName in std.core should omits prefix, but runtime need it, must complete qualifiedName here
        let stripedName = qualifiedName.replace(" ", "")
        let hasPrefix = stripedName.contains(".")
        let isGeneric = qualifiedName.contains("<")
        match ((isPrimitive, hasPrefix, isGeneric)) {
            case (true, _, _) => unsafe { stripedName }
            case (_, _, true) => unsafe { parseGeneric(stripedName) }
            case (_, false, _) => unsafe { "std.core.${stripedName}" }
            case _ => unsafe { stripedName }
        }
    }

    private static func getInfoPointerByQualifiedName(qualifiedName: String): (String, CPointer<Unit>) {
        unsafe {
            let cstring = LibC.mallocCString(qualifiedName)
            let typeInfoPointer = getTypeByQualifiedName(cstring.getChars())
            LibC.free(cstring)
            if (typeInfoPointer.isNull()) {
                let displayName = stripStdCorePrefix(qualifiedName).replace("/", "::")
                throw InfoNotFoundException("TypeInfo '${displayName}' not found.")
            }
            (qualifiedName, typeInfoPointer)
        }
    }

    // tuple and function type currently not supported
    // eg: Array<(()-> Unit, (Int64, String) -> Unit)>
    private static func parseGeneric(qualifiedName: String): String {
        var dotNum = 0
        var lastParseIdx = 0
        let sb = StringBuilder()
        var idx = 0
        while (idx < qualifiedName.size) {
            match (qualifiedName[idx]) {
                case '.' => dotNum++
                case '<' =>
                    let isPrimitive = checkPrimitive(qualifiedName[lastParseIdx..idx])[0]
                    if (dotNum == 0 && !isPrimitive && qualifiedName[lastParseIdx..idx] != "Tuple") {
                        sb.append("std.core.")
                    }
                    sb.append(qualifiedName[lastParseIdx..=idx])
                    dotNum = 0
                    lastParseIdx = idx + 1
                case '>' =>
                    let isPrimitive = checkPrimitive(qualifiedName[lastParseIdx..idx])[0]
                    if (dotNum == 0 && qualifiedName[idx - 1] != b'>' && !isPrimitive &&
                        qualifiedName[lastParseIdx..idx] != "Tuple") {
                        sb.append("std.core.")
                    }
                    sb.append(qualifiedName[lastParseIdx..=idx])
                    dotNum = 0
                    lastParseIdx = idx + 1
                case ',' =>
                    let isPrimitive = checkPrimitive(qualifiedName[lastParseIdx..idx])[0]
                    if (dotNum == 0 && !isPrimitive && qualifiedName[lastParseIdx..idx] != "Tuple") {
                        sb.append("std.core.")
                    }
                    sb.append(qualifiedName[lastParseIdx..idx])
                    sb.append(",")
                    if (idx < qualifiedName.size - 1 && qualifiedName[idx + 1] == b' ') {
                        idx++
                    }
                    dotNum = 0
                    lastParseIdx = idx + 1
                case _ => ()
            }
            idx++
        }
        sb.toString()
    }

    static func getOrCreate(typeInfoPointer: CPointer<Unit>): TypeInfo {
        if (typeInfoPointer.isNull()) {
            throw InfoNotFoundException("Failed to get TypeInfo from pointer.")
        }
        let ptrKey = typeInfoPointer.toUIntNative()
        synchronized(TYPE_INFO_CREATE_LOCK) {
            // Snapshot the metadata UUID (monotonic, assigned per load via tiMaxUUID) so a
            // reused address after UnloadCJLibrary+reload is detected on the fast path.
            let metaUUID = unsafe { CPointer<Int32>(CPointer<Byte>(typeInfoPointer) + UUID_OFFSET).read() }
            // Fast hit: the pointer-keyed memo short-circuits before any native isGeneric call,
            // qualified-name build, or uuid.toString() allocation. A cached entry is trusted only
            // when its captured UUID is non-zero and still matches the metadata at this address;
            // UUID 0 cannot prove identity (metadata created outside the registering path, or by
            // an older runtime) and must be rebuilt through the qualified-name path. On mismatch
            // or UUID 0, invalidate the pointer memo AND the string cache entries (captured uuid
            // + qualified name) that alias the stale wrapper, then rebuild a fresh one.
            if (let Some(ti) <- PTR_MEMO.get(ptrKey)) {
                let cachedUUID = PTR_MEMO_UUID.get(ptrKey)
                if (let Some(c) <- cachedUUID) {
                    if (c != 0 && c == metaUUID) {
                        return ti
                    }
                }
                // UUID mismatch (or unregistered/UUID-0 entry): the address was reused after
                // UnloadCJLibrary+reload, so the cached wrapper aliases the previous (now stale)
                // metadata. Drop it from the pointer memo and from the string cache CACHE - both
                // the captured-uuid key (when non-zero) and the qualified-name key (plus its
                // slash-to-coloncolon variant, covering the concrete path; generics are keyed
                // only by name) - so the normal path below rebuilds a fresh wrapper from current
                // metadata instead of short-circuiting on the stale CACHE entry and re-memoizing it.
                PTR_MEMO.remove(ptrKey)
                PTR_MEMO_UUID.remove(ptrKey)
                if (let Some(c) <- cachedUUID) {
                    if (c != 0) {
                        CACHE.remove(c.toString())
                    }
                }
                let staleName = getQualifiedName(typeInfoPointer)
                CACHE.remove(staleName)
                CACHE.remove(staleName.replace("/", "::"))
            }
            let isGenericTypeInfo: Bool = isGeneric(typeInfoPointer)
            let typeInfo = if (isGenericTypeInfo) {
                let qualifiedName = getQualifiedName(typeInfoPointer)
                CACHE.get(qualifiedName) ?? createGenericTypeInfo(typeInfoPointer, qualifiedName)
            } else {
                let uuid = metaUUID.toString()
                // A zero UUID cannot key the uuid cache: every unregistered type would collide
                // on "0". Fall back to the qualified name, as before the memo.
                let cached: ?TypeInfo = if (metaUUID != 0) {
                    CACHE.get(uuid)
                } else {
                    None
                }
                if (let Some(ti) <- cached) {
                    ti
                } else {
                    let qualifiedName = getQualifiedName(typeInfoPointer)
                    CACHE.get(qualifiedName) ?? createConcreteTypeInfo(typeInfoPointer, qualifiedName, uuid: uuid)
                }
            }
            // Only a non-zero UUID can ever satisfy the fast path, so a UUID-0 type must not
            // populate the memo: such an entry could never be hit, and every lookup would pay
            // two map removals plus two map insertions to discard and rebuild it.
            if (metaUUID != 0) {
                PTR_MEMO.add(ptrKey, typeInfo)
                PTR_MEMO_UUID.add(ptrKey, metaUUID)
            }
            return typeInfo
        }
    }

    static func createGenericTypeInfo(typeInfoPointer: CPointer<Unit>, qualifiedName: String): TypeInfo {
        if (qualifiedName.isEmpty()) {
            throw ReflectException("Unexpected empty 'qualifiedName'.")
        }
        let typeInfo = GenericTypeInfo(typeInfoPointer)
        CACHE.add(qualifiedName, typeInfo)
        typeInfo
    }

    @When[env != "ohos"]
    static func getTypeInfoByPointer(typeInfoPointer: CPointer<Unit>, qualifiedName: String) {
        return if (isPrimitive(typeInfoPointer)) {
            PrimitiveTypeInfo(typeInfoPointer, qualifiedName)
        } else if (isInterface(typeInfoPointer)) {
            InterfaceTypeInfo(typeInfoPointer)
        } else if (isFunction(typeInfoPointer)) {
            FunctionTypeInfo(typeInfoPointer)
        } else if (isEnum(typeInfoPointer)) {
            EnumTypeInfo(typeInfoPointer)
        } else if (isClass(typeInfoPointer)) {
            ClassTypeInfo(typeInfoPointer)
        } else if (isStruct(typeInfoPointer)) {
            StructTypeInfo(typeInfoPointer)
        } else if (isTuple(typeInfoPointer)) {
            TupleTypeInfo(typeInfoPointer)
        } else {
            throw ReflectException("Type '${qualifiedName}' is not supported.")
        }
    }

    @When[env == "ohos"]
    static func getTypeInfoByPointer(typeInfoPointer: CPointer<Unit>, qualifiedName: String) {
        return if (isPrimitive(typeInfoPointer)) {
            PrimitiveTypeInfo(typeInfoPointer, qualifiedName)
        } else if (isInterface(typeInfoPointer)) {
            InterfaceTypeInfo(typeInfoPointer)
        } else if (isClass(typeInfoPointer)) {
            ClassTypeInfo(typeInfoPointer)
        } else if (isStruct(typeInfoPointer)) {
            StructTypeInfo(typeInfoPointer)
        } else {
            throw ReflectException("Type '${qualifiedName}' is not supported.")
        }
    }

    static func createConcreteTypeInfo(typeInfoPointer: CPointer<Unit>, qualifiedName: String, uuid!: ?String = None): TypeInfo {
        if (qualifiedName.isEmpty()) {
            throw ReflectException("Unexpected empty 'qualifiedName'.")
        }

        let typeInfo = TypeInfo.getTypeInfoByPointer(typeInfoPointer, qualifiedName)

        let uuidStr = uuid ?? unsafe { CPointer<Int32>(CPointer<Byte>(typeInfoPointer) + UUID_OFFSET).read().toString() }
        let replacedName = qualifiedName.replace("/", "::")
        typeInfo._replacedName = replacedName
        CACHE.add(replacedName, typeInfo)
        // UUID 0 means "no identity assigned" (e.g. a generic CFunc, whose creation returns
        // before AddTypeInfo). It must not key the uuid cache, otherwise every such type would
        // collide on the same "0" entry.
        if (uuidStr != "0") {
            CACHE.add(uuidStr, typeInfo)
        }
        typeInfo
    }

    /**
     * Returns the simple name of type info.
     */
    public prop name: String {
        get() {
            match (_name) {
                case Some(res) => res
                case None =>
                    let typeName = getTypeNameByQualifiedName(qualifiedName)
                    _name = typeName
                    typeName
            }
        }
    }

    /**
     * Returns the qualified name of type info.
     */
    public prop qualifiedName: String {
        get() {
            match (_qualifiedName) {
                case Some(res) => res
                case None =>
                    _qualifiedName = if (isBox(_info)) {
                        let args = getTypeArgs(_info)
                        // Get the first member from the array
                        let typeArg = unsafe { CPointer<CPointer<Unit>>(args).read() }
                        getQualifiedName(typeArg)
                    } else {
                        _replacedName.getOrDefault({=> getQualifiedName(_info)})
                    }
                    _qualifiedName.getOrThrow()
            }
        }
    }

    // return qualifiedName with space from runtime
    private static func getQualifiedName(pointer: CPointer<Unit>): String {
        let namePointer = getTypeName(pointer)
        var qualifiedName = CString(namePointer).toString().replace("/", "::")
        var formatted = ArrayList<Byte>()
        for (idx in 0..qualifiedName.size - 1) {
            let ch = qualifiedName[idx]
            let nextCh = qualifiedName[idx + 1]
            let prefixCh = qualifiedName.get(idx - 1) ?? b' '

            let isOrgPrefix = (ch == b':' && nextCh == b':')
            let isOrgSuffix = (idx > 1 && ch == b':' && prefixCh == b':')

            if (isOrgPrefix || isOrgSuffix) {
                formatted.add(b':')
                continue
            }

            formatted.add(if (ch == b':') {
                b'.'
            } else {
                ch
            })
            if (ch == b',') {
                formatted.add(b' ')
            }
        }
        formatted.add(qualifiedName[qualifiedName.size - 1])
        qualifiedName = stripStdCorePrefix(String.fromUtf8(formatted.toArray()))
        return qualifiedName
    }

    /**
     * Returns the collection of public instance functions of type info.
     */
    public prop instanceFunctions: Collection<InstanceFunctionInfo> {
        get() {
            if (_instanceFunctions.isNone()) {
                getInstanceFunctions()
            }
            _instanceFunctions.getOrThrow()
        }
    }

    /**
     * Returns the list of public static functions of type info.
     */
    public prop staticFunctions: Collection<StaticFunctionInfo> {
        get() {
            if (_staticFunctions.isNone()) {
                getStaticFunctions()
            }
            _staticFunctions.getOrThrow()
        }
    }

    /**
     * Returns the collection of public instance properties of type info.
     */
    public prop instanceProperties: Collection<InstancePropertyInfo> {
        get() {
            if (_instanceProperties.isNone()) {
                getInstanceFunctions()
            }
            _instanceProperties.getOrThrow()
        }
    }

    /**
     * Returns the collection of public static properties of type info.
     */
    public prop staticProperties: Collection<StaticPropertyInfo> {
        get() {
            if (_staticProperties.isNone()) {
                getStaticFunctions()
            }
            _staticProperties.getOrThrow()
        }
    }

    /**
     * Returns the collection of annotations of type info.
     */
    public prop annotations: Collection<Annotation> {
        get() {
            match (_annotations) {
                case Some(res) => res
                case None =>
                    let infos = getTypeAnnotations(_info)
                    _annotations = infos
                    infos
            }
        }
    }

    /**
     * Returns the collection of super interfaces of type info.
     */
    public prop superInterfaces: Collection<InterfaceTypeInfo> {
        get() {
            match (_superInterfaces) {
                case Some(res) => res
                case None =>
                    let num = getNumOfInterface(_info)
                    let interfaceList = ArrayList<InterfaceTypeInfo>()
                    for (index in 0..num) {
                        let pointer = getInterface(_info, UInt32(index))
                        if (pointer == _info) {
                            continue
                        }
                        interfaceList.add(
                            (getOrCreate(pointer) as InterfaceTypeInfo) ?? throw MisMatchException(
                                "Super interface info of '${qualifiedName}' is not an InterfaceTypeInfo."))
                    }
                    let anyType = (TypeInfo.of<Any>() as InterfaceTypeInfo).getOrThrow()
                    var hasAny = false
                    for (ti in interfaceList) {
                        if (ti == anyType) {
                            hasAny = true
                        }
                    }
                    if (!hasAny) {
                        interfaceList.add(anyType)
                    }
                    let infos = interfaceList.toArray()
                    _superInterfaces = infos
                    infos
            }
        }
    }

    /**
     * Returns the collection of modifiers of type info.
     */
    public prop modifiers: Collection<ModifierInfo> {
        get() {
            match (_modifiers) {
                case Some(res) => res
                case None =>
                    let infos = ModifierInfo.byMask(getTypeInfoModifier(_info))
                    _modifiers = infos
                    infos
            }
        }
    }

    /**
     * Returns true, if current type info is subtype of incoming type info, false otherwise.
     */
    public func isSubtypeOf(supertype: TypeInfo): Bool {
        // Any is super type of all types
        if (supertype.qualifiedName == "Any") {
            return true
        }
        let realTi = if (isBox(supertype._info)) {
            let args = getTypeArgs(supertype._info)
            // Get the first member from the array
            unsafe { CPointer<CPointer<Unit>>(args).read() }
        } else {
            supertype._info
        }
        isSubType(_info, realTi)
    }

    /**
     * Searches the type info's public instance function by incoming name and parameter types.
     */
    public func getInstanceFunction(name: String, parameterTypes: Array<TypeInfo>): InstanceFunctionInfo {
        getByNameAndParamTypes(instanceFunctions, name, parameterTypes, "Instance func '${name}' not found.") {
            instanceFunction => (instanceFunction.name, instanceFunction.parameters)
        }
    }

    public func getInstanceFunctions(name: String): Array<InstanceFunctionInfo> {
        var fns: ArrayList<InstanceFunctionInfo> = ArrayList<InstanceFunctionInfo>()
        for (fn in instanceFunctions where fn.name == name) {
            fns.add(fn)
        }
        fns.toArray()
    }

    /**
     * Searches the type info's public static function by incoming name and parameter types.
     */
    public func getStaticFunction(name: String, parameterTypes: Array<TypeInfo>): StaticFunctionInfo {
        getByNameAndParamTypes(staticFunctions, name, parameterTypes, "Static func '${name}' not found.") {
            staticFunction => (staticFunction.name, staticFunction.parameters)
        }
    }

    public func getStaticFunctions(name: String): Array<StaticFunctionInfo> {
        var fns: ArrayList<StaticFunctionInfo> = ArrayList<StaticFunctionInfo>()
        for (fn in staticFunctions where fn.name == name) {
            fns.add(fn)
        }
        fns.toArray()
    }

    /**
     * Searches the type info's public instance property by incoming name and signature.
     */
    public func getInstanceProperty(name: String): InstancePropertyInfo {
        getByName(instanceProperties, name, "Instance property '${name}' not found.") {
            instanceProperty => instanceProperty.name
        }
    }

    /**
     * Searches the type info's public static property by incoming name and signature.
     */
    public func getStaticProperty(name: String): StaticPropertyInfo {
        getByName(staticProperties, name, "Static property '${name}' not found.") {
            staticProperty => staticProperty.name
        }
    }

    /**
     * Searches the type info's annotation by incoming name.
     */
    public func findAnnotation<T>(): ?T where T <: Annotation {
        findAnnotation<T>(annotations)
    }

    public func findAllAnnotations<T>(): Array<T> where T <: Annotation {
        findAllAnnotations<T>(annotations)
    }

    public func getAllAnnotations(): Array<Annotation> {
        annotations.toArray()
    }

    public operator func ==(other: TypeInfo): Bool {
        this.qualifiedName == other.qualifiedName
    }

    public operator func !=(other: TypeInfo): Bool {
        this.qualifiedName != other.qualifiedName
    }

    public func hashCode(): Int64 {
        this.qualifiedName.hashCode()
    }

    public func toString(): String {
        this.qualifiedName
    }

    func getInstanceFunctions() {
        let num = getNumOfInstanceMethodInfos(_info)
        let constructors = ArrayList<ConstructorInfo>()
        let instanceFuncs = ArrayList<InstanceFunctionInfo>()
        let instanceProps = HashMap<String, InstancePropertyInfo>()
        for (index in 0..Int64(num)) {
            let pointer = getInstanceMethodInfo(_info, UInt32(index))
            if (pointer.isNull()) {
                throw InfoNotFoundException(
                    "Failed to get instance functions for type '${qualifiedName}': method info at index ${index} is null.")
            }
            let name = getFuncName(pointer)
            if (name.isEmpty()) {
                throw ReflectException(
                    "Unexpected empty instance function name for type '${qualifiedName}' at index ${index}.")
            }
            // prop func starts with $
            // need filter $toAny , which is generated by compiler
            // NOTE: only exist in instance func of struct
            if (name[0] == b'$') {
                let isGetter = match (name[name.size - 3..]) {
                    case "get" => true
                    case "set" => false
                    case _ => continue
                }
                let propName = name[1..name.size - 3]
                if (instanceProps.contains(propName)) {
                    let propInfo = instanceProps[propName]
                    propInfo.setFunc(isGetter, pointer)
                } else {
                    let propInfo = InstancePropertyInfo(propName, _info)
                    propInfo.setFunc(isGetter, pointer)
                    instanceProps.add(propName, propInfo)
                }
            } else if (name == constructorName) {
                let constructor = ConstructorInfo(pointer, _info)
                constructors.add(constructor)
            } else {
                let instanceFunc = InstanceFunctionInfo(pointer, _info)
                instanceFunc._name = name
                instanceFuncs.add(instanceFunc)
            }
        }
        _instanceFunctions = instanceFuncs.toArray()
        _instanceProperties = instanceProps.values()
        match (this) {
            case classType: ClassTypeInfo => classType._constructors = constructors.toArray()
            case structType: StructTypeInfo => structType._constructors = constructors.toArray()
            case _ => ()
        }
    }

    func getStaticFunctions() {
        let num = getNumOfStaticMethodInfos(_info)
        let staticFuncs = ArrayList<StaticFunctionInfo>()
        let staticProps = HashMap<String, StaticPropertyInfo>()
        for (index in 0..Int64(num)) {
            let pointer = getStaticMethodInfo(_info, UInt32(index))
            if (pointer.isNull()) {
                throw InfoNotFoundException(
                    "Failed to get static functions for type '${qualifiedName}': method info at index ${index} is null.")
            }
            let name = getFuncName(pointer)
            if (name.isEmpty()) {
                throw ReflectException(
                    "Unexpected empty static function name for type '${qualifiedName}' at index ${index}.")
            }
            // prop func starts with $
            if (name.startsWith("$")) {
                let isGetter = match (name[name.size - 3..]) {
                    case "get" => true
                    case "set" => false
                    case _ => continue
                }
                let propName = name[1..name.size - 3]
                if (staticProps.contains(propName)) {
                    let propInfo = staticProps[propName]
                    propInfo.setFunc(isGetter, pointer)
                } else {
                    let propInfo = StaticPropertyInfo(propName, _info)
                    propInfo.setFunc(isGetter, pointer)
                    staticProps.add(propName, propInfo)
                }
            } else {
                let staticFunc = StaticFunctionInfo(pointer, _info)
                staticFunc._name = name
                staticFuncs.add(staticFunc)
            }
        }
        _staticProperties = staticProps.values()
        _staticFunctions = staticFuncs.toArray()
    }
}

extend<T> CPointer<T> {
    operator func ==(that: CPointer<T>): Bool {
        this.toUIntNative() == that.toUIntNative()
    }
}
