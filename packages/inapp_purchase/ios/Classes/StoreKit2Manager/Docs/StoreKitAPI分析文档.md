# StoreKit 2 API 文件详细分析

## 文件概述

`storeapi.swift` 是 StoreKit 2 框架的完整 API 接口定义文件，包含约 9903 行代码，定义了所有 StoreKit 2 相关的类型、结构体、枚举、协议和方法。

## 主要类型结构

### 1. **AppStore** (枚举)
**位置**: 第 234 行  
**作用**: 提供与 App Store 交互的属性和方法

#### 主要属性：
- `canMakePayments: Bool` - 检查设备是否可以进行支付
- `deviceVerificationID: UUID?` - 设备验证ID，用于防欺诈检测

#### 主要方法：
- `sync() async throws` - 同步已签名的交易和续订信息
- `showManageSubscriptions(in:)` - 显示订阅管理界面
- `presentOfferCodeRedeemSheet(in:)` - 显示优惠代码兑换界面
- `requestReview(in:)` - 请求应用评价

#### 嵌套类型：
- `Environment` - 服务器环境（production/sandbox/xcode）
- `Platform` - 平台类型（iOS/macOS/tvOS/visionOS）

---

### 2. **Product** (结构体)
**位置**: 第 1227 行  
**作用**: 表示应用内购买产品

#### 核心属性：
- `id: String` - 产品唯一标识符
- `type: ProductType` - 产品类型
- `displayName: String` - 本地化的显示名称
- `description: String` - 本地化的产品描述
- `price: Decimal` - 价格（数值）
- `displayPrice: String` - 本地化的价格字符串
- `isFamilyShareable: Bool` - 是否支持家庭共享
- `subscription: SubscriptionInfo?` - 订阅信息（仅自动续订订阅）

#### 产品类型 (ProductType)：
- `.consumable` - 消耗品（可重复购买）
- `.nonConsumable` - 非消耗品（一次性购买）
- `.nonRenewable` - 非续订订阅
- `.autoRenewable` - 自动续订订阅

#### 订阅相关类型：

**SubscriptionPeriod** - 订阅周期
- `unit: Unit` - 时间单位（day/week/month/year）
- `value: Int` - 单位数量
- 静态属性：`.weekly`, `.monthly`, `.yearly` 等

**SubscriptionInfo** - 订阅信息
- `introductoryOffer: SubscriptionOffer?` - 介绍性优惠
- `promotionalOffers: [SubscriptionOffer]` - 促销优惠列表
- `winBackOffers: [SubscriptionOffer]` - 赢回优惠列表（iOS 18.0+）
- `subscriptionGroupID: String` - 订阅组ID
- `subscriptionPeriod: SubscriptionPeriod` - 订阅周期
- `isEligibleForIntroOffer: Bool` - 是否有资格使用介绍性优惠（异步）

**SubscriptionOffer** - 订阅优惠
- `id: String?` - 优惠ID（介绍性优惠为 nil）
- `type: OfferType` - 优惠类型（introductory/promotional/winBack）
- `price: Decimal` - 优惠价格
- `displayPrice: String` - 显示价格
- `period: SubscriptionPeriod` - 优惠周期
- `periodCount: Int` - 周期数量（通常为 1，除了 payAsYouGo）
- `paymentMode: PaymentMode` - 支付模式

**PaymentMode** - 支付模式
- `.freeTrial` - 免费试用
- `.payAsYouGo` - 按需付费
- `.payUpFront` - 预付

**PurchaseOption** - 购买选项
- `appAccountToken(_:)` - 应用账户令牌
- `custom(key:value:)` - 自定义选项（支持 String/Double/Bool/Data）

---

### 3. **Transaction** (结构体)
**位置**: 第 3496 行  
**作用**: 表示已签名的交易信息

#### 核心属性：
- `id: UInt64` - 交易唯一ID
- `originalID: UInt64` - 原始交易ID
- `productID: String` - 产品ID
- `subscriptionGroupID: String?` - 订阅组ID（仅订阅）
- `appBundleID: String` - 应用Bundle ID
- `purchaseDate: Date` - 购买日期
- `originalPurchaseDate: Date` - 原始购买日期
- `expirationDate: Date?` - 过期日期（仅订阅）
- `purchasedQuantity: Int` - 购买数量
- `isUpgraded: Bool` - 是否已升级
- `offer: Offer?` - 应用的优惠（iOS 17.2+）

#### 嵌套类型：

**Reason** - 交易原因
- `.purchase` - 购买
- `.renewal` - 续订

**RevocationReason** - 撤销原因
- `.developerIssue` - 开发者问题
- `.other` - 其他原因

**OfferType** - 优惠类型
- `.introductory` - 介绍性优惠
- `.promotional` - 促销优惠
- `.code` - 代码优惠
- `.winBack` - 赢回优惠（iOS 18.0+）

**OwnershipType** - 所有权类型
- `.purchased` - 当前用户购买
- `.familyShared` - 家庭共享

**Offer** - 优惠详情（iOS 17.2+）
- `id: String?` - 优惠ID
- `type: OfferType` - 优惠类型
- `paymentMode: PaymentMode?` - 支付模式
- `period: SubscriptionPeriod?` - 优惠周期（iOS 18.4+）

#### 主要方法：
- `finish()` - 完成交易
- `latest(for:)` - 获取产品的最新交易
- `all` - 所有交易的异步序列
- `currentEntitlements` - 当前授权的交易异步序列
- `updates` - 交易更新的异步序列

---

### 4. **AppTransaction** (结构体)
**位置**: 第 439 行  
**作用**: 表示应用交易信息

