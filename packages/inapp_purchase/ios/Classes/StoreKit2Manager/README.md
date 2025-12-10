# StoreKit2Manager

一个简洁、易用的 StoreKit2 封装库，提供统一的接口来管理应用内购买。

## 特性

- ✅ 配置驱动，易于集成
- ✅ 支持协议回调和闭包回调两种方式
- ✅ 自动监听交易状态变化
- ✅ 完整的错误处理
- ✅ 支持所有产品类型（消耗品、非消耗品、订阅等）
- ✅ 线程安全，所有回调在主线程
- ✅ 自动管理资源生命周期
- ✅ 支持从 plist/JSON 配置文件加载
- ✅ 恢复购买功能
- ✅ 消耗品购买历史查询
- ✅ 订阅详细信息查询
- ✅ 交易历史查询
- ✅ 订阅管理链接
- ✅ 并发购买保护
- ✅ 自动处理退款和撤销
- ✅ 订阅产品国际化支持（标题、副标题、按钮文案）
- ✅ 优惠代码兑换支持
- ✅ 家庭共享检测

## 快速开始

### 1. 在 Podfile 中添加

```ruby
platform :ios, '15.0'

target 'YourApp' do
  use_frameworks!
  
  pod 'StoreKit2Manager', '~> 1.0.0'
end
```

### 1. 基本配置

```swift
import StoreKitManager

// 方式1: 使用代码配置
let config = StoreKitConfig(
    productIds: [
        "premium.lifetime",
        "subscription.monthly",
        "subscription.yearly"
    ],
    lifetimeIds: ["premium.lifetime"], // 终身会员产品ID
    nonRenewableExpirationDays: 365, // 非续订订阅过期天数
    autoSortProducts: true // 自动按价格排序
)

```

### 2. 使用代理方式

