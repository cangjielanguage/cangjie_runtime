/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.reflect

import std.collection.*
import std.fs.*
import std.sync.*

const PACKAGE_LOAD_FAIL: UIntNative = 0
const MULTI_PACKAGE_INFO: UIntNative = 1
const REPEATED_PACKAGE_LOAD: UIntNative = 2
const REPEATED_FILENAME_LOAD: UIntNative = 3
@When[os == "Windows"]
const MODULE_SUFFIX = ".dll"
@When[os != "Windows"]
const MODULE_SUFFIX = ".so"

/**
 * Contains the reflective information about packages.
 */
public class PackageInfo <: Equatable<PackageInfo> & Hashable & ToString {
    private static let filenameSet = HashSet<String>()
    private static let qualifiedNameMap = HashMap<String, PackageInfo>()
    private static let mutex = Mutex()

    let _packageInfo: CPointer<Unit>
    var _qualifiedName: ?String = None
    var _name: ?String = None

    var _typeInfos: ?Collection<TypeInfo> = None
    var _variables: ?Collection<GlobalVariableInfo> = None
    var _functions: ?Collection<GlobalFunctionInfo> = None
    var _version: ?String = None
    var _rootPackage: ?PackageInfo = None
    var _noPublicInfoList = ArrayList<TypeInfo>()

    init(cp: CPointer<Unit>) {
        _packageInfo = cp
    }

    // Return a specified packageInfo from the loaded dynamic module
    public static func get(qualifiedName: String): PackageInfo {
        if (qualifiedName.contains("/")) {
            throw InfoNotFoundException("PackageInfo '${qualifiedName}' not found.")
        }
        synchronized(mutex) {
            if (let Some(info) <- qualifiedNameMap.get(qualifiedName)) {
                return info
            }
            let replacedName = qualifiedName.replace("::", "/")
            let cname = unsafe { LibC.mallocCString(replacedName) }
            var infoPointer = CPointer<Unit>()
            try {
                infoPointer = getPackageByQualifiedName(cname.getChars())
                if (infoPointer.isNull()) {
                    throw InfoNotFoundException("Cannot find specified package '${qualifiedName}'.")
                }

                let info = PackageInfo(infoPointer)
                qualifiedNameMap.add(info.qualifiedName, info)
                info
            } finally {
                unsafe { LibC.free(cname) }
            }
        }
    }

    public static func load(path: String): PackageInfo {
        let realPath = try {
            canonicalize(if (!path.endsWith(MODULE_SUFFIX)) {
                path + MODULE_SUFFIX
            } else {
                path
            })
        } catch (e: FSException) {
            throw IllegalArgumentException("Failed to load '${path}': illegal path.")
        }

        synchronized(mutex) {
            if (filenameSet.contains(realPath.fileName)) {
                throw ReflectException("File '${path}' is already loaded.")
            }

            let cpath = unsafe { LibC.mallocCString(realPath.toString()) }
            try {
                let info: CPointer<Unit> = loadPackage(cpath.getChars())
                // for performance reason, info pointer need to carry loading result
                let result = info.toUIntNative()
                if (result == PACKAGE_LOAD_FAIL) {
                    throw ReflectException("Failed to load package from '${path}'.")
                } else if (result == MULTI_PACKAGE_INFO) {
                    throw ReflectException("Multiple package infos found in '${path}'.")
                } else if (result == REPEATED_PACKAGE_LOAD) {
                    throw ReflectException("Package from '${path}' is already loaded.")
                } else if (result == REPEATED_FILENAME_LOAD) {
                    throw ReflectException("File '${path}' is already loaded.")
                } else {
                    filenameSet.add(realPath.fileName)
                    return PackageInfo(info)
                }
            } finally {
                unsafe { LibC.free(cpath) }
            }
        }
    }

    // package name with prefix
    // returns "a.b.c" when the package name is "a.b.c"
    public prop qualifiedName: String {
        get() {
            match (_qualifiedName) {
                case Some(res) => res
                case None =>
                    let name = CString(getPackageName(_packageInfo)).toString()
                    let replacedName = name.replace("/", "::")
                    _qualifiedName = replacedName
                    replacedName
            }
        }
    }

