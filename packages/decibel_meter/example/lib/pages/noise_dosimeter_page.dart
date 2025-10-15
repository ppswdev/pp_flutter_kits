import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/chart_widgets.dart';
import '../controllers/decibel_meter_controller.dart';

class NoiseDosimeterPage extends StatelessWidget {
  const NoiseDosimeterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DecibelMeterController>();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 基本数据显示
            _buildBasicDataSection(controller),
            const SizedBox(height: 16),

            // 标准设置
            _buildStandardSection(controller),
            const SizedBox(height: 16),

            // 剂量数据
            _buildDoseDataSection(controller),
            const SizedBox(height: 16),

            // 允许暴露时长表
            _buildDurationTableSection(controller),
            const SizedBox(height: 16),

            // 操作按钮
            _buildActionButtons(controller),
            const SizedBox(height: 16),

            // 图表区域
            _buildChartsSection(controller),
          ],
        ),
      ),
    );
  }

  /// 构建基本数据显示区域
  Widget _buildBasicDataSection(DecibelMeterController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('基本数据', style: Get.textTheme.headlineSmall),
            const SizedBox(height: 16),
            Obx(
              () => Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDataItem(
                          '记录时长',
                          controller.measurementDuration,
                        ),
                      ),
                      Expanded(
                        child: _buildDataItem(
                          '当前分贝',
                          '${controller.currentDecibel.toStringAsFixed(1)} dB',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDataItem(
                          'TWA值',
                          '${controller.twa.toStringAsFixed(1)} dB(A)',
                        ),
                      ),
                      Expanded(
                        child: _buildDataItem(
                          '限值',
                          '${controller.limit.toStringAsFixed(1)} dB(A)',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDataItem(
                          '交换率',
                          '${controller.exchangeRate.toStringAsFixed(1)} dB',
                        ),
                      ),
                      Expanded(
                        child: _buildDataItem(
                          '限值余量',
                          '${controller.limitMargin.toStringAsFixed(1)} dB',
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建数据项
  Widget _buildDataItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Get.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        Text(
          value,
          style: Get.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  /// 构建标准设置区域
  Widget _buildStandardSection(DecibelMeterController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('测量标准', style: Get.textTheme.headlineSmall),
            const SizedBox(height: 16),
            Obx(
              () => OutlinedButton.icon(
                onPressed: () => _showStandardMenu(controller),
                icon: const Icon(Icons.health_and_safety),
                label: Text('当前标准: ${controller.currentStandard}'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 显示标准选择菜单
  void _showStandardMenu(DecibelMeterController controller) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('噪声限值标准', style: Get.textTheme.headlineSmall),
            const SizedBox(height: 16),
            ...controller.availableStandards.map(
              (standard) => ListTile(
                title: Text(_getStandardDisplayName(standard)),
                subtitle: Text(_getStandardDescription(standard)),
                trailing: standard == controller.currentStandard
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  controller.setNoiseStandard(standard);
                  Get.back();
                },
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
    );
  }

  /// 获取标准显示名称
  String _getStandardDisplayName(String standard) {
    switch (standard) {
      case 'OSHA':
        return 'OSHA标准';
      case 'NIOSH':
        return 'NIOSH标准';
      case 'GBZ':
        return 'GBZ标准';
      case 'EU':
        return 'EU标准';
      default:
        return standard;
    }
  }

  /// 获取标准描述
  String _getStandardDescription(String standard) {
    switch (standard) {
      case 'OSHA':
        return '美国职业安全与健康管理局标准';
      case 'NIOSH':
        return '美国国家职业安全健康研究所标准';
      case 'GBZ':
        return '中国职业卫生标准';
      case 'EU':
        return '欧盟职业噪声暴露标准';
      default:
        return '';
    }
  }

  /// 构建剂量数据区域
  Widget _buildDoseDataSection(DecibelMeterController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('剂量数据', style: Get.textTheme.headlineSmall),
            const SizedBox(height: 16),
            Obx(
              () => Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _buildDataItem(
                          '总剂量',
                          '${controller.totalDose.toStringAsFixed(1)}%',
                        ),
                      ),
                      Expanded(
                        child: _buildDataItem(
                          '剂量率',
                          '${controller.doseRate.toStringAsFixed(1)} %/h',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDataItem(
                          '是否超标',
                          controller.isExceeding ? '是' : '否',
                        ),
                      ),
                      Expanded(
                        child: _buildDataItem(
                          '风险等级',
                          _getRiskLevelDisplayName(controller.riskLevel),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 获取风险等级显示名称
  String _getRiskLevelDisplayName(String riskLevel) {
    switch (riskLevel) {
      case 'low':
        return '低风险';
      case 'medium':
        return '中等风险';
      case 'high':
        return '高风险';
      case 'veryHigh':
        return '极高风险';
      default:
        return riskLevel;
    }
  }

  /// 构建允许暴露时长表区域
  Widget _buildDurationTableSection(DecibelMeterController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('允许暴露时长表', style: Get.textTheme.headlineSmall),
            const SizedBox(height: 16),
            Obx(() {
              if (controller.durationTable.isEmpty) {
                return const Center(child: Text('暂无数据'));
              } else {
                return SizedBox(
                  height: 300,
                  child: ListView.builder(
                    itemCount: controller.durationTable.length,
                    itemBuilder: (context, index) {
                      final duration = controller.durationTable[index];
                      final soundLevel = _safeToDouble(duration['soundLevel']);
                      final allowedDuration = _safeToDouble(
                        duration['allowedDuration'],
                      );
                      final accumulatedDuration = _safeToDouble(
                        duration['accumulatedDuration'],
                      );
                      final currentLevelDose = _safeToDouble(
                        duration['currentLevelDose'],
                      );
                      final isCeilingLimit = duration['isCeilingLimit'] as bool;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 8),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: currentLevelDose > 100
                              ? Colors.red.shade50
                              : Colors.grey.shade50,
                          border: Border.all(
                            color: currentLevelDose > 100
                                ? Colors.red
                                : Colors.grey.shade300,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${soundLevel.toStringAsFixed(0)}dB',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '允许: ${allowedDuration.toStringAsFixed(1)}s',
                                  ),
                                  Text(
                                    '已暴露: ${accumulatedDuration.toStringAsFixed(1)}s',
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    '${currentLevelDose.toStringAsFixed(1)}%',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: currentLevelDose > 100
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                  ),
                                  Text(
                                    currentLevelDose > 100 ? '超标' : '正常',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: currentLevelDose > 100
                                          ? Colors.red
                                          : Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              }
            }),
          ],
        ),
      ),
    );
  }

  /// 构建操作按钮区域
  Widget _buildActionButtons(DecibelMeterController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('操作', style: Get.textTheme.headlineSmall),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => controller.resetNoiseDosimeter(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('重置'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orange,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => controller.updateNoiseDosimeterData(),
                    icon: const Icon(Icons.refresh),
                    label: const Text('刷新数据'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// 构建图表区域
  Widget _buildChartsSection(DecibelMeterController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('图表分析', style: Get.textTheme.headlineSmall),
            const SizedBox(height: 16),

            // 剂量累积图
            Obx(() {
              if (controller.doseChartData.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '剂量累积图',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: DoseAccumulationChart(
                        data: controller.doseChartData,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),

            // TWA趋势图
            Obx(() {
              if (controller.twaChartData.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TWA趋势图',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: TWATrendChart(data: controller.twaChartData),
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
      ),
    );
  }

  /// 安全的数字转换方法，处理int和double类型
  double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return 0.0;
  }
}