```swift
class MyStoreManager: StoreKitDelegate {
    func setupStore() {
        let config = StoreKitConfig(
            productIds: ["premium.lifetime", "subscription.monthly"],
            lifetimeIds: ["premium.lifetime"]
        )
        
        StoreKit2Manager.shared.configure(with: config, delegate: self)
    }
    
    // MARK: - StoreKitDelegate
    
    /// 状态更新回调 - 处理所有状态变化
    func storeKit(_ manager: StoreKit2Manager, didUpdateState state: StoreKitState) {
        switch state {
        case .idle:
            print("StoreKit 空闲状态")
            
        case .loadingProducts:
            print("正在加载产品...")
            // 显示加载指示器
            
        case .productsLoaded(let products):
            print("产品加载成功: \(products.count) 个")
            // 更新UI显示产品列表
            
        case .loadingPurchases:
            print("正在加载已购买产品...")
            // 显示加载指示器
            
        case .purchasesLoaded:
            print("已购买产品加载完成")
            // 更新已购买状态UI
            
        case .purchasing(let productId):
            print("正在购买: \(productId)")
            // 显示购买进度，禁用购买按钮
            
        case .purchaseSuccess(let productId):
            print("购买成功: \(productId)")
            // 解锁功能，显示成功提示
            unlockFeature(for: productId)
            
        case .purchasePending(let productId):
            print("购买待处理: \(productId)")
            // 提示用户等待处理（如需要家长批准）
            
        case .purchaseCancelled(let productId):
            print("用户取消购买: \(productId)")
            // 恢复购买按钮状态
            
        case .purchaseFailed(let productId, let error):
            print("购买失败: \(productId), 错误: \(error.localizedDescription)")
            // 显示错误提示，恢复购买按钮状态
            
        case .subscriptionStatusChanged(let status):
            print("订阅状态变化: \(status)")
            // 根据状态更新订阅相关UI
            updateSubscriptionUI(status: status)
            
        case .restoringPurchases:
            print("正在恢复购买...")
            // 显示恢复购买进度
            
        case .restorePurchasesSuccess:
            print("恢复购买成功")
            // 显示成功提示，刷新已购买状态
            
        case .restorePurchasesFailed(let error):
            print("恢复购买失败: \(error.localizedDescription)")
            // 显示错误提示
            
        case .purchaseRefunded(let productId):
            print("购买已退款: \(productId)")
            // 撤销功能，通知用户
            
        case .purchaseRevoked(let productId):
            print("购买已撤销: \(productId)")
            // 撤销功能，通知用户
            
        case .subscriptionCancelled(let productId):
            print("订阅已取消: \(productId)")
            // 更新订阅状态UI
            
        case .error(let error):
            print("发生错误: \(error.localizedDescription)")
            // 显示错误提示
        }
    }
    
    /// 产品加载成功回调
    func storeKit(_ manager: StoreKit2Manager, didLoadProducts products: [Product]) {
        print("产品加载成功回调: \(products.count) 个产品")
        
        // 按类型分类处理
        let nonConsumables = products.filter { $0.type == .nonConsumable }
        let consumables = products.filter { $0.type == .consumable }
        let subscriptions = products.filter { $0.type == .autoRenewable }
        
        print("非消耗品: \(nonConsumables.count) 个")
        print("消耗品: \(consumables.count) 个")
        print("订阅产品: \(subscriptions.count) 个")
        
        // 更新UI显示产品列表
        updateProductsUI(products: products)
    }
    
    /// 已购买交易更新回调
    /// - Parameters:
    ///   - efficient: 已购买的有效交易（当前有效的订阅等）
    ///   - latests: 每个产品的最新交易记录
    func storeKit(_ manager: StoreKit2Manager, didUpdatePurchasedTransactions efficient: [Transaction], latests: [Transaction]) {
        print("已购买交易更新: 有效交易 \(efficient.count) 个, 最新交易 \(latests.count) 个")
        
        // 检查特定产品是否已购买
        let hasPremium = latests.contains { $0.productID == "premium.lifetime" }
        if hasPremium {
            print("用户已购买高级版")
            unlockPremiumFeatures()
        }
        
        // 更新已购买状态UI
        updatePurchasedTransactionsUI(efficient: efficient, latests: latests)
    }
    
    // MARK: - 辅助方法
    
    private func unlockFeature(for productId: String) {
        // 根据产品ID解锁相应功能
    }
    
    private func updateProductsUI(products: [Product]) {
        // 更新产品列表UI
    }
    
    private func updatePurchasedTransactionsUI(efficient: [Transaction], latests: [Transaction]) {
        // 更新已购买交易UI
    }
    
    private func unlockPremiumFeatures() {
        // 解锁高级功能
    }
    
    private func unlockSubscriptionFeatures() {
        // 解锁订阅功能
    }
    
    private func disableSubscriptionFeatures() {
        // 禁用订阅功能
    }
    
    private func showBillingRetryAlert() {
        // 显示计费重试提示
    }
    
    private func showGracePeriodAlert() {
        // 显示宽限期提示
    }
}
```

### 3. 使用闭包方式

