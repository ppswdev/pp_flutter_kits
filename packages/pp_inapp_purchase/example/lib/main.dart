import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pp_inapp_purchase/inapp_purchase.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  // 替换成 Google Play Console 中已激活的商品 ID。
  static const _androidSubscriptionIds = <String>[
    'android_weekly_subscription',
    'android_yearly_subscription',
  ];
  static const _androidLifetimeId = 'android_lifetime_product';

  // 替换成 App Store Connect 中已配置的商品 ID。
  static const _iosProductIds = <String>[
    'ios_weekly_subscription',
    'ios_lifetime_product',
  ];
  static const _iosLifetimeId = 'ios_lifetime_product';

  String _platformVersion = 'Unknown';
  final _inappPurchase = InappPurchase.instance;

  // 产品列表
  List<Product> _allProducts = [];
  List<Product> _nonConsumables = [];
  List<Product> _consumables = [];
  List<Product> _autoRenewables = [];
  List<Transaction> _validTransactions = [];

  // 状态信息
  String _statusMessage = '未初始化';
  bool _isConfigured = false;

  // 订阅事件流
  StreamSubscription<Map<String, dynamic>>? _stateSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _productsSubscription;
  StreamSubscription<Map<String, dynamic>>? _transactionsSubscription;

  bool get _isSupportedPlatform => Platform.isAndroid || Platform.isIOS;

  List<String> get _configuredProductIds => Platform.isAndroid
      ? <String>[..._androidSubscriptionIds, _androidLifetimeId]
      : _iosProductIds;

  List<String> get _configuredLifetimeIds => Platform.isAndroid
      ? const <String>[_androidLifetimeId]
      : const <String>[_iosLifetimeId];

  @override
  void initState() {
    super.initState();
    initPlatformState();
    setupEventListeners();
  }

  @override
  void dispose() {
    // 取消事件订阅
    _stateSubscription?.cancel();
    _productsSubscription?.cancel();
    _transactionsSubscription?.cancel();
    super.dispose();
  }

  // 设置事件监听器
  void setupEventListeners() {
    // 监听状态变化
    _stateSubscription = _inappPurchase.onStateChanged.listen((state) async {
      if (!mounted) return;
      await _handlePurchaseState(state);
      debugPrint('[pp_inapp_purchase][EXAMPLE] 状态变化: $state');
    });

    // 监听产品加载完成
    _productsSubscription = _inappPurchase.onProductsLoaded.listen((products) {
      if (!mounted) return;
      setState(() {
        _statusMessage = '产品加载完成，共 ${products.length} 个产品';
      });
      debugPrint(
        '[pp_inapp_purchase][EXAMPLE] 产品加载完成，共 ${products.length} 个产品',
      );
      loadProducts();
    });

    // 监听交易更新
    _transactionsSubscription = _inappPurchase.onPurchasedTransactionsUpdated
        .listen((transaction) {
          if (!mounted) return;
          setState(() {
            _statusMessage = '交易更新: $transaction';
          });
          debugPrint('[pp_inapp_purchase][EXAMPLE] 交易更新: $transaction');
        });
  }

  Future<void> _handlePurchaseState(Map<String, dynamic> state) async {
    final type = state['type']?.toString();
    final transactionMap = state['transaction'];
    Transaction? transaction;
    if (transactionMap is Map) {
      transaction = Transaction.fromMap(
        Map<String, dynamic>.from(transactionMap),
      );
    }

    switch (type) {
      case StoreKitState.purchasePending:
        _setStatus('Google Play 付款处理中，暂不授予权益');
        return;
      case StoreKitState.purchaseSuccess:
        final token = transaction?.appTransactionID ?? transaction?.originalID;
        _setStatus(
          '购买成功: ${transaction?.productID ?? 'unknown'}, '
          'token=${_maskedSuffix(token)}。请将 token 发送业务服务端验证。',
        );
        await refreshPurchases();
        return;
      case StoreKitState.purchaseVerificationRequired:
        _setStatus(
          '等待服务端验证: ${transaction?.productID ?? 'unknown'}。'
          '当前示例使用 deferAndroidAcknowledgement=false，'
          '延迟确认接入见插件 README。',
        );
        return;
      case StoreKitState.purchaseCancelled:
        _setStatus('用户取消购买');
        return;
      case StoreKitState.purchaseFailed:
        _setStatus('购买失败: ${state['error'] ?? 'unknown'}');
        return;
      case StoreKitState.restorePurchasesSuccess:
        _setStatus('恢复购买完成');
        await refreshPurchases();
        return;
      default:
        _setStatus('状态变化: $type');
    }
  }

  String _maskedSuffix(String? value) {
    if (value == null || value.isEmpty) return 'none';
    final suffix = value.length <= 6
        ? value
        : value.substring(value.length - 6);
    return '***$suffix';
  }

  void _setStatus(String message) {
    if (!mounted) return;
    setState(() => _statusMessage = message);
  }

  // 初始化平台状态
  Future<void> initPlatformState() async {
    String platformVersion;
    try {
      platformVersion =
          await _inappPurchase.getPlatformVersion() ??
          'Unknown platform version';
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  // 配置应用内购
  Future<void> configureInAppPurchase() async {
    if (!_isSupportedPlatform) {
      _setStatus('当前示例只支持 Android 和 iOS');
      return;
    }
    try {
      await _inappPurchase.configure(
        productIds: _configuredProductIds,
        lifetimeIds: _configuredLifetimeIds,
        nonRenewableExpirationDays: 7,
        autoSortProducts: true,
        showLog: true,
        // Android 默认先 acknowledge，再发送 purchaseSuccess。业务应用仍需
        // 使用 purchase token 调服务端验证并用权威结果更新权益。
        deferAndroidAcknowledgement: false,
      );

      setState(() {
        _isConfigured = true;
        _statusMessage = '应用内购已配置完成';
      });

      // 加载产品信息
      await loadProducts();
    } catch (e) {
      setState(() {
        _statusMessage = '配置失败: $e';
      });
      debugPrint('[pp_inapp_purchase][EXAMPLE] 配置失败: $e');
    }
  }

  // 加载产品信息
  Future<void> loadProducts() async {
    try {
      _allProducts = await _inappPurchase.getAllProducts();
      _nonConsumables = await _inappPurchase.getNonConsumablesProducts();
      // Android 1.2.0 暂不支持消耗型商品。
      _consumables = Platform.isIOS
          ? await _inappPurchase.getConsumablesProducts()
          : <Product>[];
      _autoRenewables = await _inappPurchase.getAutoRenewablesProducts();

      setState(() {
        _statusMessage = '产品信息已加载';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '加载产品失败: $e';
      });
      debugPrint('[pp_inapp_purchase][EXAMPLE] 加载产品失败: $e');
    }
  }

  // 购买产品
  Future<void> purchaseProduct(String productId) async {
    try {
      await _inappPurchase.purchase(productId: productId);
      setState(() {
        _statusMessage = '正在购买产品: $productId';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '购买失败: $e';
      });
      debugPrint('[pp_inapp_purchase][EXAMPLE] 购买失败: $e');
    }
  }

  // 恢复购买
  Future<void> restorePurchases() async {
    try {
      await _inappPurchase.restorePurchases();
      setState(() {
        _statusMessage = '正在恢复购买...';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '恢复购买失败: $e';
      });
      debugPrint('[pp_inapp_purchase][EXAMPLE] 恢复购买失败: $e');
    }
  }

  // 刷新 Google Play/App Store 当前购买快照。
  Future<void> refreshPurchases() async {
    if (!_isConfigured) return;
    try {
      await _inappPurchase.refreshPurchases();
      final transactions = await _inappPurchase.getValidPurchasedTransactions();
      if (!mounted) return;
      setState(() {
        _validTransactions = transactions;
        _statusMessage = '当前有效购买: ${transactions.length}';
      });
    } catch (e) {
      _setStatus('刷新购买失败: $e');
      debugPrint('[pp_inapp_purchase][EXAMPLE] 刷新购买失败: $e');
    }
  }

  Future<void> showManageSubscriptions() async {
    try {
      await _inappPurchase.showManageSubscriptionsSheet();
      _setStatus(Platform.isAndroid ? '已打开 Google Play 订阅管理' : '已打开订阅管理');
    } catch (e) {
      _setStatus('打开订阅管理失败: $e');
    }
  }

  // 检查购买状态
  Future<void> checkPurchaseStatus(String productId) async {
    try {
      bool isPurchased = await _inappPurchase.isPurchased(productId: productId);
      final isFamilyShared = Platform.isIOS
          ? await _inappPurchase.isFamilyShared(productId: productId)
          : false;

      setState(() {
        _statusMessage =
            '$productId - 已购买: $isPurchased, 家庭共享: $isFamilyShared';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '检查购买状态失败: $e';
      });
      debugPrint('[pp_inapp_purchase][EXAMPLE] 检查购买状态失败: $e');
    }
  }

  // 请求应用评价
  void requestReview() {
    _inappPurchase.requestReview();
    setState(() {
      _statusMessage = '已请求应用评价';
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('In-App Purchase 示例')),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 平台信息
                Text('运行平台: $_platformVersion\n'),

                Text(
                  Platform.isAndroid
                      ? 'Android: Google Play Billing 9.1.0'
                      : 'iOS: StoreKit 2',
                ),
                const SizedBox(height: 8),

                // 状态信息
                Text('当前状态: $_statusMessage\n'),

                // 配置按钮
                ElevatedButton(
                  onPressed: configureInAppPurchase,
                  child: Text(_isConfigured ? '已配置' : '配置应用内购'),
                ),
                const SizedBox(height: 16),

                // 恢复购买按钮
                ElevatedButton(
                  onPressed: _isConfigured ? restorePurchases : null,
                  child: const Text('恢复购买'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _isConfigured ? refreshPurchases : null,
                  child: const Text('刷新当前购买'),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _isConfigured ? showManageSubscriptions : null,
                  child: Text(
                    Platform.isAndroid ? '管理 Google Play 订阅' : '管理订阅',
                  ),
                ),
                const SizedBox(height: 16),

                // 请求评价按钮
                ElevatedButton(
                  onPressed: requestReview,
                  child: const Text('请求应用评价'),
                ),
                const SizedBox(height: 32),

                // 产品列表
                const Text(
                  '所有产品:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildProductList(_allProducts),
                const SizedBox(height: 24),

                const Text(
                  '非消耗型产品:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildProductList(_nonConsumables),
                const SizedBox(height: 24),

                const Text(
                  '消耗型产品:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildProductList(_consumables),
                const SizedBox(height: 24),

                const Text(
                  '自动续订订阅:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                _buildProductList(_autoRenewables),
                const SizedBox(height: 24),

                const Text(
                  '当前有效购买:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                if (_validTransactions.isEmpty)
                  const Text('暂无当前购买')
                else
                  ..._validTransactions.map(
                    (transaction) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(transaction.productID ?? 'unknown'),
                      subtitle: Text(
                        'order=${_maskedSuffix(transaction.id)} '
                        'token=${_maskedSuffix(transaction.appTransactionID ?? transaction.originalID)}',
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // 构建产品列表
  Widget _buildProductList(List<Product> products) {
    if (products.isEmpty) {
      return const Text('暂无产品');
    }

    return Column(
      children: products.map((product) {
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.displayName ?? '未命名产品',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(product.description ?? '无描述'),
                Text('ID: ${product.id}'),
                Text('价格: ${product.displayPrice}'),
                Text('类型: ${product.type}'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ElevatedButton(
                      onPressed: product.id != null
                          ? () => purchaseProduct(product.id!)
                          : null,
                      child: const Text('购买'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: product.id != null
                          ? () => checkPurchaseStatus(product.id!)
                          : null,
                      child: const Text('检查状态'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
