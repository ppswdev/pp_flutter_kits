Docs: [English](README.en.md)

# pp_tool介绍

每个人都会有自己的一套技术体系和工程模版，在开发下一个项目的时候希望能够快速的生成和配置好基础的项目工程。就类似于新建一个项目工程，可以选择空项目工程，也可以选择模版工程。

我们是不是也可以通过一个命令，自动生成自己的工程模版？

比如命令终端中输入：

``` bash
ptool create -f my_flutter_project
ptool create -f my_app -o ppsw
```

**未来考虑扩展**

``` bash
ptool create -i my_ios_project
ptool create -h my_harmoney_project
ptool create -a my_android_project
ptool create -w my_web_project
```

# 构建自定义模版说明

1. 使用VSCode, 终端命令等其他工具，创建一个空的项目，名称必须叫：flutter_app,  包名必须是com.example.flutter_app
2. 在flutter_app项目中加入你的代码
3. 压缩项目工程为：flutter_app.zip
4. 配置到环境变量中

# 命令说明

``` bash
mymac@PPM2-MacBook-Air Samples % pp help
arguments: [help]
pp_tool help:
  Usage:
  ptool create -f <project_name> [-o <organization_name>]
  -f <project_name>: The name of the Flutter project to create.
  -o <organization_name>: The organization name for the project. Defaults to 'example'.

  ptool -v : Show the version of the tool
```

- 快速使用你自定义的项目工程模版，自动创建你的Flutter项目工程

``` bash
ptool create -f my_flutter_project
```

- 也可以指定你的组织机构

``` bash
ptool create -f my_flutter_project -o ppsw
```

# 使用说明

- 下载激活使用

打开终端（macOS/Linux）或命令提示符（Windows），然后运行以下命令来全局安装 pp_tool：

``` bash
dart pub global activate pp_tool

```

这将从 pub.dev 下载并安装 pp_tool，并将其添加到你的 Dart 全局工具中。返回结果：

``` bash
mymac@192 ~ % dart pub global activate pp_tool
Package pp_tool is currently active at version 1.0.2.
Downloading packages... .
> pp_tool 1.0.3 (was 1.0.2)
Building package executables...
Built pp_tool:pp_tool.
Installed executable ptool.
Activated pp_tool 1.0.3.
```

如果命令无法正常使用。可以通过一下命令进行验证：

``` bash
mymac@192 ~ % dart pub global
Missing subcommand for "dart pub global".

Usage: dart pub global [arguments...]
-h, --help    Print this usage information.

Available subcommands:
  activate     Make a package's executables globally available.
  deactivate   Remove a previously activated package.
  list         List globally activated packages.
  run          Run an executable from a globally activated package.
```

``` bash
mymac@192 ~ % dart pub global list
intl_utils 2.8.7
pp_tool 1.0.3
```

保存地址：

```
/Users/***/.pub-cache/bin/ptool
/Users/***/.pub-cache/bin/global_packages/pp_tool
```

- 将模板路径存放到环境变量

将模板路径存放到环境变量，确保你的自定义命令能够自动读取该路径。

**在操作系统中设置环境变量**：

**Windows**：在系统设置中，设置一个名为 FLUTTER_TEMPLATE_PATH 的环境变量，值为模板的绝对路径。

**macOS/Linux**：在 ~/.bashrc 或 ~/.zshrc 中添加以下行：

``` bash
export FLUTTER_TEMPLATE_PATH="/Users/mymac/dev/templates/flutter_app.zip"
```

我添加的环境变量是：

``` bash
export PATH=/Users/mymac/dev/flutter/bin:$PATH
export PATH="$PATH":"$HOME/.pub-cache/bin"
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
export FLUTTER_TEMPLATE_PATH="/Users/mymac/dev/templates/flutter_app.zip"
```

如果你不在中国，可以去掉：

``` bash
export PUB_HOSTED_URL=https://pub.flutter-io.cn
export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
```

然后运行 source ~/.bashrc 或 source ~/.zshrc ，或者重新启动终端命令，以使更改生效。

``` bash
source ~/.zshrc
```

- 运行命令

```bash
ptool create -f hello_app -o ppsw
```

- 查看结果

```
mymac@PPM2-MacBook-Air Samples % ptool create -f hello_app -o ppsw
arguments: [create, -f, hello_app, -o, ppsw]
Organization: ppsw
Project: hello_app
hello_app flutter project generating...
Template source file: /Users/mymac/dev/templates/flutter_app.zip
Target directory path: /Users/mymac/Desktop/AppDev/Flutter/Samples
Flutter project "hello_app" created successfully at /Users/mymac/Desktop/AppDev/Flutter/Samples/hello_app
Done!
```
