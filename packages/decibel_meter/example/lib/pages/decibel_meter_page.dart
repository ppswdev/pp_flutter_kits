import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/chart_widgets.dart';
import '../controllers/decibel_meter_controller.dart';
import 'calibration_page.dart';
import 'report_page.dart';

class DecibelMeterPage extends StatelessWidget {
  const DecibelMeterPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<DecibelMeterController>();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 测量控制
            _buildControlSection(controller),
            const SizedBox(height: 24),

            // 操作按钮
            _buildActionButtons(controller),
            const SizedBox(height: 24),

            // 基本数据显示
            _buildBasicDataSection(controller),
            const SizedBox(height: 24),

            // 权重设置
            _buildWeightingSection(controller),
            const SizedBox(height: 24),

            // 图表区域
            _buildChartsSection(controller),
          ],
        ),
      ),
    );
  }

  /// 构建测量控制区域
  Widget _buildControlSection(DecibelMeterController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('测量控制', style: Get.textTheme.headlineSmall),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => ElevatedButton.icon(
                      onPressed: controller.toggleMeasurement,
                      icon: Icon(
                        controller.isMeasuring ? Icons.stop : Icons.play_arrow,
                      ),
                      label: Text(controller.isMeasuring ? '停止测量' : '开始测量'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: controller.isMeasuring
                            ? Colors.red
                            : Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
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
                          'AVG(LEQ)',
                          '${controller.avgDecibel.toStringAsFixed(1)} dB',
                        ),
                      ),
                      Expanded(
                        child: _buildDataItem(
                          'MIN',
                          '${controller.minDecibel.toStringAsFixed(1)} dB',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: _buildDataItem(
                          'MAX',
                          '${controller.maxDecibel.toStringAsFixed(1)} dB',
                        ),
                      ),
                      Expanded(
                        child: _buildDataItem(
                          'PEAK',
                          '${controller.peakDecibel.toStringAsFixed(1)} dB',
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

  /// 构建权重设置区域
  Widget _buildWeightingSection(DecibelMeterController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('权重设置', style: Get.textTheme.headlineSmall),
            const SizedBox(height: 16),
            Obx(
              () => Row(
                children: [
                  Expanded(
                    child: _buildWeightingButton(
                      '频率权重',
                      controller.currentFrequencyWeighting,
                      controller.frequencyWeightings,
                      (value) => controller.setFrequencyWeighting(value),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildWeightingButton(
                      '时间权重',
                      controller.currentTimeWeighting,
                      controller.timeWeightings,
                      (value) => controller.setTimeWeighting(value),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => Center(
                child: Text(
                  '当前设置: ${controller.weightingDisplay}',
                  style: Get.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 构建权重按钮
  Widget _buildWeightingButton(
    String title,
    String currentValue,
    List<String> options,
    Function(String) onSelected,
  ) {
    return OutlinedButton.icon(
      onPressed: () =>
          _showWeightingMenu(title, currentValue, options, onSelected),
      icon: const Icon(Icons.settings),
      label: Text(currentValue),
    );
  }

  /// 显示权重选择菜单
  void _showWeightingMenu(
    String title,
    String currentValue,
    List<String> options,
    Function(String) onSelected,
  ) {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Get.textTheme.headlineSmall),
            const SizedBox(height: 16),
            ...options.map(
              (option) => ListTile(
                title: Text(option),
                trailing: option == currentValue
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  onSelected(option);
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
                    onPressed: () => controller.resetMeasurement(),
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
                    onPressed: () {
                      Get.to(() => const CalibrationPage());
                    },
                    icon: const Icon(Icons.tune),
                    label: const Text('校准'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final report = await controller.getComprehensiveReport();
                      if (report != null) {
                        Get.to(() => ReportPage(reportData: report));
                      }
                    },
                    icon: const Icon(Icons.file_download),
                    label: const Text('导出'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
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

            // 实时分贝曲线图
            Obx(() {
              if (controller.realTimeChartData.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '实时分贝曲线图',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: RealTimeChart(data: controller.realTimeChartData),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),

            // 实时指示器图
            Obx(() {
              if (controller.realTimeIndicatorData.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '实时指示器',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    RealTimeIndicator(data: controller.realTimeIndicatorData),
                    const SizedBox(height: 16),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),

            // 频谱分析图
            Obx(() {
              if (controller.spectrumData.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '频谱分析图',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: SpectrumChart(data: controller.spectrumData),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),

            // 统计分布图
            Obx(() {
              if (controller.distributionData.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '统计分布图',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: StatisticalDistributionChart(
                        data: controller.distributionData,
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),

            // LEQ趋势图
            Obx(() {
              if (controller.leqTrendData.isNotEmpty) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'LEQ趋势图',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 200,
                      child: LEQTrendChart(data: controller.leqTrendData),
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
}
