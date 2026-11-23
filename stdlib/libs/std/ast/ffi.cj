/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

package std.ast

import std.collection.ArrayList
import flatbuffers.*

let MACRO_OBJECT = ThreadLocal<CPointer<Unit>>()

foreign {
    // These CJ_AST_rXXX functions come from ast/native/, calling C++ API from
    // the CJC-frontend static library.
    func CJ_AST_ParseExpr(fptr: CPointer<Unit>, tokensBytes: CPointer<UInt8>, tokenCounter: CPointer<Int64>): CPointer<ParseRes>

    func CJ_AST_ParseDecl(fptr: CPointer<Unit>, tokensBytes: CPointer<UInt8>, tokenCounter: CPointer<Int64>): CPointer<ParseRes>

    func CJ_AST_ParsePropMemberDecl(fptr: CPointer<Unit>, tokensBytes: CPointer<UInt8>): CPointer<ParseRes>

    func CJ_AST_ParsePrimaryConstructor(fptr: CPointer<Unit>, tokensBytes: CPointer<UInt8>, tokenCounter: CPointer<Int64>): CPointer<ParseRes>

    func CJ_AST_ParsePattern(fptr: CPointer<Unit>, tokensBytes: CPointer<UInt8>, tokenCounter: CPointer<Int64>): CPointer<ParseRes>

    func CJ_AST_ParseType(fptr: CPointer<Unit>, tokensBytes: CPointer<UInt8>, tokenCounter: CPointer<Int64>): CPointer<ParseRes>

    func CJ_AST_ParseTopLevel(fptr: CPointer<Unit>, tokensBytes: CPointer<UInt8>): CPointer<ParseRes>

    func CJ_AST_ParseAnnotationArguments(tokensBytes: CPointer<UInt8>): CPointer<ParseRes>

    func CJ_AST_Lex(fptr: CPointer<Unit>, code: CString, codeLen: Int64): CPointer<ParseRes>

    func CJ_CheckParentContext(fptr: CPointer<Unit>, parent: CString, report: Bool): Bool

    func CJ_SetItemInfo(fptr: CPointer<Unit>, key: CString, value: CPointer<Unit>, valueType: UInt8): Unit

    func CJ_GetChildMessages(fptr: CPointer<Unit>, children: CString): CPointer<CPointer<CPointer<Unit>>>

    func CJ_CheckAddSpace(tokBytes: CPointer<UInt8>, spaceFlag: CPointer<Bool>): Unit

    func CJ_AST_DiagReport(fptr: CPointer<Unit>, level: CPointer<Int32>, tokensBytes: CPointer<UInt8>, message: CString,
        hint: CString): UInt8

    func CJ_GetMacroPosition(fptr: CPointer<Unit>, fileID: CPointer<UInt32>, line: CPointer<Int32>,
        column: CPointer<Int32>): Unit

    func CJ_AST_Float64ToCPointer(num: Float64): CString
}

// ======================== PART ONE: Parse/Lex API from CJC static library ========================

/**
 * NOTE: four bytes in the front of buffer represents the size of the buffer.
 */
let BUFFER_HEADER_SIZE: Int64 = 4

/**
 * Returns Int32 value from pointer.
 */
func getInt32FromUnsafePointer(ptr: CPointer<UInt8>): Int32 {
    var buf = Array<UInt8>(BUFFER_HEADER_SIZE, {x: Int64 => unsafe { ptr.read(x) }})
    return getInt32(buf[0..4])
}

@C
struct ParseRes {
    let node: CPointer<UInt8> = CPointer<UInt8>()
    let errMsg: CString = CString(CPointer<UInt8>())
}

// Releases parse result resources on all paths; pNode and pTokensBytes remain owned by genASTFormatNode on success.
private unsafe func getParsedNodeAndReleaseParseResult(
    parseResultRaw: CPointer<ParseRes>,
    pTokensBytes: CPointer<UInt8>
): CPointer<UInt8> {
    let pNode = parseResultRaw.read().node
    let pErrorMsg = parseResultRaw.read().errMsg
    try {
        if (!pErrorMsg.isNull()) {
            let errorMsg = pErrorMsg.toString()
            if (errorMsg.size > 0) {
                LibC.free(pTokensBytes)
                LibC.free(pNode)
                throw ParseASTException(errorMsg)
            }
        }
        return pNode
    } finally {
        LibC.free(pErrorMsg)
        LibC.free(parseResultRaw)
    }
}