```swift
class MyStoreViewController {
    func setupStore() {
        let config = StoreKitConfig(
            productIds: ["premium.lifetime", "subscription.monthly"],
            lifetimeIds: ["premium.lifetime"]
        )
        
        // 配置状态变化回调 - 处理所有状态
        StoreKit2Manager.shared.onStateChanged = { [weak self] state in
            guard let self = self else { return }
            
            switch state {
            case .idle:
                print("StoreKit 空闲状态")
                
            case .loadingProducts:
                print("正在加载产品...")
                self.showLoadingIndicator()
                
            case .productsLoaded(let products):
                print("产品加载成功: \(products.count) 个")
                self.hideLoadingIndicator()
                self.updateProductsList(products)
                
            case .loadingPurchases:
                print("正在加载已购买产品...")
                self.showLoadingIndicator()
                
            case .purchasesLoaded:
                print("已购买产品加载完成")
                self.hideLoadingIndicator()
                self.refreshPurchasedStatus()
                
            case .purchasing(let productId):
                print("正在购买: \(productId)")
                self.showPurchaseProgress(for: productId)
                
            case .purchaseSuccess(let productId):
                print("购买成功: \(productId)")
                self.hidePurchaseProgress()
                self.showSuccessMessage("购买成功！")
                self.unlockFeature(for: productId)
                
            case .purchasePending(let productId):
                print("购买待处理: \(productId)")
                self.showPendingMessage("购买正在处理中，请稍候...")
                
            case .purchaseCancelled(let productId):
                print("用户取消购买: \(productId)")
                self.hidePurchaseProgress()
                self.showMessage("已取消购买")
                
            case .purchaseFailed(let productId, let error):
                print("购买失败: \(productId), 错误: \(error.localizedDescription)")
                self.hidePurchaseProgress()
                self.showErrorMessage("购买失败: \(error.localizedDescription)")
                
            case .subscriptionStatusChanged(let status):
                print("订阅状态变化: \(status)")
                self.updateSubscriptionStatus(status)
                
            case .restoringPurchases:
                print("正在恢复购买...")
                self.showLoadingIndicator()
                
            case .restorePurchasesSuccess:
                print("恢复购买成功")
                self.hideLoadingIndicator()
                self.showSuccessMessage("恢复购买成功！")
                self.refreshPurchasedStatus()
                
            case .restorePurchasesFailed(let error):
                print("恢复购买失败: \(error.localizedDescription)")
                self.hideLoadingIndicator()
                self.showErrorMessage("恢复购买失败: \(error.localizedDescription)")
                
            case .purchaseRefunded(let productId):
                print("购买已退款: \(productId)")
                self.showMessage("购买已退款，功能已撤销")
                self.revokeFeature(for: productId)
                
            case .purchaseRevoked(let productId):
                print("购买已撤销: \(productId)")
                self.showMessage("购买已撤销，功能已禁用")
                self.revokeFeature(for: productId)
                
            case .subscriptionCancelled(let productId):
                print("订阅已取消: \(productId)")
                self.showMessage("订阅已取消")
                self.updateSubscriptionStatus(.expired)
                
            case .error(let error):
                print("发生错误: \(error.localizedDescription)")
                self.showErrorMessage("发生错误: \(error.localizedDescription)")
            }
        }
        
        // 配置产品加载成功回调
        StoreKit2Manager.shared.onProductsLoaded = { [weak self] products in
            guard let self = self else { return }
            
            print("产品加载成功回调: \(products.count) 个产品")
            
            // 按类型分类
            let nonConsumables = products.filter { $0.type == .nonConsumable }
            let consumables = products.filter { $0.type == .consumable }
            let subscriptions = products.filter { $0.type == .autoRenewable }
            
            print("非消耗品: \(nonConsumables.count) 个")
            print("消耗品: \(consumables.count) 个")
            print("订阅产品: \(subscriptions.count) 个")
            
            // 更新UI
            self.updateProductsList(products)
        }
        
        // 配置已购买交易更新回调
        StoreKit2Manager.shared.onPurchasedTransactionsUpdated = { [weak self] efficient, latests in
            guard let self = self else { return }
            
            print("已购买交易更新: 有效交易 \(efficient.count) 个, 最新交易 \(latests.count) 个")
            
            // 检查特定产品
            let hasPremium = latests.contains { $0.productID == "premium.lifetime" }
            if hasPremium {
                print("用户已购买高级版")
                self.unlockPremiumFeatures()
            }
            
            // 更新UI
            self.updatePurchasedStatus(efficient: efficient, latests: latests)
        }
        
        // 启动 StoreKit
        StoreKit2Manager.shared.configure(with: config)
    }
    
    // MARK: - 辅助方法
    
    private func showLoadingIndicator() {
        // 显示加载指示器
    }
    
    private func hideLoadingIndicator() {
        // 隐藏加载指示器
    }
    
    private func updateProductsList(_ products: [Product]) {
        // 更新产品列表
    }
    
    private func refreshPurchasedStatus() {
        // 刷新已购买状态
    }
    
    private func showPurchaseProgress(for productId: String) {
        // 显示购买进度
    }
    
    private func hidePurchaseProgress() {
        // 隐藏购买进度
    }
    
    private func showSuccessMessage(_ message: String) {
        // 显示成功消息
    }
    
    private func showMessage(_ message: String) {
        // 显示消息
    }
    
    private func showErrorMessage(_ message: String) {
        // 显示错误消息
    }
    
    private func showPendingMessage(_ message: String) {
        // 显示待处理消息
    }
    
    private func unlockFeature(for productId: String) {
        // 解锁功能
    }
    
    private func revokeFeature(for productId: String) {
        // 撤销功能
    }
    
    private func updatePurchasedStatus(efficient: [Transaction], latests: [Transaction]) {
        // 更新已购买状态
    }
}
```

