import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:election/main.dart';

void main() {
  testWidgets('App builds without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => ThemeProvider()),
          ChangeNotifierProvider(create: (_) => YearProvider()),
        ],
        child: const OneVoteApp(),
      ),
    );
    await tester.pump();
  });
}