unsafe func parse(input: Tokens, nativeParse: (CPointer<UInt8>) -> CPointer<ParseRes>): ASTFormat_Node {
    let tokensBytes: Array<UInt8> = input.toBytes()
    let pTokensBytes: CPointer<UInt8> = unsafePointerCastFromUint8Array(tokensBytes)
    let parseResultRaw: CPointer<ParseRes> = nativeParse(pTokensBytes)
    if (parseResultRaw.isNull()) {
        LibC.free(pTokensBytes)
        throw ParseASTException("Failed to get parse result in 'parse'.")
    }
    let pNode = getParsedNodeAndReleaseParseResult(parseResultRaw, pTokensBytes)
    /*
     * If not use isNull(), there will be segfault for some cases for cjnative backend.
     * isNull() API only exists for cjnative.
     */
    let node = genASTFormatNode(pNode, pTokensBytes)
    return node
}

unsafe func parseFragment(
    input: Tokens,
    startFrom: Int64,
    nativeParse: CFunc<(CPointer<UInt8>, CPointer<Int64>) -> CPointer<ParseRes>>
): (ASTFormat_Node, Int64) {
    let tokensBytes: Array<UInt8> = input.toBytes(startFrom)
    let pTokensBytes: CPointer<UInt8> = unsafePointerCastFromUint8Array(tokensBytes)
    var tokenCounter: Int64 = -1
    let sizeRef = LibC.malloc<Int64>()
    if (sizeRef.isNull()) {
        LibC.free(pTokensBytes)
        throw IllegalMemoryException("Failed to allocate memory in 'parseFragment'.")
    }
    let parseResultRaw = nativeParse(pTokensBytes, sizeRef)
    if (parseResultRaw.isNull()) {
        LibC.free(pTokensBytes)
        LibC.free(sizeRef)
        throw ParseASTException("Failed to get parse result in 'parseFragment'.")
    }
    tokenCounter = sizeRef.read()
    var pNode = CPointer<UInt8>()
    try {
        pNode = getParsedNodeAndReleaseParseResult(parseResultRaw, pTokensBytes)
    } finally {
        LibC.free(sizeRef)
    }
    /*
     * If not use isNull(), there will be segfault for some cases for cjnative backend.
     * isNull() API only exists for cjnative.
     */
    let node = genASTFormatNode(pNode, pTokensBytes)
    return (node, tokenCounter + startFrom)
}

func genASTFormatNode(pNode: CPointer<UInt8>, pTokensBytes: CPointer<UInt8>) {
    if (pNode.isNull()) {
        unsafe { LibC.free(pTokensBytes) }
        throw IllegalArgumentException("Node in 'genNodeFormatNode' is null.")
    }
    let bufferSize: Int64 = Int64(getInt32FromUnsafePointer(pNode))
    if (bufferSize <= 0) {
        unsafe {
            LibC.free(pNode)
            LibC.free(pTokensBytes)
        }
        throw IllegalArgumentException("Invalid 'node' buffer length: expected a positive value, got '${bufferSize}'.")
    }
    let flatBuf = Array<UInt8>(bufferSize, {x: Int64 => unsafe { pNode.read(x) }})
    unsafe {
        LibC.free(pNode)
        LibC.free(pTokensBytes)
    }
    return ASTFormat_Node(flatBuf[BUFFER_HEADER_SIZE..], 0)
}

func getTokensFromBytes(pTokenArray: CPointer<UInt8>): Tokens {
    if (pTokenArray.isNull()) {
        throw IllegalArgumentException("Token array in 'getTokensFromBytes' is null.")
    }
    var length: Int64 = Int64(getInt32FromUnsafePointer(pTokenArray))
    if (length <= 0) {
        throw IllegalArgumentException("Invalid 'TokenArray' length: expected a positive value, got '${length}'.")
    }
    var tokenArray = Array<UInt8>(length, {x: Int64 => unsafe { pTokenArray.read(x) }})
    return Tokens(tokenArray[BUFFER_HEADER_SIZE..])
}

/**
 * @return cangjie tokens.
 * @throws IllegalMemoryException if failed to call cangjieLex(code, true).
 * @throws IllegalArgumentException if failed to call cangjieLex(code, true).
 */
public func cangjieLex(code: String): Tokens {
    return cangjieLex(code, true)
}

/**
 * @return cangjie tokens.
 * @throws IllegalMemoryException if malloc failed.
 * @throws IllegalArgumentException if the call of CJ_AST_Lex returns an invalid token array.
 */
