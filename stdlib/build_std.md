# Build Cangjie Standard Library

## Build Preparation

The Cangjie standard library can be built in Ubuntu/MacOS (x86_64, aarch64) environments. Before building, you need to set up the compilation environment. For details, please check the [Build dependency tool](https://gitcode.com/Cangjie/cangjie_build/blob/main/docs/env.md).

## Build Steps

Before building the standard library, you need to first build the runtime in this repository and [cangjie_compiler](https://gitcode.com/Cangjie/cangjie_compiler). For detailed build instructions for runtime and cangjie_compiler, please refer to their respective project build guides.

1. Configure cjc

   ```shell
   source <path to the source-built cjc, e.g., ..../output/envsetup.sh>
   ```

   You can verify if cjc is configured successfully using the command below. If version information appears, it indicates that cjc is configured successfully.

   ```shell
   cjc -v
   ```

2. Build Commands

   Download the source code

   ```shell
   git clone https://gitcode.com/Cangjie/cangjie_runtime.git
   ```

   Enter the std directory, compile the standard library source code by executing the `build.py` script, which supports three functions: build, clean, and install.

   ```shell
   cd std
   python3 build.py clean
   python3 build.py build -t release --target-lib=<path to runtime build output directory> --target-lib=<path to openssl lib>
   python3 build.py install
   ```

   1. `build.py clean` command is used to clear temporary files in the workspace;
   2. `build.py build` command starts the compilation：
      - `-t` or `--build-type`，specifies the type of build artifact, which can be either `release` or `debug`;
      - `--target-lib` specifies the openssl lib directory and the output directory for runtime binary artifacts(By default, it is under runtime/output)
   3. `build.py install` command installs the build artifacts to the `output` directory.
      - `--prefix` specifies the installation path (optional), by default it installs in the std/output directory

The output directory structure is as follows:

```text
output
├── lib     #std static lib
├── modules #std cjo file
└── runtime #std dynamic lib
```

## More Build Options

The build functionality of build.py provides the following additional options:

- `--target`: Specifies the build platform, defaults to native build, supported targets are shown below(For cross-compilation, please refer to [Cangjie SDK Integration Build Guide](https://gitcode.com/Cangjie/cangjie_build/blob/main/README_zh.md)):
    - `native` (default value)
    - `ohos-aarch64`: Cross-compile for ohos(aarch64)
    - `ohos-x86_64`: Cross-compile for ohos(x86_64)
    - `ohos-arm`: Cross-compile for ohos(arm)
    - `windows-x86_64`: Cross-compile Windows from Linux
    - `ios-aarch64`: Cross-compile for ios(aarch64)
    - `ios-simulator-aarch64`: Cross-compile for ios simulator(aarch64)
    - `ios-simulator-x86_64`: Cross-compile for ios simulator(x86_64)
    - `android-aarch64`: Cross-compile for android(aarch64, default API 23)
    - `android23-aarch64`: Cross-compile for android(aarch64, API 23)
    - `android26-aarch64`: Cross-compile for android(aarch64, API 26)
    - `android31-aarch64`: Cross-compile for android(aarch64, API 31)
    - `android23-arm`: Cross-compile for android(arm, API 23)
    - `android-x86_64`: Cross-compile for android(x86_64, default API 31)
    - `android26-x86_64`: Cross-compile for android(x86_64, API 26)
    - `android31-x86_64`: Cross-compile for android(x86_64, API 31)
- `--target-toolchain`: Specifies the path to compilation tools (required for cross-compilation)
- `--target-sysroot`: Specifies the directory of target system libraries (required for cross-compilation)
- `--build-args`: cjc build options (optional)
- `--jobs(-j)`: maximum number of concurrent build tasks
- `--hwasan`：Building the HWASAN version of std (for OHOS cross-compilation)
- `--cjlib-sanitizer-support`： Build sanitizer version of cangjie std library. Valid values: `asan`, `tsan` or `hwasan`.

The install functionality of build.py provides the following additional options:

- `--prefix`: Specifies the installation directory
- `--host`: Specifies which target platform to install for

You can also refer to [build.py](https://gitcode.com/Cangjie/cangjie_runtime/blob/main/stdlib/build.py) or use the `--help` option to learn more about compilation options:

```shell
python3 build.py --help
python3 build.py build --help
python3 build.py install --help
```
