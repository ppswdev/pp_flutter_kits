import 'package:flutter/material.dart';
import 'package:decibel_meter/decibel_meter.dart';

class CalibrationPage extends StatefulWidget {
  const CalibrationPage({super.key});

  @override
  State<CalibrationPage> createState() => _CalibrationPageState();
}

class _CalibrationPageState extends State<CalibrationPage> {
  final DecibelMeter _decibelMeter = DecibelMeter();
  final TextEditingController _offsetController = TextEditingController();

  double _currentOffset = 0.0;
  double _newOffset = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCurrentOffset();
  }

  @override
  void dispose() {
    _offsetController.dispose();
    super.dispose();
  }

  Future<void> _loadCurrentOffset() async {
    try {
      final offset = await _decibelMeter.getCalibrationOffset();
      setState(() {
        _currentOffset = offset;
        _newOffset = offset;
        _offsetController.text = offset.toStringAsFixed(1);
      });
    } catch (e) {
      _showError('加载当前校准偏移失败: $e');
    }
  }

  Future<void> _setCalibrationOffset() async {
    try {
      await _decibelMeter.setCalibrationOffset(_newOffset);
      setState(() {
        _currentOffset = _newOffset;
      });
      _showSuccess('校准偏移已设置');
    } catch (e) {
      _showError('设置校准偏移失败: $e');
    }
  }

  void _onOffsetChanged(String value) {
    final offset = double.tryParse(value);
    if (offset != null) {
      setState(() {
        _newOffset = offset.clamp(-10.0, 10.0);
      });
    }
  }

  void _resetOffset() {
    setState(() {
      _newOffset = 0.0;
      _offsetController.text = '0.0';
    });
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
      appBar: AppBar(title: const Text('校准设置')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 当前校准信息
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '当前校准信息',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('当前校准偏移:'),
                        Text(
                          '${_currentOffset.toStringAsFixed(1)} dB',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: _currentOffset == 0
                                    ? Colors.green
                                    : Colors.blue,
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 校准说明
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '校准说明',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      '校准偏移用于补偿设备差异，确保测量结果的准确性：',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    const Text('• 正值：增加分贝值，适用于测量结果偏低的设备'),
                    const Text('• 负值：减少分贝值，适用于测量结果偏高的设备'),
                    const Text('• 零值：不进行校准偏移'),
                    const SizedBox(height: 8),
                    const Text(
                      '建议在标准声源下进行校准，或使用专业校准设备。',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 校准设置
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '校准设置',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 16),

                    // 滑动条设置
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('校准偏移 (dB)'),
                            Text(
                              '${_newOffset.toStringAsFixed(1)} dB',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: _newOffset == 0
                                        ? Colors.green
                                        : Colors.blue,
                                  ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Slider(
                          value: _newOffset,
                          min: -10.0,
                          max: 10.0,
                          divisions: 200,
                          label: _newOffset.toStringAsFixed(1),
                          onChanged: (value) {
                            setState(() {
                              _newOffset = value;
                              _offsetController.text = value.toStringAsFixed(1);
                            });
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 手动输入
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _offsetController,
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            decoration: const InputDecoration(
                              labelText: '手动输入校准偏移 (dB)',
                              border: OutlineInputBorder(),
                              suffixText: 'dB',
                            ),
                            onChanged: _onOffsetChanged,
                          ),
                        ),
                        const SizedBox(width: 16),
                        OutlinedButton(
                          onPressed: _resetOffset,
                          child: const Text('重置'),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // 操作按钮
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _setCalibrationOffset,
                            icon: const Icon(Icons.save),
                            label: const Text('保存校准偏移'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 校准提示
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          '校准提示',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '1. 在校准前，请确保设备处于稳定的环境中',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                    Text(
                      '2. 建议使用已知声压级的标准声源进行校准',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                    Text(
                      '3. 校准偏移范围：-10.0 dB 到 +10.0 dB',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                    Text(
                      '4. 校准设置将影响所有后续测量结果',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
