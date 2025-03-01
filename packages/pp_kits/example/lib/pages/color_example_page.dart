import 'package:flutter/material.dart';
import 'package:pp_kits/extensions/extension_on_color.dart';

/// 颜色创建示例页面
class ColorExamplePage extends StatelessWidget {
  const ColorExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('颜色工具使用示例'),
        backgroundColor: '#6200EE'.toColor(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 使用Color构造函数
            _buildSection(
              '使用Color构造函数',
              [
                _buildColorSample(
                  '不透明橙色',
                  const Color(0xFFFF5722),
                  'Color(0xFFFF5722)',
                ),
                _buildColorSample(
                  '半透明橙色',
                  const Color(0x80FF5722),
                  'Color(0x80FF5722)',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 2. 使用Color.fromARGB
            _buildSection(
              '使用Color.fromARGB',
              [
                _buildColorSample(
                  '不透明橙色',
                  const Color.fromARGB(255, 255, 87, 34),
                  'Color.fromARGB(255, 255, 87, 34)',
                ),
                _buildColorSample(
                  '半透明橙色',
                  const Color.fromARGB(128, 255, 87, 34),
                  'Color.fromARGB(128, 255, 87, 34)',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 3. 使用Color.fromRGBO
            _buildSection(
              '使用Color.fromRGBO',
              [
                _buildColorSample(
                  '不透明橙色',
                  const Color.fromRGBO(255, 87, 34, 1.0),
                  'Color.fromRGBO(255, 87, 34, 1.0)',
                ),
                _buildColorSample(
                  '半透明橙色',
                  const Color.fromRGBO(255, 87, 34, 0.5),
                  'Color.fromRGBO(255, 87, 34, 0.5)',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 4. 使用String扩展方法
            _buildSection(
              '使用String扩展方法',
              [
                _buildColorSample(
                  '不透明橙色',
                  '#FF5722'.toColor(),
                  "'#FF5722'.toColor()",
                ),
                _buildColorSample(
                  '半透明橙色',
                  '#FF5722'.toColor(alpha: 0.5),
                  "'#FF5722'.toColor(alpha: 0.5)",
                ),
              ],
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }

  Widget _buildColorSample(String label, Color color, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey.shade300),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label),
                Text(
                  text,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
