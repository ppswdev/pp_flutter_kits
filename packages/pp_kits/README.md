# pp_kits

pp_kits 是一个面向 Flutter 的快速开发应用工具库，集成了常用功能模块与第三方依赖，帮助开发者更高效地构建应用。涵盖日志、轮询任务、网络请求、存储、适配、文件处理等多项基础能力，适用于绝大多数 Flutter 应用开发场景。

## 环境要求

- Flutter >= 3.35.0
- Dart >= 3.9.0

## 主要特性

- **日志工具**：统一 Logger 类，便于调试与跟踪（release 自动关闭日志）。
- **轮询任务管理**：PollingTask 单例，快速管理多路定时任务。
- **网络请求**：集成 dio，简化接口调用与错误处理。
- **状态管理**：get 支持响应式开发。
- **国际化**：intl 国际化工具。
- **安全与本地存储**：flutter_secure_storage、shared_preferences、package_info_plus 提供多样化存储方案。
- **多媒体与文件**：支持音频播放、文件选择/路径、图片裁剪等。
- **UI 与适配**：支持对话框加载（adaptive_dialog/flutter_easyloading）、屏幕适配（flutter_screenutil）。
- **设备与环境信息**：设备/包/时区等通用能力。
- **其他三方库打包**：如 uuid、hex、encrypt、archive、url_launcher 等。

## 快速开始

在 `pubspec.yaml` 中添加依赖：

```yaml
dependencies:
  pp_kits: ^1.2.2
```

导入至 Dart 代码：

```dart
import 'package:pp_kits/pp_kits.dart';
```

## 简单示例

### 日志输出

```dart
Logger.log('普通日志');
Logger.trace('带堆栈信息的日志');
```

### 轮询任务

```dart
PollingTask().start(
  id: 'myTask',
  interval: Duration(seconds: 10),
  onTick: () {
    print('轮询触发');
  },
);
```

### 网络请求（供推荐用法参考）

```dart
// 推荐自定义封装基于 dio 的 API 方法
```

## 依赖说明

| 功能               | 三方库               |
| ------------------ | -------------------- |
| 网络请求           | dio                  |
| 状态管理           | get                  |
| 国际化             | intl                 |
| 文件/路径           | path, file_picker, path_provider |
| 唯一ID/加密        | uuid, hex, encrypt   |
| 压缩/解压          | archive              |
| 系统设置/启动      | url_launcher, app_settings |
| 本地/安全存储      | shared_preferences, flutter_secure_storage |
| 结构适配/UI        | adaptive_dialog, flutter_easyloading, flutter_screenutil |
| 设备/包/时区信息   | device_info_plus, package_info_plus, flutter_timezone |
| 时间工具           | get_time_ago         |
| 多媒体             | audioplayers, image_cropper, image_picker, share_plus |
| 网络状态           | connectivity_plus    |

## 参与贡献

欢迎反馈问题与 PR！

详细文档与用法 Demo 正在完善中，敬请期待。

## License

MIT
