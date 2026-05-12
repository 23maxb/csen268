import 'package:flutter_test/flutter_test.dart';

import 'package:csen268/main.dart';

void main() {
  testWidgets('App boots', (WidgetTester tester) async {
    await tester.pumpWidget(const MealPlannerApp());
    await tester.pump();
  });
}
