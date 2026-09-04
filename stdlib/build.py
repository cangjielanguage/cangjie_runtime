#!/usr/bin/env python3
# -*- coding: utf-8 -*-
#
# Copyright (c) Huawei Technologies Co., Ltd. 2025. All rights reserved.
# This source file is part of the Cangjie project, licensed under Apache-2.0
# with Runtime Library Exception.
#
# See https://cangjie-lang.cn/pages/LICENSE for license information.

"""cangjie compiler build entry"""

import argparse
import logging
import json
import multiprocessing
import os
import platform
import shutil
import time
import re
import stat
import subprocess
import sys
from enum import Enum
from logging.handlers import TimedRotatingFileHandler
from pathlib import Path
from subprocess import DEVNULL, PIPE

HOME_DIR = os.path.dirname(os.path.abspath(__file__))
BUILD_DIR = os.path.join(HOME_DIR, "build")
CMAKE_BUILD_DIR = os.path.join(BUILD_DIR, "build")
CMAKE_OUTPUT_DIR = os.path.join(HOME_DIR, "output")
LOG_DIR = os.path.join(BUILD_DIR, "logs")
LOG_FILE = os.path.join(LOG_DIR, "cangjie.log")

IS_WINDOWS = platform.system() == "Windows"
IS_MACOS = platform.system() == "Darwin"
IS_ARM = platform.uname().processor in ["aarch64", "arm", "arm64"]
# Wait for the version of aarch64 libcore to be ready.
MAKE_JOBS = multiprocessing.cpu_count() + 2

TARGET_DICTIONARY = {
    "native": None,
    "ohos-aarch64": "aarch64-linux-ohos",
    "ohos-x86_64": "x86_64-linux-ohos",
    "ohos-arm": "arm-linux-ohos",
    "windows-x86_64": "x86_64-w64-mingw32",
    "ios-simulator-aarch64": "arm64-apple-ios11-simulator",
    "ios-simulator-x86_64": "x86_64-apple-ios11-simulator",
    "ios-aarch64": "arm64-apple-ios11",
    "android-aarch64": "aarch64-linux-android23",
    "android23-aarch64": "aarch64-linux-android23",
    "android31-aarch64": "aarch64-linux-android31",
    "android26-aarch64": "aarch64-linux-android26",
    "android23-arm": "arm-linux-android23",
    "android-x86_64": "x86_64-linux-android",
    "android31-x86_64": "x86_64-linux-android31",
    "android26-x86_64": "x86_64-linux-android26"
}

def resolve_path(path):
    if os.path.isabs(path):
        return path
    return os.path.abspath(path)

def log_output(output, checker=None, args=[]):
    """log command output"""
    while True:
        line = output.stdout.readline()
        if not line:
            output.communicate()
            returncode = output.returncode
            if returncode != 0:
                LOG.error("build error: %d!\n", returncode)
                sys.exit(1)
            break
        try:
            LOG.info(line.decode("ascii", "ignore").rstrip())
        except UnicodeEncodeError:
            LOG.info(line.decode("utf-8", "ignore").rstrip())

