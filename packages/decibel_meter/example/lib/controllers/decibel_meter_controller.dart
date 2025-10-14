import 'dart:async';
import 'dart:convert';
import 'package:get/get.dart';
import 'package:decibel_meter/decibel_meter.dart';
import '../widgets/chart_widgets.dart';

/// 分贝测量仪控制器
///
/// 使用GetX管理分贝计和噪音测量计的状态和数据
class DecibelMeterController extends GetxController {
  // MARK: - 分贝计相关状态

  /// 是否正在测量
  final RxBool _isMeasuring = false.obs;
  bool get isMeasuring => _isMeasuring.value;

  /// 当前分贝值
  final RxDouble _currentDecibel = 0.0.obs;
  double get currentDecibel => _currentDecibel.value;

  /// 平均分贝值(LEQ)
  final RxDouble _avgDecibel = 0.0.obs;
  double get avgDecibel => _avgDecibel.value;

  /// 最小分贝值
  final RxDouble _minDecibel = 0.0.obs;
  double get minDecibel => _minDecibel.value;

  /// 最大分贝值
  final RxDouble _maxDecibel = 0.0.obs;
  double get maxDecibel => _maxDecibel.value;

  /// 峰值分贝值
  final RxDouble _peakDecibel = 0.0.obs;
  double get peakDecibel => _peakDecibel.value;

  /// 测量时长
  final RxString _measurementDuration = '00:00:00'.obs;
  String get measurementDuration => _measurementDuration.value;

  /// 当前频率权重
  final RxString _currentFrequencyWeighting = 'A'.obs;
  String get currentFrequencyWeighting => _currentFrequencyWeighting.value;

  /// 当前时间权重
  final RxString _currentTimeWeighting = 'F'.obs;
  String get currentTimeWeighting => _currentTimeWeighting.value;

  /// 权重显示格式
  final RxString _weightingDisplay = 'dB(A)F'.obs;
  String get weightingDisplay => _weightingDisplay.value;

  // MARK: - 噪音测量计相关状态

  /// 当前噪声标准
  final RxString _currentStandard = 'NIOSH'.obs;
  String get currentStandard => _currentStandard.value;

  /// TWA值
  final RxDouble _twa = 0.0.obs;
  double get twa => _twa.value;

  /// 限值
  final RxDouble _limit = 85.0.obs;
  double get limit => _limit.value;

  /// 交换率
  final RxDouble _exchangeRate = 3.0.obs;
  double get exchangeRate => _exchangeRate.value;

  /// 总剂量
  final RxDouble _totalDose = 0.0.obs;
  double get totalDose => _totalDose.value;

  /// 剂量率
  final RxDouble _doseRate = 0.0.obs;
  double get doseRate => _doseRate.value;

  /// 是否超标
  final RxBool _isExceeding = false.obs;
  bool get isExceeding => _isExceeding.value;

  /// 限值余量
  final RxDouble _limitMargin = 0.0.obs;
  double get limitMargin => _limitMargin.value;

  /// 风险等级
  final RxString _riskLevel = 'low'.obs;
  String get riskLevel => _riskLevel.value;

  // MARK: - 选项列表

  /// 可用频率权重列表
  final RxList<String> _frequencyWeightings = <String>[].obs;
  List<String> get frequencyWeightings => _frequencyWeightings;

  /// 可用时间权重列表
  final RxList<String> _timeWeightings = <String>[].obs;
  List<String> get timeWeightings => _timeWeightings;

  /// 可用噪声标准列表
  final RxList<String> _availableStandards = <String>[].obs;
  List<String> get availableStandards => _availableStandards;

  // MARK: - 图表数据

  /// 实时图表数据
  final RxList<ChartData> _realTimeChartData = <ChartData>[].obs;
  List<ChartData> get realTimeChartData => _realTimeChartData;

  /// 实时指示器数据
  final RxMap<String, dynamic> _realTimeIndicatorData = <String, dynamic>{}.obs;
  Map<String, dynamic> get realTimeIndicatorData => _realTimeIndicatorData;

  /// 频谱数据
  final RxMap<String, dynamic> _spectrumData = <String, dynamic>{}.obs;
  Map<String, dynamic> get spectrumData => _spectrumData;

  /// 分布数据
  final RxMap<String, dynamic> _distributionData = <String, dynamic>{}.obs;
  Map<String, dynamic> get distributionData => _distributionData;