public func cangjieLex(code: String, truncated: Bool): Tokens {
    /* NOTE: call cangjie compiler lexer. */
    var pCode = unsafe { LibC.mallocCString(code) }
    if (pCode.isNull()) {
        throw IllegalMemoryException("Failed to allocate memory in 'cangjieLex'.")
    }
    var fPtr = CPointer<Unit>()
    if (let Some(macroObjPtr) <- MACRO_OBJECT.get()) {
        fPtr = macroObjPtr
    }
    let tokens = unsafe {
        let lexResultRaw: CPointer<ParseRes> = CJ_AST_Lex(fPtr, pCode, code.size)
        if (lexResultRaw.isNull()) {
            LibC.free(pCode)
            throw IllegalMemoryException("Failed to get lexer result in 'cangjieLex'.")
        }
        let pTokens = lexResultRaw.read().node
        let pErrorMsg = lexResultRaw.read().errMsg
        try {
            if (!pErrorMsg.isNull()) {
                let errorMsg = pErrorMsg.toString()
                if (errorMsg.size > 0) {
                    throw IllegalArgumentException(errorMsg)
                }
            }
            getTokensFromBytes(pTokens)
        } finally {
            LibC.free(pCode)
            LibC.free(lexResultRaw)
            LibC.free(pErrorMsg)
            LibC.free(pTokens)
        }
    }
    if (!truncated) {
        return tokens
    }
    if (tokens.size >= 1 && tokens[tokens.size - 1].kind == TokenKind.END) {
        tokens.remove(tokens.size - 1)
    }
    return tokens
}

// ======================== PART TWO: CPointer<UInt8>/Array casting APIs ========================
// The call of UnsafePointerCastFromUint8Array will be generated by compiler when we desugar a MacroDecl.
/**
 * @throws IllegalMemoryException while system error.
 */
func unsafePointerCastFromUint8Array(arr: Array<UInt8>): CPointer<UInt8> {
    let arrSize: Int64 = arr.size
    if (arrSize <= 0) {
        return CPointer<UInt8>()
    }
    var ptr: CPointer<UInt8> = unsafe { LibC.malloc<UInt8>(count: arrSize) }
    if (ptr.isNull()) {
        throw IllegalMemoryException("Failed to allocate memory in 'unsafePointerCastFromUint8Array'.")
    }
    for (i in 0..arrSize) {
        unsafe { ptr.write(i, arr[i]) }
    }
    return ptr
}

/**
 * This part is the Macro with context related API:
 */
public class MacroContextException <: Exception {
    public init() {
        super()
    }
    public init(message: String) {
        super(message)
    }
    protected override func getClassName(): String {
        return "MacroAssertParentException"
    }
}

/**
 * For situations an inner macro call finds itself nested inside a particular outer macro call.
 *
 * @param parentMacroName - a particular outer macro call name.
 *
 * @return Unit.
 *
 * Throw an error unless the inner macro call is nested in the given outer macro call.
 */
public func assertParentContext(parentMacroName: String): Unit {
    unsafe {
        if (let Some(macroObjPtr) <- MACRO_OBJECT.get()) {
            var pStr = LibC.mallocCString(parentMacroName)
            if (pStr.isNull()) {
                throw IllegalMemoryException("Failed to allocate memory in 'assertParentContext'.")
            }
            var flag = CJ_CheckParentContext(macroObjPtr, pStr, true)
            LibC.free(pStr)
            if (!flag) {
                throw MacroContextException("Parent macro context check failed for macro '${parentMacroName}'.")
            }
        }
    }
}
/**
 * For situations an inner macro call finds itself nested inside a particular outer macro call.
 *
 * @param parentMacroName - a particular outer macro call name.
 *
 * @return Bool. Returns true only if the inner macro call is nested in the given outer macro call.
 */
public func insideParentContext(parentMacroName: String): Bool {
    unsafe {
        if (let Some(macroObjPtr) <- MACRO_OBJECT.get()) {
            var pStr = LibC.mallocCString(parentMacroName)
            if (pStr.isNull()) {
                throw IllegalMemoryException("Failed to allocate memory in 'insideParentContext'.")
            }
            var flag = CJ_CheckParentContext(macroObjPtr, pStr, false)
            LibC.free(pStr)
            return flag
        }
    }
    return false
}