### 4. 购买产品

```swift
// 通过产品ID购买
Task {
    do {
        try await StoreKit2Manager.shared.purchase(productId: "premium.lifetime")
    } catch {
        print("购买失败: \(error)")
    }
}

// 通过产品对象购买
if let product = StoreKit2Manager.shared.product(for: "premium.lifetime") {
    Task {
        try await StoreKit2Manager.shared.purchase(product)
    }
}
```

### 5. 查询购买状态

```swift
// 检查是否已购买
if StoreKit2Manager.shared.isPurchased(productId: "premium.lifetime") {
    // 解锁功能
}

// 检查是否通过家庭共享获得
if StoreKit2Manager.shared.isFamilyShared(productId: "premium.lifetime") {
    // 通过家庭共享获得
}

// 获取所有已购买的有效交易
let purchasedTransactions = StoreKit2Manager.shared.purchasedTransactions

// 获取每个产品的最新交易
let latestTransactions = StoreKit2Manager.shared.latestTransactions

// 获取特定类型的已购买产品（从 allProducts 中筛选）
let subscriptions = StoreKit2Manager.shared.autoRenewables
```

### 6. 恢复购买

```swift
// 恢复购买
Task {
    do {
        try await StoreKit2Manager.shared.restorePurchases()
        print("恢复购买成功")
    } catch {
        print("恢复购买失败: \(error)")
    }
}
```

### 6.1. 订阅产品国际化

```swift
// 获取订阅产品标题
let title = StoreKit2Manager.shared.productForVipTitle(
    for: "subscription.monthly",
    periodType: .month,
    languageCode: "zh_Hans",
    isShort: false
)

// 获取订阅产品副标题（异步）
Task {
    let subtitle = await StoreKit2Manager.shared.productForVipSubtitle(
        for: "subscription.monthly",
        periodType: .month,
        languageCode: "zh_Hans"
    )
    print("副标题: \(subtitle)")
}

// 获取订阅按钮文案（异步）
Task {
    let buttonText = await StoreKit2Manager.shared.productForVipButtonText(
        for: "subscription.monthly",
        languageCode: "zh_Hans"
    )
    print("按钮文案: \(buttonText)")
}
```

### 7. 交易历史查询

```swift
// 获取所有交易历史
Task {
    let history = await StoreKit2Manager.shared.getTransactionHistory()
    for transaction in history {
        print("产品: \(transaction.productId), 日期: \(transaction.purchaseDate)")
    }
}

// 获取特定产品的交易历史
Task {
    let history = await StoreKit2Manager.shared.getTransactionHistory(for: "premium.lifetime")
}

// 获取消耗品的购买历史
Task {
    let consumableHistory = await StoreKit2Manager.shared.getConsumablePurchaseHistory(for: "consumable.coins")
}
```

### 8. 订阅详细信息

```swift
// 获取订阅详细信息（返回 Product.SubscriptionInfo）
Task {
    if let subscriptionInfo = await StoreKit2Manager.shared.getSubscriptionInfo(for: "subscription.monthly") {
        // subscriptionInfo 是 Product.SubscriptionInfo 类型
        // 可以访问 subscriptionPeriod, introductoryOffer, promotionalOffers 等属性
        print("订阅周期: \(subscriptionInfo.subscriptionPeriod)")
    }
}

// 获取订阅续订信息（包含续订状态、过期日期等）
Task {
    if let renewalInfo = await StoreKit2Manager.shared.getRenewalInfo(for: "subscription.monthly") {
        print("是否自动续订: \(renewalInfo.willAutoRenew)")
        print("过期日期: \(renewalInfo.expirationDate)")
        print("续订日期: \(renewalInfo.renewalDate)")
    }
}
```

### 9. 订阅管理

