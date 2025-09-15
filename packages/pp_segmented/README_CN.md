
一个简单易用，高度自定义的Segmented Control组件

## Features

- 支持固定宽度，圆角，阴影，内容自适应缩放，图文组合
- 支持自定义背景色：纯色、渐变色
- 支持自定义指示器背景：纯色、渐变色、图片、等自定义widget
- 支持滚动模式：（开发中）

## Screenshots

<video autoplay muted loop playsinline width="640">
  <source src="screenshots/video.mp4" type="video/mp4">
  <a href="screenshots/video.mp4">播放视频</a>
</video>

## Getting started

```yaml
dependencies:
  pp_segmented: ^1.0.0
```

## Usage

简单示例：

```dart
 // 文字模式
PPSegmentedControl<int>(
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
    indicatorGradient:
        LinearGradient(colors: [Colors.blue, Colors.purple]),
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
),
SizedBox(height: 15),
// 图标模式
PPSegmentedControl<int>(
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
    indicatorGradient:
        LinearGradient(colors: [Colors.blue, Colors.purple]),
    indicatorBorderRadius: 10,
    selectedTextColor: Colors.white,
    unselectedTextColor: Colors.black87,
),
SizedBox(height: 15),
```

## Additional information

更多示例查看代码和 `example`