def generate_cmake_defs(args):
    """convert args to cmake defs"""

    def bool_to_opt(value):
        return "ON" if value else "OFF"

    if args.target:
        if args.target == "aarch64-linux-ohos":
            toolchain_file = "ohos_aarch64_clang_toolchain.cmake"
        if args.target == "arm-linux-ohos":
            toolchain_file = "ohos_arm_clang_toolchain.cmake"
        elif args.target == "x86_64-linux-ohos":
            toolchain_file = "ohos_x86_64_clang_toolchain.cmake"
        elif args.target == "x86_64-w64-mingw32":
            toolchain_file = "mingw_x86_64_toolchain.cmake"
        elif args.target == "arm64-apple-ios11-simulator":
            toolchain_file = "ios_simulator_arm64_toolchain.cmake"
        elif args.target == "x86_64-apple-ios11-simulator":
            toolchain_file = "ios_simulator_x86_64_toolchain.cmake"
        elif args.target == "arm64-apple-ios11":
            toolchain_file = "ios_arm64_toolchain.cmake"
        elif "aarch64-linux-android" in args.target:
            toolchain_file = "android_aarch64_toolchain.cmake"
        elif "x86_64-linux-android" in args.target:
            toolchain_file = "android_x86_64_toolchain.cmake"
        elif "arm-linux-android" in args.target:
            toolchain_file = "android_arm_toolchain.cmake"
    else:
        args.target = None
        if IS_WINDOWS:
            toolchain_file = "mingw_x86_64_toolchain.cmake"
        elif IS_MACOS:
            toolchain_file = "darwin_aarch64_toolchain.cmake" if IS_ARM else "darwin_x86_64_toolchain.cmake"
        elif IS_ARM:
            toolchain_file = "linux_aarch64_toolchain.cmake"
        else:
            toolchain_file = "linux_x86_64_toolchain.cmake"

    if args.target:
        fields = args.target.split("-")

    install_prefix = CMAKE_OUTPUT_DIR

    result = [
        "-DCMAKE_BUILD_TYPE=" + args.build_type.value,
        "-DCMAKE_TOOLCHAIN_FILE=../../cmake/" + toolchain_file,
        "-DCMAKE_INSTALL_PREFIX=" + install_prefix,
        "-DCANGJIE_TARGET_LIB=" + (";".join(args.target_lib) if args.target_lib else ""),
        "-DCANGJIE_TARGET_TOOLCHAIN=" + (args.target_toolchain if args.target_toolchain else ""),
        "-DCANGJIE_ENABLE_HWASAN=" + bool_to_opt(args.hwasan),
        "-DCANGJIE_TARGET_SYSROOT=" + (args.target_sysroot if args.target_sysroot else ""),
        "-DCANGJIE_BUILD_ARGS=" + (";".join(args.build_args) if args.build_args else ""),
        "-DCANGJIE_INCLUDE=" + (";".join(args.include) if args.include else ""),
        "-DCANGJIE_BUILD_STDLIB_WITH_COVERAGE=" + bool_to_opt(args.stdlib_coverage),
        "-DCANGJIE_ENABLE_ASAN_COV=" + bool_to_opt(args.asancov),
        "-DBUILD_GCC_TOOLCHAIN=" + (args.gcc_toolchain if args.gcc_toolchain and args.target is None else ""),
    ]

    if args.target and "aarch64-linux-android" in args.target:
        android_api_level = re.match(r'aarch64-linux-android(\d{2})?', args.target).group(1)
        result.append("-DCMAKE_ANDROID_NDK=" + os.path.join(args.target_toolchain, "../../../../.."))
        result.append("-DCMAKE_ANDROID_API=" + (android_api_level if android_api_level else ""))

    if args.target and "arm-linux-android" in args.target:
        android_api_level = "23"
        result.append("-DCMAKE_ANDROID_NDK=" + os.path.join(args.target_toolchain, "../../../../.."))
        result.append("-DCMAKE_ANDROID_API=" + (android_api_level if android_api_level else ""))

    if args.sanitizer_support:
        result.append("-DCANGJIE_SANITIZER_SUPPORT=" + args.sanitizer_support)
    return result