```swift
// 方式1: 显示应用内订阅管理界面（推荐，iOS 15.0+ / macOS 12.0+）
// 注意：界面关闭后会自动刷新订阅状态
Task {
    let success = await StoreKit2Manager.shared.showManageSubscriptionsSheet()
    if !success {
        // 如果应用内界面不可用，回退到 URL 方式
        StoreKit2Manager.shared.openSubscriptionManagement()
    }
}

// 方式2: 打开订阅管理页面（使用 URL，兼容所有版本）
StoreKit2Manager.shared.openSubscriptionManagement()

// 方式3: 手动检查订阅状态（获取最新状态）
// 建议在以下时机调用：
// - 应用启动时
// - 应用进入前台时
// - 用户打开订阅页面时
// - 购买/恢复购买后
Task {
    await StoreKit2Manager.shared.checkSubscriptionStatus()
}
```

#### 获取最新订阅状态

当用户取消订阅后，有几种方式获取最新的订阅状态：

1. **自动刷新**：使用 `showManageSubscriptionsSheet()` 时，界面关闭后会自动刷新订阅状态。

2. **手动检查**：调用 `checkSubscriptionStatus()` 方法手动检查订阅状态：

```swift
Task {
    await StoreKit2Manager.shared.checkSubscriptionStatus()
}
```

3. **实时监听**：通过 `StoreKitDelegate` 的 `storeKit(_:didUpdatePurchasedTransactions:latests:)` 方法实时监听交易变化。

4. **查询订阅信息**：使用 `getSubscriptionInfo(for:)` 或 `getRenewalInfo(for:)` 方法查询特定订阅的详细信息：

```swift
Task {
    // 获取订阅信息
    if let subscriptionInfo = await StoreKit2Manager.shared.getSubscriptionInfo(for: "subscription.monthly") {
        print("订阅周期: \(subscriptionInfo.subscriptionPeriod)")
    }
    
    // 获取续订信息（包含状态）
    if let renewalInfo = await StoreKit2Manager.shared.getRenewalInfo(for: "subscription.monthly") {
        print("是否自动续订: \(renewalInfo.willAutoRenew)")
        print("过期日期: \(renewalInfo.expirationDate)")
    }
}
```

### 9.1. 优惠代码兑换

```swift
// 显示优惠代码兑换界面（iOS 16.0+）
Task {
    let success = await StoreKit2Manager.shared.presentOfferCodeRedeemSheet()
    if success {
        // 兑换成功，可以刷新购买状态
        await StoreKit2Manager.shared.refreshPurchases()
    }
}
```

### 10. 手动刷新

```swift
// 刷新产品列表
Task {
    await StoreKit2Manager.shared.refreshProducts()
}

// 刷新已购买交易信息（包括有效的订阅交易和每个产品的最新交易）
Task {
    await StoreKit2Manager.shared.refreshPurchases()
}
```

### 11. 请求应用评价

```swift
// 请求应用评价（兼容 iOS 15.0+ 和 iOS 16.0+）
// 注意：系统会根据用户的使用情况决定是否显示评价弹窗
// 每个应用在每个版本中最多显示 3 次评价请求
StoreKit2Manager.shared.requestReview()
```

## 配置文件格式

### Plist 格式 (StoreKitConfig.plist)

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>productIds</key>
    <array>
        <string>premium.lifetime</string>
        <string>subscription.monthly</string>
        <string>subscription.yearly</string>
    </array>
    <key>lifetimeIds</key>
    <array>
        <string>premium.lifetime</string>
    </array>
    <key>nonRenewableExpirationDays</key>
    <integer>365</integer>
    <key>autoSortProducts</key>
    <true/>
