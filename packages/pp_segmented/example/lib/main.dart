import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:pp_segmented/pp_segmented.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // 数字模式示例1- 纯色
            numberModeSample1(),
            SizedBox(height: 15),
            // 数字模式示例2- 渐变
            numberModeSample2(),
            SizedBox(height: 15),
            // 数字模式示例3- 圆角
            numberModelSample3(),
            SizedBox(height: 15),
            // 文字模式
            textModeSample1(),
            SizedBox(height: 15),
            // 图标模式
            iconModeSample1(),
            SizedBox(height: 15),
            // 文字自适应
            textAutoSizeSample(),
            SizedBox(height: 15),
            // 图文组合
            iconTextSample(),
            SizedBox(height: 15),
            // 自定义复杂内容
            customMoreSample(),
            SizedBox(height: 15),
            // 滚动模式 - 自定义Item样式（背景、圆角、间距）
            scrollModeSample1(),
            SizedBox(height: 15),
            // 滚动模式 - 渐变背景
            scrollModeSample2(),
            SizedBox(height: 15),
            // 滚动模式 - 简单样式（透明背景）
            scrollModeSample3(),
          ],
        ),
      ),
    );
  }

  Widget scrollModeSample3() {
    return PPSegmentedControl<String>(
      items: [
        SegmentItem(value: 'all', child: Text('全部')),
        SegmentItem(value: 'tech', child: Text('科技')),
        SegmentItem(value: 'sports', child: Text('体育')),
        SegmentItem(value: 'entertainment', child: Text('娱乐')),
        SegmentItem(value: 'finance', child: Text('财经')),
        SegmentItem(value: 'health', child: Text('健康')),
        SegmentItem(value: 'education', child: Text('教育')),
      ],
      selectedValue: 'all',
      onChanged: (value) => print('选中: $value'),
      isScrollable: true,
      height: 36,
      minItemWidth: 60,
      itemPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      selectedItemBackgroundColor: Colors.orange,
      selectedItemBorderRadius: 18,
      unselectedItemBackgroundColor: Colors.transparent,
      unselectedItemBorderRadius: 18,
      selectedTextColor: Colors.white,
      unselectedTextColor: Colors.black54,
      autoScrollOnTap: true,
    );
  }

  Widget scrollModeSample2() {
    return PPSegmentedControl<String>(
      items: [
        SegmentItem(value: 'all', child: Text('全部')),
        SegmentItem(value: 'latest', child: Text('最新')),
        SegmentItem(value: 'popular', child: Text('热门')),
        SegmentItem(value: 'recommended', child: Text('推荐')),
        SegmentItem(value: 'trending', child: Text('趋势')),
        SegmentItem(value: 'following', child: Text('关注')),
        SegmentItem(value: 'favorites', child: Text('收藏')),
      ],
      selectedValue: 'all',
      onChanged: (value) => print('选中: $value'),
      isScrollable: true,
      height: 40,
      minItemWidth: 70,
      itemPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      selectedItemBackgroundGradient: LinearGradient(
        colors: [Color(0xFF667eea), Color(0xFF764ba2)],
      ),
      selectedItemBorderRadius: 20,
      unselectedItemBackgroundColor: Colors.grey[100],
      unselectedItemBorderRadius: 20,
      selectedTextColor: Colors.white,
      unselectedTextColor: Colors.black54,
      autoScrollOnTap: true,
    );
  }

  Widget scrollModeSample1() {
    return PPSegmentedControl<String>(
      items: [
        SegmentItem(value: 'all', child: Text('全部')),
        SegmentItem(value: 'tech', child: Text('科技')),
        SegmentItem(value: 'sports', child: Text('体育')),
        SegmentItem(value: 'entertainment', child: Text('娱乐')),
        SegmentItem(value: 'finance', child: Text('财经')),
        SegmentItem(value: 'health', child: Text('健康')),
        SegmentItem(value: 'education', child: Text('教育')),
        SegmentItem(value: 'travel', child: Text('旅游')),
        SegmentItem(value: 'food', child: Text('美食')),
        SegmentItem(value: 'fashion', child: Text('时尚')),
      ],
      selectedValue: 'all',
      onChanged: (value) => print('选中: $value'),
      isScrollable: true,
      height: 44,
      minItemWidth: 70,
      itemPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemSpacing: 8,
      selectedItemBackgroundColor: Colors.blue,
      selectedItemBorderRadius: 22,
      unselectedItemBackgroundColor: Colors.grey[200],
      unselectedItemBorderRadius: 22,
      selectedTextColor: Colors.white,
      unselectedTextColor: Colors.black87,
      autoScrollOnTap: true,
    );
  }

  Widget customMoreSample() {
    return PPSegmentedControl<String>(
      items: [
        SegmentItem(
          value: 'easy',
          child: Container(
            padding: EdgeInsets.only(bottom: 5),
            color: Colors.amber,
            child: Text('简单'),
          ),
        ),
        SegmentItem(
          value: 'medium',
          child: Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.star, size: 16),
                SizedBox(width: 4),
                Text('中等'),
              ],
            ),
          ),
        ),
        SegmentItem(
          value: 'hard',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.diamond, size: 16),
              Text('困难', style: TextStyle(fontSize: 12)),
            ],
          ),
        ),
      ],
      selectedValue: 'easy',
      onChanged: (value) => print('选中: $value'),
      selectedTextColor: Colors.white,
      unselectedTextColor: Colors.black54,
      backgroundColor: Colors.grey.withOpacity(0.1),
      indicatorColor: Colors.green,
      indicator: Container(
        decoration: BoxDecoration(
          color: Colors.green,
          borderRadius: BorderRadius.circular(5),
        ),
      ),
    );
  }

  Widget iconTextSample() {
    return PPSegmentedControl<String>(
      items: [
        SegmentItem(
          value: 'home',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.home, size: 16),
              SizedBox(width: 4),
              Text('首页'),
            ],
          ),
        ),
        SegmentItem(
          value: 'search',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.search, size: 16),
              SizedBox(width: 4),
              Text('搜索'),
            ],
          ),
        ),
      ],
      selectedValue: 'home',
      onChanged: (value) => print(value),
      height: 50,
      borderRadius: 20,
      backgroundGradient: LinearGradient(
        colors: [
          Colors.blue.withOpacity(0.1),
          Colors.purple.withOpacity(0.1),
        ],
      ),
      indicatorGradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
      indicatorBorderRadius: 20,
      selectedTextColor: Colors.white,
      unselectedTextColor: Colors.black,
    );
  }

  Widget textAutoSizeSample() {
    return PPSegmentedControl<int>(
      items: [
        SegmentItem(value: 1, child: Text('首页')),
        SegmentItem(
          value: 2,
          child: AutoSizeText(
            '发现发现发现发现发现发现',
            textAlign: TextAlign.center,
            minFontSize: 8,
          ),
        ),
        SegmentItem(
          value: 3,
          child: AutoSizeText(
            'Long length word Long length word',
            textAlign: TextAlign.center,
            minFontSize: 8,
            maxFontSize: 20,
            style: TextStyle(fontSize: 13),
          ),
        ),
        SegmentItem(value: 4, child: Text('我的')),
      ],
      selectedValue: 1,
      onChanged: (value) => print('选中: $value'),
      height: 60,
      borderRadius: 20,
      backgroundGradient: LinearGradient(
        colors: [
          Colors.blue.withOpacity(0.1),
          Colors.purple.withOpacity(0.1),
        ],
      ),
      indicatorGradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
      indicatorBorderRadius: 20,
      selectedTextColor: Colors.white,
      unselectedTextColor: Colors.black87,
    );
  }

  Widget iconModeSample1() {
    return PPSegmentedControl<int>(
      items: [
        SegmentItem(value: 1, child: Icon(Icons.home, size: 16)),
        SegmentItem(value: 2, child: Icon(Icons.search, size: 16)),
        SegmentItem(value: 3, child: Icon(Icons.message, size: 16)),
        SegmentItem(value: 4, child: Icon(Icons.person, size: 16)),
      ],
      selectedValue: 1,
      onChanged: (value) => print('选中: $value'),
      height: 45,
      borderRadius: 12,
      backgroundGradient: LinearGradient(
        colors: [
          Colors.blue.withOpacity(0.1),
          Colors.purple.withOpacity(0.1),
        ],
      ),
      indicatorGradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
      indicatorBorderRadius: 10,
      selectedTextColor: Colors.white,
      unselectedTextColor: Colors.black87,
    );
  }

  Widget textModeSample1() {
    return PPSegmentedControl<int>(
      items: [
        SegmentItem(value: 1, child: Text('首页')),
        SegmentItem(value: 2, child: Text('发现')),
        SegmentItem(value: 3, child: Text('消息')),
        SegmentItem(value: 4, child: Text('我的')),
      ],
      selectedValue: 1,
      onChanged: (value) => print('选中: $value'),
      height: 45,
      borderRadius: 12,
      backgroundGradient: LinearGradient(
        colors: [
          Colors.blue.withOpacity(0.1),
          Colors.purple.withOpacity(0.1),
        ],
      ),
      indicatorGradient: LinearGradient(colors: [Colors.blue, Colors.purple]),
      indicatorBorderRadius: 10,
      indicatorShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.5),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
      selectedTextColor: Colors.white,
      unselectedTextColor: Colors.black87,
    );
  }

  Widget numberModelSample3() {
    return PPSegmentedControl<int>(
      items: List.generate(
        9,
        (index) => SegmentItem(value: index + 1, child: Text('${index + 1}')),
      ),
      selectedValue: 1,
      onChanged: (count) {
        print('选中: $count');
      },
      width: double.infinity,
      height: 40,
      borderRadius: 20,
      backgroundColor: Color(0xFF807D78).withValues(alpha: 0.12),
      indicatorColor: Colors.green,
      indicatorGradient: LinearGradient(
        colors: [Colors.blue, Colors.purple],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      selectedTextColor: Colors.white,
      unselectedTextColor: Colors.black,
      indicatorBorderRadius: 20,
    );
  }

  Widget numberModeSample2() {
    return PPSegmentedControl<int>(
      items: List.generate(
        9,
        (index) => SegmentItem(value: index + 1, child: Text('${index + 1}')),
      ),
      selectedValue: 1,
      onChanged: (count) {
        print('选中: $count');
      },
      width: double.infinity,
      height: 35,
      borderRadius: 9,
      backgroundColor: Color(0xFF807D78).withOpacity(0.12),
      backgroundGradient: LinearGradient(
        colors: [Colors.blue, Colors.purple],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ),
      indicatorColor: Colors.green,
      indicatorGradient: LinearGradient(
        colors: [Colors.white, Colors.green],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ),
      selectedTextColor: Colors.white,
      unselectedTextColor: Colors.black,
      indicatorBorderRadius: 7,
    );
  }

  Widget numberModeSample1() {
    return PPSegmentedControl<int>(
      items: List.generate(
        9,
        (index) => SegmentItem(value: index + 1, child: Text('${index + 1}')),
      ),
      selectedValue: 1,
      onChanged: (count) {
        print('选中: $count');
      },
      width: double.infinity,
      height: 35,
      borderRadius: 9,
      backgroundColor: Color(0xFF807D78).withValues(alpha: 0.12),
      indicatorColor: Colors.green,
      selectedTextColor: Colors.white,
      unselectedTextColor: Colors.black,
      indicatorBorderRadius: 7,
      itemSpacing: 5,
    );
  }
}
