# 安装指南

## CocoaPods

### 1. 在 Podfile 中添加

```ruby
platform :ios, '15.0'

target 'YourApp' do
  use_frameworks!
  
  pod 'StoreKit2Manager', '~> 1.0.0'
end
```

### 2. 安装依赖

```bash
pod install
```

### 3. 使用

```swift
import StoreKit2Manager

// 配置
let config = StoreKitConfig(
    productIds: ["your.product.id"],
    lifetimeIds: ["your.lifetime.id"]
)

StoreKit2Manager.shared.configure(with: config)
```

## Swift Package Manager

### 方式一：通过 GitHub 仓库（推荐）

#### 1. 准备仓库

确保你的代码已经推送到 GitHub 并创建了版本标签：

```bash
# 在 StoreKit2Manager 目录下
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/yourusername/StoreKit2Manager.git
git push -u origin main

# 创建版本标签
git tag 1.0.0
git push origin --tags
```

#### 2. 在 Xcode 中添加

1. 打开 Xcode 项目
2. 选择 `File` → `Add Packages...`
3. 输入仓库 URL: `https://github.com/yourusername/StoreKit2Manager.git`
4. 选择版本规则（推荐：`Up to Next Major Version` 从 `1.0.0`）
5. 点击 `Add Package`

### 方式二：通过本地路径

1. 在 Xcode 中选择 `File` → `Add Packages...`
2. 点击 `Add Local...`
3. 选择 `StoreKit2Manager` 目录（包含 `Package.swift` 的目录）
4. 点击 `Add Package`

### 方式三：通过 Package.swift 文件（命令行）

如果你的项目使用 Swift Package Manager，可以在项目的 `Package.swift` 中添加依赖：

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/StoreKit2Manager.git", from: "1.0.0")
]
```

然后在 target 的依赖中添加：

```swift
.target(
    name: "YourTarget",
    dependencies: ["StoreKit2Manager"]
)
```

### 使用

```swift
import StoreKit2Manager

// 配置
let config = StoreKitConfig(
    productIds: ["your.product.id"],
    lifetimeIds: ["your.lifetime.id"]
)

StoreKit2Manager.shared.configure(with: config)
```

### 验证 Package.swift

创建 `Package.swift` 后，可以验证配置是否正确：

```bash
cd StoreKit2Manager
swift package describe
```

如果看到包的描述信息，说明配置正确。

## 手动安装

### 1. 下载源码

```bash
git clone https://github.com/yourusername/StoreKit2Manager.git
```

### 2. 添加到项目

1. 将 `StoreKit2Manager` 目录拖拽到你的 Xcode 项目中
2. 确保 `StoreKit2Manager` 目录下的所有 `.swift` 文件都被添加到 Target
3. 在需要使用的文件中导入：

```swift
import StoreKit2Manager
```

## 系统要求

- iOS 15.0+
- macOS 12.0+
- watchOS 8.0+
- tvOS 15.0+
- visionOS 1.0+
- Swift 5.9+
- Xcode 15.0+

## 注意事项

1. 确保在 App Store Connect 中配置了所有产品ID
2. 在真机上测试购买功能（模拟器不支持）
3. 使用沙盒测试账号进行测试
4. 所有回调都在主线程执行，可以直接更新UI
