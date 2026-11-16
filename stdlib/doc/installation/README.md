# Installing the Cangjie Toolchain

When developing Cangjie programs, one essential tool is the Cangjie compiler, which can compile Cangjie source code into executable binary files. However, modern programming languages come with more than just compilers. In fact, Cangjie provides developers with a complete toolchain including the compiler, debugger, package manager, static analysis tools, formatting tools, and coverage analysis tools, all designed for a seamless "out-of-the-box" experience.

Currently, the Cangjie toolchain has been adapted for certain versions of Linux, macOS, and Windows platforms. However, full functional testing has only been completed for specific Linux distributions (SUSE Linux Enterprise Server 12 SP5, Ubuntu 18.04, Ubuntu 20.04). On platforms that haven't undergone complete functional testing, the full functionality of the Cangjie toolchain cannot be guaranteed. Additionally, the current Windows version of the Cangjie compiler is implemented based on MinGW and has some functional limitations compared to the Linux version.

## Linux / macOS

### Environment Preparation

#### Linux

The system requirements for the Linux version of the Cangjie toolchain are as follows:

| Architecture | Environment Requirements |
| ------------ | ------------------------ |
| x86_64       | glibc 2.22, Linux Kernel 4.12 or later, system-installed libstdc++ 6.0.24 or later |
| aarch64      | glibc 2.27, Linux Kernel 4.15 or later, system-installed libstdc++ 6.0.24 or later |

Additionally, for Ubuntu 18.04, the following dependency packages need to be installed:

```bash
$ apt-get install binutils libc-dev libc++-dev libgcc-7-dev
```

Furthermore, the Cangjie toolchain depends on the OpenSSL 3 component. Since this component may not be directly available from the default software repositories of the above distributions, it needs to be manually installed.

#### macOS

The macOS version of the Cangjie toolchain supports operation on macOS 12.0 and later versions.Before using the macOS version, you need to install the required dependency packages by executing the following command:

```bash
$ brew install libffi
```

### Installation Guide

First, please visit the official Cangjie release channel to download the installation package compatible with your platform architecture:

- `cangjie-sdk-linux-x64-x.y.z.tar.gz`: Cangjie toolchain for Linux systems with x86_64 architecture
- `cangjie-sdk-linux-aarch64-x.y.z.tar.gz`: Cangjie toolchain for Linux systems with aarch64 architecture
- `cangjie-sdk-mac-x64-x.y.z.tar.gz`: Cangjie toolchain for macOS systems with x86_64 architecture
- `cangjie-sdk-mac-aarch64-x.y.z.tar.gz`: Cangjie toolchain for macOS systems with aarch64/arm64 architecture

Assuming you have selected `cangjie-sdk-linux-x64-x.y.z.tar.gz`, after downloading it locally, please execute the following command to extract it:

```bash
tar xvf cangjie-sdk-linux-x64-x.y.z.tar.gz
```

After extraction, you will see a directory named `cangjie` in your current working path, which contains all the components of the Cangjie toolchain. Please execute the following command to complete the installation and configuration of the Cangjie toolchain:

```bash
source cangjie/envsetup.sh
```

To verify whether the installation was successful, you can execute the following command:

```bash
cjc -v
```

Here, `cjc` is the executable filename of the Cangjie compiler. If the version information of the Cangjie compiler is displayed in the command line, it indicates that the Cangjie toolchain has been successfully installed. It should be noted that the `envsetup.sh` script only configures the toolchain-related environment variables in the current shell environment. Therefore, the Cangjie toolchain is only available in the current shell session. In a new shell environment, you need to re-execute the `envsetup.sh` script to configure the environment.

To make the Cangjie toolchain environment variables automatically take effect upon shell startup, you can add the following command at the end of shell initialization configuration files such as `$HOME/.bashrc` or `$HOME/.zshrc` (depending on the shell type):

```shell
# Assuming the Cangjie installation package is extracted to /home/user/cangjie
source /home/user/cangjie/envsetup.sh  # The absolute path to envsetup.sh
```

After configuration, the Cangjie compilation toolchain will be directly available upon shell startup.

### Uninstallation and Update

On Linux and macOS platforms, to uninstall the Cangjie toolchain, simply delete the installation directory mentioned above and remove the environment variables (the simplest method is to open a new shell environment).

```bash
$ rm -rf <path>/<to>/cangjie
```

If you need to update the Cangjie toolchain, first uninstall the current version, then follow the installation instructions above to reinstall the latest version of the Cangjie toolchain.

## Windows

This section uses Windows 10 as an example to introduce the installation method of the Cangjie toolchain.

### Installation Guide

On the Windows platform, Cangjie provides developers with two formats of installation packages: `exe` and `zip`. Please visit the official Cangjie release channels to select and download the Windows version installation package that matches your platform architecture.

- If you choose the `exe` format installation package (e.g., `cangjie-sdk-windows-x64-x.y.z.exe`), simply execute this file and follow the installation wizard to complete the setup.