def build(args):

    if args.target:
        args.target = TARGET_DICTIONARY[args.target]

    check_compiler(args)

    if args.gcc_toolchain and args.target:
        LOG.warning("--gcc-toolchain won't take effect when --target is specified, "
                     "because HOST and TARGET need different toolchains in cross compilation")

    """build cangjie compiler"""
    LOG.info("begin build...")

    if args.target == "aarch64-linux-ohos" or args.target == "x86_64-linux-ohos" or args.target == "arm-linux-ohos":
        # Frontend supports cross compilation in a general way by asking path to required tools
        # and libraries. However, Runtime supports cross compilation in a speific way, which asks
        # for the root path of OHOS toolchain. Since we asked for a path to tools, the root path of
        # OHOS toolchain is relative to the tool path we get. Tool path normally looks like
        # ${OHOS_ROOT}/prebuilts/clang/ohos/linux-x86_64/llvm/bin/. Six /.. can bring us to the root.
        os.environ["OHOS_ROOT"] = os.path.join(args.target_toolchain, "../../../../../..")

    if args.target and "linux-android" in args.target:
        os.environ["ANDROID_NDK_ROOT"] = os.path.join(args.target_toolchain, "../../../../..")

    if IS_MACOS:
        os.environ["ZERO_AR_DATE"] = "1"
        
    if IS_WINDOWS:
        # For Windows, try Ninja first, otherwise use Make instead.
        ninja_valid = True
        try:
            output = subprocess.Popen(["ninja", "--version"], stdout=DEVNULL, stderr=DEVNULL)
            output.communicate()
            ninja_valid = output.returncode == 0
        except:
            ninja_valid = False

        if ninja_valid:
            generator = "Ninja"
            build_cmd = ["ninja"]
            if args.jobs > 0:
                build_cmd.extend(["-j", str(args.jobs)])
        else:
            generator = "MinGW Makefiles"
            build_cmd = ["mingw32-make", "-j" + str(MAKE_JOBS)]
    else:
        # For Linux, just use Ninja.
        generator = "Ninja"
        build_cmd = ["ninja"]
        if args.jobs > 0:
            build_cmd.extend(["-j", str(args.jobs)])

    cmake_command = ["cmake", HOME_DIR, "-G", generator] + generate_cmake_defs(args)

    if not os.path.exists(BUILD_DIR):
        os.makedirs(BUILD_DIR)

    if args.sanitizer_support:
        cmake_build_dir = os.path.join(BUILD_DIR, "build-libs-{}".format(args.sanitizer_support))
        if args.target:
            cmake_build_dir += "-{}".format(args.target)
    else:
        cmake_build_dir = os.path.join(BUILD_DIR, "build-libs-{}".format(args.target)) if args.target else CMAKE_BUILD_DIR

    if not os.path.exists(cmake_build_dir):
        os.makedirs(cmake_build_dir)
        output = subprocess.Popen(cmake_command, cwd=cmake_build_dir, stdout=PIPE)
        log_output(output)

    output = subprocess.Popen(build_cmd, cwd=cmake_build_dir, stdout=PIPE)
    log_output(output)

    if output.returncode != 0:
        LOG.fatal("build failed")

    LOG.info("end build")

def install(args):
    """install targets"""
    LOG.info("begin install targets...")
    
    if args.host:
        args.host = TARGET_DICTIONARY[args.host]

    targets = []

    # - If "build.py install" is invoked without "--host",
    #   the native build directories and all cross-compiled libs
    #   will be installed to the "output" directory.
    # - If "build.py install" is invoked with "--host <triple>",
    #   the build-cjc-<triple> directories and all cross-compiled libs
    #   will be installed to a seperated "output-<target>" directory.

    # Searching for cjc's build directory.
    if not args.host:
        if os.path.exists(CMAKE_BUILD_DIR):
            targets.append(("native", CMAKE_BUILD_DIR))
    else:
        suffix = "cjc-{}".format(args.host)
        cross_build_path = os.path.join(BUILD_DIR, "build-{}".format(suffix))
        if os.path.exists(cross_build_path):
            targets.append((suffix, cross_build_path))

    # Searching for all libs' build directories.
    for directory in os.listdir(BUILD_DIR):
        build_prefix = "build-libs-"
        if directory.startswith(build_prefix):
            targets.append(("libs-{}".format(directory[len(build_prefix):]), os.path.join(BUILD_DIR, directory)))

    if len(targets) == 0:
        LOG.fatal("Nothing is built yet.")
        sys.exit(1)

    # install for all build directories in the list
    for target in targets:
        LOG.info("installing {} build...".format(target[0]))
        cmake_cmd = ["cmake", "--install", "."]
        if args.prefix:
            cmake_cmd += ["--prefix", os.path.abspath(args.prefix)]
        elif args.host:
            cmake_cmd += ["--prefix", os.path.join(HOME_DIR, "output-{}".format(args.host))]
        LOG.info(target[1])
        output = subprocess.Popen(cmake_cmd, cwd=target[1], stdout=PIPE)
        log_output(output)
        if output.returncode != 0:
            LOG.fatal("install {} build failed".format(target[0]))
            sys.exit(1)

    if args.host == "x86_64-w64-mingw32":
        mingw_bin_path = os.path.join(HOME_DIR, "output-x86_64-w64-mingw32/third_party/mingw/bin")
        if os.path.exists(mingw_bin_path):
            for bin in os.listdir(mingw_bin_path):
                bin_path = os.path.join(mingw_bin_path, bin)
                if os.path.isfile(bin_path) and not bin.endswith(".exe"):
                    os.remove(bin_path)
    LOG.info("end install targets...")


