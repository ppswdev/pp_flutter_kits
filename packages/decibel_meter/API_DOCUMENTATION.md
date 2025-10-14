# DecibelMeter API 文档

## 概述

DecibelMeter 是一个专业的分贝测量 Flutter 插件，提供实时音频采集、分贝计算、权重应用和统计分析功能。符合国际标准 IEC 61672-1、ISO 1996-1。

## 快速开始

```dart
import 'package:decibel_meter/decibel_meter.dart';

final decibelMeter = DecibelMeter();

// 开始测量
await decibelMeter.startMeasurement();

// 获取当前分贝值
final decibel = await decibelMeter.getCurrentDecibel();
print('当前分贝: ${decibel.toStringAsFixed(1)} dB');

// 停止测量
await decibelMeter.stopMeasurement();
```

## API 方法分类

### 1. 核心测量方法 (2个)

#### `startMeasurement()`

开始测量，启动音频采集和分贝计算。

```dart
Future<bool> startMeasurement()
```

**返回**: `true` 表示成功启动

**示例**:

```dart
final started = await decibelMeter.startMeasurement();
if (started) {
  print('测量已开始');
}
```

#### `stopMeasurement()`

停止测量，计算最终统计信息。

```dart
Future<bool> stopMeasurement()
```

**返回**: `true` 表示成功停止

---

### 2. 状态和数据获取方法 (8个)

#### `getCurrentState()`

获取当前测量状态。

```dart
Future<String> getCurrentState()
```

**返回值**:

- `"idle"` - 停止状态
- `"measuring"` - 测量中
- `"error: xxx"` - 错误状态（包含错误信息）

#### `getCurrentDecibel()`

获取当前分贝值（已应用权重和校准）。

```dart
Future<double> getCurrentDecibel()
```

**返回**: 当前分贝值（dB）

#### `getCurrentMeasurement()`

获取当前测量数据（包含完整信息）。

```dart
Future<DecibelMeasurement?> getCurrentMeasurement()
```

**返回**: `DecibelMeasurement` 对象，包含：

- `timestamp` - 时间戳
- `rawDecibel` - 原始分贝值
- `aWeightedDecibel` - A权重分贝值
- `fastDecibel` - Fast时间权重值
- `slowDecibel` - Slow时间权重值
- `calibratedDecibel` - 校准后分贝值
- `frequencySpectrum` - 频谱数据
- `levelDescription` - 等级描述
- `levelColor` - 等级颜色

#### `getStatistics()`

获取基本统计信息。

```dart
Future<Map<String, double>> getStatistics()
```

**返回**: 包含以下键的 Map：

- `"current"` - 当前分贝值
- `"max"` - 最大分贝值
- `"min"` - 最小分贝值

#### `getMeasurementHistory()`

获取测量历史记录（最多1000条）。

```dart
Future<List<DecibelMeasurement>> getMeasurementHistory()
```

**返回**: `DecibelMeasurement` 数组

#### `getCurrentStatistics()`

获取完整统计信息。

```dart
Future<DecibelStatistics?> getCurrentStatistics()
```

**返回**: `DecibelStatistics` 对象，包含：

- `avgDecibel` - 平均值
- `minDecibel` - 最小值
- `maxDecibel` - 最大值
- `peakDecibel` - 峰值
- `leqDecibel` - 等效连续声级
- `l10Decibel` - L10值
- `l50Decibel` - L50值（中位数）
- `l90Decibel` - L90值
- `standardDeviation` - 标准偏差
- `sampleCount` - 样本数量
- `measurementDuration` - 测量时长

#### `getRealTimeLeq()`

获取实时LEQ值（等效连续声级）。

```dart
Future<double> getRealTimeLeq()
```

**返回**: LEQ值（dB）

#### `getCurrentPeak()`

获取当前峰值（不应用时间权重）。

```dart
Future<double> getCurrentPeak()
```

**返回**: 峰值（dB）

---

### 3. 校准方法 (2个)

#### `setCalibrationOffset(double offset)`

设置校准偏移值。

```dart
Future<bool> setCalibrationOffset(double offset)
```

**参数**:

- `offset` - 校准偏移值（dB），正值增加，负值减少

