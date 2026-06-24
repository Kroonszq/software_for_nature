import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:software_for_nature/presentation/widgets/navigation/nav_button.dart';

void main()
{
  Widget buildSubject({required bool isActive}) {
    return MaterialApp(
      home: Scaffold(
        body: NavButton(
          label: 'Timeline',
          route: '/timeline',
          isActive: isActive,
        ),
      ),
    );
  }

  group('NavButton', () {

    testWidgets('renders its label', (tester) async {
      await tester.pumpWidget(buildSubject(isActive: false));

      expect(find.text('Timeline'), findsOneWidget);
    });

    testWidgets('uses the accent color when active', (tester) async {
      await tester.pumpWidget(buildSubject(isActive: true));

      final Text label = tester.widget(find.text('Timeline'));

      expect(label.style?.color, const Color(0xFFFF5900));
    });

  });
}
