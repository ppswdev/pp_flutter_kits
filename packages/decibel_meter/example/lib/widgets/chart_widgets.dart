import 'package:flutter/material.dart';

/// 图表数据点
class ChartData {
  final String x;
  final double y;

  ChartData(this.x, this.y);
}

/// 实时分贝曲线图
class RealTimeChart extends StatelessWidget {
  final List<ChartData> data;

  const RealTimeChart({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            '实时分贝曲线',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: data.isEmpty
                ? const Center(child: Text('暂无数据'))
                : CustomPaint(
                    painter: LineChartPainter(data),
                    size: Size.infinite,
                  ),
          ),
        ],
      ),
    );
  }
}

/// 简单折线图绘制器
class LineChartPainter extends CustomPainter {
  final List<ChartData> data;

  LineChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final minY = 0.0;
    final maxY = 140.0;
    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y =
          size.height - ((data[i].y - minY) / (maxY - minY)) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 实时指示器
class RealTimeIndicator extends StatelessWidget {
  final Map<String, dynamic> data;

  const RealTimeIndicator({super.key, required this.data});

  /// 安全的数字转换方法，处理int和double类型
  double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final currentDecibel = _safeToDouble(data['currentDecibel']);
    final leq = _safeToDouble(data['leq']);
    final min = _safeToDouble(data['min']);
    final max = _safeToDouble(data['max']);
    final peak = _safeToDouble(data['peak']);
    final weightingDisplay = data['weightingDisplay'] as String? ?? 'dB(A)F';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '实时指示器',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                weightingDisplay,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildIndicatorItem('当前', currentDecibel, Colors.blue),
              _buildIndicatorItem('LEQ', leq, Colors.green),
              _buildIndicatorItem('MIN', min, Colors.orange),
              _buildIndicatorItem('MAX', max, Colors.red),
              _buildIndicatorItem('PEAK', peak, Colors.purple),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIndicatorItem(String label, double value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.3)),
          ),
          child: Text(
            value.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}

/// 频谱分析图
class SpectrumChart extends StatelessWidget {
  final Map<String, dynamic> data;

  const SpectrumChart({super.key, required this.data});

  /// 安全的数字转换方法，处理int和double类型
  double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final dataPoints = (data['dataPoints'] as List?) ?? [];
    final chartData = dataPoints.map((point) {
      final frequency = _safeToDouble(point['frequency']);
      final magnitude = _safeToDouble(point['magnitude']);
      return ChartData(frequency.toString(), magnitude);
    }).toList();

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            '频谱分析 - ${data['bandType'] ?? ''}',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: chartData.isEmpty
                ? const Center(child: Text('暂无数据'))
                : CustomPaint(
                    painter: BarChartPainter(chartData),
                    size: Size.infinite,
                  ),
          ),
        ],
      ),
    );
  }
}

/// 简单柱状图绘制器
class BarChartPainter extends CustomPainter {
  final List<ChartData> data;

  BarChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    final paint = Paint()
      ..color = Colors.green
      ..style = PaintingStyle.fill;

    final minY = 0.0;
    final maxY = 140.0;
    final barWidth = size.width / data.length;

    for (int i = 0; i < data.length; i++) {
      final x = i * barWidth;
      final barHeight = ((data[i].y - minY) / (maxY - minY)) * size.height;
      final rect = Rect.fromLTWH(
        x,
        size.height - barHeight,
        barWidth * 0.8,
        barHeight,
      );
      canvas.drawRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// 统计分布图
class StatisticalDistributionChart extends StatelessWidget {
  final Map<String, dynamic> data;

  const StatisticalDistributionChart({super.key, required this.data});

  /// 安全的数字转换方法，处理int和double类型
  double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final dataPoints = (data['dataPoints'] as List?) ?? [];
    final chartData = dataPoints.map((point) {
      final percentile = _safeToDouble(point['percentile']);
      final decibel = _safeToDouble(point['decibel']);
      return ChartData('${percentile.toInt()}%', decibel);
    }).toList();

    final l10 = _safeToDouble(data['l10']);
    final l50 = _safeToDouble(data['l50']);
    final l90 = _safeToDouble(data['l90']);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            '统计分布图 - L10: ${l10.toStringAsFixed(1)} dB, L50: ${l50.toStringAsFixed(1)} dB, L90: ${l90.toStringAsFixed(1)} dB',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: chartData.isEmpty
                ? const Center(child: Text('暂无数据'))
                : CustomPaint(
                    painter: BarChartPainter(chartData),
                    size: Size.infinite,
                  ),
          ),
        ],
      ),
    );
  }
}

