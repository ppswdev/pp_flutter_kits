import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:decibel_meter/decibel_meter.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final DecibelMeter _decibelMeter = DecibelMeter();

  Map<String, dynamic>? _reportData;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _generateReport();
  }

  Future<void> _generateReport() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final reportJson = await _decibelMeter.generateNoiseDosimeterReport();
      if (reportJson != null) {
        final reportData = jsonDecode(reportJson);
        setState(() {
          _reportData = reportData;
        });
      } else {
        _showError('无法生成报告，请确保已开始测量');
      }
    } catch (e) {
      _showError('生成报告失败: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据报告'),
        actions: [
          IconButton(
            onPressed: _generateReport,
            icon: const Icon(Icons.refresh),
            tooltip: '刷新报告',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _reportData == null
          ? _buildNoDataView()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 报告标题
                  _buildReportHeader(),
                  const SizedBox(height: 16),

                  // 测量信息
                  _buildMeasurementInfo(),
                  const SizedBox(height: 16),

                  // 剂量数据
                  _buildDoseData(),
                  const SizedBox(height: 16),

                  // 统计信息
                  _buildStatisticsData(),
                  const SizedBox(height: 16),

                  // 合规性结论
                  _buildComplianceConclusion(),
                  const SizedBox(height: 16),

                  // 操作按钮
                  _buildActionButtons(),
                ],
              ),
            ),
    );
  }

  Widget _buildNoDataView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.assessment_outlined, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            '暂无报告数据',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Text(
            '请先开始测量以生成报告',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _generateReport,
            icon: const Icon(Icons.refresh),
            label: const Text('重新生成报告'),
          ),
        ],
      ),
    );
  }

  Widget _buildReportHeader() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(Icons.assessment, size: 48, color: Colors.blue),
            const SizedBox(height: 8),
            Text(
              '噪音测量计综合报告',
              style: Theme.of(
                context,
              ).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '生成时间: ${_formatDateTime(_reportData!['reportTime'])}',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMeasurementInfo() {
    final data = _reportData!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('测量信息', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            _buildInfoRow(
              '开始时间',
              _formatDateTime(data['measurementStartTime']),
            ),
            _buildInfoRow('结束时间', _formatDateTime(data['measurementEndTime'])),
            _buildInfoRow('测量时长', '${data['measurementDuration']} 小时'),
            _buildInfoRow('使用标准', _getStandardDisplayName(data['standard'])),
          ],
        ),
      ),
    );
  }

  Widget _buildDoseData() {
    final doseData = _reportData!['doseData'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('剂量数据', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            _buildInfoRow(
              'TWA值',
              '${doseData['twa'].toStringAsFixed(1)} dB(A)',
            ),
            _buildInfoRow(
              '剂量百分比',
              '${doseData['dosePercentage'].toStringAsFixed(1)}%',
            ),
            _buildInfoRow(
              '剂量率',
              '${doseData['doseRate'].toStringAsFixed(1)} %/小时',
            ),
            _buildInfoRow('暴露时长', '${doseData['duration']} 小时'),
            _buildInfoRow('是否超标', doseData['isExceeding'] ? '是' : '否'),
            _buildInfoRow(
              '限值余量',
              '${doseData['limitMargin'].toStringAsFixed(1)} dB',
            ),
            _buildInfoRow(
              '风险等级',
              _getRiskLevelDisplayName(doseData['riskLevel']),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatisticsData() {
    final statistics = _reportData!['statistics'];
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('统计信息', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '平均分贝',
                    '${statistics['avg'].toStringAsFixed(1)} dB',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    '最小分贝',
                    '${statistics['min'].toStringAsFixed(1)} dB',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    '最大分贝',
                    '${statistics['max'].toStringAsFixed(1)} dB',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    '峰值分贝',
                    '${statistics['peak'].toStringAsFixed(1)} dB',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'L10',
                    '${statistics['l10'].toStringAsFixed(1)} dB',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'L50',
                    '${statistics['l50'].toStringAsFixed(1)} dB',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    'L90',
                    '${statistics['l90'].toStringAsFixed(1)} dB',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    'LEQ',
                    '${_reportData!['leq'].toStringAsFixed(1)} dB',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceConclusion() {
    final doseData = _reportData!['doseData'];
    final isExceeding = doseData['isExceeding'] as bool;
    final dosePercentage = doseData['dosePercentage'] as double;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('合规性结论', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isExceeding ? Colors.red.shade50 : Colors.green.shade50,
                border: Border.all(
                  color: isExceeding ? Colors.red : Colors.green,
                  width: 2,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Icon(
                        isExceeding ? Icons.warning : Icons.check_circle,
                        color: isExceeding ? Colors.red : Colors.green,
                        size: 32,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _getComplianceText(isExceeding, dosePercentage),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: isExceeding ? Colors.red : Colors.green,
                          ),
                        ),
                      ),
                    ],
                  ),
                  if (isExceeding) ...[
                    const SizedBox(height: 12),
                    const Text(
                      '建议措施：',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('• 立即停止暴露或减少暴露时间'),
                    const Text('• 必须佩戴听力保护设备'),
                    const Text('• 建议降低噪声源或改善工作环境'),
                    const Text('• 定期进行听力检查'),
                  ] else if (dosePercentage >= 50.0) ...[
                    const SizedBox(height: 12),
                    const Text(
                      '建议措施：',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('• 建议佩戴听力保护设备'),
                    const Text('• 注意暴露时间控制'),
                    const Text('• 定期监测噪声水平'),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _generateReport,
            icon: const Icon(Icons.refresh),
            label: const Text('刷新报告'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // TODO: 实现导出功能
              _showSuccess('导出功能开发中...');
            },
            icon: const Icon(Icons.file_download),
            label: const Text('导出报告'),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _formatDateTime(String dateTimeStr) {
    try {
      final dateTime = DateTime.parse(dateTimeStr);
      return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}:${dateTime.second.toString().padLeft(2, '0')}';
    } catch (e) {
      return dateTimeStr;
    }
  }

  String _getStandardDisplayName(String standard) {
    switch (standard) {
      case 'osha':
        return 'OSHA (美国职业安全与健康管理局)';
      case 'niosh':
        return 'NIOSH (美国国家职业安全与健康研究所)';
      case 'gbz':
        return 'GBZ (中国国家标准)';
      case 'eu':
        return 'EU (欧盟标准)';
      default:
        return standard;
    }
  }

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

  String _getComplianceText(bool isExceeding, double dosePercentage) {
    if (isExceeding) {
      return '不符合标准，已超过限值';
    } else if (dosePercentage >= 50.0) {
      return '符合标准，但建议采取听力保护措施';
    } else {
      return '符合标准，在安全范围内';
    }
  }
}
