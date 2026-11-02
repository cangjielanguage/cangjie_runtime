// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#include <iostream>
#include <string>
#include <vector>

#include "Base/CString.h"
#include "CangjieDemangle.h"
#include "Demangler.h"

using namespace Cangjie;

namespace {
// A checklist including the known mangled rules, each item
// represents a pair of <mangledName, demangledName>.
static std::vector<std::pair<std::string, std::string>> checkList = {
    // multi-level package
    { "_CN13pkg$pkg1$pkg28pkg2_arrIlE", "pkg/pkg1/pkg2.pkg2_arr<Int64>" },
    { "_CN13pkg$pkg1$pkg212GetPkg2ArrayEv", "pkg/pkg1/pkg2.GetPkg2Array()" },
    // Function type in function parameters.
    { "_CN7default19function_funcTest_1Ev", "default.function_funcTest_1()" },
    { "_CN7default19function_funcTest_2EF0ldCN7default9classTestIsEE",
      "default.function_funcTest_2((Float64, default.classTest<Int16>)-> Int64)" },
    // Struct Array type in function parameters.
    { "_CN7default16array_funcTest_1ERN9core$core5ArrayIRN9core$core5ArrayIRN9core$core5ArrayIR"
      "N9core$core6StringEEEEE",
      "default.array_funcTest_1(core/core.Array<core/core.Array<core/core.Array<core/core.String>>>)" },
    { "_CN7default16array_funcTest_2ERN9core$core5ArrayICN7default9classTestIlEE",
      "default.array_funcTest_2(core/core.Array<default.classTest<Int64>>)" },
    // Class/struct/enum type in function parameters.
    { "_CN7default14class_funcTestECN7default11classTest_1ECN7default11classTest_2IlERN7default12recordTest_"
      "1IdEN_"
      "ZN7default10enumTest_1IiE",
      "default.class_funcTest(default.classTest_1, default.classTest_2<Int64>, default.recordTest_1<Float64>, "
      "default.enumTest_1<Int32>)" },
    // Generic functions.
    { "_CN7default18generic_funcTest_1ECN7default11classTest_1IdCN7default11classTest_2IlEE",
      "default.generic_funcTest_1(default.classTest_1<Float64, default.classTest_2<Int64>>)" },
    { "_CN7default7default7default7default3TlsIl5alphaIl5bravoIl7charlieIlS20a0ea0a0a0a0a0a0a0a_aEv",
      "default.default.default.default.Tls<Int64>.alpha<Int64>.bravo<Int64>.charlie<Int64>()" },
    { "_CN7default7default3TlsIl7default5alphaIl7default5bravoIl7charlieIlS20a0ea0a0a0a0a0a0a0a_aEv",
      "default.default.Tls<Int64>.default.alpha<Int64>.default.bravo<Int64>.charlie<Int64>()" },
    { "_CN7default2D14DataIi5appleIlEv", "default.D1.Data<Int32>.apple<Int64>()" },
    { "_CN7default7default3TlsIl7default5alphaIl7default5bravoIl7charlieIlS20a0ea0a0a0a0a0a0a0a_aEv",
      "default.default.Tls<Int64>.default.alpha<Int64>.default.bravo<Int64>.charlie<Int64>()" },
    { "_CN7default5A_pkg1AIl3fooEv", "default.A_pkg.A<Int64>.foo()" },
    { "_CN7default5A_pkg1A3fooIlEv", "default.A_pkg.A.foo<Int64>()" },
    { "_CN7default2D14DataIi5appleIlEv", "default.D1.Data<Int32>.apple<Int64>()" },
    // Primitive type in function parameters.
    { "_CN7default20primitive_funcTest_1EubcDhfdasilhtjmqr",
      "default.primitive_funcTest_1(Unit, Bool, Char, Float16, Float32, Float64, Int8, Int16, Int32, Int64, UInt8, "
      "UInt16, UInt32, UInt64, IntNative, UIntNative)" },
    // Tuple type in function parameters.
    { "_CN7default16tuple_funcTest_1ET3_idlE", "default.tuple_funcTest_1(Tuple<Int32, Float64, Int64>)" },
    { "_CN7default16tuple_funcTest_2ET3_idCN7default9classTestIlEE",
      "default.tuple_funcTest_2(Tuple<Int32, Float64, default.classTest<Int64>>)" },
    // Function parameters with default value.
    { "_CN7default3fooElCN7default1AERN8std$core6StringE$b_1l",
      "default.foo(Int64, default.A, std/core.String).b(Int64)" },
    { "_CN7default3fooElCN7default1AERN8std$core6StringE$c_2lCN7default1AE",
      "default.foo(Int64, default.A, std/core.String).c(Int64, default.A)" },
    // Functions overload in different scopes.
    { "_CN7default4main3gooS13a0a0a0a0a0a_aEv", "default.main.goo()" },
    { "_CN7default4main3gooS13a0a0a0a0b0b_bEv", "default.main.goo()" },
    { "_CN7default4main3goo3fooS19a0a0a0a0a0a0a0a0a_aEv", "default.main.goo.foo()" },
    { "_CN7default4main3goo3fooS19a0a0a0a0b0b0b0b0b_bEv", "default.main.goo.foo()" },
    // Function in an extended generic types.
    { "_CN7default6Extend1A10extendFuncEl", "default.A.extendFunc(Int64)" },
    { "_CN7default6ExtendCN7default1AE10extendFuncEl", "default.default.A.extendFunc(Int64)" },
    { "_CN7default6ExtendCN7default1AE10extendFunc18extendFuncInnerBarS12a0bo0a0a0a_aEl",
      "default.default.A.extendFunc.extendFuncInnerBar(Int64)" },
    { "_CN7default6Extend7default5A_dep1AIl3fooEv", "default.default.A_dep.A<Int64>.foo()" },
    { "_CN7default6Extend1A5A_dep1AIl3fooEv", "default.A.A_dep.A<Int64>.foo()" },
    // Interface type in function parameters.
    { "_CN7default13interfaceTestECN7default4IntfEaa", "default.interfaceTest(default.Intf, Int8, Int8)" },
    // Global init functions.
    { "_CGP7defaultiiHv", "package_global_init" },
    { "_CGP3pkgiiHv$", "package_global_init" },
    { "_CGF7defaultU_iiHv", "file_global_init" },
    { "_CGF7defaultU1_iiHv", "file_global_init" },
    { "_CGF7defaultU2_iiHv", "file_global_init" },
    // CPointer type in function parameters.
    { "_CN7default3fooECN7default6TokensEF0PhPhE",
      "default.foo(default.Tokens, (CPointer<UInt8>)-> CPointer<UInt8>)" },
    // Constructor init function in enum type.
    { "_CN7default3Foo5ALPHAEl", "default.Foo.ALPHA(Int64)" },
    { "_CN7default3Foo5BRAVOEc", "default.Foo.BRAVO(Char)" },
    // Prop decl in a type.
    { "_CN7default1A6$p1getEv", "default.A.p1::get()" },
    { "_CN7default1A6$p1setEl", "default.A.p1::set(Int64)" },
    // Some variable, printed as decl.
    { "_CN7default21$__STRING_LITERAL__$0E", "default.$__STRING_LITERAL__$0" },
    { "_CN1a1b1ccE", "_CN1a1b1ccE" },
    { "_CN1a1b1cE", "a.b.c" },
    // CString type in function parameters.
    { "_CN7default6fun_C1Ek", "default.fun_C1(CString)" },
    // CFunc wrapper as argument.
    { "cfuncInCJ$real", "cfuncInCJ" },
    { "macroCall_a_Bench_unittest.testmacro$real", "macroCall_a_Bench_unittest.testmacro" },
    // Lambda expression
    { "default$lambda.0", "default.lambda.0()" },
    // Global var
    { "_CGV7default1aHv", "default.a" },
    // Illegal mangledName, not core dump.
    { "", "" },
    { "P", "P" },
    { "C", "C" },
    { "R", "R" },
    { "F", "F" },
    { "N", "N" },
    { "T", "T" },
    { "S", "S" },
    { "v", "v" },
    { "asertwe5  we5", "asertwe5  we5" },
    { "__S++sd", "__S++sd" },
    { "%^$%@*(!&*(^&(!&#)", "%^$%@*(!&*(^&(!&#)" },
    { "______", "______" },
    { "+++++", "+++++" },
    { "????", "????" },
    { "$$$$", "$$$$" },
    { "!!!!", "!!!!" },
    { "__S_DHUJAS*IW____SADJKA", "__S_DHUJAS*IW____SADJKA" },
    { "``", "``" },
    { "002", "002" },
    { "101010", "101010" },
    { "__GI_raise(sig=2)", "__GI_raise(sig=2)" },
    { "__GI_abort", "__GI_abort" },
    { "frame #6: 0x0000000000409d14 cjfilt`MapleRuntime::De", "frame #6: 0x0000000000409d14 cjfilt`MapleRuntime::De" },
    { "ilt`MapleRuntime::Demangler.GetNextNum(this=0x00007ffffff",
      "ilt`MapleRuntime::Demangler.GetNextNum(this=0x00007ffffff" },
    { "_CN4llvm3sys15PrintStackTraceERNS_11raw_ostreamEi+0x31",
      "_CN4llvm3sys15PrintStackTraceERNS_11raw_ostreamEi+0x31" },
    { "_CN100llvm3sys15PrintStackTraceER", "_CN100llvm3sys15PrintStackTraceER" },
    { "_CN4OHOS10AppExecFwk11ElementNameC1ERKNSt3__h12basic_stringIcNS2_11char_traitsIcEENS2_9allocatorIcEEEESA_SA_",
      "_CN4OHOS10AppExecFwk11ElementNameC1ERKNSt3__h12basic_stringIcNS2_11char_traitsIcEENS2_9allocatorIcEEEESA_SA_" },
    { "_CN7default06Extend1A10extendFuncEl", "_CN7default06Extend1A10extendFuncEl" },
    { "_CN7default3Foo5ALPHAEl0", "_CN7default3Foo5ALPHAEl0" },
    { "_CN7default3Foo5ALPHAEl-1", "_CN7default3Foo5ALPHAEl-1" },
    { "_CN7default8funcTestE$initialParam1___0F0uuEsl",
      "_CN7default8funcTestE$initialParam1___0F0uuEsl" },
    { "_CN7default3fooElCN7default1AERN11std$FS$core6StringE$",
      "_CN7default3fooElCN7default1AERN11std$FS$core6StringE$" },
    { "_CN7default3fooElCN7default1AERN11std$FS$core6StringE$c",
      "_CN7default3fooElCN7default1AERN11std$FS$core6StringE$c" },
    { "_CN7default3fooElCN7default1AERN11std$FS$core6StringE$c_",
      "_CN7default3fooElCN7default1AERN11std$FS$core6StringE$c_" },
    { "_CN7default3fooElCN7default1AERN11std$FS$core6StringE$c_2",
      "_CN7default3fooElCN7default1AERN11std$FS$core6StringE$c_2" },
    { "_CN7default3fooElCN7default1AERN11std$FS$core6StringE$c_2_",
      "_CN7default3fooElCN7default1AERN11std$FS$core6StringE$c_2_" },
    { "$real", "$real" },
    { "$lambda.", "$lambda." },
    { "_CN1aE", "_CN1aE" },
    { "std$FS$core", "std$FS$core" },
    { "_CN7defaultCN7default1AE10extendFunc18extendFuncInnerBarS12a0bo0a0a0a_aEl",
      "_CN7defaultCN7default1AE10extendFunc18extendFuncInnerBarS12a0bo0a0a0a_aEl" },
    { "T4_llRN11std$FS$core6StringECN16encoding$FS$json9JsonValueEE",
      "T4_llRN11std$FS$core6StringECN16encoding$FS$json9JsonValueEE" },
    // Functions overload with different generic constraints.
    { "_CN7default1A3sumICN7default3F64EERN9core$core5ArrayICN7default3F64EEGC_CN7default3F64E_C_"
      "ZN1A5FloatICN7default3F64EE",
      "_CN7default1A3sumICN7default3F64EERN9core$core5ArrayICN7default3F64EEGC_CN7default3F64E_C_"
      "ZN1A5FloatICN7default3F64EE" },
    { "_CN7default1A3sumICN7default3F64EEvGC_CN7default3F64E_CN1A5FloatICN7default3F64EE",
      "_CN7default1A3sumICN7default3F64EEvGC_CN7default3F64E_CN1A5FloatICN7default3F64EE" },
    { "_CN7default4TEST4testICN7default1CEElisamjthDhfdRN11net$FS$core6StringEcbCN7default1AERN7default1BEC_"
      "ZN7default1CEGC_CN7default1CE_CN7default1CE",
      "_CN7default4TEST4testICN7default1CEElisamjthDhfdRN11net$FS$core6StringEcbCN7default1AERN7default1BEC_"
      "ZN7default1CEGC_CN7default1CE_CN7default1CE" },
    // Raw array
    { "_CN7default16array_funcTest_1EA3_RN9core$core6StringEE",
      "default.array_funcTest_1(RawArray<core/core.String>[][][])" },
    { "_CN7default16array_funcTest_2EA1_CN7default9classTestIlEE",
      "default.array_funcTest_2(RawArray<default.classTest<Int64>>[])" },
    // default param funtion
    { "_CPI9pkg1.pkg212global_test3HlllE1cHll", "pkg1.pkg2.global_test3(Int64, Int64, Int64).c(Int64, Int64)" },
    // Global var function
    { "_CGV9pkg1.pkg28global_aHv", "pkg1.pkg2.global_a" },
    // Call operator: its own name is "()" and its parameters still render once.
    { "_CN7default1AclHCNY_1AE", "default.A.()(default.A)" },
    // Local modal on function decls (this param and param modal).
    { "_CN18stdx.encoding.json9parseJsonHCNY_15JsonParserLocalEQLE",
      "stdx.encoding.json.parseJson(stdx.encoding.json.JsonParserLocal @ local!)" },
    { "_CN18stdx.encoding.json14JsonArrayLocal3addHWLECN18stdx.encoding.json14JsonValueLocalEQLE",
      "stdx.encoding.json.JsonArrayLocal.add(this @ local!, stdx.encoding.json.JsonValueLocal @ local!)" },
    // Nested local-function chain: parent levels render their names only; the innermost
    // function renders the single parameter list.
    { "_CN6pkg_re4mainHRNat5ArrayIRNat6StringEEE10test_inputHY2_E12test_input_3Hl",
      "pkg_re.main.test_input.test_input_3(Int64)" },
    { "_CN6pkg_re4mainHRNat5ArrayIRNat6StringEEE10test_inputHY2_E12test_input_3HlQlE",
      "pkg_re.main.test_input.test_input_3(Int64 @ local?)" },
    // _CV compiler-generated virtual wrapper: the suffix precedes ONE parameter list.
    { "_CVNad10LoggerImpl3logHCNax6TokensERNat6StringEb$Nad10LoggerImplE$CNbl6LoggerE",
      "std.deriving.LoggerImpl.log<compiler generated>(std.ast.Tokens, std.core.String, Bool)" },
};

static std::vector<std::pair<std::string, std::string>> checkListForTypes = {
    { "l", "Int64" },
    { "ll", "ll" },
    { "RN9core$core6StringE", "core/core.String" },
    { "V3_RN9core$core6StringEE", "VArray<core/core.String,$4>" },
    { "CN7default1AE", "default.A" },
    { "defaultLambda", "defaultLambda" },
    { "Dh", "Float16" },
    { "DhfaultLambda", "DhfaultLambda" },
    { "iQLE", "Int32 @ local!" },
    { "iQlE", "Int32 @ local?" },
    { "lQLE", "Int64 @ local!" },
    { "CN7default1AEQLE", "default.A @ local!" },
    // A/V/P bodies are not 'E'-terminated: the trailing mode-set belongs to the container
    // (WithModal placement).
    { "A0_lQLE", "RawArray<Int64>[] @ local!" },
    { "V3_lQlE", "VArray<Int64,$4> @ local?" },
    { "PlQLE", "CPointer<Int64> @ local!" },
    // A modal function type keeps its own mode-set in the rendering.
    { "F0ilEQlE", "(Int64) -> Int32 @ local?" },
};

std::string AssembleDemangledName(const std::string& pkgName, const std::string& fullName, bool isFunctionLike)
{
    std::string demangledName;
    if (isFunctionLike) {
        demangledName = pkgName + std::string(pkgName.empty() ? "" : ".") + fullName;
    } else {
        demangledName = pkgName + std::string(pkgName.empty() ? "" : ".") + fullName;
    }
    return demangledName;
}

std::string DemangleRaw(const std::string& mangledName)
{
    auto demangler = Demangler<MapleRuntime::CString>(mangledName.c_str(), MapleRuntime::CString("."));
    auto di = demangler.Demangle();
    return AssembleDemangledName(di.GetPkgName().Str(), di.GetFullName(demangler.ScopeResolution()).Str(),
                                 di.IsFunctionLike());
}

std::string DemangleClass(const std::string& mangledName)
{
    auto demangler = Demangler<MapleRuntime::CString>(mangledName.c_str());
    return demangler.DemangleClassType().Str();
}

std::string DemangleEncapsule(const std::string& mangledName)
{
    auto dd = Demangle(mangledName, ".");
    return AssembleDemangledName(dd.GetPkgName(), dd.GetFullName(), dd.IsFunctionLike());
}

std::string DemangleTypes(const std::string& mangledName)
{
    auto dd = DemangleType(mangledName, ".");
    return dd.GetFullName();
}

bool CheckResult(const std::string& mangledName, const std::string& demangledName,
                 const std::string& expectedDemangledName)
{
    if (demangledName == expectedDemangledName) {
        return true;
    }
    std::cout << "Error when demangle '" << mangledName << "'" << std::endl;
    std::cout << "Expected : " << expectedDemangledName << std::endl;
    std::cout << "Demangle : " << demangledName << std::endl;
    return false;
}
} // namespace