def redo_with_write(redo_func, path, err):

    # Is the error an access error?
    if not os.access(path, os.W_OK):
        os.chmod(path, stat.S_IWUSR)
        redo_func(path)
    else:
        raise

def clean(args):
    """clean build outputs and logs"""
    LOG.info("begin clean...\n")
    handlerToBeRemoved = []
    for handler in LOG.handlers:
        if isinstance(handler, logging.FileHandler):
            handler.close()
            handlerToBeRemoved.append(handler)
    for handler in handlerToBeRemoved:
        LOG.removeHandler(handler)
    output_dirs = []
    # Remove entire build directory by default
    output_dirs.append("build")
    output_dirs.append("output")
    for file_path in output_dirs:
        abs_file_path = os.path.join(HOME_DIR, file_path)
        if os.path.isdir(abs_file_path):
            # If some build files are read-only and not allowed to be deleted (especially in Windows),
            # Try to deal with the error by giving write permissions and deleting them again.
            shutil.rmtree(abs_file_path, ignore_errors=False, onerror=redo_with_write)
        if os.path.isfile(abs_file_path):
            os.remove(abs_file_path)
    LOG.info("end clean\n")


def init_log(name):
    """init log config"""
    if not os.path.exists(LOG_DIR):
        os.makedirs(LOG_DIR)

    log = logging.getLogger(name)
    log.setLevel(logging.DEBUG)
    formatter = logging.Formatter(
        "[%(asctime)s] [%(module)s] [%(levelname)s] %(message)s",
        "%Y-%m-%d %H:%M:%S"
    )
    streamhandler = logging.StreamHandler(sys.stdout)
    streamhandler.setLevel(logging.DEBUG)
    streamhandler.setFormatter(formatter)
    log.addHandler(streamhandler)
    filehandler = TimedRotatingFileHandler(
        LOG_FILE, when="W6", interval=1, backupCount=60
    )
    filehandler.setLevel(logging.DEBUG)
    filehandler.setFormatter(formatter)
    log.addHandler(filehandler)
    return log


class BuildType(Enum):
    """CMAKE_BUILD_TYPE options"""

    debug = "Debug"
    release = "Release"
    relwithdebinfo = "RelWithDebInfo"

    def __str__(self):
        return self.name

    def __repr__(self):
        return str(self)

    @staticmethod
    def argparse(s):
        try:
            return BuildType[s]
        except KeyError:
            return s.build_type


