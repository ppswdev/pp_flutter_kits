# pp_inapp_purchase Android Billing 对接说明

## 当前能力

Android 原生实现使用 Google Play Billing Library `9.1.0`。商品查询、购买和恢复继续复用原有 Dart API；另提供可选的延迟确认配置和后台验单完成接口。iOS 收到该接口时为空操作，不改变 StoreKit 流程。

当前支持：

- 自动续订：周订阅、年订阅。
- 一次性商品：终身买断，按非消耗型商品处理。
- 查询 Google Play 商品和当前购买。
- 自动选择当前 Play 账号可用的 offer。
- 处理 `PENDING`、`PURCHASED`、用户取消和购买失败。
- 支持等待业务后台验单后再 acknowledge。
- 恢复购买、刷新购买、打开 Google Play 订阅管理页。
- 返回 purchase token，供服务端验证。
- 标题、副标题和购买按钮支持与 iOS `SubscriptionLocale.swift` 对应的语言。

暂不支持：

- 消耗型商品。
- 预付费订阅计划。
- 同一商品多个 base plan/offer 的手动 UI 选择。
- 订阅升级、降级和 replacement mode。
- Android 客户端直接获取权威订阅到期时间。

后三项如果需要由 Flutter UI 指定，必须扩展 Dart `purchase()` 参数，修改前应先确认接口方案。

## Android 原生代码结构

Android 实现按与 iOS StoreKit2Manager 相近的职责拆分，所有 Kotlin 文件仍使用
`com.ppswdev.inapp_purchase` 包名：

| 路径 | 职责 |
| --- | --- |
| `InappPurchasePlugin.kt` | Flutter MethodChannel/EventChannel 注册、方法分发和 Activity 生命周期 |
| `Internal/GooglePlayBillingManager.kt` | BillingClient 连接、商品查询、购买、恢复、acknowledge 和权益快照 |
| `Internal/BillingStreamHandler.kt` | 在 Android 主线程向 Flutter 发送事件 |
| `Converts/BillingDataConverter.kt` | ProductDetails/Purchase 转 Flutter Map、offer 选择、价格和周期转换 |
| `Loggers/BillingLogger.kt` | `[pp_inapp_purchase][NATIVE]` 日志、响应摘要和 token 脱敏 |
| `Locals/SubscriptionLocale.kt` | Android 订阅标题、副标题和按钮本地化 |

维护规则：

1. 新增或修改 Flutter 方法名时，只在 `InappPurchasePlugin.kt` 处理参数和分发。
2. 修改购买、恢复、查询、acknowledge 或 BillingClient 生命周期时，进入
   `GooglePlayBillingManager.kt`。
3. 修改 Flutter 接收字段、offer 选择或商品排序时，进入
   `BillingDataConverter.kt`，并保持 iOS/Dart 模型字段兼容。
4. 原生层不得直接调用 `Log.*`，统一使用 `BillingLogger`，禁止输出完整
   purchase token。
5. EventChannel 事件必须由 `BillingStreamHandler` 切换到主线程发送。

## 商品配置

Flutter 侧继续调用：

```dart
await InappPurchase.instance.configure(
  productIds: SubsConfig.subsProductIds,
  lifetimeIds: SubsConfig.subsLifetimeIds,
  autoSortProducts: true,
  showLog: false,
  deferAndroidAcknowledgement: false,
);
```

`deferAndroidAcknowledgement` 支持两种业务模式：

- `false`：原生层在购买成功后立即 acknowledge，确认成功后发送
  `purchaseSuccess`，并为交易提供 24 小时客户端临时权益期限。业务层可先开放
  权益，再异步使用后台结果覆盖本地状态。Finger Chooser 当前使用此模式。
- `true`：先发送 `purchaseVerificationRequired`，业务后台确认后再调用
  `completePurchaseVerification()` acknowledge，适合严格的服务端先验单模式。

当前 Android 商品：

| 类型 | Product ID | Play Console 配置 |
| --- | --- | --- |
| 引导页周订阅 | `chooser_guide_trial_weekly_vip` | Subscription，自动续订周 base plan，可配置新用户优惠 |
| 应用内周订阅 | `chooser_vip_9.99` | Subscription，自动续订周 base plan |
| 应用内年订阅 | `chooser_yearly_vip` | Subscription，自动续订年 base plan |
| 终身买断 | `chooser_origin_lifetime_price` | One-time product，非消耗型 |

每个订阅商品目前应只配置一个需要应用主动选择的 base plan。可以配置一个符合资格的免费试用或介绍优惠；插件会按以下顺序选择 Play 返回的可用 offer：

1. 免费试用。
2. 其他带 `offerId` 的优惠。
3. 基础 base plan。

Google Play 只向客户端返回当前账号符合资格的 offer。实际发起购买和 UI 价格展示使用同一个 offer token。

## 现有 API

```dart
await InappPurchase.instance.getAllProducts();
await InappPurchase.instance.getAutoRenewablesProducts();
await InappPurchase.instance.getNonConsumablesProducts();

await InappPurchase.instance.purchase(productId: productId);
await InappPurchase.instance.completePurchaseVerification(
  purchaseToken: purchaseToken,
  approved: true,
  emitPurchaseSuccess: true,
);
await InappPurchase.instance.restorePurchases();
await InappPurchase.instance.refreshPurchases();

final valid = await InappPurchase.instance.getValidPurchasedTransactions();
final latest = await InappPurchase.instance.getLatestTransactions();
```