int main()
{
    bool isAllPassed = true;
    for (auto& item : checkList) {
        auto mangledName = item.first;
        auto expectedDemangledName = item.second;
        isAllPassed &= CheckResult(mangledName, DemangleRaw(mangledName), expectedDemangledName);
    }
    std::cout << (isAllPassed ? "Common Tests for Raw All Passed!\n" : "");
    for (auto& item : checkList) {
        auto mangledName = item.first;
        auto expectedDemangledName = item.second;
        isAllPassed &= CheckResult(mangledName, DemangleEncapsule(mangledName), expectedDemangledName);
    }
    std::cout << (isAllPassed ? "Common Tests for Encapsule All Passed!\n" : "");
    auto isAllPassedForTypes = true;
    for (auto& item : checkListForTypes) {
        auto mangledName = item.first;
        auto expectedDemangledName = item.second;
        isAllPassedForTypes &= CheckResult(mangledName, DemangleTypes(mangledName), expectedDemangledName);
    }
    std::string mangledName = "CN8std$core9ExceptionE";
    isAllPassed &= CheckResult(mangledName, "Exception", DemangleClass(mangledName));
    std::cout << (isAllPassed ? "Common Tests All Passed!\n" : "");
    std::cout << (isAllPassedForTypes ? "Demangle for types All Passed!\n" : "");
    return 0;
}