  /// LEQ趋势数据
  final RxMap<String, dynamic> _leqTrendData = <String, dynamic>{}.obs;
  Map<String, dynamic> get leqTrendData => _leqTrendData;

  /// 剂量图表数据
  final RxMap<String, dynamic> _doseChartData = <String, dynamic>{}.obs;
  Map<String, dynamic> get doseChartData => _doseChartData;

  /// TWA趋势数据
  final RxMap<String, dynamic> _twaChartData = <String, dynamic>{}.obs;
  Map<String, dynamic> get twaChartData => _twaChartData;

  /// 允许暴露时长表
  final RxList<Map<String, dynamic>> _durationTable =
      <Map<String, dynamic>>[].obs;
  List<Map<String, dynamic>> get durationTable => _durationTable;

  // MARK: - 私有变量

  Timer? _measurementTimer;
  Timer? _dataUpdateTimer;
  StreamSubscription<(String, Map<String, dynamic>)>? _eventSubscription;
  final DecibelMeter _decibelMeter = DecibelMeter();

  // 测量开始时间，用于计算记录时长
  DateTime? _measurementStartTime;

  @override
  void onInit() {
    super.onInit();
    _loadInitialData();
    _setupEventListeners();
  }

  @override
  void onClose() {
    _measurementTimer?.cancel();
    _dataUpdateTimer?.cancel();
    _eventSubscription?.cancel();
    super.onClose();
  }

  /// 设置事件监听器
  void _setupEventListeners() {
    _eventSubscription = _decibelMeter.onDecibelMeterEvents.listen(
      (event) {
        final eventType = event.$1;
        final eventData = event.$2;
        _handleEvent(eventType, eventData);
      },
      onError: (error) {
        print('事件监听错误: $error');
      },
    );
  }

  /// 处理事件
  void _handleEvent(String eventType, Map<String, dynamic> eventData) {
    switch (eventType) {
      case 'measurementUpdate':
        _handleMeasurementUpdate(eventData);
        break;
      case 'stateChange':
        _handleStateChange(eventData);
        break;
      case 'meterDataUpdate':
        _handleMeterDataUpdate(eventData);
        break;
      case 'noiseDosimeterUpdate':
        _handleNoiseDosimeterUpdate(eventData);
        break;
      case 'error':
        print('接收到错误事件: ${eventData['desc']}');
        break;
      default:
        print('未知事件类型: $eventType');
    }
  }

  /// 处理测量更新事件
  void _handleMeasurementUpdate(Map<String, dynamic> eventData) {
    try {
      final measurement = eventData['measurement'];
      if (measurement != null) {
        _currentDecibel.value = _safeToDouble(measurement['displayDecibel']);

        // 使用测量开始时间计算记录时长
        if (_measurementStartTime != null) {
          _measurementDuration.value = _formatDuration(
            DateTime.now()
                .difference(_measurementStartTime!)
                .inSeconds
                .toDouble(),
          );
        }
      }
    } catch (e) {
      print('处理测量更新事件失败: $e');
    }
  }

  /// 处理状态变化事件
  void _handleStateChange(Map<String, dynamic> eventData) {
    try {
      final state = eventData['state'] as String?;
      if (state != null) {
        _isMeasuring.value = state == 'measuring';

        // 记录测量开始时间
        if (state == 'measuring' && _measurementStartTime == null) {
          _measurementStartTime = DateTime.now();
        } else if (state != 'measuring') {
          _measurementStartTime = null;
        }
      }
    } catch (e) {
      print('处理状态变化事件失败: $e');
    }
  }

  /// 处理仪表数据更新事件
  void _handleMeterDataUpdate(Map<String, dynamic> eventData) {
    try {
      _currentDecibel.value = _safeToDouble(eventData['current']);
      _maxDecibel.value = _safeToDouble(eventData['max']);
      _minDecibel.value = _safeToDouble(eventData['min']);
      _peakDecibel.value = _safeToDouble(eventData['peak']);
      _avgDecibel.value = _safeToDouble(eventData['leq']); // 添加LEQ值处理
    } catch (e) {
      print('处理仪表数据更新事件失败: $e');
    }
  }

