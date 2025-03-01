import 'package:flutter/material.dart';
import 'package:pp_kits/extensions/extension_on_color.dart';

class ColorExamplePage extends StatelessWidget {
  const ColorExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('颜色工具使用示例'),
        backgroundColor: HexColor('#6200EE'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. 创建十六进制颜色
            _buildSection(
              '创建十六进制颜色',
              [
                _buildColorSample('标准格式 (#RRGGBB)', HexColor('#FF5722')),
                _buildColorSample('简写格式 (#RGB)', HexColor('#F52')),
                _buildColorSample('带透明度 (#RRGGBBAA)', HexColor('#FF5722AA')),
                _buildColorSample('自定义透明度', HexColor('#FF5722', alpha: 0.5)),
                _buildColorSample(
                    '不带#前缀', HexColor.fromStringWithoutHash('FF5722')),
                _buildColorSample(
                    '从RGB值创建', HexColor.fromRGBO(255, 87, 34, 255)),
              ],
            ),

            const SizedBox(height: 24),

            // 2. 颜色转换
            _buildSection(
              '颜色转换',
              [
                _buildColorConversion(
                  '转为十六进制',
                  Colors.teal,
                  '${Colors.teal.toHex()} (默认)',
                ),
                _buildColorConversion(
                  '转为十六进制(无#前缀)',
                  Colors.teal,
                  Colors.teal.toHex(leadingHashSign: false),
                ),
                _buildColorConversion(
                  '转为十六进制(带透明度)',
                  Colors.teal.withOpacity(0.5),
                  Colors.teal.withOpacity(0.5).toHex(includeAlpha: true),
                ),
                _buildColorConversion(
                  '转为十六进制(大写)',
                  Colors.teal,
                  Colors.teal.toHex(uppercase: true),
                ),
                _buildColorConversion(
                  '转为Material色板',
                  HexColor('#FF5722'),
                  '生成包含不同明暗度的MaterialColor',
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 3. 颜色调整
            _buildSection(
              '颜色调整',
              [
                _buildColorAdjustment(
                  '原始颜色',
                  HexColor('#3F51B5'),
                ),
                _buildColorAdjustment(
                  '调亮 (+0.2)',
                  HexColor('#3F51B5').adjustBrightness(0.2),
                ),
                _buildColorAdjustment(
                  '调暗 (-0.2)',
                  HexColor('#3F51B5').adjustBrightness(-0.2),
                ),
                _buildColorAdjustment(
                  '增加饱和度 (+0.3)',
                  HexColor('#3F51B5').adjustSaturation(0.3),
                ),
                _buildColorAdjustment(
                  '减少饱和度 (-0.3)',
                  HexColor('#3F51B5').adjustSaturation(-0.3),
                ),
                _buildColorAdjustment(
                  '调整色相 (+60)',
                  HexColor('#3F51B5').adjustHue(60),
                ),
                _buildColorAdjustment(
                  '调整透明度 (0.5)',
                  HexColor('#3F51B5').withOpacity(0.5),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 4. 颜色混合
            _buildSection(
              '颜色混合',
              [
                _buildColorMixing(
                  HexColor('#E91E63'),
                  HexColor('#2196F3'),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // 5. 颜色属性
            _buildSection(
              '颜色属性',
              [
                _buildColorProperty(
                  '深色判断',
                  HexColor('#212121'),
                  '是深色: ${HexColor('#212121').isDark}',
                ),
                _buildColorProperty(
                  '浅色判断',
                  HexColor('#F5F5F5'),
                  '是浅色: ${HexColor('#F5F5F5').isLight}',
                ),
                _buildColorProperty(
                  '对比色(深色背景)',
                  HexColor('#212121'),
                  '对比色: ${HexColor('#212121').contrastColor.toHex()}',
                ),
                _buildColorProperty(
                  '对比色(浅色背景)',
                  HexColor('#F5F5F5'),
                  '对比色: ${HexColor('#F5F5F5').contrastColor.toHex()}',
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

  Widget _buildColorSample(String label, Color color) {
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
                  color.toHex(includeAlpha: true),
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

  Widget _buildColorConversion(String label, Color color, String result) {
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
                  result,
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

  Widget _buildColorAdjustment(String label, Color color) {
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
                  color.toHex(),
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

  Widget _buildColorMixing(Color color1, Color color2) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: color1,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    bottomLeft: Radius.circular(8),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  color1.toHex(),
                  style: TextStyle(
                    color: color1.contrastColor,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                height: 40,
                decoration: BoxDecoration(
                  color: color2,
                  borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  color2.toHex(),
                  style: TextStyle(
                    color: color2.contrastColor,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: List.generate(
            5,
            (index) {
              final ratio = index / 4;
              final mixedColor = color1.mix(color2, ratio);
              return Expanded(
                child: Container(
                  height: 40,
                  decoration: BoxDecoration(
                    color: mixedColor,
                    borderRadius: BorderRadius.horizontal(
                      left: index == 0 ? const Radius.circular(8) : Radius.zero,
                      right:
                          index == 4 ? const Radius.circular(8) : Radius.zero,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '${(ratio * 100).toInt()}%',
                    style: TextStyle(
                      color: mixedColor.contrastColor,
                      fontSize: 10,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildColorProperty(String label, Color color, String property) {
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
            child: Center(
              child: Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: color.contrastColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label),
                Text(
                  property,
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
