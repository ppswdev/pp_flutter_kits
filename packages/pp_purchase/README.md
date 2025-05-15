
Easy-to-use in-app purchases that can callback results and facilitate operational tracking

## Features

- Configurable
- Callable function

## Getting started

### Install command

``` bash
flutter pub add pp_purchase
```

### Init method

``` dart
//初始化所有内购对象
Future<void> initialize(List<String> productIds,{required String sharedSecret, bool showLog = false}) async
```

### Load all products

``` dart
//加载所有产品
SubPurchase.instance.loadProducts();
```

### Load all purcharsed products

``` dart
//加载所有已购买产品
SubPurchase.instance.loadPurchasedProducts();
```

### Check product is purchased?

``` dart
//判断产品是否已购买过
SubPurchase.instance.hasPurchased('vip_weekly');
```

### Get latest purchase product

``` dart
//获取最新购买的产品信息对象
SubPurchase.instance.latestPurchasedProducts;
```

### Get latest purchase timestamp

``` dart
//获取最后一次购买时间戳
SubPurchase.instance.lastPurchaseTimeMs;
```

### Get all purchased products

``` dart
//获取所有已购买的产品
SubPurchase.instance.allPurchasedProducts;
```

## Usage

### Step1: Create `constants.dart` file

Config your subscription constants

``` dart
// 订阅配置
  static const String subs_weekly = 'vip_weekly';
  static const String subs_weekly_inapp = 'vip_weekly_inapp';
  static const String subs_annual_inapp = 'vip_annually_inapp';
  static const String subs_lifelong_inapp = 'lifelong_vip';
  static const List<String> subs_productIds = [
    subs_weekly,
    subs_weekly_inapp,
    subs_annual_inapp,
    subs_lifelong_inapp
  ];
  static const List<String> subsOneTimeIds = [subs_lifelong_inapp];
  static const String sharedSecret = 'your shared secret value';
  static const bool showSubLogs = true;
```

### Step2: First launch call init

You can create a global singleton file and save the code.

``` dart
  // 最后一次购买时间
  int _lastPurchaseTime = 0;
  int get lastPurchaseTime => _lastPurchaseTime;
  Future<void> setLastPurchaseTime(int value) async {
    if (_lastPurchaseTime != value) {
      _lastPurchaseTime = value;
      //Use Shared Preferences to save value
      await getSp().setInt('lastPurchaseTime', value);
    }
  }

void initInAppPurchase() {
    checkVip();
    if (!isVip) {
      Logger.trace('SubsPurchase 检测到不是会员，初始化订阅');
      // init 
      SubsPurchase.instance.initialize(Consts.subs_productIds, Consts.subsOneTimeIds, 
                sharedSecret: Consts.sharedSecret, showLog: Consts.showSubLogs);
      SubsPurchase.instance.lastPurchaseTimeMs = lastPurchaseTime;
      // Request all purchased products detail infomation
      SubsPurchase.instance.loadPurchasedProducts().then((value) {
        // After loaded purchased logic code
        //refreshVip();
        Logger.trace('uploadsign 初始化首次订阅信息');
        initFirstBuyInfo();
      });
      SubsPurchase.instance.loadProducts();
    } else {
      Logger.trace('SubsPurchase 检测到是会员，不初始化订阅');
    }
  }

  Future<bool> initFirstBuyInfo() async {
    //获取首次订阅信息
    final allPurchasedProducts = SubsPurchase.instance.allPurchasedProducts;
    int firstPurchaseTime = DateTime.now().millisecondsSinceEpoch;
    String? firstOriginalTransactionId;
    String? firstOriginalPurchaseDateMs;
    if (allPurchasedProducts.isEmpty) {
      Logger.trace('uploadsign 首次订阅信息为空');
      return false;
    }
    for (var element in allPurchasedProducts) {
      final purchaseTime = int.parse(element['purchase_date_ms'].toString());
      if (purchaseTime < firstPurchaseTime) {
        firstPurchaseTime = purchaseTime;
        firstOriginalTransactionId = element['original_transaction_id'];
        firstOriginalPurchaseDateMs = element['original_purchase_date_ms'];
        await SharepUtil.setString(
            'firstBuyOriginTransactionId', firstOriginalTransactionId!);
        await SharepUtil.setString(
            'firstBuyOriginalPurchaseDateMs', firstOriginalPurchaseDateMs!);
        Logger.trace(
            'uploadsign 首次订阅时间: ${DateTime.fromMillisecondsSinceEpoch(int.parse(firstOriginalPurchaseDateMs))}');
        Logger.trace('uploadsign 首次订阅原始交易ID: $firstOriginalTransactionId');
      }
    }
    return true;
  }

```

### Step3: Purchase product