    // current package name
    // returns "c" when the package name is "a.b.c"
    public prop name: String {
        get() {
            match (_name) {
                case Some(res) => res
                case None =>
                    let name = if (let Some(index) <- qualifiedName.lastIndexOf(".")) {
                        qualifiedName[index + 1..]
                    } else {
                        qualifiedName
                    }
                    _name = name
                    name
            }
        }
    }

    public prop organizationName: String {
        get() {
            if (let Some(index) <- qualifiedName.indexOf("::")) {
                qualifiedName[..index]
            } else {
                ""
            }
        }
    }

    prop noPublicInfos: ArrayList<TypeInfo> {
        get() {
            _noPublicInfoList
        }
    }

    // Get all type information of the current package
    public prop typeInfos: Collection<TypeInfo> {
        get() {
            match (_typeInfos) {
                case Some(res) => res
                case None =>
                    let infoList = ArrayList<TypeInfo>()
                    var subPackageInfo = _packageInfo
                    do {
                        let num = getPackageNumOfTypeInfos(subPackageInfo)
                        getTypeInfos(num, subPackageInfo, infoList)
                        subPackageInfo = getRelatedPackageInfo(subPackageInfo)
                    } while (!subPackageInfo.isNull())
                    _typeInfos = infoList
                    infoList
            }
        }
    }

    public prop version: String {
        get() {
            match (_version) {
                case Some(version) => version
                case _ => CString(getPackageVersion(_packageInfo)).toString() // no need to free this pointer
            }
        }
    }

    public prop subPackages: Collection<PackageInfo> {
        get() {
            synchronized(mutex) {
                getSubPackagesMap().values()
            }
        }
    }

    public prop parentPackage: PackageInfo {
        get() {
            match (this.qualifiedName.lastIndexOf(b'.')) {
                case Some(idx) => PackageInfo.get(this.qualifiedName[..idx])
                case None => PackageInfo.get(this.qualifiedName)
            }
        }
    }

    public prop rootPackage: PackageInfo {
        get() {
            match (this.qualifiedName.indexOf(b'.')) {
                case Some(idx) => PackageInfo.get(this.qualifiedName[..idx])
                case None => PackageInfo.get(this.qualifiedName)
            }
        }
    }

    public func getSubPackage(qualifiedName: String): PackageInfo {
        getSubPackagesMap().get(qualifiedName) ?? throw InfoNotFoundException(
            "Cannot find subpackage '${qualifiedName}'.")
    }

    private func getSubPackagesMap(): HashMap<String, PackageInfo> {
        synchronized(mutex) {
            let infos = match (getSubPackages(_packageInfo, TypeInfo.of<Array<CPointer<Unit>>>()._info)) {
                case arr: Array<CPointer<Unit>> => arr
                case _ => Array<CPointer<Unit>>()
            }

            HashMap<String, PackageInfo>(infos.size) {
                idx =>
                    let info = PackageInfo(infos[idx])
                    qualifiedNameMap.add(info.qualifiedName, info)
                    (info.qualifiedName, info)
            }
        }
    }

    func getTypeInfos(num: UInt32, subPackageInfo: CPointer<Unit>, infoList: ArrayList<TypeInfo>) {
        for (i in 0..num) {
            let pointer = getPackageTypeInfo(subPackageInfo, i)
            if (pointer.isNull()) {
                throw InfoNotFoundException("Failed to get type info at index ${i} from package '${this.qualifiedName}'.")
            }

            if (isReflectUnsupportedType(pointer)) {
                continue
            }

            let info = TypeInfo.getOrCreate(pointer)
            if (!ModifierInfo.isPublic(getTypeInfoModifier(pointer))) {
                _noPublicInfoList.add(info)
            } else {
                infoList.add(info)
            }
        }
    }

