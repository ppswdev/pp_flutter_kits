# pp_keychain

A secure keychain storage plugin for Flutter, supporting both iOS and Android platforms with multi-app keychain sharing capabilities.

## Language

- [English](README.md) | [中文](README_CN.md)

## Features

- **Secure Storage**: Uses system keychain on iOS and KeyStore on Android
- **Multi-App Sharing**: Supports Keychain Sharing for iOS and shared storage for Android
- **Easy to Use**: Simple API for saving, reading, and deleting data
- **Cross-Platform**: Same API for both iOS and Android

## Installation

Add `pp_keychain` to your `pubspec.yaml` file:

```yaml
dependencies:
  pp_keychain: ^1.0.0
```

Then run:

```bash
flutter pub get
```

## Configuration

### iOS Configuration

**Note: The following configuration is only required if you need to share keychain information between multiple apps. If your app doesn't need to share keychain data with other apps, you can skip this configuration.**

1. **Add Keychain Sharing Capability**:
   - Open your iOS project in Xcode
   - Select your target, go to `Signing & Capabilities`
   - Add `Keychain Sharing` capability
   - Add your group ID like this: `com.ppswdev.apps.group`

2. **Update entitlements file**:
   Ensure your `Runner.entitlements` file includes:

   ```xml
   <key>keychain-access-groups</key>
   <array>
    <string>$(AppIdentifierPrefix)com.ppswdev.apps.group</string>
   </array>
   ```

3. **Configuration Notes**:
   - All apps that need to share keychain data must be signed with the same developer account
   - All apps that need to share keychain data must be configured with the same access group ID
   - After configuration, multiple apps under the same developer account can share data in the keychain

### Android Configuration

**Basic Configuration**：

- No additional configuration is needed. The plugin automatically uses Android KeyStore for encrypted storage.

**Multi-App Sharing Configuration** (only required if needed)：

- All apps that need to share keychain data must use the same signing key
- The plugin default uses `com.mobiunity.apps.shared_prefs` as the shared storage name
- Ensure all apps that need to share data use the same version of the plugin

**Note**：If you don't need multi-app sharing functionality, the plugin will still work normally, and data will be stored in the app's private storage.

## Usage

```dart
import 'package:pp_keychain/pp_keychain.dart';

// Initialize the plugin
final ppKeychain = PPKeychain();

// Save data
bool success = await ppKeychain.save(key: 'user_token', value: 'abc123xyz');
print('Save success: $success');

// Read data
String? token = await ppKeychain.read(key: 'user_token');
print('Read token: $token');

// Delete data
success = await ppKeychain.delete(key: 'user_token');
print('Delete success: $success');
```

## API Reference

### PpKeychain Class### PpKeychain Class

- **Parameters**:
  - `key`: The key to save the value under
  - `value`: The value to save
- **Returns**: `true` if the save operation was successful, `false` otherwise

#### `Future<String?> read({required String key})`

- **Parameters**:
  - `key`: The key to read the value for
- **Returns**: The saved value, or `null` if the key does not exist or the read operation failed

#### `Future<bool> delete({required String key})`

- **Parameters**:
  - `key`: The key to delete
- **Returns**: `true` if the delete operation was successful, `false` otherwise

#### `Future<String?> getPlatformVersion()`

- **Returns**: The platform version as a string

## Security

- **iOS**: Uses the system keychain with access groups for sharing
- **Android**: Uses Android KeyStore for key management and AES-256-GCM encryption for data

## Compatibility

- iOS 10.0+
- Android 6.0+ (API 23+)

## Example

See the `example` directory for a complete example of how to use the plugin.

## License

MIT LicenseSee the `example` directory for a complete example of how to use the plugin.

## License

MIT License
