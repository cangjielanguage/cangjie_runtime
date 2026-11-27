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
- `--build-args`：转发给 cjc 的构建选项（可选）。每个 `--build-args` 取值成为 CMake 列表中的一个元素，随后按 shell 规则分词为 cjc 参数，例如 `--build-args="-g --apc=1"` 会转发两个参数；含空格的单个参数需在取值内部加引号（例如 `--build-args="'VALUE WITH SPACES'"`）。取值以 `-` 开头时必须使用等号形式 `--build-args=VALUE`；分离写法 `--build-args VALUE` 会被 argparse 当作选项而拒绝。例如 `--build-args=--experimental` 或 `--build-args=--cfg=arkts_interop=on`。需要多个取值时重复该选项。取值中不得包含 `;`（CMake 列表分隔符）。该列表会加入每个 stdlib 包，并同时进入普通编译与 LTO 编译命令，因此只应传入整个构建都能接受的选项。
- `--jobs(-j)` : 并发构建任务最大数量
- `--hwasan` ：构建 hwasan 版本 std（OHOS 交叉编译使用）
- `--cjlib-sanitizer-support`： 构建 sanitizer 版本的仓颉标准库。可选项有 `asan`, `tsan` 和 `hwasan`。

### 实验性 ArkTS 互操作包

仅当构建参数带有用户自定义条件 `--cfg=arkts_interop=on`（或 `--cfg arkts_interop=on`）时才构建 `std.interop.arkts`，例如：

```shell
python3 build.py build -t release --build-args=--cfg=arkts_interop=on
```

选项 `CANGJIE_ENABLE_ARKTS_INTEROP` 每次 configure 都根据 `CANGJIE_BUILD_ARGS` 推导；单独设置 `-DCANGJIE_ENABLE_ARKTS_INTEROP=ON` 不会启用该包。

此时互操作运行时的 CJO 位于 stdlib 源码树之外，需要通过 CMake 缓存变量 `CANGJIE_ARKTS_INTEROP_IMPORT_DIRS` 提供：以分号分隔的目录列表，每一项都必须是完整路径，且每个目录至少包含一个 `.cjo` 文件，例如：

```shell
cmake -DCANGJIE_BUILD_ARGS="--cfg=arkts_interop=on" \
      -DCANGJIE_ARKTS_INTEROP_IMPORT_DIRS="/opt/interop/cjo;/opt/ohos/cjo" ...
```

取值可以包含空格，交给 shell 时需加引号。若某个条目是相对路径、包含 `..`、不存在、不是目录，或其中没有 CJO，configure 会以明确错误终止。`build.py` 不转发额外的 `-D` 选项，因此需要这些导入目录时请直接用 `cmake` configure（或在运行 `build.py` 前设置好缓存项）。

`build.py` 的 `install` 功能提供如下额外选项：

- `--prefix`：指定安装目录
- `--host`：指定为哪个 target 平台安装

您也可以参阅 [build.py](https://gitcode.com/Cangjie/cangjie_runtime/blob/main/stdlib/build.py) 或通过 `--help` 选项了解更多编译选项：

```shell
python3 build.py --help
python3 build.py build --help
python3 build.py install --help
```
