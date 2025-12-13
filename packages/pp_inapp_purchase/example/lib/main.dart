import 'package:flutter/material.dart';
import 'dart:async';

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
  String _platformVersion = 'Unknown';
  final _inappPurchase = InappPurchase.instance;

  // 产品列表
  List<Product> _allProducts = [];
  List<Product> _nonConsumables = [];
  List<Product> _consumables = [];
  List<Product> _autoRenewables = [];

  // 状态信息
  String _statusMessage = '未初始化';
  bool _isConfigured = false;

  // 订阅事件流
  StreamSubscription? _stateSubscription;
  StreamSubscription? _productsSubscription;
  StreamSubscription? _transactionsSubscription;

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
    _stateSubscription = _inappPurchase.onStateChanged.listen((state) {
      setState(() {
        _statusMessage = '状态变化: $state';
      });
      print('状态变化: $state');
    });

    // 监听产品加载完成
    _productsSubscription = _inappPurchase.onProductsLoaded.listen((products) {
      setState(() {
        _statusMessage = '产品加载完成，共 ${products.length} 个产品';
      });
      print('产品加载完成，共 ${products.length} 个产品');
      loadProducts();
    });

    // 监听交易更新
    _transactionsSubscription = _inappPurchase.onPurchasedTransactionsUpdated
        .listen((transaction) {
          setState(() {
            _statusMessage = '交易更新: $transaction';
          });
          print('交易更新: $transaction');
        });
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
    try {
      await _inappPurchase.configure(
        productIds: [
          'com.example.product1',
          'com.example.subscription1',
          'com.example.consumable1',
        ],
        lifetimeIds: [],
        nonRenewableExpirationDays: 7,
        autoSortProducts: true,
        showLog: true,
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
      print('配置失败: $e');
    }
  }

  // 加载产品信息
  Future<void> loadProducts() async {
    try {
      _allProducts = await _inappPurchase.getAllProducts();
      _nonConsumables = await _inappPurchase.getNonConsumablesProducts();
      _consumables = await _inappPurchase.getConsumablesProducts();
      _autoRenewables = await _inappPurchase.getAutoRenewablesProducts();

      setState(() {
        _statusMessage = '产品信息已加载';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '加载产品失败: $e';
      });
      print('加载产品失败: $e');
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
      print('购买失败: $e');
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
      print('恢复购买失败: $e');
    }
  }

  // 检查购买状态
  Future<void> checkPurchaseStatus(String productId) async {
    try {
      bool isPurchased = await _inappPurchase.isPurchased(productId: productId);
      bool isFamilyShared = await _inappPurchase.isFamilyShared(
        productId: productId,
      );

      setState(() {
        _statusMessage =
            '$productId - 已购买: $isPurchased, 家庭共享: $isFamilyShared';
      });
    } catch (e) {
      setState(() {
        _statusMessage = '检查购买状态失败: $e';
      });
      print('检查购买状态失败: $e');
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