**示例**:

```dart
// 增加3dB
await decibelMeter.setCalibrationOffset(3.0);
```

#### `getCalibrationOffset()`

获取当前校准偏移值。

```dart
Future<double> getCalibrationOffset()
```

**返回**: 校准偏移值（dB）

---

### 4. 频率权重方法 (5个)

#### `getCurrentFrequencyWeighting()`

获取当前频率权重。

```dart
Future<String> getCurrentFrequencyWeighting()
```

**返回值**:

- `"dB-A"` - A权重（最常用）
- `"dB-B"` - B权重（已弃用）
- `"dB-C"` - C权重
- `"dB-Z"` - Z权重（无修正）
- `"ITU-R 468"` - ITU-R 468权重

#### `setFrequencyWeighting(String weighting)`

设置频率权重。

```dart
Future<bool> setFrequencyWeighting(String weighting)
```

**参数**:

- `weighting` - 频率权重类型（如 `"dB-A"`, `"dB-C"`）

#### `getAvailableFrequencyWeightings()`

获取所有可用的频率权重列表。

```dart
Future<List<String>> getAvailableFrequencyWeightings()
```

**返回**: 频率权重类型数组

#### `getFrequencyWeightingCurve(String weighting)`

获取频率权重曲线数据。

```dart
Future<List<double>> getFrequencyWeightingCurve(String weighting)
```

**参数**:

- `weighting` - 频率权重类型

**返回**: 频率响应曲线数据数组

#### `getFrequencyWeightingsList()`

获取频率权重列表（JSON格式）。

```dart
Future<String> getFrequencyWeightingsList()
```

**返回**: JSON字符串，包含所有频率权重选项的详细信息

---

### 5. 时间权重方法 (4个)

#### `getCurrentTimeWeighting()`

获取当前时间权重。

```dart
Future<String> getCurrentTimeWeighting()
```

**返回值**:

- `"Fast"` - 快响应（125ms）
- `"Slow"` - 慢响应（1000ms）
- `"Impulse"` - 脉冲响应（35ms↑/1500ms↓）

#### `setTimeWeighting(String weighting)`

设置时间权重。

```dart
Future<bool> setTimeWeighting(String weighting)
```

**参数**:

- `weighting` - 时间权重类型（如 `"Fast"`, `"Slow"`, `"Impulse"`）

#### `getAvailableTimeWeightings()`

获取所有可用的时间权重列表。

```dart
Future<List<String>> getAvailableTimeWeightings()
```

**返回**: 时间权重类型数组

#### `getTimeWeightingsList()`

获取时间权重列表（JSON格式）。

```dart
Future<String> getTimeWeightingsList()
```

**返回**: JSON字符串，包含所有时间权重选项的详细信息

---

### 6. 扩展的公共获取方法 (6个)

#### `getFormattedMeasurementDuration()`

获取格式化的测量时长。

```dart
Future<String> getFormattedMeasurementDuration()
```

**返回**: 格式如 `"00:05:23"` 的时长字符串

#### `getMeasurementDuration()`

获取测量时长（秒）。

```dart
Future<double> getMeasurementDuration()
```

**返回**: 测量时长（秒）

#### `getWeightingDisplayText()`

获取权重显示文本。

```dart
Future<String> getWeightingDisplayText()
```

**返回**: 格式如 `"dB(A)F"` 的权重显示文本

#### `getMinDecibel()`

获取最小分贝值（应用时间权重）。

```dart
Future<double> getMinDecibel()
```

**返回**: 最小分贝值（dB）

#### `getMaxDecibel()`

获取最大分贝值（应用时间权重）。

```dart
Future<double> getMaxDecibel()
```

**返回**: 最大分贝值（dB）

#### `getLeqDecibel()`

获取LEQ值（等效连续声级）。

```dart
Future<double> getLeqDecibel()
```

**返回**: LEQ值（dB）

---

### 7. 图表数据获取方法 (5个)

#### `getTimeHistoryChartData({double timeRange = 60.0})`

获取时间历程图数据（JSON格式）。

```dart
Future<String> getTimeHistoryChartData({double timeRange = 60.0})
```

**参数**:

