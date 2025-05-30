import 'package:flutter/material.dart';

/// A widget that provides a responsive layout based on the screen size.
/// It displays different widgets for mobile, tablet, and desktop sizes.
/// The mobile layout is used for screens smaller than 650 pixels,
/// the tablet layout is used for screens between 650 and 1100 pixels,
/// and the desktop layout is used for screens larger than 1100 pixels.
/// The tablet layout is optional and defaults to the desktop layout if not provided.
/// The `ResponsiveLayout` widget is useful for creating applications
/// that need to adapt to different screen sizes and orientations.
/// It uses the `MediaQuery` class to determine the screen size and
/// display the appropriate layout.
/// The `ResponsiveLayout` widget takes three required parameters:
/// - `mobile`: The widget to display for mobile screens.
/// - `tablet`: The widget to display for tablet screens (optional).
/// - `desktop`: The widget to display for desktop screens.
/// The `ResponsiveLayout` widget also provides three static methods
/// to check the current screen size:
/// - `isMobile`: Returns true if the screen size is less than 650 pixels.
/// - `isTablet`: Returns true if the screen size is between 650 and 1100 pixels.
/// - `isDesktop`: Returns true if the screen size is greater than 1100 pixels.
/// These methods can be used to conditionally render widgets based on the screen size.
///
/// Example usage:
/// ```dart
/// ResponsiveLayout(
///  mobile: mobileWidget(),
///  tablet: tabletWidget(),
///  desktop: desktopWidget(),
///  );
/// ```
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  static bool isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 650;

  static bool isTablet(BuildContext context) =>
      MediaQuery.of(context).size.width < 1100 &&
      MediaQuery.of(context).size.width >= 650;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1100;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    if (size.width >= 1100 && desktop != null) {
      return desktop!;
    }

    if (size.width >= 650 && tablet != null) {
      return tablet!;
    }

    return mobile;
  }
}