``` dart
SubsPurchase.instance.purchaseProduct(
      productId,
      callback: (result) {
        //判断是否已经是会员，如果是，则不继续处理购买结果
        if (app.isVip) {
          Logger.trace('SubsPurchase 已经是会员，不处理购买结果');
          return;
        }

        // 处理购买结果
        String message;
        switch (result.status) {
          case IAPPurchaseStatus.purchasing:
            message = '${result.message}...';
            break;
          case IAPPurchaseStatus.verifying:
            message = '正在验证购买凭据...';
            EasyLoading.show(status: 'IAP_Verifying'.localized);
            break;
          case IAPPurchaseStatus.verifyingFailed:
            message = '验证失败(无统计价值): ${result.message}';
            break;
          case IAPPurchaseStatus.canceled:
            message = '购买已取消';
            global.logEvent('iap_buy_cancel');
            EasyLoading.dismiss();
            break;
          case IAPPurchaseStatus.purchased:
            final purchaseData = result.getDataAs<Map<String, dynamic>>();
            if (purchaseData == null) {
              return;
            }
            message = '购买成功\n交易日期: $purchaseData';
            global.logEvent('iap_buy_ok');
            app.refreshVip();
            app.initFirstBuyInfo().then((value) {
              if (value) {
                Logger.trace('uploadsign 上传首次订阅数据 in subs purchase');
                global.uploadFirstSubsData();
              }
            });
            Get.back();
            EasyLoading.dismiss();
            break;
          case IAPPurchaseStatus.purchaseFailed:
            message = '购买失败: ${result.message}';
            global.logEvent('iap_buy_failed');
            EasyLoading.dismiss();
            PPAlert.showSysAlert(
              'IAP_PurchaseFailedTitle'.localized,
              'IAP_PurchaseFailedMsg'.localized,
              onOK: () {},
            );
            break;
          case IAPPurchaseStatus.systemError:
            message = '购买过程系统错误: ${result.message}';
            global.logEvent('iap_buy_error');
            EasyLoading.dismiss();
            PPAlert.showSysConfirm(
              title: 'IAP_PurchaseErrorTitle'.localized,
              text: 'IAP_PurchaseErrorMsg'.localized,
              cancelText: 'Close'.localized,
              okText: 'Details'.localized,
              onConfirm: () {
                Get.toNamed(AppPages.subsReport, arguments: result);
              },
            );
            break;
          case IAPPurchaseStatus.crashes:
            message = '购买过程崩溃: ${result.message}';
            global.logEvent('iap_buy_crash');
            EasyLoading.dismiss();
            PPAlert.showSysConfirm(
              title: 'IAP_PurchaseCrashTitle'.localized,
              text: 'IAP_PurchaseCrashMsg'.localized,
              cancelText: 'Close'.localized,
              okText: 'Details'.localized,
              onConfirm: () {
                Get.toNamed(AppPages.subsReport, arguments: result);
              },
            );
            break;
          default:
            message = '其他状态: ${result.status}';
            EasyLoading.dismiss();
            break;
        }
        Logger.trace('SubsPurchase inapp ${result.status.text} $message');
      },
    );
```

### Step4: Restore product

``` dart
SubsPurchase.instance.restorePurchases(callback: (result) {
          //判断是否已经是会员，如果是，则不继续处理购买结果
          if (app.isVip) {
            Logger.trace('SubsPurchase 已经是会员，不处理购买结果');
            return;
          }

          // 处理购买结果
          String message;
          switch (result.status) {
            case IAPPurchaseStatus.verifying:
              message = '正在验证购买凭据...';
              EasyLoading.show(status: 'IAP_Verifying'.localized);
              break;
            case IAPPurchaseStatus.verifyingFailed:
              message = '验证失败: ${result.message}';
              break;
            case IAPPurchaseStatus.restored:
              final purchaseData = result.getDataAs<Map<String, dynamic>>();
              if (purchaseData == null) {
                return;
              }
              message = '恢复购买成功\n交易日期: $purchaseData';
              global.logEvent('iap_restore_ok');
              app.refreshVip();
              app.initFirstBuyInfo().then((value) {
                if (value) {
                  Logger.trace('uploadsign 上传首次订阅数据 in subs restore');
                  global.uploadFirstSubsData();
                }
              });
              Get.back();
              EasyLoading.dismiss();
              break;
            case IAPPurchaseStatus.restoreFailed:
              message = '恢复购买失败: ${result.message}';
              global.logEvent('iap_restore_failed');
              EasyLoading.dismiss();
              PPAlert.showSysAlert(
                'IAP_RestoreFailedTitle'.localized,
                'IAP_RestoreFailedMsg'.localized,
                onOK: () {},
              );
              break;
            case IAPPurchaseStatus.systemError:
              message = '系统错误: ${result.message}';
              global.logEvent('iap_restore_error');
              EasyLoading.dismiss();
              PPAlert.showSysConfirm(
                title: 'IAP_PurchaseErrorTitle'.localized,
                text: 'IAP_PurchaseErrorMsg'.localized,
                cancelText: 'Close'.localized,
                okText: 'Details'.localized,
                onConfirm: () {
                  Get.toNamed(AppPages.subsReport, arguments: result);
                },
              );
              break;
            case IAPPurchaseStatus.crashes:
              message = '购买或恢复崩溃: ${result.message}';
              global.logEvent('iap_restore_crash');
              EasyLoading.dismiss();
              PPAlert.showSysConfirm(
                title: 'IAP_PurchaseCrashTitle'.localized,
                text: 'IAP_PurchaseCrashMsg'.localized,
                cancelText: 'Close'.localized,
                okText: 'Details'.localized,
                onConfirm: () {
                  Get.toNamed(AppPages.subsReport, arguments: result);
                },
              );
              break;
            default:
              message = '其他状态: ${result.status}';
              EasyLoading.dismiss();
              break;
          }
          Logger.trace('SubsPurchase inapp ${result.status.text} $message');
        });
```

