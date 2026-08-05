# pp_inapp_purchase

一个功能完整的 Flutter 应用内购插件，支持 Apple(StoreKit2) 和 Android 平台，提供统一的 API 接口来管理应用内购买功能。

| 平台     | 支持状态       | 最低版本 |
|----------|----------------|----------|
| iOS      | ✅ 已支持       | 15.0+    |
| macOS    | 🧪 开发测试中   | —        |
| Android  | ✅ 已支持       | API 24+  |
| HarmonyOS| ❌ 暂不支持     | —        |

Android 使用 Google Play Billing Library 9.1.0。商品配置、接口语义、测试流程和服务端验证要求见 [ANDROID_BILLING.md](ANDROID_BILLING.md)。

## 功能特性

- ✅ iOS 支持消耗型、非消耗型和订阅产品
- ✅ Android 支持自动续订和非消耗型一次性商品
- ✅ 提供产品信息获取和管理功能
- ✅ 支持购买、恢复购买和刷新购买信息
- ✅ 提供订阅状态检查和管理功能
- ✅ 支持 iOS 家庭共享检查
- ✅ 支持介绍性优惠资格检查
- ✅ 支持订阅管理页面
- ✅ iOS 支持优惠码兑换
- ✅ 提供状态变化、产品加载和交易更新的流事件
- ✅ 支持产品自动排序和自定义配置

## 安装

在 `pubspec.yaml` 文件中添加以下依赖：

```yaml
dependencies:
  pp_inapp_purchase: ^1.2.0
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
  // Android only. false: acknowledge first; true: verify first.
  deferAndroidAcknowledgement: false,
);
```

### Android 配置与购买

Android 支持 Google Play 自动续订订阅和非消耗型一次性商品。商品 ID 必须已经在
Google Play Console 创建并激活，并包含在上传到测试轨道的应用版本中。

```dart
import 'dart:io';

import 'package:pp_inapp_purchase/inapp_purchase.dart';

const androidSubscriptions = <String>[
  'your_weekly_subscription',
  'your_yearly_subscription',
];
const androidLifetime = 'your_lifetime_product';

final purchase = InappPurchase.instance;

await purchase.configure(
  productIds: <String>[
    ...androidSubscriptions,
    androidLifetime,
  ],
  lifetimeIds: const <String>[androidLifetime],
  showLog: true,
  deferAndroidAcknowledgement: false,
);

final products = await purchase.getAllProducts();
await purchase.purchase(productId: androidSubscriptions.first);

// 冷启动、回到前台和恢复购买后都应主动刷新并读取当前购买。
await purchase.refreshPurchases();
final currentPurchases =
    await purchase.getValidPurchasedTransactions();

if (Platform.isAndroid) {
  await purchase.showManageSubscriptionsSheet();
}
```

`deferAndroidAcknowledgement: false` 是默认模式。BillingClient 收到 `PURCHASED`
后先 acknowledge，成功后发送 `purchaseSuccess`。应用可立即展示短期临时权益，
但必须将 purchase token 发送业务服务端，并使用 Google Play Developer API 的
结果覆盖客户端状态。

### Android purchase token 与服务端验证

```dart
purchase.onStateChanged.listen((state) async {
  if (state['type'] != StoreKitState.purchaseSuccess ||
      state['transaction'] is! Map) {
    return;
  }

  final transaction = Transaction.fromMap(
    Map<String, dynamic>.from(state['transaction'] as Map),
  );
  final purchaseToken =
      transaction.appTransactionID ?? transaction.originalID;
  if (purchaseToken == null || purchaseToken.isEmpty) return;

  // TODO: 通过 HTTPS 把 productID 和 purchaseToken 发给业务服务端。
  // 订阅使用 purchases.subscriptionsv2.get；一次性商品使用
  // purchases.products.get。不要在客户端保存服务账号密钥。
});
```

如果业务要求服务端通过后才 acknowledge，可启用延迟确认模式：

```dart
await purchase.configure(
  productIds: const ['your_weekly_subscription', 'your_lifetime_product'],
  lifetimeIds: const ['your_lifetime_product'],
  deferAndroidAcknowledgement: true,
);

purchase.onStateChanged.listen((state) async {
  if (state['type'] != StoreKitState.purchaseVerificationRequired ||
      state['transaction'] is! Map) {
    return;
  }

  final transaction = Transaction.fromMap(
    Map<String, dynamic>.from(state['transaction'] as Map),
  );
  final token = transaction.appTransactionID ?? transaction.originalID;
  if (token == null || token.isEmpty) return;

  final approved = await verifyPurchaseWithYourBackend(transaction);
  await purchase.completePurchaseVerification(
    purchaseToken: token,
    approved: approved,
    emitPurchaseSuccess: approved,
  );
});
```

上例中的 `verifyPurchaseWithYourBackend` 由接入方实现。服务端不可用时不要传入
`approved: true`，并应在下一次启动、回到前台或恢复购买时重试。

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

常用 Android 状态：

| 状态 | 说明 |
| --- | --- |
| `purchasing` | 已开始拉起 Google Play 购买流程 |
| `purchasePending` | 付款待处理，不应授予权益 |
| `purchaseSuccess` | 已完成 acknowledge；默认模式的购买成功事件 |
| `purchaseVerificationRequired` | 延迟确认模式下等待业务后台验证 |
| `purchaseCancelled` | 用户关闭购买页 |
| `purchaseFailed` | BillingClient 或 acknowledge 失败 |
| `purchasesLoaded` | 当前 SUBS/INAPP 购买快照已刷新 |

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
bool isTrialCancelled = await inappPurchase.isSubscribedButFreeTrailCancelled(productId: 'product_id_1');

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
  - `deferAndroidAcknowledgement`: Android 是否等待业务后台验证后再 acknowledge，默认 `false`

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

1. 在 Google Play Console 中创建并激活订阅、base plan 和一次性商品
2. 上传 AAB 到测试轨道，并使用 License testing 账号安装测试
3. Billing 权限和 Billing Library 9.1.0 由插件 Android 模块提供
4. 按 [ANDROID_BILLING.md](ANDROID_BILLING.md) 接入服务端 purchase token 验证

Android 注意事项：

- 当前不支持消耗型商品、预付费订阅、订阅升级/降级和手动选择多个 base plan。
- `queryPurchasesAsync()` 不提供权威订阅到期时间，不能使用客户端时间推算权益。
- `getLatestTransactions()` 仅代表本次进程观察到的购买，不是完整历史订单。
- 终身商品必须在 `lifetimeIds` 中声明，并在 Play Console 配置为非消耗型一次性商品。
- 退款、撤销、到期、Grace period 和 Account hold 应由服务端结合 RTDN 与
  Voided Purchases API 维护。
- 普通日志不得输出完整 purchase token；插件日志统一使用
  `[pp_inapp_purchase]` 前缀并对 token 脱敏。

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
