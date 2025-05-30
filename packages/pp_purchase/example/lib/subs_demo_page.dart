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

  // 订阅产品ID
  static const List<String> _productIds = [
    'weekly_vip',
    'annually_vip',
  ];

  // 非消耗型产品
  static const List<String> _nonconsumableIds = [];

  @override
  void initState() {
    super.initState();
    _initPurchase();
  }

  Future<void> _initPurchase() async {
    // 可以在启动时初始化，也可以在需要时初始化，根据功能需求需要
    await _subsPurchase.initialize(_productIds, _nonconsumableIds,
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
