import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:decibel_meter/decibel_meter.dart';
import '../widgets/chart_widgets.dart';
import 'calibration_page.dart';
import 'report_page.dart';

class DecibelMeterPage extends StatefulWidget {
  const DecibelMeterPage({super.key});

  @override
  State<DecibelMeterPage> createState() => _DecibelMeterPageState();
}

class _DecibelMeterPageState extends State<DecibelMeterPage> {
  final DecibelMeter _decibelMeter = DecibelMeter();
  Timer? _timer;

  // 测量状态
  bool _isMeasuring = false;
  String _measurementState = 'idle';

  // 基本数据
  double _currentDecibel = 0.0;
  double _avgDecibel = 0.0;
  double _minDecibel = -1.0;
  double _maxDecibel = -1.0;
  double _peakDecibel = -1.0;
  String _measurementDuration = '00:00:00';

  // 权重设置
  String _currentFrequencyWeighting = 'A-weight';
  String _currentTimeWeighting = 'Fast';
  String _weightingDisplayText = 'dB(A)F';

  // 权重选项
  List<String> _frequencyWeightings = [];
  List<String> _timeWeightings = [];

  // 图表数据
  List<ChartData> _realTimeChartData = [];
  Map<String, dynamic> _realTimeIndicatorData = {};
  Map<String, dynamic> _spectrumData = {};
  Map<String, dynamic> _distributionData = {};
  Map<String, dynamic> _leqTrendData = {};

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    if (_isMeasuring) {
      _decibelMeter.stopMeasurement();
    }
    super.dispose();
  }

  Future<void> _initializeData() async {
    await _loadWeightingOptions();
    await _updateDisplayData();
  }

  Future<void> _loadWeightingOptions() async {
    try {
      final freqWeightings = await _decibelMeter
          .getAvailableFrequencyWeightings();
      final timeWeightings = await _decibelMeter.getAvailableTimeWeightings();

      setState(() {
        _frequencyWeightings = freqWeightings;
        _timeWeightings = timeWeightings;
      });
    } catch (e) {
      _showError('加载权重选项失败: $e');
    }
  }

  Future<void> _updateDisplayData() async {
    try {
      final state = await _decibelMeter.getCurrentState();
      final decibel = await _decibelMeter.getCurrentDecibel();
      final duration = await _decibelMeter.getFormattedMeasurementDuration();
      final leq = await _decibelMeter.getRealTimeLeq();
      final min = await _decibelMeter.getMinDecibel();
      final max = await _decibelMeter.getMaxDecibel();
      final peak = await _decibelMeter.getCurrentPeak();
      final freqWeighting = await _decibelMeter.getCurrentFrequencyWeighting();
      final timeWeighting = await _decibelMeter.getCurrentTimeWeighting();
      final weightingText = await _decibelMeter.getWeightingDisplayText();

      setState(() {
        _measurementState = state;
        _currentDecibel = decibel;
        _avgDecibel = leq;
        _minDecibel = min < 0 ? 0.0 : min;
        _maxDecibel = max < 0 ? 0.0 : max;
        _peakDecibel = peak < 0 ? 0.0 : peak;
        _measurementDuration = duration;
        _currentFrequencyWeighting = freqWeighting;
        _currentTimeWeighting = timeWeighting;
        _weightingDisplayText = weightingText;
      });
    } catch (e) {
      _showError('更新显示数据失败: $e');
    }
  }

  Future<void> _updateChartData() async {
    try {
      // 实时指示器数据
      final indicatorJson = await _decibelMeter.getRealTimeIndicatorData();
      _realTimeIndicatorData = jsonDecode(indicatorJson);

      // 时间历程图数据
      final timeHistoryJson = await _decibelMeter.getTimeHistoryChartData(
        timeRange: 60.0,
      );
      final timeHistoryData = jsonDecode(timeHistoryJson);

      setState(() {
        _realTimeChartData =
            (timeHistoryData['dataPoints'] as List?)
                ?.map(
                  (point) => ChartData(
                    point['timestamp'] as String,
                    (point['decibel'] as num).toDouble(),
                  ),
                )
                .toList() ??
            [];
      });

      // 频谱分析图数据
      final spectrumJson = await _decibelMeter.getSpectrumChartData(
        bandType: '1/3',
      );
      _spectrumData = jsonDecode(spectrumJson);

      // 统计分布图数据
      final distributionJson = await _decibelMeter
          .getStatisticalDistributionChartData();
      _distributionData = jsonDecode(distributionJson);

      // LEQ趋势图数据
      final leqTrendJson = await _decibelMeter.getLEQTrendChartData(
        interval: 10.0,
      );
      _leqTrendData = jsonDecode(leqTrendJson);
    } catch (e) {
      _showError('更新图表数据失败: $e');
    }
  }

  Future<void> _toggleMeasurement() async {
    try {
      if (_isMeasuring) {
        await _decibelMeter.stopMeasurement();
        _timer?.cancel();
        setState(() {
          _isMeasuring = false;
        });
      } else {
        await _decibelMeter.startMeasurement();
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          _updateDisplayData();
          _updateChartData();
        });
        setState(() {
          _isMeasuring = true;
        });
      }
    } catch (e) {
      _showError('切换测量状态失败: $e');
    }
  }

  Future<void> _resetData() async {
    try {
      await _decibelMeter.resetAllData();
      await _updateDisplayData();
      setState(() {
        _realTimeChartData.clear();
        _realTimeIndicatorData.clear();
        _spectrumData.clear();
        _distributionData.clear();
        _leqTrendData.clear();
      });
      _showSuccess('数据已重置');
    } catch (e) {
      _showError('重置数据失败: $e');
    }
  }

  void _showFrequencyWeightingMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildWeightingMenu(
        '频率权重',
        _frequencyWeightings,
        _currentFrequencyWeighting,
        (value) async {
          await _decibelMeter.setFrequencyWeighting(value);
          await _updateDisplayData();
        },
      ),
    );
  }

  void _showTimeWeightingMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _buildWeightingMenu(
        '时间权重',
        _timeWeightings,
        _currentTimeWeighting,
        (value) async {
          await _decibelMeter.setTimeWeighting(value);
          await _updateDisplayData();
        },
      ),
    );
  }

  Widget _buildWeightingMenu(
    String title,
    List<String> options,
    String currentValue,
    Function(String) onSelected,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 16),
          ...options.map(
            (option) => ListTile(
              title: Text(option),
              trailing: option == currentValue ? const Icon(Icons.check) : null,
              onTap: () {
                onSelected(option);
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
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
            // 控制按钮区域
            _buildControlSection(),
            const SizedBox(height: 24),

            // 基本数据显示
            _buildBasicDataSection(),
            const SizedBox(height: 24),

            // 权重设置
            _buildWeightingSection(),
            const SizedBox(height: 24),

            // 操作按钮
            _buildActionButtons(),
            const SizedBox(height: 24),

            // 图表区域
            _buildChartsSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildControlSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('测量控制', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _toggleMeasurement,
                  icon: Icon(_isMeasuring ? Icons.stop : Icons.play_arrow),
                  label: Text(_isMeasuring ? '停止测量' : '开始测量'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isMeasuring ? Colors.red : Colors.green,
                    foregroundColor: Colors.white,
                  ),
                ),
                Text(
                  '状态: $_measurementState',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
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
                    'AVG(LEQ)',
                    '${_avgDecibel.toStringAsFixed(1)} dB',
                  ),
                ),
                Expanded(
                  child: _buildDataItem(
                    'MIN',
                    '${_minDecibel.toStringAsFixed(1)} dB',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDataItem(
                    'MAX',
                    '${_maxDecibel.toStringAsFixed(1)} dB',
                  ),
                ),
                Expanded(
                  child: _buildDataItem(
                    'PEAK',
                    '${_peakDecibel.toStringAsFixed(1)} dB',
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

  Widget _buildWeightingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('权重设置', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showFrequencyWeightingMenu,
                    icon: const Icon(Icons.tune),
                    label: Text('频率权重: $_currentFrequencyWeighting'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _showTimeWeightingMenu,
                    icon: const Icon(Icons.access_time),
                    label: Text('时间权重: $_currentTimeWeighting'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Center(
              child: Text(
                '显示格式: $_weightingDisplayText',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
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
          child: OutlinedButton.icon(
            onPressed: _resetData,
            icon: const Icon(Icons.refresh),
            label: const Text('重置'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CalibrationPage(),
                ),
              );
            },
            icon: const Icon(Icons.tune),
            label: const Text('校准'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ReportPage()),
              );
            },
            icon: const Icon(Icons.file_download),
            label: const Text('导出'),
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

            // 实时分贝曲线图
            if (_realTimeChartData.isNotEmpty) ...[
              const Text(
                '实时分贝曲线图',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: RealTimeChart(data: _realTimeChartData),
              ),
              const SizedBox(height: 16),
            ],

            // 实时指示器图
            if (_realTimeIndicatorData.isNotEmpty) ...[
              const Text(
                '实时指示器',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              RealTimeIndicator(data: _realTimeIndicatorData),
              const SizedBox(height: 16),
            ],

            // 频谱分析图
            if (_spectrumData.isNotEmpty) ...[
              const Text(
                '频谱分析图',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(height: 200, child: SpectrumChart(data: _spectrumData)),
              const SizedBox(height: 16),
            ],

            // 统计分布图
            if (_distributionData.isNotEmpty) ...[
              const Text(
                '统计分布图',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 200,
                child: StatisticalDistributionChart(data: _distributionData),
              ),
              const SizedBox(height: 16),
            ],

            // LEQ趋势图
            if (_leqTrendData.isNotEmpty) ...[
              const Text(
                'LEQ趋势图',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              SizedBox(height: 200, child: LEQTrendChart(data: _leqTrendData)),
            ],
          ],
        ),
      ),
    );
  }
}
