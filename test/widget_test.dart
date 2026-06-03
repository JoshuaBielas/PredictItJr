import 'package:flutter_test/flutter_test.dart';
import 'package:predictit_jr/main.dart';
import 'package:predictit_jr/providers/auth_model.dart';
import 'package:predictit_jr/providers/portfolio_model.dart';

// I got help from AI on this file

void main() {
  testWidgets('app boots to sign in when signed out', (WidgetTester tester) async {
    await tester.pumpWidget(
      PredictItApp(
        portfolio: PortfolioModel(),
        auth: AuthModel(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Sign in'), findsWidgets);
    expect(find.text('Markets'), findsNothing);
  });
}
