import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gemma_chat/app.dart';

void main() {
  testWidgets('App should render', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: GemmaChatApp()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Gemma Chat'), findsOneWidget);
  });
}