let ITEM_TYPE_STRING: UInt8 = 1
let ITEM_TYPE_INT64: UInt8 = 2
let ITEM_TYPE_BOOL: UInt8 = 3
let ITEM_TYPE_TOKENS: UInt8 = 4

/**
 * For situations an inner macro can sending key/value pairs to the outer macro by setItem.
 *
 * @param key - the key send to outer macro for index.
 *
 * @param value - the value that send to outer macro.
 */
public func setItem(key: String, value: String): Unit {
    unsafe {
        if (let Some(macroObjPtr) <- MACRO_OBJECT.get()) {
            var keyStr = LibC.mallocCString(key)
            if (keyStr.isNull()) {
                throw IllegalMemoryException("Failed to allocate memory in 'setItem'.")
            }
            var strV = LibC.mallocCString(value)
            if (strV.isNull()) {
                LibC.free(keyStr)
                throw IllegalMemoryException("Failed to allocate memory in 'setItem'.")
            }
            CJ_SetItemInfo(macroObjPtr, keyStr, CPointer<Unit>(strV.getChars()), ITEM_TYPE_STRING)
        }
    }
}

public func setItem(key: String, value: Int64): Unit {
    unsafe {
        if (let Some(macroObjPtr) <- MACRO_OBJECT.get()) {
            var keyStr = LibC.mallocCString(key)
            if (keyStr.isNull()) {
                throw IllegalMemoryException("Failed to allocate memory in 'setItem'.")
            }
            var intV = LibC.malloc<Int64>()
            if (intV.isNull()) {
                LibC.free(keyStr)
                throw IllegalMemoryException("Failed to allocate memory in 'setItem'.")
            }
            intV.write(value)
            CJ_SetItemInfo(macroObjPtr, keyStr, CPointer<Unit>(intV), ITEM_TYPE_INT64)
        }
    }
}

public func setItem(key: String, value: Bool): Unit {
    unsafe {
        if (let Some(macroObjPtr) <- MACRO_OBJECT.get()) {
            var keyStr = LibC.mallocCString(key)
            if (keyStr.isNull()) {
                throw IllegalMemoryException("Failed to allocate memory in 'setItem'.")
            }
            var boolV = LibC.malloc<Bool>()
            if (boolV.isNull()) {
                LibC.free(keyStr)
                throw IllegalMemoryException("Failed to allocate memory in 'setItem'.")
            }
            boolV.write(value)
            CJ_SetItemInfo(macroObjPtr, keyStr, CPointer<Unit>(boolV), ITEM_TYPE_BOOL)
        }
    }
}

public func setItem(key: String, value: Tokens): Unit {
    unsafe {
        if (let Some(macroObjPtr) <- MACRO_OBJECT.get()) {
            var keyStr = LibC.mallocCString(key)
            if (keyStr.isNull()) {
                throw IllegalMemoryException("Failed to allocate memory in 'setItem'.")
            }
            let tokensBytes = value.toBytes()
            var tksV: CPointer<UInt8> = unsafePointerCastFromUint8Array(tokensBytes)
            CJ_SetItemInfo(macroObjPtr, keyStr, CPointer<Unit>(tksV), ITEM_TYPE_TOKENS)
        }
    }
}

class McInfo {
    private var keyVal: CString
    private var value_: CPointer<Unit>
    private var valueType_: UInt8

    init(keyVal_: CString, v: CPointer<Unit>, vType: UInt8) {
        keyVal = keyVal_
        value_ = v
        valueType_ = vType
    }

    prop keyV: CString {
        get() {
            keyVal
        }
    }

    prop value: CPointer<Unit> {
        get() {
            value_
        }
    }

    prop valueType: UInt8 {
        get() {
            valueType_
        }
    }
}

public class MacroMessage {
    var infoMap: ArrayList<McInfo>
    init(res: ArrayList<McInfo>) {
        infoMap = res
    }

    private func getIndexFromKey(key: String) {
        var index = 0
        for (info in infoMap) {
            if (info.keyV.toString() == key) {
                return index
            }
            index++
        }
        return -1
    }

    /*
     * Check the given 'key' wheather have an item
     */
    public func hasItem(key: String): Bool {
        return getIndexFromKey(key) != -1
    }

    /**
     * Get info of key, and return a string value
     * @param key - the key send to outer macro for index.
     * @return String - return a string value.
     * throw an exception if there is no such key/value pairs.
     */
    public func getString(key: String): String {
        var keyIndex = getIndexFromKey(key)
        if (keyIndex != -1) {
            if (infoMap[keyIndex].valueType != ITEM_TYPE_STRING) {
                throw Exception("Macro item '${key}' has a different type: expected 'String'.")
            } else {
                return CString(CPointer<UInt8>(infoMap[keyIndex].value)).toString()
            }
        }
        throw Exception("Macro item '${key}' does not exist.")
    }