#### 主要属性：
- `appID: UInt64?` - 应用ID
- `appTransactionID: String` - 应用交易ID
- `appVersion: String` - 应用版本
- `appVersionID: UInt64?` - 应用版本ID
- `bundleID: String` - Bundle ID
- `environment: Environment` - 环境（production/sandbox/xcode）
- `originalAppVersion: String` - 原始应用版本
- `originalPurchaseDate: Date` - 原始购买日期
- `originalPlatform: Platform` - 原始平台（iOS 18.4+）
- `preorderDate: Date?` - 预购日期
- `deviceVerification: Data` - 设备验证数据
- `deviceVerificationNonce: UUID` - 设备验证随机数
- `signedDate: Date` - 签名日期

#### 主要方法：
- `shared` - 获取缓存的或从服务器获取的 AppTransaction
- `refresh()` - 从服务器刷新 AppTransaction

---

### 5. **Storefront** (结构体)
**位置**: 约第 8000 行  
**作用**: 表示 App Store 商店区域

#### 主要属性：
- `id: String` - 商店区域ID
- `countryCode: String` - 国家代码

---

### 6. **AdvancedCommerceProduct** (结构体)
**位置**: 第 41 行  
**可用性**: iOS 18.4+  
**作用**: 高级商务API的产品表示

#### 主要属性：
- `id: String` - 产品标识符
- `type: ProductType` - 产品类型

#### 主要方法：
- `purchase(compactJWS:confirmIn:options:)` - 使用 JWS 购买
- `latestTransaction` - 最新交易
- `allTransactions` - 所有交易
- `currentEntitlements` - 当前授权

---

### 7. **PaymentMethodBinding** (结构体)
**位置**: 第 1090 行  
**可用性**: iOS 16.4+  
**作用**: 绑定第三方支付方式到用户的 App Store 账户

#### 主要属性：
- `id: String` - 绑定ID（inAppPinningId）

#### 主要方法：
- `init(id:)` - 初始化并检查绑定资格
- `bind()` - 绑定支付方式到账户

#### 错误类型：
- `.notEligible` - 不符合条件
- `.invalidPinningID` - 无效的绑定ID
- `.failed` - 绑定失败

---

### 8. **Message** (结构体)
**位置**: 约第 900 行  
**可用性**: iOS 16.0+  
**作用**: 表示来自 App Store 的消息

#### 主要方法：
- `display(in:)` - 显示消息
- `messages` - 待显示消息的异步序列

---

### 9. **StoreKitError** (枚举)
**位置**: 约第 7000 行  
**作用**: StoreKit 错误类型

#### 常见错误：
- `.networkError` - 网络错误
- `.systemError` - 系统错误
- `.unknown` - 未知错误

---

## 关键异步序列

### Transaction.updates
实时监听交易更新，包括：
- 新购买
- 订阅续订
- 退款
- 撤销

### Transaction.currentEntitlements
获取用户当前所有有效的授权交易

### Transaction.all
获取用户所有历史交易记录

---

## 购买流程

1. **获取产品**: 使用 `Product.products(for:)` 获取产品列表
2. **购买产品**: 调用 `product.purchase()` 方法
3. **监听交易**: 通过 `Transaction.updates` 监听交易更新
4. **验证交易**: 检查 `VerificationResult` 验证交易有效性
5. **完成交易**: 调用 `transaction.finish()` 完成交易

---

## 订阅管理

### 检查订阅状态
```swift
let statuses = try await product.subscription?.status
```

### 订阅状态类型 (RenewalState)
- `.subscribed` - 已订阅
- `.expired` - 已过期
- `.inBillingRetryPeriod` - 计费重试期
- `.inGracePeriod` - 宽限期
- `.revoked` - 已撤销

### 续订信息 (RenewalInfo)
- `willAutoRenew: Bool` - 是否自动续订
- `expirationDate: Date?` - 过期日期
- `renewalDate: Date?` - 续订日期

---

## 设备验证

StoreKit 2 提供了设备验证机制来防止欺诈：

1. **deviceVerificationID**: 设备唯一标识
2. **deviceVerificationNonce**: 验证随机数
3. **deviceVerification**: SHA-384 哈希值

验证公式：
```
SHA-384(lowercase(deviceVerificationNonce) + lowercase(deviceVerificationID))
```

---

## 版本兼容性

- **iOS 15.0+**: 基础 StoreKit 2 功能
- **iOS 16.0+**: 消息、订阅管理界面
- **iOS 16.4+**: 支付方式绑定、产品推广
- **iOS 17.0+**: 交易原因、高级优惠信息
- **iOS 17.2+**: 交易优惠详情
- **iOS 18.0+**: 赢回优惠
- **iOS 18.4+**: 高级商务API、平台信息

---

## 最佳实践

1. **始终验证交易**: 使用 `VerificationResult` 验证交易
2. **及时完成交易**: 处理完交易后调用 `finish()`
3. **监听交易更新**: 在应用启动时设置 `Transaction.updates` 监听
4. **处理错误**: 妥善处理所有可能的错误情况
5. **使用异步序列**: 利用 `AsyncSequence` 处理实时更新
6. **设备验证**: 在服务器端验证设备信息防止欺诈

---

## 总结

这个 API 文件定义了 StoreKit 2 的完整接口，包括：
- 产品管理（Product）
- 交易处理（Transaction）
- 订阅管理（SubscriptionInfo）
- 应用交易（AppTransaction）
- 商店区域（Storefront）
- 错误处理（StoreKitError）
- 高级功能（AdvancedCommerceProduct, PaymentMethodBinding）

所有 API 都遵循 Swift 现代并发模式（async/await），使用 `AsyncSequence` 处理实时更新，提供了类型安全的接口和完整的错误处理机制。

