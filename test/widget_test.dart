import 'package:flutter_test/flutter_test.dart';
import 'package:devicespecs/main.dart';

void main() {
  testWidgets('App démarre sans erreur', (WidgetTester tester) async {
    await tester.pumpWidget(const DeviceSpecsApp());
    expect(find.text('DeviceSpecs'), findsOneWidget);
  });
}
