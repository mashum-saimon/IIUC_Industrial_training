import 'package:flutter_test/flutter_test.dart';

import 'package:quizapp/main.dart';

void main() {
  testWidgets('Login screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const QuizApp());

    expect(find.text('Quiz App'), findsOneWidget);
    expect(find.text('Login to continue'), findsOneWidget);
    expect(find.text('Username'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
  });
}