`getValidPurchasedTransactions()`：

- 只返回 `PurchaseState.PURCHASED`。
- 只返回当前配置的商品。
- 必须在 SUBS 与 INAPP 两类查询均成功后才原子更新。
- 开启 `deferAndroidAcknowledgement` 时，列表是等待后台验单的当前购买候选，不等同于已授权权益。
- 关闭该配置时，原生层先 acknowledge 再发送购买成功；列表仍只作为后台对账候选，不能替代 Developer API 的权威状态。
- SUBS 或 INAPP 查询失败时抛出错误并保留上一轮快照，不会伪装成空订单。

`getLatestTransactions()`：

- 只用于本次进程已观察到的购买历史、首次购买判断和诊断。
- 不得用于授予会员权益。
- BillingClient 不提供完整的已过期历史；完整历史必须由服务端保存。

## Transaction 字段

Android 返回的关键字段：

| 字段 | Android 含义 |
| --- | --- |
| `id` | Google Play `orderId`；缺失时使用 purchase token |
| `productID` | Google Play product ID |
| `originalID` | purchase token |
| `appTransactionID` | purchase token |
| `appBundleID` | Android package name |
| `purchaseDate` | BillingClient 返回的 purchase time |
| `expirationDate` | 延迟确认模式下为 `null`；立即确认模式下为 24 小时临时权益期限，权威到期时间仍使用后台返回值 |

服务端验证时优先读取：

```dart
final purchaseToken =
    transaction.appTransactionID ?? transaction.originalID;
```

## 到期时间与服务端验证

BillingClient 的 `queryPurchasesAsync()` 可以判断商品当前是否仍由账号持有，但不会返回 Google Play 权威订阅到期时间。

Finger Chooser 使用“客户端先确认和临时授权、后台最终对账”模式，并接入以下业务接口：

```text
POST /api/gpa/{packageName}/subscription-status
```

AES 加密前业务参数：

```json
{
  "userId": "<APP_USER_ID>",
  "productId": "<PRODUCT_ID>",
  "purchaseType": "<SUBSCRIPTION|ONE_TIME_LIFETIME>",
  "purchaseToken": "<PURCHASE_TOKEN>"
}
```

实际 HTTP Body：

```json
{
  "data": "<AES encrypted payload>"
}
```

响应关键字段：

```json
{
  "code": 0,
  "data": {
    "entitled": true,
    "productId": "<PRODUCT_ID>",
    "expiryTime": "<EPOCH_MILLIS_OR_ISO8601_WITH_OFFSET>",
    "autoRenewing": true,
    "subscriptionStatus": "<GOOGLE_SUBSCRIPTION_STATE>"
  }
}
```

客户端闭环：

1. BillingClient 收到 `PURCHASED` 后先 acknowledge；确认失败时发送购买失败，不授予权益。
2. acknowledge 成功后发送 `purchaseSuccess`，Flutter 立即授予最多 24 小时的临时会员权益。
3. Flutter 延迟异步提交 product ID、purchase type、user ID 和 purchase token 到后台，不阻塞购买成功页面。
4. 后台返回 `entitled=true` 且商品、到期时间有效时，Flutter 用权威到期时间覆盖临时权益；终身商品此时才写入长期权益。
5. 后台明确返回无效时撤销临时权益；网络或服务异常时保留临时权益，并在启动、恢复购买和进入前台时重试，临时权益最长保留 24 小时。

服务端必须：

1. 使用 `purchases.subscriptionsv2.get` 验证订阅 token。
2. 使用 `purchases.products.get` 验证终身买断 token。
3. 校验 package name、product ID、购买状态和 acknowledgement 状态。
4. 使用 purchase token 作为唯一键，防止重复绑定和重放。
5. 处理 `linkedPurchaseToken`，撤销被替换的旧权益。
6. 保存 Google 返回的真实 `expiryTime`。
7. 接入 RTDN，及时处理续订、取消、宽限期、暂停、过期、退款和撤销。
8. 接入 Voided Purchases API，回收退款、拒付和撤销订单的权益。
9. 到期时间返回 epoch milliseconds 或带时区偏移的 ISO 8601；旧版无时区字符串按 UTC+8 兼容解析，不应继续作为新接口格式。

## Play Console 验收

1. 创建并激活两个订阅商品及其 base plan。
2. 创建并激活终身一次性商品。
3. 将测试账号加入 License testing。
4. 上传包含 Billing 权限的 AAB 到 Internal testing。
5. License tester 可以侧载包名一致的本地 APK 快速联调；发布前仍须使用从
   Google Play 内部测试轨道安装的测试包完成正式验收。
6. 分别测试成功、取消、PENDING 后完成、PENDING 后取消、恢复购买。
7. 测试取消自动续订后当前周期内仍有效，到期后失效。
8. 测试订阅退款/撤销和终身商品退款后，重新进入前台会清除权益。
9. 上线前更新隐私政策、用户条款、Play Console SDK 说明和 Data safety，删除“Android 不启用 Google Play Billing”的旧声明。