- `timeRange` - 时间范围（秒），默认60秒

**返回**: JSON字符串，包含：

- `dataPoints` - 数据点数组
- `timeRange` - 时间范围
- `minDecibel` - 最小分贝值
- `maxDecibel` - 最大分贝值
- `title` - 图表标题

#### `getRealTimeIndicatorData()`

获取实时指示器数据（JSON格式）。

```dart
Future<String> getRealTimeIndicatorData()
```

**返回**: JSON字符串，包含：

- `currentDecibel` - 当前分贝值
- `leq` - LEQ值
- `min` - 最小值
- `max` - 最大值
- `peak` - 峰值
- `weightingDisplay` - 权重显示文本
- `timestamp` - 时间戳

#### `getSpectrumChartData({String bandType = '1/3'})`

获取频谱分析图数据（JSON格式）。

```dart
Future<String> getSpectrumChartData({String bandType = '1/3'})
```

**参数**:

- `bandType` - 倍频程类型
  - `"1/1"` - 1/1倍频程（10个频点）
  - `"1/3"` - 1/3倍频程（30个频点，默认）

**返回**: JSON字符串，包含各频率点的声压级数据

#### `getStatisticalDistributionChartData()`

获取统计分布图数据（JSON格式）。

```dart
Future<String> getStatisticalDistributionChartData()
```

**返回**: JSON字符串，包含：

- `l10` - L10值（噪声峰值特征）
- `l50` - L50值（中位数）
- `l90` - L90值（背景噪声水平）
- `dataPoints` - 数据点数组

#### `getLEQTrendChartData({double interval = 10.0})`

获取LEQ趋势图数据（JSON格式）。

```dart
Future<String> getLEQTrendChartData({double interval = 10.0})
```

**参数**:

- `interval` - 采样间隔（秒），默认10秒

**返回**: JSON字符串，包含：

- `currentLeq` - 当前LEQ值
- `timeRange` - 时间范围
- `dataPoints` - 数据点数组（包含时段LEQ和累积LEQ）

---

### 8. 设置方法 (2个)

#### `resetAllData()`

重置所有数据。

```dart
Future<bool> resetAllData()
```

**功能**:

- 停止测量
- 清除所有历史数据
- 重置统计值
- 重置校准偏移为0

**注意**: 此操作不可恢复

#### `clearHistory()`

清除历史记录。

```dart
Future<bool> clearHistory()
```

**功能**:

- 清除所有测量历史数据
- 保留当前测量状态和校准设置

---

## 数据模型

### DecibelMeasurement

单次分贝测量结果。

```dart
class DecibelMeasurement {
  final DateTime timestamp;
  final double rawDecibel;
  final double aWeightedDecibel;
  final double fastDecibel;
  final double slowDecibel;
  final double calibratedDecibel;
  final List<double> frequencySpectrum;
  final double displayDecibel;
  final String levelDescription;
  final String levelColor;
}
```

### DecibelStatistics

完整统计信息。

```dart
class DecibelStatistics {
  final DateTime timestamp;
  final double measurementDuration;
  final int sampleCount;
  final double avgDecibel;
  final double minDecibel;
  final double maxDecibel;
  final double peakDecibel;
  final double leqDecibel;
  final double l10Decibel;
  final double l50Decibel;
  final double l90Decibel;
  final double standardDeviation;
  final String summary;
  final String detailedSummary;
}
```

### MeasurementState

测量状态枚举。

```dart
enum MeasurementState {
  idle,      // 停止状态
  measuring, // 测量中
  error;     // 错误状态
}
```

---

## 完整使用示例

