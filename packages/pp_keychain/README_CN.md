# pp_keychain

一个为 Flutter 开发的安全钥匙串存储插件，支持 iOS 和 Android 平台，并具备多应用钥匙串共享能力。

## 语言

- [English](README.md) | [中文](README_CN.md)

## 功能特性

- **安全存储**：iOS 使用系统钥匙串，Android 使用 KeyStore
- **多应用共享**：支持 iOS 的 Keychain Sharing 和 Android 的共享存储
- **易于使用**：简单的 API 用于保存、读取和删除数据
- **跨平台**：iOS 和 Android 使用相同的 API

## 安装

在你的 `pubspec.yaml` 文件中添加 `pp_keychain`：

```yaml
dependencies:
  pp_keychain: ^1.0.0
```

然后运行：

```bash
flutter pub get
```

## 配置

### iOS 配置

**注意：以下配置仅在需要多App共享钥匙串信息时才需要执行。如果您的应用不需要与其他应用共享钥匙串数据，可以跳过此配置。**

1. **添加 Keychain Sharing 能力**：
   - 在 Xcode 中打开你的 iOS 项目
   - 选择你的目标，进入 `Signing & Capabilities`
   - 添加 `Keychain Sharing` 能力
   - 添加你的组 ID，例如：`com.ppswdev.apps.group`

2. **更新 entitlements 文件**：
   确保你的 `Runner.entitlements` 文件包含：

   ```xml
   <key>keychain-access-groups</key>
   <array>
    <string>$(AppIdentifierPrefix)com.ppswdev.apps.group</string>
   </array>
   ```

3. **配置说明**：
   - 所有需要共享钥匙串数据的应用必须使用相同的开发者账号签名
   - 所有需要共享钥匙串数据的应用必须配置相同的访问组 ID
   - 配置完成后，同一开发者账号下的多个应用可以共享钥匙串中的数据

### Android 配置

**基本配置**：

- 无需额外配置，插件会自动使用 Android KeyStore 进行加密存储。

**多应用共享配置**（仅在需要时执行）：

- 所有需要共享钥匙串数据的应用必须使用相同的签名密钥
- 插件默认使用 `com.mobiunity.apps.shared_prefs` 作为共享存储名称
- 确保所有需要共享数据的应用都使用相同版本的插件

**注意**：如果不需要多应用共享功能，插件仍会正常工作，数据会存储在应用的私有存储中。

## 使用

```dart
import 'package:pp_keychain/pp_keychain.dart';

// 初始化插件
final ppKeychain = PPKeychain();

// 保存数据
bool success = await ppKeychain.save(key: 'user_token', value: 'abc123xyz');
print('Save success: $success');

// 读取数据
String? token = await ppKeychain.read(key: 'user_token');
print('Read token: $token');

// 删除数据
success = await ppKeychain.delete(key: 'user_token');
print('Delete success: $success');
```

## API 参考

### PpKeychain 类

#### `Future<bool> save({required String key, required String value})`

- **参数**：
  - `key`：保存值的键
  - `value`：要保存的值
- **返回值**：保存成功返回 `true`，失败返回 `false`

#### `Future<String?> read({required String key})`

- **参数**：
  - `key`：要读取值的键
- **返回值**：保存的值，如果键不存在或读取操作失败则返回 `null`

#### `Future<bool> delete({required String key})`

- **参数**：
  - `key`：要删除的键
- **返回值**：删除成功返回 `true`，失败返回 `false`

#### `Future<String?> getPlatformVersion()`

- **返回值**：平台版本字符串

## 安全性

- **iOS**：使用带有访问组的系统钥匙串进行共享
- **Android**：使用 Android KeyStore 进行密钥管理，使用 AES-256-GCM 加密算法进行数据加密

## 兼容性

- iOS 10.0+
- Android 6.0+ (API 23+)

## 示例

请查看 `example` 目录获取完整的插件使用示例。

## 许可证

MIT 许可证