/// LEQ趋势图
class LEQTrendChart extends StatelessWidget {
  final Map<String, dynamic> data;

  const LEQTrendChart({super.key, required this.data});

  /// 安全的数字转换方法，处理int和double类型
  double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final dataPoints = (data['dataPoints'] as List?) ?? [];
    final chartData = dataPoints.map((point) {
      final timestamp = point['timestamp'] as String? ?? '';
      final leq = _safeToDouble(point['leq']);
      return ChartData(timestamp, leq);
    }).toList();

    final currentLeq = _safeToDouble(data['currentLeq']);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'LEQ趋势图 - 当前LEQ: ${currentLeq.toStringAsFixed(1)} dB',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: chartData.isEmpty
                ? const Center(child: Text('暂无数据'))
                : CustomPaint(
                    painter: LineChartPainter(chartData),
                    size: Size.infinite,
                  ),
          ),
        ],
      ),
    );
  }
}

/// 剂量累积图
class DoseAccumulationChart extends StatelessWidget {
  final Map<String, dynamic> data;

  const DoseAccumulationChart({super.key, required this.data});

  /// 安全的数字转换方法，处理int和double类型
  double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final dataPoints = (data['dataPoints'] as List?) ?? [];
    final chartData = dataPoints.map((point) {
      final timestamp = point['timestamp'] as String? ?? '';
      final cumulativeDose = _safeToDouble(point['cumulativeDose']);
      return ChartData(timestamp, cumulativeDose);
    }).toList();

    final currentDose = _safeToDouble(data['currentDose']);
    final limitLine = _safeToDouble(data['limitLine']);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            '剂量累积图 - 当前剂量: ${currentDose.toStringAsFixed(1)}%',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: chartData.isEmpty
                ? const Center(child: Text('暂无数据'))
                : CustomPaint(
                    painter: DoseChartPainter(chartData, limitLine),
                    size: Size.infinite,
                  ),
          ),
        ],
      ),
    );
  }
}

/// 剂量图表绘制器
class DoseChartPainter extends CustomPainter {
  final List<ChartData> data;
  final double limitLine;

  DoseChartPainter(this.data, this.limitLine);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // 绘制限值线
    final limitPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final limitY =
        size.height - ((limitLine - 0.0) / (120.0 - 0.0)) * size.height;
    canvas.drawLine(Offset(0, limitY), Offset(size.width, limitY), limitPaint);

    // 绘制数据线
    final dataPaint = Paint()
      ..color = Colors.blue
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final minY = 0.0;
    final maxY = 120.0;
    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y =
          size.height - ((data[i].y - minY) / (maxY - minY)) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, dataPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

/// TWA趋势图
class TWATrendChart extends StatelessWidget {
  final Map<String, dynamic> data;

  const TWATrendChart({super.key, required this.data});

  /// 安全的数字转换方法，处理int和double类型
  double _safeToDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is num) return value.toDouble();
    return 0.0;
  }

  @override
  Widget build(BuildContext context) {
    final dataPoints = (data['dataPoints'] as List?) ?? [];
    final chartData = dataPoints.map((point) {
      final timestamp = point['timestamp'] as String? ?? '';
      final twa = _safeToDouble(point['twa']);
      return ChartData(timestamp, twa);
    }).toList();

    final currentTWA = _safeToDouble(data['currentTWA']);
    final limitLine = _safeToDouble(data['limitLine']);

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            'TWA趋势图 - 当前TWA: ${currentTWA.toStringAsFixed(1)} dB',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: chartData.isEmpty
                ? const Center(child: Text('暂无数据'))
                : CustomPaint(
                    painter: TWATrendPainter(chartData, limitLine),
                    size: Size.infinite,
                  ),
          ),
        ],
      ),
    );
  }
}

/// TWA趋势图绘制器
class TWATrendPainter extends CustomPainter {
  final List<ChartData> data;
  final double limitLine;

  TWATrendPainter(this.data, this.limitLine);

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // 绘制限值线
    final limitPaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final limitY =
        size.height - ((limitLine - 0.0) / (120.0 - 0.0)) * size.height;
    canvas.drawLine(Offset(0, limitY), Offset(size.width, limitY), limitPaint);

    // 绘制数据线
    final dataPaint = Paint()
      ..color = Colors.green
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final path = Path();
    final minY = 0.0;
    final maxY = 120.0;
    final stepX = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * stepX;
      final y =
          size.height - ((data[i].y - minY) / (maxY - minY)) * size.height;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    canvas.drawPath(path, dataPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
