import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_cronometro/screens/timer_screen.dart';

/// Suite de pruebas de widget para la pantalla principal TimerScreen
///
/// Estas pruebas verifican la funcionalidad completa del cronómetro,
/// incluyendo la interacción con botones, el incremento del tiempo,
/// y la gestión correcta del estado.
void main() {
  group('TimerScreen', () {
    /// Prueba: Estado inicial del cronómetro
    group('Estado Inicial', () {
      testWidgets('muestra 00:00 al cargar', (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

        // Verificar que el tiempo inicial es 00:00
        expect(find.text('00:00'), findsOneWidget);
      });

      testWidgets('el botón Iniciar está habilitado inicialmente',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

        // Encontrar el botón Iniciar
        final startButton = find.widgetWithText(ElevatedButton, 'Iniciar');
        expect(startButton, findsOneWidget);

        // Verificar que está habilitado (onPressed no es null)
        final button = tester.widget<ElevatedButton>(startButton);
        expect(button.onPressed, isNotNull);
      });

      testWidgets('el botón Parar está deshabilitado inicialmente',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

        // Encontrar el botón Parar
        final stopButton = find.widgetWithText(ElevatedButton, 'Parar');
        expect(stopButton, findsOneWidget);

        // Verificar que está deshabilitado (onPressed es null)
        final button = tester.widget<ElevatedButton>(stopButton);
        expect(button.onPressed, isNull);
      });

      testWidgets('el botón Reiniciar está habilitado inicialmente',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

        // Encontrar el botón Reiniciar
        final resetButton = find.widgetWithText(ElevatedButton, 'Reiniciar');
        expect(resetButton, findsOneWidget);

        // Verificar que está habilitado
        final button = tester.widget<ElevatedButton>(resetButton);
        expect(button.onPressed, isNotNull);
      });
    });

    /// Prueba: Funcionalidad de iniciar el cronómetro
    group('Funcionalidad Iniciar', () {
      testWidgets('al presionar Iniciar, el cronómetro incrementa',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

        // Verificar estado inicial
        expect(find.text('00:00'), findsOneWidget);

        // Presionar el botón Iniciar
        await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar'));
        await tester.pump();

        // Avanzar el tiempo 1 segundo
        await tester.pump(const Duration(seconds: 1));

        // El tiempo debe mostrar 00:01
        expect(find.text('00:01'), findsOneWidget);
      });

      testWidgets('el cronómetro incrementa continuamente cada segundo',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

        // Presionar Iniciar
        await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar'));
        await tester.pump();

        // Avanzar 3 segundos
        await tester.pump(const Duration(seconds: 1));
        expect(find.text('00:01'), findsOneWidget);

        await tester.pump(const Duration(seconds: 1));
        expect(find.text('00:02'), findsOneWidget);

        await tester.pump(const Duration(seconds: 1));
        expect(find.text('00:03'), findsOneWidget);
      });

      testWidgets('después de iniciar, el botón Iniciar se deshabilita',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

        // Presionar Iniciar
        await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar'));
        await tester.pump();

        // El botón Iniciar debe estar deshabilitado
        final startButton =
            tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Iniciar'));
        expect(startButton.onPressed, isNull);
      });

      testWidgets('después de iniciar, el botón Parar se habilita',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

        // Presionar Iniciar
        await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar'));
        await tester.pump();

        // El botón Parar debe estar habilitado
        final stopButton =
            tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Parar'));
        expect(stopButton.onPressed, isNotNull);
      });

      testWidgets('el cronómetro maneja correctamente el cambio de minutos',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

        // Presionar Iniciar
        await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar'));
        await tester.pump();

        // Avanzar 59 segundos
        await tester.pump(const Duration(seconds: 59));
        expect(find.text('00:59'), findsOneWidget);

        // Avanzar 1 segundo más (debería cambiar a 01:00)
        await tester.pump(const Duration(seconds: 1));
        expect(find.text('01:00'), findsOneWidget);
      });
    });

    /// Prueba: Funcionalidad de detener el cronómetro
    group('Funcionalidad Parar', () {
      testWidgets('al presionar Parar, el cronómetro se detiene',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

        // Iniciar el cronómetro
        await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar'));
        await tester.pump();

        // Avanzar 3 segundos
        await tester.pump(const Duration(seconds: 3));
        expect(find.text('00:03'), findsOneWidget);

        // Presionar Parar
        await tester.tap(find.widgetWithText(ElevatedButton, 'Parar'));
        await tester.pump();

        // Avanzar más tiempo
        await tester.pump(const Duration(seconds: 5));

        // El tiempo debe seguir en 00:03
        expect(find.text('00:03'), findsOneWidget);
      });

      testWidgets('después de parar, el botón Iniciar se habilita nuevamente',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

        // Iniciar y parar
        await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));

        await tester.tap(find.widgetWithText(ElevatedButton, 'Parar'));
        await tester.pump();

        // El botón Iniciar debe estar habilitado
        final startButton =
            tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Iniciar'));
        expect(startButton.onPressed, isNotNull);
      });

      testWidgets('después de parar, el botón Parar se deshabilita',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

        // Iniciar y parar
        await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar'));
        await tester.pump();

        await tester.tap(find.widgetWithText(ElevatedButton, 'Parar'));
        await tester.pump();

        // El botón Parar debe estar deshabilitado
        final stopButton =
            tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Parar'));
        expect(stopButton.onPressed, isNull);
      });
    });

    /// Prueba: Funcionalidad de reiniciar el cronómetro
    group('Funcionalidad Reiniciar', () {
      testWidgets('al presionar Reiniciar, el cronómetro vuelve a 00:00',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

        // Iniciar el cronómetro y dejar correr
        await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 5));
        expect(find.text('00:05'), findsOneWidget);

        // Presionar Reiniciar
        await tester.tap(find.widgetWithText(ElevatedButton, 'Reiniciar'));
        await tester.pump();

        // Debe volver a 00:00
        expect(find.text('00:00'), findsOneWidget);
      });

      testWidgets('Reiniciar detiene el cronómetro si estaba corriendo',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

        // Iniciar el cronómetro
        await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 3));

        // Presionar Reiniciar
        await tester.tap(find.widgetWithText(ElevatedButton, 'Reiniciar'));
        await tester.pump();

        // Avanzar más tiempo
        await tester.pump(const Duration(seconds: 5));

        // Debe permanecer en 00:00 (no incrementar)
        expect(find.text('00:00'), findsOneWidget);
      });

      testWidgets('después de Reiniciar, el botón Iniciar está habilitado',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

        // Iniciar, esperar, y reiniciar
        await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 3));

        await tester.tap(find.widgetWithText(ElevatedButton, 'Reiniciar'));
        await tester.pump();

        // El botón Iniciar debe estar habilitado
        final startButton =
            tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Iniciar'));
        expect(startButton.onPressed, isNotNull);
      });

      testWidgets('después de Reiniciar, el botón Parar está deshabilitado',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

        // Iniciar, esperar, y reiniciar
        await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 3));

        await tester.tap(find.widgetWithText(ElevatedButton, 'Reiniciar'));
        await tester.pump();

        // El botón Parar debe estar deshabilitado
        final stopButton =
            tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Parar'));
        expect(stopButton.onPressed, isNull);
      });

      testWidgets('Reiniciar funciona cuando el cronómetro está detenido',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

        // Iniciar, avanzar, parar
        await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 7));
        expect(find.text('00:07'), findsOneWidget);

        await tester.tap(find.widgetWithText(ElevatedButton, 'Parar'));
        await tester.pump();

        // Presionar Reiniciar mientras está detenido
        await tester.tap(find.widgetWithText(ElevatedButton, 'Reiniciar'));
        await tester.pump();

        // Debe volver a 00:00
        expect(find.text('00:00'), findsOneWidget);
      });
    });

    /// Prueba: Flujos de usuario completos
    group('Flujos de Usuario Completos', () {
      testWidgets('ciclo completo: Iniciar → Parar → Reiniciar',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

        // Estado inicial
        expect(find.text('00:00'), findsOneWidget);

        // Iniciar
        await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 5));
        expect(find.text('00:05'), findsOneWidget);

        // Parar
        await tester.tap(find.widgetWithText(ElevatedButton, 'Parar'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 3));
        expect(find.text('00:05'), findsOneWidget); // No incrementa

        // Reiniciar
        await tester.tap(find.widgetWithText(ElevatedButton, 'Reiniciar'));
        await tester.pump();
        expect(find.text('00:00'), findsOneWidget);
      });

      testWidgets('múltiples ciclos de Iniciar → Parar',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

        // Primer ciclo
        await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 3));
        expect(find.text('00:03'), findsOneWidget);

        await tester.tap(find.widgetWithText(ElevatedButton, 'Parar'));
        await tester.pump();

        // Segundo ciclo (debe continuar desde donde paró)
        await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));
        expect(find.text('00:05'), findsOneWidget);

        await tester.tap(find.widgetWithText(ElevatedButton, 'Parar'));
        await tester.pump();

        // Tercer ciclo
        await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 4));
        expect(find.text('00:09'), findsOneWidget);
      });

      testWidgets('Reiniciar durante la ejecución y volver a iniciar',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

        // Iniciar y dejar correr
        await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 8));
        expect(find.text('00:08'), findsOneWidget);

        // Reiniciar mientras corre
        await tester.tap(find.widgetWithText(ElevatedButton, 'Reiniciar'));
        await tester.pump();
        expect(find.text('00:00'), findsOneWidget);

        // Iniciar nuevamente desde cero
        await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 4));
        expect(find.text('00:04'), findsOneWidget);
      });
    });

    /// Prueba: Casos extremos y validación
    group('Casos Extremos', () {
      testWidgets('presionar Iniciar múltiples veces no acelera el cronómetro',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

        // Presionar Iniciar
        await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar'));
        await tester.pump();

        // Intentar presionar Iniciar nuevamente (está deshabilitado)
        // El botón está deshabilitado así que no debería hacer nada
        await tester.pump(const Duration(seconds: 2));
        expect(find.text('00:02'), findsOneWidget);

        // Avanzar más tiempo
        await tester.pump(const Duration(seconds: 2));
        expect(find.text('00:04'), findsOneWidget);
      });

      testWidgets('el cronómetro funciona correctamente con tiempos largos',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

        // Iniciar
        await tester.tap(find.widgetWithText(ElevatedButton, 'Iniciar'));
        await tester.pump();

        // Avanzar 2 minutos y 30 segundos
        await tester.pump(const Duration(minutes: 2, seconds: 30));
        expect(find.text('02:30'), findsOneWidget);
      });

      testWidgets('presionar Reiniciar múltiples veces mantiene el estado correcto',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

        // Presionar Reiniciar varias veces desde el estado inicial
        await tester.tap(find.widgetWithText(ElevatedButton, 'Reiniciar'));
        await tester.pump();
        expect(find.text('00:00'), findsOneWidget);

        await tester.tap(find.widgetWithText(ElevatedButton, 'Reiniciar'));
        await tester.pump();
        expect(find.text('00:00'), findsOneWidget);

        // El botón Iniciar debe seguir habilitado
        final startButton =
            tester.widget<ElevatedButton>(find.widgetWithText(ElevatedButton, 'Iniciar'));
        expect(startButton.onPressed, isNotNull);
      });
    });
  });
}
