import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:decibel_meter/decibel_meter.dart';
import '../widgets/chart_widgets.dart';

class NoiseDosimeterPage extends StatefulWidget {
  const NoiseDosimeterPage({super.key});

  @override
  State<NoiseDosimeterPage> createState() => _NoiseDosimeterPageState();
}

class _NoiseDosimeterPageState extends State<NoiseDosimeterPage> {
  final DecibelMeter _decibelMeter = DecibelMeter();
  Timer? _timer;

  // 基本数据
  double _currentDecibel = 0.0;
  double _twa = 0.0;
  double _limit = 85.0;
  double _exchangeRate = 3.0;
  String _measurementDuration = '00:00:00';

  // 标准设置
  String _currentStandard = 'niosh';
  List<String> _availableStandards = [];

  // 剂量数据
  double _totalDose = 0.0;
  double _doseRate = 0.0;
  bool _isExceeding = false;
  String _riskLevel = 'low';
  double _limitMargin = 0.0;

  // 允许暴露时长表
  List<Map<String, dynamic>> _durationTable = [];

  // 图表数据
  Map<String, dynamic> _doseChartData = {};
  Map<String, dynamic> _twaChartData = {};

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _loadStandards();
    await _updateDisplayData();
  }

  Future<void> _loadStandards() async {
    try {
      final standards = await _decibelMeter.getAvailableNoiseStandards();
      setState(() {
        _availableStandards = standards;
      });
    } catch (e) {
      _showError('加载标准列表失败: $e');
    }
  }

  Future<void> _updateDisplayData() async {
    try {
      // 基本数据
      final decibel = await _decibelMeter.getCurrentDecibel();
      final duration = await _decibelMeter.getFormattedMeasurementDuration();

      // 剂量数据
      final doseData = await _decibelMeter.getNoiseDoseData(
        standard: _currentStandard,
      );

      // 限值比较结果
      final comparisonResult = await _decibelMeter.getLimitComparisonResult(
        _currentStandard,
      );

      // 允许暴露时长表
      final durationTableJson = await _decibelMeter
          .getPermissibleExposureDurationTable(standard: _currentStandard);
      final durationTableData = jsonDecode(durationTableJson);

      // 图表数据
      final doseChartJson = await _decibelMeter.getDoseAccumulationChartData(
        standard: _currentStandard,
      );
      final twaChartJson = await _decibelMeter.getTWATrendChartData(
        standard: _currentStandard,
      );

      setState(() {
        _currentDecibel = decibel;
        _measurementDuration = duration;
        _twa = doseData['twa'] ?? 0.0;
        _totalDose = doseData['dosePercentage'] ?? 0.0;
        _doseRate = doseData['doseRate'] ?? 0.0;
        _isExceeding = doseData['isExceeding'] ?? false;
        _riskLevel = doseData['riskLevel'] ?? 'low';
        _limitMargin = comparisonResult['limitMargin'] ?? 0.0;

        // 根据标准设置限值和交换率
        switch (_currentStandard) {
          case 'osha':
            _limit = 90.0;
            _exchangeRate = 5.0;
            break;
          case 'niosh':
            _limit = 85.0;
            _exchangeRate = 3.0;
            break;
          case 'gbz':
            _limit = 85.0;
            _exchangeRate = 3.0;
            break;
          case 'eu':
            _limit = 87.0;
            _exchangeRate = 3.0;
            break;
        }

        _durationTable =
            (durationTableData['durations'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e))
                .toList() ??
            [];

        _doseChartData = jsonDecode(doseChartJson);
        _twaChartData = jsonDecode(twaChartJson);
      });
    } catch (e) {
      _showError('更新显示数据失败: $e');
    }
  }

  Future<void> _setStandard(String standard) async {
    try {
      await _decibelMeter.setNoiseStandard(standard);
      setState(() {
        _currentStandard = standard;
      });
      await _updateDisplayData();
    } catch (e) {
      _showError('设置标准失败: $e');
    }
  }

  Future<void> _resetData() async {
    try {
      await _decibelMeter.resetAllData();
      await _updateDisplayData();
      _showSuccess('数据已重置');
    } catch (e) {
      _showError('重置数据失败: $e');
    }
  }

  void _showStandardMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('噪声限值标准', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            ..._availableStandards.map(
              (standard) => ListTile(
                title: Text(_getStandardDisplayName(standard)),
                subtitle: Text(_getStandardDescription(standard)),
                trailing: standard == _currentStandard
                    ? const Icon(Icons.check)
                    : null,
                onTap: () {
                  _setStandard(standard);
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
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

  String _getStandardDescription(String standard) {
    switch (standard) {
      case 'osha':
        return 'TWA限值: 90 dB(A), 交换率: 5 dB';
      case 'niosh':
        return 'TWA限值: 85 dB(A), 交换率: 3 dB';
      case 'gbz':
        return 'TWA限值: 85 dB(A), 交换率: 3 dB';
      case 'eu':
        return 'TWA限值: 87 dB(A), 交换率: 3 dB';
      default:
        return '';
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 基本数据显示
            _buildBasicDataSection(),
            const SizedBox(height: 16),

            // 标准设置
            _buildStandardSection(),
            const SizedBox(height: 16),

            // 剂量数据
            _buildDoseDataSection(),
            const SizedBox(height: 16),

            // 允许暴露时长表
            _buildDurationTableSection(),
            const SizedBox(height: 16),

            // 操作按钮
            _buildActionButtons(),
            const SizedBox(height: 16),

            // 图表区域
            _buildChartsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicDataSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('基本数据', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildDataItem('记录时长', _measurementDuration)),
                Expanded(
                  child: _buildDataItem(
                    '当前分贝',
                    '${_currentDecibel.toStringAsFixed(1)} dB',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDataItem(
                    'TWA值',
                    '${_twa.toStringAsFixed(1)} dB(A)',
                  ),
                ),
                Expanded(
                  child: _buildDataItem(
                    '限值',
                    '${_limit.toStringAsFixed(1)} dB(A)',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDataItem(
                    '交换率',
                    '${_exchangeRate.toStringAsFixed(1)} dB',
                  ),
                ),
                Expanded(
                  child: _buildDataItem(
                    '限值余量',
                    '${_limitMargin.toStringAsFixed(1)} dB',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        Text(
          value,
          style: Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStandardSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('测量标准', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _showStandardMenu,
              icon: const Icon(Icons.health_and_safety),
              label: Text('当前标准: ${_getStandardDisplayName(_currentStandard)}'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDoseDataSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('剂量数据', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildDataItem(
                    '总剂量',
                    '${_totalDose.toStringAsFixed(1)}%',
                  ),
                ),
                Expanded(
                  child: _buildDataItem(
                    '剂量率',
                    '${_doseRate.toStringAsFixed(1)} %/h',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDataItem(
                    '风险等级',
                    _getRiskLevelDisplayName(_riskLevel),
                  ),
                ),
                Expanded(
                  child: _buildDataItem('是否超标', _isExceeding ? '是' : '否'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _isExceeding ? Colors.red.shade50 : Colors.green.shade50,
                border: Border.all(
                  color: _isExceeding ? Colors.red : Colors.green,
                  width: 1,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    _isExceeding ? Icons.warning : Icons.check_circle,
                    color: _isExceeding ? Colors.red : Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _isExceeding ? '已超过限值，需要采取措施' : '在安全范围内',
                      style: TextStyle(
                        color: _isExceeding ? Colors.red : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDurationTableSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '允许暴露时长表',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  '总剂量: ${_totalDose.toStringAsFixed(1)}%',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: _totalDose > 100 ? Colors.red : Colors.green,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            if (_durationTable.isEmpty)
              const Center(child: Text('暂无数据'))
            else
              SizedBox(
                height: 300,
                child: ListView.builder(
                  itemCount: _durationTable.length,
                  itemBuilder: (context, index) {
                    final duration = _durationTable[index];
                    final soundLevel = duration['soundLevel'] as double;
                    final allowedDuration =
                        duration['allowedDuration'] as double;
                    final accumulatedDuration =
                        duration['accumulatedDuration'] as double;
                    final currentLevelDose =
                        duration['currentLevelDose'] as double;
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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                '${soundLevel.toStringAsFixed(1)} dB(A)${isCeilingLimit ? ' (天花板限值)' : ''}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                '${currentLevelDose.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: currentLevelDose > 100
                                      ? Colors.red
                                      : Colors.green,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '累计: ${_formatDuration(accumulatedDuration)} / 允许: ${_formatDuration(allowedDuration)}',
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(double seconds) {
    final hours = (seconds / 3600.0).floor();
    final minutes = ((seconds % 3600.0) / 60.0).floor();
    return '${hours}h ${minutes}m';
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _resetData,
            icon: const Icon(Icons.refresh),
            label: const Text('重置'),
          ),
        ),
      ],
    );
  }

  Widget _buildChartsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('图表分析', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),

            // 剂量累积图
            if (_doseChartData.isNotEmpty) ...[
              const Text(
                '剂量累积图',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: DoseAccumulationChart(data: _doseChartData),
              ),
              const SizedBox(height: 16),
            ],

            // TWA趋势图
            if (_twaChartData.isNotEmpty) ...[
              const Text(
                'TWA趋势图',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(height: 200, child: TWATrendChart(data: _twaChartData)),
            ],
          ],
        ),
      ),
    );
  }
}