```dart
import 'package:decibel_meter/decibel_meter.dart';
import 'dart:convert';

void main() async {
  final decibelMeter = DecibelMeter();

  // 1. 开始测量
  await decibelMeter.startMeasurement();

  // 2. 设置权重
  await decibelMeter.setFrequencyWeighting('dB-A');
  await decibelMeter.setTimeWeighting('Fast');

  // 3. 等待测量
  await Future.delayed(Duration(seconds: 10));

  // 4. 获取实时数据
  final decibel = await decibelMeter.getCurrentDecibel();
  print('当前分贝: ${decibel.toStringAsFixed(1)} dB');

  // 5. 获取统计信息
  final statistics = await decibelMeter.getCurrentStatistics();
  if (statistics != null) {
    print('AVG: ${statistics.avgDecibel.toStringAsFixed(1)} dB');
    print('MAX: ${statistics.maxDecibel.toStringAsFixed(1)} dB');
    print('LEQ: ${statistics.leqDecibel.toStringAsFixed(1)} dB');
  }

  // 6. 获取图表数据
  final indicatorJson = await decibelMeter.getRealTimeIndicatorData();
  final indicator = jsonDecode(indicatorJson);
  print('实时指示器: $indicator');

  // 7. 停止测量
  await decibelMeter.stopMeasurement();
}
```

---

## 方法统计

| 类别 | 方法数量 |
|------|---------|
| 核心测量方法 | 2 |
| 状态和数据获取方法 | 8 |
| 校准方法 | 2 |
| 频率权重方法 | 5 |
| 时间权重方法 | 4 |
| 扩展的公共获取方法 | 6 |
| 图表数据获取方法 | 5 |
| 设置方法 | 2 |
| 噪音测量计功能 | 10 |
| **总计** | **44** |

---

## 9. 噪音测量计功能

### 9.1 获取噪声剂量数据

```dart
Future<Map<String, dynamic>> getNoiseDoseData({String? standard})
```

**功能**：获取完整的噪声剂量数据，包含剂量、TWA、预测时间等完整信息。

**参数**：

- `standard`：噪声限值标准（可选），如 'niosh', 'osha', 'gbz', 'eu'

**返回值**：

- `Map<String, dynamic>`：包含剂量百分比、剂量率、TWA值、暴露时长、是否超标、限值余量、风险等级等

**使用示例**：

```dart
final doseData = await decibelMeter.getNoiseDoseData(standard: 'niosh');
print('剂量: ${doseData["dosePercentage"]}%');
print('TWA: ${doseData["twa"]} dB(A)');
print('风险等级: ${doseData["riskLevel"]}');
```

### 9.2 检查是否超过限值

```dart
Future<bool> isExceedingLimit(String standard)
```

**功能**：检查当前TWA或剂量是否超过指定标准的限值。

**参数**：

- `standard`：噪声限值标准

**返回值**：

- `bool`：是否超过限值

**使用示例**：

```dart
final isExceeding = await decibelMeter.isExceedingLimit('niosh');
if (isExceeding) {
  print('警告：已超过NIOSH限值！');
}
```

### 9.3 获取限值比较结果

```dart
Future<Map<String, dynamic>> getLimitComparisonResult(String standard)
```

**功能**：返回与指定标准的详细比较结果，包括余量、风险等级、建议措施。

**参数**：

- `standard`：噪声限值标准

**返回值**：

- `Map<String, dynamic>`：包含当前TWA、TWA限值、当前剂量、是否超标、限值余量、建议措施等

**使用示例**：

```dart
final result = await decibelMeter.getLimitComparisonResult('niosh');
print('TWA: ${result["currentTWA"]} dB, 限值: ${result["twaLimit"]} dB');
print('余量: ${result["limitMargin"]} dB');
print('建议措施: ${result["recommendations"]}');
```

### 9.4 获取剂量累积图数据

```dart
Future<String> getDoseAccumulationChartData({
  double interval = 60.0,
  String? standard,
})
```

**功能**：返回剂量随时间累积的数据，用于绘制剂量累积图。

**参数**：

- `interval`：采样间隔（秒），默认60秒
- `standard`：噪声限值标准（可选）

**返回值**：

- `String`：JSON格式的图表数据

**使用示例**：

```dart
final chartJson = await decibelMeter.getDoseAccumulationChartData(
  interval: 60.0,
  standard: 'niosh',
);
final chart = jsonDecode(chartJson);
print('当前剂量: ${chart["currentDose"]}%');
```

### 9.5 获取TWA趋势图数据

```dart
Future<String> getTWATrendChartData({
  double interval = 60.0,
  String? standard,
})
```

**功能**：返回TWA随时间变化的数据，用于绘制TWA趋势图。

**参数**：