</dict>
</plist>
```

### JSON 格式 (StoreKitConfig.json)

```json
{
    "productIds": [
        "premium.lifetime",
        "subscription.monthly",
        "subscription.yearly"
    ],
    "lifetimeIds": [
        "premium.lifetime"
    ],
    "nonRenewableExpirationDays": 365,
    "autoSortProducts": true
}
```

## 状态枚举

```swift
public enum StoreKitState {
    case idle                           // 空闲
    case loadingProducts                // 正在加载产品
    case productsLoaded([Product])      // 产品加载成功
    case loadingPurchases               // 正在加载已购买产品
    case purchasesLoaded                // 已购买产品加载完成
    case purchasing(String)             // 正在购买
    case purchaseSuccess(String)        // 购买成功
    case purchasePending(String)        // 购买待处理
    case purchaseCancelled(String)      // 用户取消购买
    case purchaseFailed(String, Error)  // 购买失败
    case subscriptionStatusChanged(RenewalState) // 订阅状态变化
    case restoringPurchases             // 正在恢复购买
    case restorePurchasesSuccess        // 恢复购买成功
    case restorePurchasesFailed(Error)  // 恢复购买失败
    case purchaseRefunded(String)      // 购买已退款
    case purchaseRevoked(String)        // 购买已撤销
    case subscriptionCancelled(String)  // 订阅已取消
    case error(Error)                   // 发生错误
}
```

## 错误处理

```swift
public enum StoreKitError: Error {
    case productNotFound(String)        // 产品未找到
    case purchaseFailed(Error)          // 购买失败
    case verificationFailed             // 交易验证失败
    case configurationMissing           // 配置缺失
    case serviceNotStarted              // 服务未启动
    case purchaseInProgress             // 购买正在进行中
    case cancelSubscriptionFailed(Error) // 取消订阅失败
    case restorePurchasesFailed(Error)   // 恢复购买失败
    case unknownError                   // 未知错误
}
```

## 数据模型

### SubscriptionPeriodType（订阅周期类型）

```swift
public enum SubscriptionPeriodType: String {
    case week = "week"       // 周
    case month = "month"     // 月
    case year = "year"       // 年
    case lifetime = "lifetime" // 终身
}
```

### SubscriptionButtonType（订阅按钮类型）

```swift
public enum SubscriptionButtonType: String {
    case standard = "standard"      // 标准订阅
    case freeTrial = "freeTrial"     // 免费试用
    case payUpFront = "payUpFront"  // 预付
    case payAsYouGo = "payAsYouGo"  // 按需付费
    case lifetime = "lifetime"      // 终身会员
}
```

### SubscriptionInfo（订阅信息）

`SubscriptionInfo` 是 `Product.SubscriptionInfo` 的类型别名，包含订阅产品的详细信息：

```swift
public typealias SubscriptionInfo = StoreKit.Product.SubscriptionInfo

// 主要属性：
// - subscriptionPeriod: 订阅周期
// - introductoryOffer: 介绍性优惠
// - promotionalOffers: 促销优惠数组
// - subscriptionGroupID: 订阅组ID
// 等等...
```

### TransactionHistory（交易历史）

```swift
public struct TransactionHistory {
    let productId: String
    let product: Product?
    let transaction: Transaction
    let purchaseDate: Date
    let expirationDate: Date?
    let isRefunded: Bool
    let isRevoked: Bool
    let ownershipType: Transaction.OwnershipType
    let transactionId: UInt64
}
```

## 架构说明

```text
StoreKit2Manager (对外接口)
    ↓
StoreKitService (内部服务)
    ↓
StoreKit API
```

- **StoreKit2Manager**: 提供统一的对外接口，管理配置和回调
- **StoreKitService**: 内部服务层，处理与 StoreKit API 的交互
- **Models**: 配置、状态、错误、订阅信息、交易历史等数据模型
- **Protocols**: 代理协议定义
- **Locals**: 订阅产品国际化支持（SubscriptionLocale）

## 高级功能

### 并发购买保护

库内置了并发购买保护机制，防止同时进行多个购买操作。如果尝试在购买进行中再次购买，会抛出 `StoreKitError.purchaseInProgress` 错误。

```swift
Task {
    do {
        try await StoreKit2Manager.shared.purchase(productId: "premium.lifetime")
    } catch StoreKitError.purchaseInProgress {
        print("已有购买正在进行，请等待完成")
    }
}
```

### 消耗品处理

消耗品购买后会立即完成交易，不会出现在 `currentEntitlements` 中。如果需要查询消耗品的购买历史，使用 `getConsumablePurchaseHistory` 方法。

```swift
// 购买消耗品
try await StoreKit2Manager.shared.purchase(productId: "consumable.coins")

