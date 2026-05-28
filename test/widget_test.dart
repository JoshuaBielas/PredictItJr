import 'package:flutter_test/flutter_test.dart';
import 'package:predictit_jr/main.dart';
import 'package:predictit_jr/providers/portfolio_model.dart';

// I got help from AI on this file

void main() {
  testWidgets('app boots and shows the Markets title', (WidgetTester tester) async {
    await tester.pumpWidget(PredictItApp(portfolio: PortfolioModel()));

    expect(find.text('Markets'), findsOneWidget);
  });
}