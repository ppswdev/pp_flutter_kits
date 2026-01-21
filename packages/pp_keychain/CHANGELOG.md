## 1.0.0

### 新增功能

- 添加 `save(key, value)` 方法：将数据安全保存到钥匙串
- 添加 `read(key)` 方法：从钥匙串读取数据
- 添加 `delete(key)` 方法：从钥匙串删除数据

### 平台支持

- **iOS**：使用系统钥匙串，支持 Keychain Sharing
- **Android**：使用 KeyStore 系统，支持加密存储

### 多应用共享

- iOS：通过 Keychain Sharing 实现多应用共享
- Android：通过共享 SharedPreferences 实现多应用共享

### 安全特性

- iOS：使用系统钥匙串的安全存储
- Android：使用 AES-256-GCM 加密算法

### 兼容性

- iOS 10.0+
- Android 6.0+ (API 23+)