### Simple Example

Include short and useful examples for package users. Add longer examples
to `/example` folder.

```dart
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:pp_purchase/pp_purchase.dart';

class SubsDemoPage extends StatefulWidget {
  const SubsDemoPage({super.key});

  @override
  State<SubsDemoPage> createState() => _SubsDemoPageState();
}

class _SubsDemoPageState extends State<SubsDemoPage> {
  final _subsPurchase = SubsPurchase.instance;
  List<ProductDetails> _products = [];
  bool _isLoading = true;
  String _status = '';

  // 定义产品ID
  static const List<String> _productIds = [
    'weekly_vip',
    'annually_vip',
  ];

  @override
  void initState() {
    super.initState();
    _initPurchase();
  }

  Future<void> _initPurchase() async {
    // 可以在启动时初始化，也可以在需要时初始化，根据功能需求需要
    await _subsPurchase.initialize(_productIds,
        sharedSecret: 'testf80cba1241718168ddde807test', showLog: true);
    final products = await _subsPurchase.loadProducts();
    setState(() {
      _products = products;
      _isLoading = false;
    });
  }

  void _purchase(String productId) {
    setState(() => _status = '正在购买...');

    _subsPurchase.purchaseProduct(
      productId,
      callback: (result) {
        //判断是否已经是会员，如果是，则不继续处理购买结果

        // 处理购买结果
        String message;
        switch (result.status) {
          case IAPPurchaseStatus.purchasing:
            message = '购买中...';
            break;
          case IAPPurchaseStatus.verifying:
            message = '正在验证购买凭据...';
            break;
          case IAPPurchaseStatus.verifyingFailed:
            message = '验证失败(无统计价值): ${result.message}';
            break;
          case IAPPurchaseStatus.canceled:
            message = '购买已取消';
            break;
          case IAPPurchaseStatus.purchased:
            final purchaseData = result.getDataAs<Map<String, dynamic>>();
            message = '购买成功\n交易日期: $purchaseData';
            break;
          case IAPPurchaseStatus.purchaseFailed:
            message = '购买失败: ${result.message}';
            break;

          case IAPPurchaseStatus.systemError:
            message = '购买过程系统错误: ${result.message}';
            break;
          default:
            message = '其他状态: ${result.status}';
            break;
        }
        setState(() => _status = message);
        print('subslog 1 ${result.status.text}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
    );
  }

  void _restorePurchases() {
    setState(() => _status = '正在恢复购买...');

    _subsPurchase.restorePurchases(
      callback: (result) {
        //判断是否已经是会员，如果是，则不继续处理购买结果

        // 处理购买结果
        String message;
        switch (result.status) {
          case IAPPurchaseStatus.verifying:
            message = '正在验证购买凭据...';
            break;
          case IAPPurchaseStatus.verifyingFailed:
            message = '验证失败: ${result.message}';
            break;
          case IAPPurchaseStatus.restored:
            final purchaseData = result.getDataAs<Map<String, dynamic>>();
            message = '恢复购买成功\n交易日期: $purchaseData';
            break;
          case IAPPurchaseStatus.restoreFailed:
            message = '恢复购买失败: ${result.message}';
            break;
          default:
            message = '其他状态: ${result.status}';
            break;
        }
        setState(() => _status = message);
        print('subslog 2 ${result.status.text}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('订阅演示'),
        actions: [
          IconButton(
            icon: const Icon(Icons.restore),
            onPressed: _restorePurchases,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              _status,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _products.length,
                    itemBuilder: (context, index) {
                      final product = _products[index];
                      return Card(
                        margin: const EdgeInsets.all(8.0),
                        child: ListTile(
                          title: Text(product.title),
                          subtitle: Text(product.description),
                          trailing: Text(
                            product.price,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onTap: () => _purchase(product.id),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

```
