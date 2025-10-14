import 'package:flutter/material.dart';
import 'package:decibel_meter/decibel_meter.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final DecibelMeter _decibelMeter = DecibelMeter();

  // 设置项
  double _calibrationOffset = 0.0;
  String _currentFrequencyWeighting = 'A-weight';
  String _currentTimeWeighting = 'Fast';
  String _currentNoiseStandard = 'niosh';

  // 选项列表
  List<String> _frequencyWeightings = [];
  List<String> _timeWeightings = [];
  List<String> _noiseStandards = [];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      // 加载当前设置
      final calibrationOffset = await _decibelMeter.getCalibrationOffset();
      final freqWeighting = await _decibelMeter.getCurrentFrequencyWeighting();
      final timeWeighting = await _decibelMeter.getCurrentTimeWeighting();
      final noiseStandard = await _decibelMeter.getCurrentNoiseStandard();

      // 加载选项列表
      final freqWeightings = await _decibelMeter
          .getAvailableFrequencyWeightings();
      final timeWeightings = await _decibelMeter.getAvailableTimeWeightings();
      final noiseStandards = await _decibelMeter.getAvailableNoiseStandards();

      setState(() {
        _calibrationOffset = calibrationOffset;
        _currentFrequencyWeighting = freqWeighting;
        _currentTimeWeighting = timeWeighting;
        _currentNoiseStandard = noiseStandard;
        _frequencyWeightings = freqWeightings;
        _timeWeightings = timeWeightings;
        _noiseStandards = noiseStandards;
      });
    } catch (e) {
      _showError('加载设置失败: $e');
    }
  }

  Future<void> _saveCalibrationOffset() async {
    try {
      await _decibelMeter.setCalibrationOffset(_calibrationOffset);
      _showSuccess('校准偏移已保存');
    } catch (e) {
      _showError('保存校准偏移失败: $e');
    }
  }

  Future<void> _setFrequencyWeighting(String weighting) async {
    try {
      await _decibelMeter.setFrequencyWeighting(weighting);
      setState(() {
        _currentFrequencyWeighting = weighting;
      });
      _showSuccess('频率权重已设置');
    } catch (e) {
      _showError('设置频率权重失败: $e');
    }
  }

  Future<void> _setTimeWeighting(String weighting) async {
    try {
      await _decibelMeter.setTimeWeighting(weighting);
      setState(() {
        _currentTimeWeighting = weighting;
      });
      _showSuccess('时间权重已设置');
    } catch (e) {
      _showError('设置时间权重失败: $e');
    }
  }

  Future<void> _setNoiseStandard(String standard) async {
    try {
      await _decibelMeter.setNoiseStandard(standard);
      setState(() {
        _currentNoiseStandard = standard;
      });
      _showSuccess('噪声标准已设置');
    } catch (e) {
      _showError('设置噪声标准失败: $e');
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
            // 校准设置
            _buildCalibrationSection(),
            const SizedBox(height: 16),

            // 频率权重设置
            _buildFrequencyWeightingSection(),
            const SizedBox(height: 16),

            // 时间权重设置
            _buildTimeWeightingSection(),
            const SizedBox(height: 16),

            // 噪声标准设置
            _buildNoiseStandardSection(),
            const SizedBox(height: 16),

            // 应用信息
            _buildAppInfoSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildCalibrationSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('校准设置', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '校准偏移 (dB)',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 8),
                      Slider(
                        value: _calibrationOffset,
                        min: -10.0,
                        max: 10.0,
                        divisions: 200,
                        label: _calibrationOffset.toStringAsFixed(1),
                        onChanged: (value) {
                          setState(() {
                            _calibrationOffset = value;
                          });
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${_calibrationOffset.toStringAsFixed(1)} dB',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _saveCalibrationOffset,
                        child: const Text('保存'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '校准偏移用于补偿设备差异，正值表示增加分贝值，负值表示减少分贝值。',
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFrequencyWeightingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('频率权重设置', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _frequencyWeightings.map((weighting) {
                final isSelected = weighting == _currentFrequencyWeighting;
                return FilterChip(
                  label: Text(_getFrequencyWeightingDisplayName(weighting)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      _setFrequencyWeighting(weighting);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              _getFrequencyWeightingDescription(_currentFrequencyWeighting),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimeWeightingSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('时间权重设置', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _timeWeightings.map((weighting) {
                final isSelected = weighting == _currentTimeWeighting;
                return FilterChip(
                  label: Text(_getTimeWeightingDisplayName(weighting)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      _setTimeWeighting(weighting);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              _getTimeWeightingDescription(_currentTimeWeighting),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoiseStandardSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('噪声限值标准', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _noiseStandards.map((standard) {
                final isSelected = standard == _currentNoiseStandard;
                return FilterChip(
                  label: Text(_getNoiseStandardDisplayName(standard)),
                  selected: isSelected,
                  onSelected: (selected) {
                    if (selected) {
                      _setNoiseStandard(standard);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 8),
            Text(
              _getNoiseStandardDescription(_currentNoiseStandard),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('应用信息', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            _buildInfoItem('版本', '1.0.0'),
            _buildInfoItem('平台', 'iOS'),
            _buildInfoItem('符合标准', 'IEC 61672-1:2013, ISO 1996-1:2016'),
            _buildInfoItem('开发者', 'PPSoft'),
            const SizedBox(height: 16),
            Text(
              '分贝测量仪是一款专业的声级测量工具，符合国际标准，适用于职业健康监测和法规符合性评估。',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
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

  String _getFrequencyWeightingDisplayName(String weighting) {
    switch (weighting) {
      case 'A-weight':
        return 'A权重';
      case 'B-weight':
        return 'B权重';
      case 'C-weight':
        return 'C权重';
      case 'Z-weight':
        return 'Z权重';
      case 'ITU-R 468':
        return 'ITU-R 468';
      default:
        return weighting;
    }
  }

  String _getFrequencyWeightingDescription(String weighting) {
    switch (weighting) {
      case 'A-weight':
        return 'A权重：模拟人耳在40 phon等响度曲线下的响应，最常用';
      case 'B-weight':
        return 'B权重：模拟人耳在70 phon等响度曲线下的响应，已较少使用';
      case 'C-weight':
        return 'C权重：模拟人耳在100 phon等响度曲线下的响应，适用于高声级';
      case 'Z-weight':
        return 'Z权重：无频率修正，保持原始频率响应';
      case 'ITU-R 468':
        return 'ITU-R 468权重：专门用于广播音频设备的噪声测量';
      default:
        return '';
    }
  }

  String _getTimeWeightingDisplayName(String weighting) {
    switch (weighting) {
      case 'Fast':
        return '快响应 (F)';
      case 'Slow':
        return '慢响应 (S)';
      case 'Impulse':
        return '脉冲响应 (I)';
      default:
        return weighting;
    }
  }

  String _getTimeWeightingDescription(String weighting) {
    switch (weighting) {
      case 'Fast':
        return '快响应：时间常数125ms，适用于一般噪声测量';
      case 'Slow':
        return '慢响应：时间常数1000ms，适用于稳态噪声测量';
      case 'Impulse':
        return '脉冲响应：上升35ms/下降1500ms，适用于冲击噪声';
      default:
        return '';
    }
  }

  String _getNoiseStandardDisplayName(String standard) {
    switch (standard) {
      case 'osha':
        return 'OSHA';
      case 'niosh':
        return 'NIOSH';
      case 'gbz':
        return 'GBZ';
      case 'eu':
        return 'EU';
      default:
        return standard;
    }
  }

  String _getNoiseStandardDescription(String standard) {
    switch (standard) {
      case 'osha':
        return 'OSHA标准：TWA限值90 dB(A)，交换率5 dB';
      case 'niosh':
        return 'NIOSH标准：TWA限值85 dB(A)，交换率3 dB（更保守）';
      case 'gbz':
        return 'GBZ标准：TWA限值85 dB(A)，交换率3 dB';
      case 'eu':
        return 'EU标准：TWA限值87 dB(A)，交换率3 dB';
      default:
        return '';
    }
  }
}
