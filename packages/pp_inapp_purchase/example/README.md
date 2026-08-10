# pp_inapp_purchase example

该示例展示 `pp_inapp_purchase 1.2.1` 在 iOS StoreKit 2 和 Android Google Play
Billing Library 9.1.0 上的统一调用方式。

## Android 运行准备

1. 在 Google Play Console 创建并激活自动续订订阅、base plan 和非消耗型一次性商品。
2. 修改 `lib/main.dart` 中的以下占位 ID：
   - `android_weekly_subscription`
   - `android_yearly_subscription`
   - `android_lifetime_product`
3. 将 `android/app/build.gradle.kts` 的 `applicationId` 修改为 Play Console 中的应用包名。
4. 上传签名 AAB 到 Internal testing，并把测试账号同时加入测试轨道和 License testing。
5. 使用测试账号从 Google Play 安装应用，或在 Play 已识别该包名后侧载本地调试包。

插件 Android Manifest 已声明 `com.android.vending.BILLING` 权限，宿主应用无需重复
声明。运行前仍应检查最终合并后的 Manifest。

```bash
flutter pub get
flutter run
```

## Android 示例流程

1. 点击“配置应用内购”。
2. 确认订阅与终身商品能够加载，并显示 Play 返回的价格。
3. 点击商品的“购买”，使用 License Tester 的测试付款方式完成订单。
4. 观察 `purchasePending`、`purchaseSuccess`、取消和失败事件。
5. 购买成功后查看脱敏的 order ID 与 purchase token 后缀。
6. 点击“刷新当前购买”检查 `SUBS` 与 `INAPP` 当前快照。
7. 点击“管理 Google Play 订阅”测试取消自动续订。

示例使用：

```dart
deferAndroidAcknowledgement: false
```

此模式由原生层先 acknowledge，再发送 `purchaseSuccess`。示例只展示如何取得
purchase token，不包含业务服务器地址、加密方式或服务账号。正式应用必须将 token
通过 HTTPS 发给自己的服务端：订阅使用 `purchases.subscriptionsv2.get` 验证，
一次性商品使用 `purchases.products.get` 验证。

服务端先验单再 acknowledge 的用法见插件根目录
[README.md](../README.md#android-purchase-token-与服务端验证) 和
[ANDROID_BILLING.md](../ANDROID_BILLING.md)。

## iOS 运行准备

1. 修改 `lib/main.dart` 中的 iOS 商品占位 ID。
2. 在 App Store Connect 或 StoreKit Configuration 中创建对应商品。
3. 在 Xcode 为 Runner 添加 In-App Purchase capability。
4. 使用 StoreKit 测试或 Sandbox Apple Account 运行。

## 说明

- Android 1.2.1 支持自动续订订阅和非消耗型一次性商品，暂不支持消耗型商品。
- 当前购买快照不是完整购买历史，也不能提供 Android 权威订阅到期时间。
- 不要在客户端放置 Google Play 服务账号 JSON 或其他服务端密钥。
- 完整 purchase token 不应写入正式日志。
