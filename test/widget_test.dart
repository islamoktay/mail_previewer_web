import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mail_previewer_web/app/app.dart';

void main() {
  testWidgets('archive shell renders key sections',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('MSG Archive'), findsOneWidget);
    expect(find.text('Search archive...'), findsOneWidget);
    expect(find.text('Drag and drop .msg files'), findsOneWidget);
    expect(find.text('RECENT ARCHIVES'), findsOneWidget);
    expect(find.text('No archived messages yet'), findsOneWidget);
  });

  testWidgets('search updates the archive shell query',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'project');
    await tester.pump();

    expect(find.text('project'), findsOneWidget);
  });
}