    /**
     * Get info of key, and return the Int64 value
     * @param key - the key send to outer macro for index.
     * @return Int64 - return the Int64 value.
     * throw an exception if there is no such key/value pairs.
     */
    public func getInt64(key: String): Int64 {
        var keyIndex = getIndexFromKey(key)
        if (keyIndex != -1) {
            if (infoMap[keyIndex].valueType != ITEM_TYPE_INT64) {
                throw Exception("Macro item '${key}' has a different type: expected 'Int64'.")
            } else {
                unsafe {
                    return CPointer<Int64>(infoMap[keyIndex].value).read()
                }
            }
        }
        throw Exception("Macro item '${key}' does not exist.")
    }

    /**
     * Get info of key, and return the Bool value
     * @param key - the key send to outer macro for index.
     * @return Bool - return the Bool value.
     * throw an exception if there is no such key/value pairs.
     */
    public func getBool(key: String): Bool {
        var keyIndex = getIndexFromKey(key)
        if (keyIndex != -1) {
            if (infoMap[keyIndex].valueType != ITEM_TYPE_BOOL) {
                throw Exception("Macro item '${key}' has a different type: expected 'Bool'.")
            } else {
                unsafe {
                    return CPointer<Bool>(infoMap[keyIndex].value).read()
                }
            }
        }
        throw Exception("Macro item '${key}' does not exist.")
    }

    /**
     * Get info of key, and return the Tokens value
     * @param key - the key send to outer macro for index.
     * @return Tokens - return the Tokens value.
     * throw an exception if there is no such key/value pairs.
     */
    public func getTokens(key: String): Tokens {
        var keyIndex = getIndexFromKey(key)
        if (keyIndex != -1) {
            if (infoMap[keyIndex].valueType != ITEM_TYPE_TOKENS) {
                throw Exception("Macro item '${key}' has a different type: expected 'Tokens'.")
            } else {
                if (infoMap[keyIndex].value.isNull()) {
                    return Tokens()
                } else {
                    return getTokensFromBytes(CPointer<UInt8>(infoMap[keyIndex].value))
                }
            }
        }
        throw Exception("Macro item '${key}' does not exist.")
    }
}

func readCpointerToMap(cp: CPointer<CPointer<Unit>>): ArrayList<McInfo> {
    var i: Int64 = 0
    var infoMap: ArrayList<McInfo> = ArrayList<McInfo>()
    unsafe {
        while (true) {
            if (cp.read(i).isNull()) {
                break
            }
            var key = CString(CPointer<UInt8>(cp.read(i)))
            i++
            var value = cp.read(i)
            i++
            var itemType = CPointer<UInt8>(cp.read(i)).read()
            i++
            infoMap.add(McInfo(key, value, itemType))
        }
    }
    return infoMap
}

/**
 * Getting one message (a map of key/value pairs) for each inner macro invocation that sent messages.
 * @param innerMacroName - the inner macro name that has send to the current outer macro.
 * @return String - return the arraylist of hashmap info.
 * If there are no such messages, this is not an error, it's just an empty list.
 */
public func getChildMessages(children: String): ArrayList<MacroMessage> {
    let macroObjPtr = match (MACRO_OBJECT.get()) {
        case Some(v) => v
        case None => return ArrayList<MacroMessage>()
    }

    var childrenStr = unsafe { LibC.mallocCString(children) }
    if (childrenStr.isNull()) {
        throw IllegalMemoryException("Failed to allocate memory in 'getChildMessages'.")
    }
    var resVector: CPointer<CPointer<CPointer<Unit>>> = unsafe { CJ_GetChildMessages(macroObjPtr, childrenStr) }
    var res: ArrayList<MacroMessage> = ArrayList<MacroMessage>()
    var i: Int64 = 0
    unsafe {
        LibC.free(childrenStr)
    }
    if (resVector.isNull()) {
        return res
    }

    unsafe {
        while (true) {
            var resArray = resVector.read(i)
            if (resArray.isNull()) {
                break
            }
            i++
            res.add(MacroMessage(readCpointerToMap(resArray)))
            LibC.free(resArray)
        }
        LibC.free(resVector)
    }

    return res
}
