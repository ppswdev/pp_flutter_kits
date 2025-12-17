<p align="center">
  <img src="https://developer.apple.com/assets/elements/icons/storekit/storekit-128x128_2x.png" alt="StoreKit2">
</p>

# inapp_purchase

一个功能完整的 Flutter 应用内购插件，支持 iOS(StoreKit2) 和 Android 平台，提供统一的 API 接口来管理应用内购买功能。

## 功能特性

- ✅ 支持消耗型产品、非消耗型产品和订阅产品
- ✅ 提供产品信息获取和管理功能
- ✅ 支持购买、恢复购买和刷新购买信息
- ✅ 提供订阅状态检查和管理功能
- ✅ 支持家庭共享检查
- ✅ 支持介绍性优惠资格检查
- ✅ 提供应用内评价请求功能
- ✅ 支持订阅管理页面和优惠码兑换
- ✅ 提供状态变化、产品加载和交易更新的流事件
- ✅ 支持产品自动排序和自定义配置

## 安装

在 `pubspec.yaml` 文件中添加以下依赖：

```yaml
dependencies:
  pp_inapp_purchase: ^1.0.2
```

然后运行 `flutter pub get` 命令安装依赖。

## 使用示例

### 初始化和配置

```dart
import 'package:pp_inapp_purchase/inapp_purchase.dart';

// 初始化插件
final InappPurchase inappPurchase = InappPurchase.instance;

// 配置应用内购
await inappPurchase.configure(
  productIds: ['product_id_1', 'product_id_2', 'subscription_id_1'],
  lifetimeIds: ['lifetime_product_id'],
  nonRenewableExpirationDays: 7,
  autoSortProducts: true,
  showLog: false,
);
```

### 监听事件流

```dart
// 监听状态变化
inappPurchase.onStateChanged.listen((state) {
  print('状态变化: $state');
});

// 监听产品加载完成
inappPurchase.onProductsLoaded.listen((products) {
  print('产品加载完成，共 ${products.length} 个产品');
});

// 监听交易更新
inappPurchase.onPurchasedTransactionsUpdated.listen((transaction) {
  print('交易更新: $transaction');
});
```

### 获取产品信息

```dart
// 获取所有产品
List<Product> allProducts = await inappPurchase.getAllProducts();

// 获取非消耗型产品
List<Product> nonConsumables = await inappPurchase.getNonConsumablesProducts();

// 获取消耗型产品
List<Product> consumables = await inappPurchase.getConsumablesProducts();

// 获取自动续订订阅产品
List<Product> autoRenewables = await inappPurchase.getAutoRenewablesProducts();

// 获取单个产品信息
Product? product = await inappPurchase.getProduct(productId: 'product_id_1');
```

### 购买产品

```dart
try {
  await inappPurchase.purchase(productId: 'product_id_1');
  print('购买成功');
} catch (e) {
  print('购买失败: $e');
}
```

### 恢复购买

```dart
try {
  await inappPurchase.restorePurchases();
  print('恢复购买成功');
} catch (e) {
  print('恢复购买失败: $e');
}
```

### 检查购买状态

```dart
// 检查产品是否已购买
bool isPurchased = await inappPurchase.isPurchased(productId: 'product_id_1');

// 检查产品是否通过家庭共享获得
bool isFamilyShared = await inappPurchase.isFamilyShared(productId: 'product_id_1');

// 检查产品是否在有效订阅期间内但在免费试用期已取消
bool isFamilyShared = await inappPurchase.isSubscribedButFreeTrailCancelled(productId: 'product_id_1');

// 检查订阅状态
await inappPurchase.checkSubscriptionStatus();
```

### 其他功能

```dart
// 获取VIP订阅产品的标题
String title = await inappPurchase.getProductForVipTitle(
  productId: 'subscription_id_1',
  periodType: SubscriptionPeriodType.monthly,
  langCode: 'zh_CN',
);

// 打开订阅管理页面
await inappPurchase.showManageSubscriptionsSheet();

// 请求应用内评价
inappPurchase.requestReview();
```

## API 参考

### 配置方法

- `configure()`: 配置应用内购
  - `productIds`: 所有产品ID列表
  - `lifetimeIds`: 终身会员产品ID列表
  - `nonRenewableExpirationDays`: 非续订订阅的过期天数
  - `autoSortProducts`: 是否自动按价格排序产品
  - `showLog`: 是否显示日志

### 产品管理

- `getAllProducts()`: 获取所有产品
- `getNonConsumablesProducts()`: 获取非消耗型产品
- `getConsumablesProducts()`: 获取消耗型产品
- `getNonRenewablesProducts()`: 获取非自动续订订阅产品
- `getAutoRenewablesProducts()`: 获取自动续订订阅产品
- `getProduct()`: 获取单个产品信息

### 购买操作

- `purchase()`: 购买指定产品
- `restorePurchases()`: 恢复购买
- `refreshPurchases()`: 刷新购买信息

### 状态检查

- `isPurchased()`: 检查产品是否已购买
- `isFamilyShared()`: 检查产品是否通过家庭共享获得
- `isEligibleForIntroOffer()`: 检查是否符合享受介绍性优惠资格
- `isSubscribedButFreeTrailCancelled()`: 检查产品是否在有效订阅期间内但在免费试用期已取消
- `checkSubscriptionStatus()`: 检查订阅状态

### 其他功能

- `getProductForVipTitle()`: 获取VIP订阅产品的标题
- `getProductForVipSubtitle()`: 获取VIP订阅产品的副标题
- `getProductForVipButtonText()`: 获取VIP订阅产品的按钮文本
- `showManageSubscriptionsSheet()`: 打开订阅管理页面
- `presentOfferCodeRedeemSheet()`: 打开介绍性优惠码兑换页面
- `requestReview()`: 请求应用内评价

### 事件流

- `onStateChanged`: 状态变化流
- `onProductsLoaded`: 产品加载完成流
- `onPurchasedTransactionsUpdated`: 交易更新流

## 平台特定配置

### iOS

1. 在 Xcode 中打开项目，选择 `Runner` 目标
2. 进入 `Signing & Capabilities` 标签页
3. 点击 `+ Capability` 按钮，添加 `In-App Purchase` 能力
4. 在 App Store Connect 中创建应用内购买产品

### Android

1. 在 `AndroidManifest.xml` 文件中添加必要的权限
2. 在 Google Play Console 中创建应用内购买产品
3. 配置 billing_client 版本

## 注意事项

1. 确保在调用任何购买相关方法之前配置好插件
2. 监听事件流以获取实时的状态变化和交易信息
3. 在适当的时机请求应用内评价，避免影响用户体验
4. 处理好错误情况，提供友好的用户提示
5. 定期刷新购买信息以确保数据的准确性

## 许可证

MIT License

## 贡献

欢迎提交 Issue 和 Pull Request！

## 联系方式

如有问题或建议，请通过 GitHub Issues 联系我们。
