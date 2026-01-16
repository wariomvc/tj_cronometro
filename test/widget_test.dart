import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:tj_cronometro/main.dart';
import 'package:tj_cronometro/screens/configuration_screen.dart';
import 'package:tj_cronometro/screens/countdown_screen.dart';

void main() {
  group('TjCronometroApp', () {
    testWidgets('app loads correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const TjCronometroApp());
      expect(find.text('Configurar Timer'), findsOneWidget);
    });
  });

  group('ConfigurationScreen', () {
    testWidgets('displays timer configuration UI', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ConfigurationScreen()));

      expect(find.text('Duración del Cronómetro'), findsOneWidget);
      expect(find.text('minutos'), findsOneWidget);
      expect(find.text('Iniciar Timer'), findsOneWidget);
    });

    testWidgets('has default value of 5 minutes', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ConfigurationScreen()));

      final textField = find.byType(TextField);
      expect(textField, findsOneWidget);

      final TextField textFieldWidget = tester.widget(textField);
      expect(textFieldWidget.controller?.text, '5');
    });

    testWidgets('navigates to countdown screen', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: ConfigurationScreen()));

      await tester.tap(find.text('Iniciar Timer'));
      await tester.pumpAndSettle();

      expect(find.text('05:00'), findsOneWidget);
    });
  });

  group('CountdownScreen', () {
    testWidgets('displays countdown with correct initial time',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CountdownScreen(durationMinutes: 5)),
      );

      expect(find.text('05:00'), findsOneWidget);
    });

    testWidgets('displays 1 minute correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CountdownScreen(durationMinutes: 1)),
      );

      expect(find.text('01:00'), findsOneWidget);
    });

    testWidgets('has Iniciar, Parar, and Reiniciar buttons',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CountdownScreen(durationMinutes: 1)),
      );

      expect(find.text('Iniciar'), findsOneWidget);
      expect(find.text('Parar'), findsOneWidget);
      expect(find.text('Reiniciar'), findsOneWidget);
    });

    testWidgets('has back button', (WidgetTester tester) async {
      await tester.pumpWidget(
        const MaterialApp(home: CountdownScreen(durationMinutes: 1)),
      );

      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
    });
  });
}
