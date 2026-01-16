import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tj_cronometro/main.dart';
import 'package:tj_cronometro/screens/timer_screen.dart';

void main() {
  group('TjCronometroApp', () {
    testWidgets('app loads correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const TjCronometroApp());
      expect(find.text('00:00'), findsOneWidget);
    });
  });

  group('TimerScreen', () {
    testWidgets('displays timer starting at 00:00', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TimerScreen()));
      expect(find.text('00:00'), findsOneWidget);
    });

    testWidgets('has Iniciar, Parar, and Reiniciar buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

      expect(find.text('Iniciar'), findsOneWidget);
      expect(find.text('Parar'), findsOneWidget);
      expect(find.text('Reiniciar'), findsOneWidget);
    });

    testWidgets('has play, stop, and refresh icons',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

      expect(find.byIcon(Icons.play_arrow), findsOneWidget);
      expect(find.byIcon(Icons.stop), findsOneWidget);
      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });
  });
}
