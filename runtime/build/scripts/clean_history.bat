@REM Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
@REM This source file is part of the Cangjie project, licensed under Apache-2.0
@REM with Runtime Library Exception.
@REM
@REM See https://cangjie-lang.cn/pages/LICENSE for license information.

@REM Windows clean script
@echo off

set PROJECT_PATH="%~dp0\..\.."
set TEST_PATH=%PROJECT_PATH%\test_tools\tests\cjthread_test
set BUILD_PATH=%PROJECT_PATH%\build\cjthread_build

echo "-----------------------------------------------------------------"
echo "clean cjthread project begin..."
@REM clean all construct file

if exist "%PROJECT_PATH%\output" (
    rmdir /s /q %PROJECT_PATH%\output
)

if exist "%PROJECT_PATH%\build\cjthread_build" (
    rmdir /s /q %PROJECT_PATH%\build\cjthread_build
)

if exist "%TEST_PATH%\cjthread_sdv\build" (
    rmdir /s /q %TEST_PATH%\cjthread_sdv\build
)

if exist "%TEST_PATH%\cjthread_sdv\bin" (
    rmdir /s /q %TEST_PATH%\cjthread_sdv\bin
)

if exist "%TEST_PATH%\dtest\build" (
    rmdir /s /q %TEST_PATH%\dtest\build
)

if exist "%TEST_PATH%\dtest\lib" (
    rmdir /s /q %TEST_PATH%\dtest\lib
)

if exist "%PROJECT_PATH%\Test_Report_*" (
    del /q %PROJECT_PATH%\Test_Report_*
)

if exist "%PROJECT_PATH%\result.xml" (
    del /q %PROJECT_PATH%\result.xml
)

if exist "%PROJECT_PATH%\test_syscall.txt" (
    del /q %PROJECT_PATH%\test_syscall.txt
)

echo "clean cjthread project end..."
echo "-----------------------------------------------------------------"