- `interval`：采样间隔（秒），默认60秒
- `standard`：噪声限值标准（可选）

**返回值**：

- `String`：JSON格式的图表数据

**使用示例**：

```dart
final chartJson = await decibelMeter.getTWATrendChartData(
  interval: 60.0,
  standard: 'niosh',
);
final chart = jsonDecode(chartJson);
print('当前TWA: ${chart["currentTWA"]} dB');
```

### 9.6 设置噪声限值标准

```dart
Future<bool> setNoiseStandard(String standard)
```

**功能**：切换使用的噪声限值标准（OSHA、NIOSH、GBZ、EU）。

**参数**：

- `standard`：要设置的标准

**返回值**：

- `bool`：操作是否成功

**使用示例**：

```dart
await decibelMeter.setNoiseStandard('niosh');
```

### 9.7 获取当前噪声限值标准

```dart
Future<String> getCurrentNoiseStandard()
```

**功能**：获取当前使用的噪声限值标准。

**返回值**：

- `String`：当前标准名称

**使用示例**：

```dart
final standard = await decibelMeter.getCurrentNoiseStandard();
print('当前标准: $standard');
```

### 9.8 获取所有可用的噪声限值标准

```dart
Future<List<String>> getAvailableNoiseStandards()
```

**功能**：获取所有可用的噪声限值标准列表。

**返回值**：

- `List<String>`：所有标准的数组

**使用示例**：

```dart
final standards = await decibelMeter.getAvailableNoiseStandards();
print('可用标准: $standards');
```

### 9.9 生成噪音测量计综合报告

```dart
Future<String?> generateNoiseDosimeterReport({String? standard})
```

**功能**：生成包含所有关键数据的完整报告，用于法规符合性评估。

**参数**：

- `standard`：噪声限值标准（可选）

**返回值**：

- `String?`：JSON格式的报告数据，如果未开始测量则返回null

**使用示例**：

```dart
final reportJson = await decibelMeter.generateNoiseDosimeterReport(standard: 'niosh');
if (reportJson != null) {
  final report = jsonDecode(reportJson);
  print('测量时长: ${report["measurementDuration"]} 小时');
  print('最终TWA: ${report["doseData"]["twa"]} dB(A)');
  print('合规性结论: ${report["complianceConclusion"]}');
}
```

### 9.10 获取允许暴露时长表

```dart
Future<String> getPermissibleExposureDurationTable({String? standard})
```

**功能**：根据当前测量数据生成允许暴露时长表，包含每个声级的累计暴露时间和剂量。

**参数**：

- `standard`：噪声限值标准（可选）

**返回值**：

- `String`：JSON格式的暴露时长表数据

**使用示例**：

```dart
final tableJson = await decibelMeter.getPermissibleExposureDurationTable(standard: 'niosh');
final table = jsonDecode(tableJson);
print('总剂量: ${table["totalDose"]}%');
print('超标声级数: ${table["exceedingLevelsCount"]}');
```

### 9.11 噪声限值标准说明

#### 9.11.1 OSHA标准

- **TWA限值**：90 dB(A)
- **行动值**：85 dB(A)
- **交换率**：5 dB
- **适用**：美国职业安全与健康管理局标准

#### 9.11.2 NIOSH标准

- **TWA限值**：85 dB(A)
- **行动值**：85 dB(A)
- **交换率**：3 dB（更保守）
- **适用**：美国国家职业安全与健康研究所标准

#### 9.11.3 GBZ标准

- **TWA限值**：85 dB(A)
- **行动值**：80 dB(A)
- **交换率**：3 dB
- **适用**：中国国家标准

#### 9.11.4 EU标准

- **TWA限值**：87 dB(A)
- **行动值**：80 dB(A)
- **交换率**：3 dB
- **适用**：欧盟标准

---

## 平台支持

- ✅ iOS
- ⏳ Android（待开发）
- ⏳ Web（待开发）

---

## 符合标准

- IEC 61672-1:2013 - 声级计标准
- ISO 1996-1:2016 - 环境噪声测量
- IEC 61260-1:2014 - 倍频程滤波器

---

## 许可证

请查看 LICENSE 文件了解详情。
