容易且高度自定义样式的进度条

## 功能特性

- 自定义高度、进度值、圆角
- 自定义显示百分比值，文本样式
- 默认轨道颜色、高亮轨道颜色、高亮轨道圆角
- 可添加透明覆盖层，增强显示效果
- 支持渐变色

## 示例效果

![Sample1](screenshots/sample1.png)

## 使用指南

```dart
Padding(
    padding: EdgeInsets.symmetric(horizontal: 20.px),
    child: PPProgressBar(
        value: progress.toDouble() / 100.0,
        height: 60.px,
        borderRadius: 24.px,
        trackColor: HexColor('#4A148C'),
        progressColor: HexColor('#AC50F9'),
        progressRadius: 1.0,
        percentageStyle: TextStyle(
            color: Colors.white,
            fontSize: 24.px,
            fontWeight: FontWeight.bold,
        ),
        overlay: Image.asset(
            A.imageButtonHighlight,
            fit: BoxFit.fill,
        ),
    ),
)
```