- If you choose the `zip` format installation package (e.g., `cangjie-sdk-windows-x64-x.y.z.zip`), extract it to an appropriate directory. Inside the package, Cangjie provides three different formats of installation scripts: `envsetup.bat`, `envsetup.ps1`, and `envsetup.sh`. Depending on your usage habits and environment configuration, select one to execute:

    - For Windows Command Prompt (CMD) environments, execute:

        ```bash
        path\to\cangjie\envsetup.bat
        ```

    - For PowerShell environments, execute:

        ```bash
        . path\to\cangjie\envsetup.ps1
        ```

    - For MSYS shell, bash, or similar environments, execute:

        ```bash
        source path/to/cangjie/envsetup.sh
        ```

    To verify a successful installation, execute the `cjc -v` command in the respective command environment. If the Cangjie compiler version information is displayed, it indicates that the Cangjie toolchain has been successfully installed.

**It is important to note** that the installation method using the zip package and execution scripts is similar to that on Linux platforms. Specifically, the environment variables configured by the `envsetup` script are only effective in the current command-line environment. If you open a new command-line window, you will need to re-execute the `envsetup` script to configure the environment. To make the Cangjie toolchain environment variables automatically effective upon command prompt or terminal startup, you can configure the system as follows:

- For bash environments, follow these steps:Add the following command at the end of the initialization configuration file `$HOME/.bashrc` (`$HOME` represents the path to the current user's home directory):

```shell
# Assuming the Cangjie installation package is extracted to /home/user/cangjie
source /home/user/cangjie/envsetup.sh  # The absolute path to envsetup.sh
```

After configuration, the Cangjie compilation toolchain will be directly available upon bash startup.

- If using Windows Command Prompt (CMD), PowerShell, or other environments, follow these steps:

    1. In the Windows search box, search for "View advanced system settings" and open the corresponding window.

    2. Click the "Environment Variables" button.

    3. Perform the following steps to configure the CANGJIE_HOME variable:

        1. In the "User variables" (for the current user) or "System variables" (for all users) section, check if the CANGJIE_HOME environment variable already exists. If not, click the "New" button and enter `CANGJIE_HOME` in the "Variable name" field. If it exists, it indicates that the environment may have been previously configured for Cangjie. To proceed with configuring the current Cangjie version and overwrite the existing configuration, click the "Edit" button to enter the "Edit System Variable" window.

        2. In the "Variable value" field, enter the extraction path of the Cangjie installation package. If a path already exists, overwrite it with the new path. For example, if the Cangjie installation package is extracted to `D:\cangjie`, enter `D:\cangjie`.

        3. After configuration, verify the path is correct in the "Edit User Variable" or "Edit System Variable" window, then click the "OK" button.

    4. Perform the following steps to configure the Path variable:

        1. In the "User variables" (for the current user) or "System variables" (for all users) section, locate and select the Path variable, then click the "Edit" button to enter the "Edit Environment Variable" window.

        2. Click the "New" button and enter the following paths separately: `%CANGJIE_HOME%\bin`, `%CANGJIE_HOME%\tools\bin`, `%CANGJIE_HOME%\tools\lib`, `%CANGJIE_HOME%\runtime\lib\windows_x86_64_llvm` (`%CANGJIE_HOME%` represents the extraction path of the Cangjie installation package). For example, if the installation package is extracted to `D:\cangjie`, the new environment variables should be: `D:\cangjie\bin`, `D:\cangjie\tools\bin`, `D:\cangjie\tools\lib`, `D:\cangjie\runtime\lib\windows_x86_64_llvm`.

        3. (Applicable only for current user settings) Click the "New" button, and enter the current user directory path, then append `.cjpm\bin` at the end. For example, if the user path is `C:\Users\bob`, input `C:\Users\bob\.cjpm\bin`.

        4. After configuration, the configured path should be visible in the "Edit Environment Variables" window. Verify the path is correctly configured and click the "OK" button.

    5. Click the "OK" button to exit the "Environment Variables" window;

    6. Click the "OK" button to complete the setup.

    > **Note:**
    >
    > After setup, you may need to restart the command-line window or reboot the system for the settings to take effect.

    Once configured, the Cangjie compilation toolchain can be used directly from Windows Command Prompt (CMD) or PowerShell.

### Uninstallation and Update

- If installed using the `exe` format installer, run the `unins000.exe` executable in the Cangjie installation directory, follow the uninstallation wizard, and complete the uninstallation process.

- If installed using the `zip` format package, delete the Cangjie toolchain installation directory and remove the aforementioned environment variable settings (if any) to complete the uninstallation.

To update the Cangjie toolchain, first uninstall the current version, then follow the above instructions to reinstall the latest version of the Cangjie toolchain.

## Local-mode build option

`CANGJIE_ENABLE_LOCAL_MODE` controls whether `add_cangjie_library` passes `--experimental --enable-local-mode`. When the CMake module is reused on its own, it defaults to `OFF`; pass `-DCANGJIE_ENABLE_LOCAL_MODE=ON` to opt in. This branch's standard-library project explicitly defaults it to `ON` because its sources contain local-mode declarations, and reports the value during configuration. The setting is a CMake cache option and can be overridden with `-DCANGJIE_ENABLE_LOCAL_MODE=OFF` for sources that do not require the feature.