// 查询消耗品购买历史
let history = await StoreKit2Manager.shared.getConsumablePurchaseHistory(for: "consumable.coins")
```

### 自动处理退款和撤销

库会自动监听交易状态变化，当发生退款或撤销时，会通过状态回调通知：

```swift
func storeKit(_ manager: StoreKit2Manager, didUpdateState state: StoreKitState) {
    switch state {
    case .purchaseRefunded(let productId):
        print("产品已退款: \(productId)")
        // 撤销用户权限
    case .purchaseRevoked(let productId):
        print("购买已撤销: \(productId)")
        // 撤销用户权限
    case .subscriptionCancelled(let productId):
        print("订阅已取消: \(productId)")
        // 处理订阅取消
    default:
        break
    }
}
```

## 注意事项

1. 确保在 App Store Connect 中配置了所有产品ID
2. 在真机上测试购买功能（模拟器不支持）
3. 使用沙盒测试账号进行测试
4. 所有回调都在主线程执行，可以直接更新UI
5. 服务会自动监听交易状态变化，无需手动刷新
6. 消耗品购买后会立即完成交易，不会保留在 entitlements 中
7. 恢复购买会同步所有已购买的产品，包括在其他设备上购买的
8. 订阅取消需要通过系统设置完成，应用内只能打开设置页面
9. `purchasedTransactions` 包含当前有效的交易（如活跃的订阅），`latestTransactions` 包含每个产品的最新交易记录
10. 使用国际化功能时，确保传入正确的 `languageCode`（如 "zh_Hans"、"en" 等）
11. 订阅产品的标题、副标题和按钮文案获取是异步的，在 SwiftUI 中使用 `.task` 修饰符加载
12. 终身会员产品需要在配置中通过 `lifetimeIds` 指定，以便正确显示本地化文案

## 生命周期管理

```swift
// 启动服务（在 configure 时自动启动）
StoreKit2Manager.shared.configure(with: config, delegate: self)

// 停止服务（释放资源）
StoreKit2Manager.shared.stop()
```

## 订阅产品国际化

StoreKit2Manager 提供了完整的订阅产品国际化支持，包括标题、副标题和按钮文案的本地化。

### 使用示例

```swift
// 在 SwiftUI 视图中使用
struct SubscriptionProductRow: View {
    let product: Product
    @State private var customTitle: String = ""
    @State private var customSubtitle: String = ""
    @State private var customButtonText: String = "订阅"
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(customTitle.isEmpty ? product.displayName : customTitle)
                .font(.headline)
            
            Text(customSubtitle.isEmpty ? product.description : customSubtitle)
                .font(.caption)
                .foregroundColor(.secondary)
            
            Button(customButtonText) {
                // 购买逻辑
            }
        }
        .task {
            await loadCustomContent()
        }
    }
    
    private func loadCustomContent() async {
        let languageCode = SubscriptionLocale.currentLanguageCode()
        let periodType = SubscriptionLocale.getPeriodType(from: product)
        
        // 加载标题（同步）
        customTitle = StoreKit2Manager.shared.productForVipTitle(
            for: product.id,
            periodType: periodType,
            languageCode: languageCode,
            isShort: false
        )
        
        // 加载副标题和按钮文案（异步，并发执行）
        async let subtitleTask = StoreKit2Manager.shared.productForVipSubtitle(
            for: product.id,
            periodType: periodType,
            languageCode: languageCode
        )
        
        async let buttonTextTask = StoreKit2Manager.shared.productForVipButtonText(
            for: product.id,
            languageCode: languageCode
        )
        
        let (subtitle, buttonText) = await (subtitleTask, buttonTextTask)
        customSubtitle = subtitle
        customButtonText = buttonText
    }
}
```

### 支持的语言

- 简体中文 (zh_Hans)
- 繁体中文 (zh_Hant)
- 英语 (en)
- 日语 (ja)
- 韩语 (ko)
- 以及其他多种语言

### 功能特性

- 自动识别订阅周期类型（周、月、年、终身）
- 支持介绍性优惠和促销优惠的本地化描述
- 根据支付模式（免费试用、预付、按需付费）显示不同的按钮文案
- 自动格式化价格显示（支持不同地区的货币格式）

## 官方文档

官方App内购买项目文档StoreKit 2.0

<https://developer.apple.com/cn/in-app-purchase/>

<https://developer.apple.com/documentation/storekit/in-app-purchase>

<https://developer.apple.com/documentation/storekit/implementing-a-store-in-your-app-using-the-storekit-api>

## 许可证

MIT License