  /// 处理噪音测量计更新事件
  void _handleNoiseDosimeterUpdate(Map<String, dynamic> eventData) {
    try {
      // 更新TWA值
      if (eventData.containsKey('twa')) {
        _twa.value = _safeToDouble(eventData['twa']);
      }

      // 更新剂量数据
      if (eventData.containsKey('totalDose')) {
        _totalDose.value = _safeToDouble(eventData['totalDose']);
      }

      if (eventData.containsKey('doseRate')) {
        _doseRate.value = _safeToDouble(eventData['doseRate']);
      }

      // 更新超标状态
      if (eventData.containsKey('isExceeding')) {
        _isExceeding.value = eventData['isExceeding'] as bool? ?? false;
      }

      // 更新风险等级
      if (eventData.containsKey('riskLevel')) {
        _riskLevel.value = eventData['riskLevel'] as String? ?? 'low';
      }
    } catch (e) {
      print('处理噪音测量计更新事件失败: $e');
    }
  }

  /// 加载初始数据
  Future<void> _loadInitialData() async {
    try {
      // 加载权重选项
      await _loadWeightingOptions();

      // 加载噪声标准选项
      await _loadNoiseStandardOptions();

      // 加载当前设置
      await _loadCurrentSettings();
    } catch (e) {
      print('加载初始数据失败: $e');
    }
  }

  /// 加载权重选项
  Future<void> _loadWeightingOptions() async {
    try {
      final freqWeightings = await _decibelMeter
          .getAvailableFrequencyWeightings();
      final timeWeightings = await _decibelMeter.getAvailableTimeWeightings();

      _frequencyWeightings.assignAll(freqWeightings);
      _timeWeightings.assignAll(timeWeightings);
    } catch (e) {
      print('加载权重选项失败: $e');
    }
  }

  /// 加载噪声标准选项
  Future<void> _loadNoiseStandardOptions() async {
    try {
      final standards = await _decibelMeter.getAvailableNoiseStandards();
      _availableStandards.assignAll(standards);
    } catch (e) {
      print('加载噪声标准选项失败: $e');
    }
  }

  /// 加载当前设置
  Future<void> _loadCurrentSettings() async {
    try {
      final currentFreqWeighting = await _decibelMeter
          .getCurrentFrequencyWeighting();
      final currentTimeWeighting = await _decibelMeter
          .getCurrentTimeWeighting();

      _currentFrequencyWeighting.value = currentFreqWeighting;
      _currentTimeWeighting.value = currentTimeWeighting;
      _updateWeightingDisplay();
    } catch (e) {
      print('加载当前设置失败: $e');
    }
  }

  /// 更新权重显示格式
  void _updateWeightingDisplay() {
    final freqShort = _getFrequencyWeightingShort(
      _currentFrequencyWeighting.value,
    );
    final timeShort = _getTimeWeightingShort(_currentTimeWeighting.value);
    _weightingDisplay.value = 'dB($freqShort)$timeShort';
  }

  /// 获取频率权重简写
  String _getFrequencyWeightingShort(String weighting) {
    switch (weighting) {
      case 'dB-A':
      case 'A':
        return 'A';
      case 'dB-B':
      case 'B':
        return 'B';
      case 'dB-C':
      case 'C':
        return 'C';
      case 'dB-Z':
      case 'Z':
        return 'Z';
      case 'ITU-R 468':
        return 'ITU';
      default:
        return weighting.isNotEmpty ? weighting[0].toUpperCase() : 'A';
    }
  }

  /// 获取时间权重简写
  String _getTimeWeightingShort(String weighting) {
    switch (weighting.toLowerCase()) {
      case 'fast':
      case 'f':
        return 'F';
      case 'slow':
      case 's':
        return 'S';
      case 'impulse':
      case 'i':
        return 'I';
      default:
        return weighting.isNotEmpty ? weighting[0].toUpperCase() : 'F';
    }
  }

  // MARK: - 分贝计操作方法

  /// 开始/停止测量
  Future<void> toggleMeasurement() async {
    try {
      if (_isMeasuring.value) {
        await _stopMeasurement();
      } else {
        await _startMeasurement();
      }
    } catch (e) {
      print('切换测量状态失败: $e');
    }
  }

  /// 开始测量
  Future<void> _startMeasurement() async {
    try {
      await _decibelMeter.startMeasurement();
      // 记录测量开始时间
      _measurementStartTime = DateTime.now();

      // 定期更新图表数据（事件流不包含图表数据）
      _startDataUpdateTimer();
    } catch (e) {
      print('开始测量失败: $e');
    }
  }

