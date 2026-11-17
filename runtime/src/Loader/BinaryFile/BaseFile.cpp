// Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
// This source file is part of the Cangjie project, licensed under Apache-2.0
// with Runtime Library Exception.
//
// See https://cangjie-lang.cn/pages/LICENSE for license information.


#include "BaseFile.h"
#include "CjFile/CjFile.h"
namespace MapleRuntime {
BaseFile* BaseFile::CreateCJFile(FileType type, CString filePath, Uptr cfileMetaAddr)
{
    BaseFile* baseFile = nullptr;
    switch (type) {
        case FileType::C_FILE:
            CHECK(cfileMetaAddr != 0);
            baseFile = new (std::nothrow) CJFile(filePath, cfileMetaAddr);
        default:
            break;
    }
    CHECK_DETAIL(baseFile != nullptr, "CreateFile failed, file type: %d, path: %s",
                 static_cast<int>(type), filePath.Str());
    return baseFile;
}

const CString& BaseFile::GetRealPath() const { return realPath; }

const CString& BaseFile::GetBaseName() const { return baseName; }
} // namespace MapleRuntime