    // Get all global variable information of the current package
    public prop variables: Collection<GlobalVariableInfo> {
        get() {
            match (_variables) {
                case Some(res) => res
                case None =>
                    let infoList = ArrayList<GlobalVariableInfo>()
                    var subPackageInfo = _packageInfo
                    do {
                        let num = getPackageNumOfGlobalFieldInfos(subPackageInfo)
                        getGlobalVariableInfos(num, subPackageInfo, infoList)
                        subPackageInfo = getRelatedPackageInfo(subPackageInfo)
                    } while (!subPackageInfo.isNull())
                    _variables = infoList
                    infoList
            }
        }
    }

    func getGlobalVariableInfos(num: UInt32, subPackageInfo: CPointer<Unit>, infoList: ArrayList<GlobalVariableInfo>) {
        for (i in 0..num) {
            let pointer = getPackageGlobalFieldInfo(subPackageInfo, i)
            if (pointer.isNull()) {
                throw InfoNotFoundException("Failed to get variable info at index ${i} from package '${this.qualifiedName}'.")
            }
            let varInfo = GlobalVariableInfo(pointer)
            infoList.add(varInfo)
        }
    }

    // Get all global function information of the current package
    public prop functions: Collection<GlobalFunctionInfo> {
        get() {
            match (_functions) {
                case Some(res) => res
                case None =>
                    let infoList = ArrayList<GlobalFunctionInfo>()
                    var subPackageInfo = _packageInfo
                    do {
                        let num = getPackageNumOfGlobalMethodInfos(subPackageInfo)
                        getGlobalFunctionInfos(num, subPackageInfo, infoList)
                        subPackageInfo = getRelatedPackageInfo(subPackageInfo)
                    } while (!subPackageInfo.isNull())
                    let infos = infoList.toArray()
                    _functions = infos
                    infos
            }
        }
    }

    func getGlobalFunctionInfos(num: UInt32, subPackageInfo: CPointer<Unit>, infoList: ArrayList<GlobalFunctionInfo>) {
        for (i in 0..num) {
            let pointer = getPackageGlobalMethodInfo(subPackageInfo, i)
            if (pointer.isNull()) {
                throw InfoNotFoundException("Failed to get global function info at index ${i} from package '${this.qualifiedName}'.")
            }
            let funcName = getFuncName(pointer)
            if (funcName == constructorName) {
                continue
            }
            let funcInfo = GlobalFunctionInfo(pointer)
            funcInfo._name = funcName
            infoList.add(funcInfo)
        }
    }

    // lookup type information, return None if
    // Unable to look up the generic type
    public func getTypeInfo(qualifiedTypeName: String): TypeInfo {
        getByName(typeInfos, qualifiedTypeName,
            "Type info '${qualifiedTypeName}' not found from package '${qualifiedName}'.") {
            typeInfo => typeInfo.qualifiedName
        }
    }

    // Find the global variable, return None if not found or the type does not match
    public func getVariable(name: String): GlobalVariableInfo {
        getByName(variables, name, "Variable info '${name}' not found from package '${qualifiedName}'.") {
            variable => variable.name
        }
    }

    // Find the global function, return None if not found or the type does not match
    // Could not find generic function
    public func getFunction(name: String, parameterTypes: Array<TypeInfo>): GlobalFunctionInfo {
        getByNameAndParamTypes(functions, name, parameterTypes,
            "Func info '${name}' not found from package '${qualifiedName}'.") {
            function => (function.name, function.parameters)
        }
    }

    public func getFunctions(name: String): Array<GlobalFunctionInfo> {
        var fns: ArrayList<GlobalFunctionInfo> = ArrayList<GlobalFunctionInfo>()
        for (fn in functions where fn.name == name) {
            fns.add(fn)
        }
        fns.toArray()
    }

    public operator func ==(other: PackageInfo): Bool {
        this.hashCode() == other.hashCode()
    }

    public operator func !=(other: PackageInfo): Bool {
        this.hashCode() != other.hashCode()
    }

    public func hashCode(): Int64 {
        this._packageInfo.toUIntNative().hashCode()
    }

    public func toString(): String {
        qualifiedName
    }
}