  /// 停止测量
  Future<void> _stopMeasurement() async {
    try {
      await _decibelMeter.stopMeasurement();
      // 清理测量开始时间
      _measurementStartTime = null;

      // 停止定时器
      _dataUpdateTimer?.cancel();
    } catch (e) {
      print('停止测量失败: $e');
    }
  }

  /// 开始数据更新定时器
  void _startDataUpdateTimer() {
    _dataUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // 更新记录时长（实时计算）
      if (_measurementStartTime != null) {
        _measurementDuration.value = _formatDuration(
          DateTime.now()
              .difference(_measurementStartTime!)
              .inSeconds
              .toDouble(),
        );
      }

      // 基本数据通过事件流实时更新，这里只更新图表数据
      _updateChartData();
      _updateStatisticsData();
    });
  }

  /// 更新统计数据
  Future<void> _updateStatisticsData() async {
    try {
      // LEQ值现在通过meterDataUpdate事件流更新，这里只作为备用更新
      // 如果事件流没有及时更新，这里可以确保数据同步
      final statistics = await _decibelMeter.getStatistics();

      // 只有在事件流没有更新LEQ值时才使用API数据
      if (_avgDecibel.value == 0.0) {
        _avgDecibel.value = statistics['avg'] ?? 0.0;
      }
    } catch (e) {
      print('更新统计数据失败: $e');
    }
  }

  /// 更新图表数据
  Future<void> _updateChartData() async {
    try {
      // 更新实时指示器数据
      final realTimeIndicatorJson = await _decibelMeter
          .getRealTimeIndicatorData();
      final realTimeIndicator =
          jsonDecode(realTimeIndicatorJson) as Map<String, dynamic>;
      _realTimeIndicatorData.assignAll(realTimeIndicator);

      // 更新实时图表数据（减少频率，避免过度更新）
      if (_realTimeChartData.length < 60) {
        final timeHistoryJson = await _decibelMeter.getTimeHistoryChartData(
          timeRange: 60.0,
        );
        final timeHistoryData = jsonDecode(timeHistoryJson);

        final chartData =
            (timeHistoryData['dataPoints'] as List?)
                ?.map(
                  (point) => ChartData(
                    point['timestamp'] as String,
                    _safeToDouble(point['decibel']),
                  ),
                )
                .toList() ??
            [];

        _realTimeChartData.assignAll(chartData);
      }
    } catch (e) {
      print('更新图表数据失败: $e');
    }
  }

  /// 设置频率权重
  Future<void> setFrequencyWeighting(String weighting) async {
    try {
      await _decibelMeter.setFrequencyWeighting(weighting);
      _currentFrequencyWeighting.value = weighting;
      _updateWeightingDisplay();
    } catch (e) {
      print('设置频率权重失败: $e');
    }
  }

  /// 设置时间权重
  Future<void> setTimeWeighting(String weighting) async {
    try {
      await _decibelMeter.setTimeWeighting(weighting);
      _currentTimeWeighting.value = weighting;
      _updateWeightingDisplay();
    } catch (e) {
      print('设置时间权重失败: $e');
    }
  }

  /// 重置测量数据
  Future<void> resetMeasurement() async {
    try {
      await _decibelMeter.clearHistory();

      // 重置所有状态
      _currentDecibel.value = 0.0;
      _avgDecibel.value = 0.0;
      _minDecibel.value = 0.0;
      _maxDecibel.value = 0.0;
      _peakDecibel.value = 0.0;
      _measurementDuration.value = '00:00:00';
      _measurementStartTime = null;

      // 清空图表数据
      _realTimeChartData.clear();
      _realTimeIndicatorData.clear();
      _spectrumData.clear();
      _distributionData.clear();
      _leqTrendData.clear();
    } catch (e) {
      print('重置测量数据失败: $e');
    }
  }

  /// 加载所有图表数据
  Future<void> loadAllChartData() async {
    try {
      // 频谱分析图数据
      final spectrumJson = await _decibelMeter.getSpectrumChartData(
        bandType: '1/3',
      );
      _spectrumData.assignAll(jsonDecode(spectrumJson));

      // 统计分布图数据
      final distributionJson = await _decibelMeter
          .getStatisticalDistributionChartData();
      _distributionData.assignAll(jsonDecode(distributionJson));

      // LEQ趋势图数据
      final leqTrendJson = await _decibelMeter.getLEQTrendChartData(
        interval: 10.0,
      );
      _leqTrendData.assignAll(jsonDecode(leqTrendJson));
    } catch (e) {
      print('加载图表数据失败: $e');
    }
  }

  // MARK: - 噪音测量计操作方法

  /// 设置噪声标准
  Future<void> setNoiseStandard(String standard) async {
    try {
      await _decibelMeter.setNoiseStandard(standard);
      _currentStandard.value = standard;

      // 根据标准设置限值和交换率
      switch (standard) {
        case 'OSHA':
          _limit.value = 90.0;
          _exchangeRate.value = 5.0;
          break;
        case 'NIOSH':
          _limit.value = 85.0;
          _exchangeRate.value = 3.0;
          break;
        case 'GBZ':
          _limit.value = 85.0;
          _exchangeRate.value = 3.0;
          break;
        case 'EU':
          _limit.value = 87.0;
          _exchangeRate.value = 3.0;
          break;
      }

      // 更新噪音测量计数据
      await updateNoiseDosimeterData();
    } catch (e) {
      print('设置噪声标准失败: $e');
    }
  }

  /// 更新噪音测量计数据
  Future<void> updateNoiseDosimeterData() async {
    try {
      // 剂量数据
      final doseData = await _decibelMeter.getNoiseDoseData(
        standard: _currentStandard.value,
      );

      // 限值比较结果
      final comparisonResult = await _decibelMeter.getLimitComparisonResult(
        _currentStandard.value,
      );

      // 允许暴露时长表
      final durationTableJson = await _decibelMeter
          .getPermissibleExposureDurationTable(
            standard: _currentStandard.value,
          );
      final durationTableData = jsonDecode(durationTableJson);

      // 剂量累积图表
      final doseChartJson = await _decibelMeter.getDoseAccumulationChartData();

      // TWA趋势图表
      final twaChartJson = await _decibelMeter.getTWATrendChartData();

      // 更新状态
      _twa.value = _safeToDouble(doseData['twa']);
      _totalDose.value = _safeToDouble(doseData['dosePercentage']);
      _doseRate.value = _safeToDouble(doseData['doseRate']);
      _isExceeding.value = doseData['isExceeding'] as bool? ?? false;
      _riskLevel.value = doseData['riskLevel'] as String? ?? 'low';
      _limitMargin.value = _safeToDouble(comparisonResult['limitMargin']);

      // 更新表格数据
      _durationTable.assignAll(
        (durationTableData['durations'] as List?)
                ?.map((e) => Map<String, dynamic>.from(e))
                .toList() ??
            [],
      );

      // 更新图表数据
      _doseChartData.assignAll(jsonDecode(doseChartJson));
      _twaChartData.assignAll(jsonDecode(twaChartJson));
    } catch (e) {
      print('更新噪音测量计数据失败: $e');
    }
  }

  /// 重置噪音测量计数据
  Future<void> resetNoiseDosimeter() async {
    try {
      await _decibelMeter.clearHistory();

      // 重置状态
      _twa.value = 0.0;
      _totalDose.value = 0.0;
      _doseRate.value = 0.0;
      _isExceeding.value = false;
      _limitMargin.value = 0.0;
      _riskLevel.value = 'low';

      // 清空数据
      _durationTable.clear();
      _doseChartData.clear();
      _twaChartData.clear();
    } catch (e) {
      print('重置噪音测量计数据失败: $e');
    }
  }

  /// 获取综合报告
  Future<Map<String, dynamic>?> getComprehensiveReport() async {
    try {
      final reportJson = await _decibelMeter.generateNoiseDosimeterReport();
      return reportJson != null ? jsonDecode(reportJson) : null;
    } catch (e) {
      print('获取综合报告失败: $e');
      return null;
    }
  }

  // MARK: - 工具方法

  /// 安全的数字转换方法，处理int和double类型
  double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return 0.0;
  }

  /// 格式化时长
  String _formatDuration(double seconds) {
    final hours = (seconds / 3600).floor();
    final minutes = ((seconds % 3600) / 60).floor();
    final secs = (seconds % 60).floor();
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}
