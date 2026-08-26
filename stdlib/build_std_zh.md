# 构建仓颉标准库

## 构建准备

仓颉标准库支持在 Ubuntu/MacOS（x86_64, aarch64）环境中编译构建。构建前需要完成编译环境的搭建，详情请查看[构建依赖工具](https://gitcode.com/Cangjie/cangjie_build/blob/main/docs/env.md)

## 构建步骤

构建标准库之前需要先源码构建本仓的 runtime 和 [cangjie_compiler](https://gitcode.com/Cangjie/cangjie_compiler)，runtime 和 cangjie_compiler 的构建详细见其项目的构建指导。

1. 配置 cjc

   ```shell
   source <源码构建的cjc路径，如..../output/envsetup.sh>
   ```

   可以通过下面的命令验证 cjc 是否配置成功，若出现版本信息，证明 cjc 配置成功

   ```shell
   cjc -v
   ```

2. 构建命令

   下载源码

   ```shell
   git clone https://gitcode.com/Cangjie/cangjie_runtime.git
   ```

   进入 std 目录，对标准库源码进行编译，执行 `build.py` 脚本，脚本支持构建、清理、和安装三个功能

   ```shell
   cd std
   python3 build.py clean
   python3 build.py build -t release --target-lib=<runtime构建产物路径> --target-lib=<openssl lib路径>
   python3 build.py install
   ```

   1. `build.py clean` 命令用于清空工作区临时文件；
   2. `build.py build` 命令开始执行编译：
      - `-t` 即 `--build-type`，指定编译产物类型，可以是 `release` 或 `debug`；
      - `--target-lib` 指定 openssl lib 目录和 runtime 二进制产物 output 目录（默认在项目的 runtime/output）
   3. `build.py install` 命令将编译产物安装到 `output` 目录下。
      - `--prefix` 指定安装路径（可选），默认安装在 std/output 目录

output 目录结构如下：

```text
output
├── lib     #标准库 static lib
├── modules #标准库 cjo 文件
└── runtime #标准库 dynamic lib
```

## 更多构建选项

`build.py` 的 `build` 功能提供如下额外选项：

- `--target`：指定构建平台，默认为 native，支持的 target 如下所示（交叉编译请参考[仓颉 SDK 集成构建指导书](https://gitcode.com/Cangjie/cangjie_build/blob/main/README_zh.md)）：
    - `native`（默认值）
    - `ohos-aarch64` ： 交叉编译 ohos(aarch64)
    - `ohos-x86_64` ：交叉编译 ohos(x86_64)
    - `ohos-arm` ：交叉编译 ohos(arm)
    - `windows-x86_64` ： linux 交叉编译 windows
    - `ios-aarch64` ：交叉编译 ios(aarch64)
    - `ios-simulator-aarch64` ：交叉编译 ios 模拟器(aarch64)
    - `ios-simulator-x86_64` ：交叉编译 ios 模拟器(x86_64)
    - `android-aarch64` ：交叉编译 android(aarch64, 默认 API 23)
    - `android23-aarch64` ：交叉编译 android(aarch64, API 23)
    - `android26-aarch64` ：交叉编译 android(aarch64, API 26)
    - `android31-aarch64` ：交叉编译 android(aarch64, API 31)
    - `android23-arm` ：交叉编译 android(arm, API 23)
    - `android-x86_64` ：交叉编译 android(x86_64, 默认 API 31)
    - `android26-x86_64` ：交叉编译 android(x86_64, API 26)
    - `android31-x86_64` ：交叉编译 android(x86_64, API 31)
- `--target-toolchain` ：指定编译工具所在路径（交叉编译需要指定）
- `--target-sysroot` ：指定编译目标系统库所在目录（交叉编译需要指定）
- `--build-args` ：cjc 构建选项（可选）
- `--jobs(-j)` : 并发构建任务最大数量
- `--hwasan` ：构建 hwasan 版本 std（OHOS 交叉编译使用）
- `--cjlib-sanitizer-support`： 构建 sanitizer 版本的仓颉标准库。可选项有 `asan`, `tsan` 和 `hwasan`。

`build.py` 的 `install` 功能提供如下额外选项：

- `--prefix`：指定安装目录
- `--host`：指定为哪个 target 平台安装

您也可以参阅 [build.py](https://gitcode.com/Cangjie/cangjie_runtime/blob/main/stdlib/build.py) 或通过 `--help` 选项了解更多编译选项：

```shell
python3 build.py --help
python3 build.py build --help
python3 build.py install --help
```
