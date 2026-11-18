/*
 * Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
 * This source file is part of the Cangjie project, licensed under Apache-2.0
 * with Runtime Library Exception.
 *
 * See https://cangjie-lang.cn/pages/LICENSE for license information.
 */

#ifndef CANGJIE_AST_API_H
#define CANGJIE_AST_API_H

#include <cstdint>
#include <string>

namespace StdAst {

struct ParseRes {
    uint8_t* node;
    char* eMsg;
};

} // namespace StdAst

extern "C" {
StdAst::ParseRes* CJ_AST_Lex(void *fptr, const char* code, int64_t codeLen);

StdAst::ParseRes* CJ_AST_ParseExpr(void* fptr, const uint8_t* tokensBytes, int64_t* tokenCounter);

StdAst::ParseRes* CJ_AST_ParseDecl(void* fptr, const uint8_t* tokensBytes, int64_t* tokenCounter);

StdAst::ParseRes* CJ_AST_ParsePropMemberDecl(void* fptr, const uint8_t* tokensBytes);

StdAst::ParseRes* CJ_AST_ParsePrimaryConstructor(void* fptr, const uint8_t* tokensBytes, int64_t* tokenCounter);

StdAst::ParseRes* CJ_AST_ParsePattern(void* fptr, const uint8_t* tokensBytes, int64_t* tokenCounter);

StdAst::ParseRes* CJ_AST_ParseType(void* fptr, const uint8_t* tokensBytes, int64_t* tokenCounter);

StdAst::ParseRes* CJ_AST_ParseTopLevel(void* fptr, const uint8_t* tokensBytes);

StdAst::ParseRes* CJ_AST_ParseAnnotationArguments(const uint8_t* tokensBytes);

bool CJ_CheckParentContext(void* fptr, char* parent, bool report);

void CJ_SetItemInfo(void* fptr, char* key, void* value, uint8_t type);

void*** CJ_GetChildMessages(void* fptr, char* children);

void CJ_CheckAddSpace(const uint8_t* tokensBytes, bool* spaceFlag);

uint8_t CJ_AST_DiagReport(void* fptr, const int* level, const uint8_t* tokensBytes,
    const char* message, const char* hint);
}

#endif /* CANGJIE_AST_API_H */
