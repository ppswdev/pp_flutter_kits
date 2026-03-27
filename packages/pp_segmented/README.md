A simple and easy-to-use, highly customizable Segmented Control component.

## Features

- Supports fixed width, rounded corners, shadows, content adaptive scaling, and image-text combination.
- Supports custom background color: solid color, gradient color.
- Supports custom indicator background: solid color, gradient color, image, etc. (custom widgets).
- Supports scrolling mode.
- Supports custom direction: horizontal, vertical (coming soon).

## Screenshots

![Sample1](screenshots/output.gif)

## Getting started

```yaml
dependencies:
  pp_segmented: ^1.0.3
```

## Usage

简单示例：

```dart
 // Text Mode
PPSegmentedControl<int>(
    items: [
        SegmentItem(value: 1, child: Text('Home')),
        SegmentItem(value: 2, child: Text('Find')),
        SegmentItem(value: 3, child: Text('Message')),
        SegmentItem(value: 4, child: Text('Me')),
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
// Icon Mode
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

View more examples of code and `example`

```dart
Column(
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
)
```