def main():
    """build entry"""
    parser = argparse.ArgumentParser(description="build cangjie project")
    subparsers = parser.add_subparsers(help="sub command help")
    parser_build = subparsers.add_parser("build", help=" build cangjie")
    parser_build.add_argument(
        "-t",
        "--build-type",
        type=BuildType.argparse,
        dest="build_type",
        choices=list(BuildType),
        required=True,
        help="select target build type",
    )
    parser_build.add_argument(
        "--jobs","-j" , dest="jobs", type=int, default=0, help="run N jobs in parallel (0 means default)"
    )
    parser_build.add_argument(
        "--hwasan", action="store_true", help="build with hardware asan"
    )
    parser_build.add_argument(
        "--target", dest="target", type=str, choices=TARGET_DICTIONARY.keys(), default="native",
        help="build a second stdlib for the target triple specified"
    )
    parser_build.add_argument(
        "--target-lib", "-L", dest="target_lib", type=str, action='append', default=[],
        help="link libraries under this path for all products"
    )
    parser_build.add_argument(
        "--target-toolchain", dest="target_toolchain", type=str,
        help="use the tools under the given path to cross-compile stdlib"
    )
    parser_build.add_argument(
        "--include", "-I", dest="include", type=str, action='append', default=[],
        help="search header files in given paths"
    )
    parser_build.add_argument(
        "--stdlib-coverage", action="store_true", help="build stdlib with coverage"
    )
    parser_build.add_argument(
        "--target-sysroot", dest="target_sysroot", type=str,
        help="pass this argument to C/CXX compiler as --sysroot"
    )
    parser_build.add_argument(
        "--asancov", action="store_true", help="build with asan and sanitize-coverage, used for cjc_fuzz and lsp_test"
    )
    parser_build.add_argument(
        "--cjlib-sanitizer-support",
        type=str,
        choices=["asan", "tsan", "hwasan"],
        dest="sanitizer_support",
        help="Enable cangjie sanitizer support for cangjie libraries."
    )
    parser_build.add_argument(
        "--build-args",
        type=str,
        dest="build_args",
        action='append', default=[],
        help="ther arguments directly passed to cjc"
    )
    parser_build.add_argument(
        "--gcc-toolchain", dest="gcc_toolchain", help="Specify GCC toolchain for Clang to use"
    )
    parser_build.set_defaults(func=build)

    parser_install = subparsers.add_parser("install", help="install targets")

    parser_install.add_argument(
        "--host", dest="host", type=str, choices=TARGET_DICTIONARY.keys(), help="Generate installation package for the host"
    )
    parser_install.add_argument(
        "--prefix", dest="prefix", help="target install prefix"
    )
    parser_install.set_defaults(func=install)

    parser_clean = subparsers.add_parser("clean", help="clean build")
    parser_clean.set_defaults(func=clean)

    args, unknown = parser.parse_known_args()
    args.func(args)

def check_compiler(args):
    # If user didn't specify --target-toolchain, we search for an available compiler in $PATH.
    # If user did specify --target-toolchain, we search in user given path ONLY. By doing so
    # user could see a 'compiler not found' error if the given path is incorrect.
    toolchain_path = args.target_toolchain if args.target_toolchain else None
    if toolchain_path and (not os.path.exists(toolchain_path)):
        LOG.error("the given toolchain path does not exist, {}".format(toolchain_path))
    # The gcc with the MinGW triple prefix is used for Windows native compiling.
    if IS_WINDOWS and args.target is None:
        c_compiler = shutil.which("x86_64-w64-mingw32-gcc.exe", path=toolchain_path)
        cxx_compiler = shutil.which("x86_64-w64-mingw32-g++.exe", path=toolchain_path)
    else: # On other platform, clang is always the first choice.
        c_compiler = shutil.which("clang", path=toolchain_path)
        cxx_compiler = shutil.which("clang++", path=toolchain_path)
    # If clang is not available and we are cross compiling, we check for gcc cross compiler.
    if (c_compiler == None or cxx_compiler == None) and args.target:
        prefix = ""
        if args.target == "windows-x86_64":
            prefix = "x86_64-w64-mingw32"
        c_compiler = shutil.which(prefix + "-gcc", path=toolchain_path)
        cxx_compiler = shutil.which(prefix + "-g++", path=toolchain_path)
    # If none of above is available, we search for generic gcc compiler.

    if c_compiler == None or cxx_compiler == None:
        c_compiler = shutil.which("gcc", path=toolchain_path)
        cxx_compiler = shutil.which("g++", path=toolchain_path)

    if c_compiler == None or cxx_compiler == None:
        if toolchain_path:
            LOG.error("cannot find available compiler in the given toolchain path")
        else:
            LOG.error("cannot find available compiler in $PATH")
        LOG.error("clang/clang++ or gcc/g++ is required to build cangjie compiler")

    os.environ["CC"] = c_compiler
    os.environ["CXX"] = cxx_compiler

if __name__ == "__main__":
    LOG = init_log("root")
    os.environ["LANG"] = "C.UTF-8"

    main()
