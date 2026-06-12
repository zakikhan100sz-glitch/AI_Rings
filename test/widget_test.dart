import 'package:airings_mobile/app/app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('AIRings login screen renders', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: AiringsApp()),
    );
    await tester.pumpAndSettle();

    expect(find.text('Sign In'), findsOneWidget);
    expect(find.text('Demo Access'), findsOneWidget);
  });
}
