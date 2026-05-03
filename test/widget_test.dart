import 'package:flutter_test/flutter_test.dart';
import 'package:svoc_puzzle/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const SVOCPuzzleApp());
    expect(find.text('SVOC パズル'), findsWidgets);
  });
}
