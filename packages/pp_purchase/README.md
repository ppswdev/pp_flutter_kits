
Easy-to-use in-app purchases that can callback results and facilitate operational tracking

## Maintenance Termination Notice

The current version is the in_app_purchase version that supports StoreKit1. Subsequent versions will no longer maintain the functions related to StoreKit1. All the code related to StoreKit1 will be archived. It is recommended to migrate to <a href="https://pub.dev/packages/pp_inapp_purchase">pp_inapp_purchase(https://pub.dev/packages/pp_inapp_purchase)</a>, and more up-to-date features of StoreKit2 are provided.

## Features

- Configurable
- Callable function
- Get Subscription Title,Subtitle,Button text

## Getting started

### Install command

``` bash
flutter pub add pp_purchase
```

### Init method

``` dart
//初始化所有内购对象
Future<void> initialize(List<String> productIds, List<String> onetimeSubIds,
      {required String sharedSecret, bool showLog = false}) async
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

## 常见错误日志信息

``` bash
flutter: 2025-05-15 15:58:04.240713 [package:spinthewheel/modules/guides/guides2_controller.dart:315 Guides2Controller.purchase.<anonymous closure>] SubsPurchase guides 崩溃 购买过程崩溃: PlatformException(storekit_duplicate_product_object, There is a pending transaction for the same product identifier. Please either wait for it to be finished or finish it manually using `completePurchase` to avoid edge cases., {applicationUsername: null, requestData: null, simulatesAskToBuyInSandbox: false, paymentDiscount: null, productIdentifier: spiteel_weekly, quantity: 1}, null) null
```

```
flutter: 2025-05-15 18:08:02.137080 [package:spinthewheel/modules/guides/guides2_controller.dart:315 Guides2Controller.purchase.<anonymous closure>] SubsPurchase guides 系统错误 购买过程系统错误: SKErrorDomain IAPError(code: purchase_error, source: app_store, message: SKErrorDomain, details: {NSLocalizedDescription: An unknown error occurred, NSUnderlyingError: {domain: ASDServerErrorDomain, userInfo: {NSLocalizedFailureReason: You are currently subscribed to this}, code: 3532}})
```

```
标题: NSURLErrorDomain
详细堆栈: IAPError(代码: purchase_error, 来源: app_store, 消息: NSURLErrorDomain, 详情: {NSLocalizedDescription: 互联网连接似乎已断开。, NSUnderlyingError: {域: kCFErrorDomainCFNetwork, 用户信息: {}, 代码: -1009}})
```

```
标题: SKErrorDomain
详细堆栈: IAPError(代码: purchase_error, 来源: app_store, 消息: SKErrorDomain, 详情: {NSLocalizedDescription: 发生了未知错误, NSUnderlyingError: {domain: ASDErrorDomain, userInfo: {NSUnderlyingError: {domain: AMSErrorDomain, userInfo: {AMSDescription: Bag加载失败, NSDebugDescription: Bag加载失败 无法获取p2-in-app-buy因为我们未能加载bag., AMSFailureReason: 无法获取p2-in-app-buy因为我们未能加载bag., NSUnderlyingError: {domain: AMSErrorDomain, userInfo: {AMSDescription: Bag加载失败, NSDebugDescription: Bag加载失败 我们未能加载bag., AMSFailureReason: 我们未能加载bag., NSUnderlyingError: {domain: NSURLErrorDomain, userInfo: {AMSStatusCode: 0, _NSURLErrorFailingURLSessionTaskErrorKey: LocalDataTask <88D242DF-58FE-441B-B087-014A6FC806AA>.<777>, AMSDescription: 发生未知错误。请重试。, NSUnderlyingError: {domain: kCFErrorDomainCFNetwork, userInfo: {_kCFStreamErrorDomainKey: 1, _kCFStreamErrorCodeKey: 50, _NSURLErrorNWPathKey_desc: 不满足条件 (无网络路由), _NSURLErrorNWResolutionReportKey_desc: 在1ms内使用缓存中的未知解析了0个端点}, code: -1009}, NSDebugDescription: 发生未知错误。请重试。, _kCFStreamErrorCodeKey: 50, _NSURLErrorRelatedURLSessionTaskErrorKey: [LocalDataTask <88D242DF-58FE-441B-B087-014A6FC806AA>.<777>], NSLocalizedDescription: 互联网连接似乎已关闭。, NSErrorFailingURLStringKey: https://bag.itunes.apple.com/bag.xml?deviceClass=iPad&format=json&os=iOS&osVersion=18.0.1&product=com.apple.storekitd&productVersion=3.0&profile=appstored&profileVersion=1&storefront=143504-28,30, NSErrorFailingURLKey: https://bag.itunes.apple.com/bag.xml?deviceClass=iPad&format=json&os=iOS&osVersion=18.0.1&product=com.apple.storekitd&productVersion=3.0&profile=appstored&profileVersion=1&storefront=143504-28,30, _kCFStreamErrorDomainKey: 1}, code: -1009}}, code: 203}}, code: 203}}, code: 500}})
```

```
标题：SKErrorDomain
详细堆栈：IAPError（代码：purchase_error，来源：app_store，消息：SKErrorDomain，详细信息：{NSLocalizedDescription：发生了错误，NSUnderlyingError：{domain：ASDErrorDomain，userInfo：{NSDebugDescription：收到的购买响应没有交易，但包含带有购买参数的操作URL，NSUnderlyingError：{domain：AMSErrorDomain，userInfo：{NSLocalizedDescription：购买失败，AMSURL： https://p29-buy.itunes.apple.com/WebObjects/MZBuy.woa/wa/inAppBuy?guid=bd6dacc17e08f495dfd21e72a66453e9d0fd3af2，AMSStatusCode：200，AMSServerPayload_desc：{
"取消购买批次" = 1;
customerMessage = "Se necesita informaci\U00f3n de pago";
对话框={
取消按钮字符串=取消；
默认按钮=确定；
解释=“Para suscribirte，agrega un nuevo m\U00e9todo de pago。Set te cobrar\U00e1 s\U00f3lo cuando termine tu periodo de prueba。”;
初始复选框值 = 1;
isFree = 1;
"m-allowed" = 0;
message = "您需要付款信息\U00f3n";
okButtonAction = {
kind = Goto;
subtarget = "account.editAddress";
target = main;
tidContinue = 1;
url = "https://p29-buy.itunes.apple.com/WebObjects/MZFinance.woa/wa/com.apple.jingle.app.finance.DirectAction/editAddress?offerName=offline_music_weekly&guid=bd6dacc17e08f495dfd21e72a66453e9d0fd3af2&quantity=1&ageCheck=true&pricingParameters=STDQ&vid= 0C50D690-C1BE-473A-90C8-84807C2ACA2B&appExtVrsId=875007291&bvrs=107&appAdamId=6532609250&showIAPExtraDialog=false&hasConfirmedBuySubscription=true&offrd-free-trial=false&salableAdamId=6566171053&clientCorrelationKey=4F1BCD13-A060-4605-A494-B463D F3F421F&hasBeenAuthedForBuy=true&price=0&pg=default&storeCohort=10%7Cdate%3D1749180600000&sf%3D143509&pgtp%3DSoftware&pgid%3D6532609250&prpg%3DSearch_e666c085-dfad-4899-b9a9-9ca6871aeb56&ctxt%3DSearch&issrch%3D1&lngid%3D28&icloud-backup-enabled= 1&productType=A&hasConfirmedPaymentSheet=true&offrd-intro-price=true&bid=com.mobiunity.htmusic&hasWebOptIn=false&xToken=BAIAAAF5AAJNFAAAAABoRQEI73wiycqQnSRoQoYjuzB1Eg7lCiglWNWuWaQgiYC593%2FBoQPOekmbtZvyvd5Jlx4hJahryanAgnCwa6Sx";
};
okButtonString = 继续;
};
failureType = "";
"m-allowed" = 0;
metrics = {
actionUrl = "p29-buy.itunes.apple.com/WebObjects/MZBuy.woa/wa/inAppBuy";
asnState = 0;
dialogId = "MZCommerce.CreditCardRequiredOnFileForIAPSubscriptionFreeTrialBuy";
eventType = dialog;
message = "Se necesita informaci\U00f3n d";
mtEventTime = "2025-06-08 03:18:09 Etc/GMT";
mtTopic = "xp_its_main";
options = (
继续,
取消
);
};
pings = (
"https://xp.apple.com/report/2/xp_its_main?code=MZCommerce.CreditCardRequiredOnFileForIAPSubscriptionFreeTrialBuy&buttons=Continuar%3ACancelar&baseVersion=1&dsId=22433974012&eventVersion=1&storeFrontHeader=143509-28%2C29&eventTime=1749352713987&eventType=dialog&message=Se%20necesita%20informaci%C3%B3n%20d"
);
}, NSLocalizedFailureReason: 服务器取消了购买}, 代码: 305}}, 代码: 504}})


```

```
标题：SKErrorDomain
详细堆栈：IAPError（代码：purchase_error，来源：app_store，消息：SKErrorDomain，详细信息：{NSLocalizedDescription：发生未知错误，NSUnderlyingError：{domain：ASDErrorDomain，userInfo：{NSUnderlyingError：{domain：AMSErrorDomain，userInfo：{}，代码：305}}，代码：504}}）
```

```

```
