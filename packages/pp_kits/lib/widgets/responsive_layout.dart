import 'package:flutter/material.dart';

/// [ResponsiveLayout]
///
/// 一个根据屏幕尺寸自适应展示不同布局的响应式组件，适用于同时支持移动端、平板和桌面端界面的场景。
///
/// - 当屏幕宽度小于650像素时，显示 [mobile] 组件；
/// - 当屏幕宽度介于650到1100像素（含）之间时，显示 [tablet] 组件（若未提供则显示 [desktop]）；
/// - 当屏幕宽度大于等于1100像素时，显示 [desktop] 组件（若未提供则优先显示 [tablet]，再回退至 [mobile]）；
///
/// 常用于根据屏幕大小调整布局，提升多终端适配体验。
///
/// ## 参数说明
/// - [mobile] 必填，移动端显示的组件。
/// - [tablet] 选填，平板端显示的组件，如未设置则回退为 [desktop]。
/// - [desktop] 选填，桌面端显示的组件。
///
/// ## 静态方法
/// - [isMobile]: 判断当前屏幕是否为移动端（宽度小于650）。
/// - [isTablet]: 判断当前屏幕是否为平板（宽度650~1099）。
/// - [isDesktop]: 判断当前屏幕是否为桌面（宽度大于等于1100）。
///
/// ## 代码示例
/// ```dart
/// ResponsiveLayout(
///   mobile: MobileWidget(),
///   tablet: TabletWidget(),
///   desktop: DesktopWidget(),
/// )
/// ```
///
/// ## 返回结果
/// 返回当前屏幕尺寸下对应的 [Widget]，以适配不同终端。
class ResponsiveLayout extends StatelessWidget {
  /// 移动端显示的组件
  final Widget mobile;

  /// 平板端显示的组件（可选，未设置时回退为desktop或mobile）
  final Widget? tablet;

  /// 桌面端显示的组件（可选）
  final Widget? desktop;

  /// 构造函数
  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  /// 判断是否为移动端（宽度小于650像素）
  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  /// 判断是否为平板（宽度大于等于650且小于1100像素）
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 650 && width < 1100;
  }

  /// 判断是否为桌面端（宽度大于等于1100像素）
  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  /// 根据屏幕尺寸返回对应的Widget
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final double width = size.width;

    if (width >= 1100) {
      // 桌面端优先显示
      if (desktop != null) return desktop!;
      if (tablet != null) return tablet!;
      return mobile;
    }
    if (width >= 650) {
      // 平板端
      if (tablet != null) return tablet!;
      if (desktop != null) return desktop!;
      return mobile;
    }
    // 移动端
    return mobile;
  }
}
