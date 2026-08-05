import 'package:flutter_test/flutter_test.dart';

import 'package:inapp_purchase_example/main.dart';

void main() {
  testWidgets('shows the purchase example controls', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('In-App Purchase 示例'), findsOneWidget);
    expect(find.text('配置应用内购'), findsOneWidget);
    expect(find.text('恢复购买'), findsOneWidget);
    expect(find.text('刷新当前购买'), findsOneWidget);
  });
}
