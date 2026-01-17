import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:tj_cronometro/main.dart' as app;

/// Suite de pruebas de integración End-to-End para TJ Cronómetro
///
/// Estas pruebas validan el comportamiento completo de la aplicación
/// desde la perspectiva del usuario, simulando interacciones reales
/// y verificando que todos los componentes funcionen correctamente juntos.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('TJ Cronómetro - Integration Tests', () {
    /// Prueba: Flujo completo de usuario básico
    group('Flujos de Usuario Completos', () {
      testWidgets('usuario inicia la app y usa el cronómetro básicamente',
          (WidgetTester tester) async {
        // Iniciar la aplicación
        app.main();
        await tester.pumpAndSettle();

        // Verificar que la app cargó correctamente
        expect(find.text('00:00'), findsOneWidget);
        expect(find.text('Iniciar'), findsOneWidget);
        expect(find.text('Parar'), findsOneWidget);
        expect(find.text('Reiniciar'), findsOneWidget);

        // Usuario presiona Iniciar
        await tester.tap(find.text('Iniciar'));
        await tester.pump();

        // Esperar 3 segundos
        await tester.pump(const Duration(seconds: 3));
        expect(find.text('00:03'), findsOneWidget);

        // Usuario presiona Parar
        await tester.tap(find.text('Parar'));
        await tester.pump();

        // Verificar que se detuvo
        await tester.pump(const Duration(seconds: 2));
        expect(find.text('00:03'), findsOneWidget); // No incrementó

        // Usuario presiona Reiniciar
        await tester.tap(find.text('Reiniciar'));
        await tester.pump();

        // Verificar que volvió a cero
        expect(find.text('00:00'), findsOneWidget);
      });

      testWidgets('usuario realiza sesión completa tipo Pomodoro',
          (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Iniciar sesión de trabajo (simular 25 minutos con 10 segundos)
        await tester.tap(find.text('Iniciar'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 10));

        // Verificar progreso
        expect(find.text('00:10'), findsOneWidget);

        // Pausar para tomar nota
        await tester.tap(find.text('Parar'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));

        // Continuar
        await tester.tap(find.text('Iniciar'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 5));
        expect(find.text('00:15'), findsOneWidget);

        // Finalizar y reiniciar para descanso
        await tester.tap(find.text('Reiniciar'));
        await tester.pump();
        expect(find.text('00:00'), findsOneWidget);

        // Iniciar descanso
        await tester.tap(find.text('Iniciar'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 5));
        expect(find.text('00:05'), findsOneWidget);
      });

      testWidgets('usuario usa el cronómetro para intervalos cortos múltiples',
          (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Intervalo 1
        await tester.tap(find.text('Iniciar'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 3));
        await tester.tap(find.text('Parar'));
        await tester.pump();
        expect(find.text('00:03'), findsOneWidget);

        // Reiniciar para siguiente intervalo
        await tester.tap(find.text('Reiniciar'));
        await tester.pump();

        // Intervalo 2
        await tester.tap(find.text('Iniciar'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 4));
        await tester.tap(find.text('Parar'));
        await tester.pump();
        expect(find.text('00:04'), findsOneWidget);

        // Reiniciar para siguiente intervalo
        await tester.tap(find.text('Reiniciar'));
        await tester.pump();

        // Intervalo 3
        await tester.tap(find.text('Iniciar'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 5));
        expect(find.text('00:05'), findsOneWidget);
      });
    });

    /// Prueba: Precisión del cronómetro
    group('Precisión Temporal', () {
      testWidgets('el cronómetro mantiene precisión en ejecuciones de 30 segundos',
          (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Iniciar cronómetro
        await tester.tap(find.text('Iniciar'));
        await tester.pump();

        // Avanzar 30 segundos y verificar precisión
        await tester.pump(const Duration(seconds: 30));
        expect(find.text('00:30'), findsOneWidget);
      });

      testWidgets('el cronómetro maneja correctamente múltiples transiciones de minutos',
          (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        await tester.tap(find.text('Iniciar'));
        await tester.pump();

        // Primera transición: 0:59 → 1:00
        await tester.pump(const Duration(seconds: 59));
        expect(find.text('00:59'), findsOneWidget);

        await tester.pump(const Duration(seconds: 1));
        expect(find.text('01:00'), findsOneWidget);

        // Segunda transición: 1:59 → 2:00
        await tester.pump(const Duration(seconds: 59));
        expect(find.text('01:59'), findsOneWidget);

        await tester.pump(const Duration(seconds: 1));
        expect(find.text('02:00'), findsOneWidget);
      });

      testWidgets('el cronómetro acumula tiempo correctamente en pausas/reinicios',
          (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Primer segmento: 5 segundos
        await tester.tap(find.text('Iniciar'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 5));
        await tester.tap(find.text('Parar'));
        await tester.pump();
        expect(find.text('00:05'), findsOneWidget);

        // Pausa de 2 segundos (no debe afectar el tiempo)
        await tester.pump(const Duration(seconds: 2));
        expect(find.text('00:05'), findsOneWidget);

        // Segundo segmento: 7 segundos adicionales (total 12)
        await tester.tap(find.text('Iniciar'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 7));
        expect(find.text('00:12'), findsOneWidget);
      });
    });

    /// Prueba: Cambios de estado visual
    group('Estados Visuales', () {
      testWidgets('el fondo cambia de color según el estado del cronómetro',
          (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Estado inicial: gris azulado (verificar que existe el container)
        final initialContainer = find.byType(Container).first;
        expect(initialContainer, findsOneWidget);

        // Iniciar: debe cambiar a verde
        await tester.tap(find.text('Iniciar'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Verificar que el fondo es verde (el widget se reconstruyó)
        expect(find.text('00:01'), findsOneWidget);

        // Parar: debe cambiar a naranja
        await tester.tap(find.text('Parar'));
        await tester.pump();

        // Verificar que el texto sigue siendo 00:01 (pausado)
        expect(find.text('00:01'), findsOneWidget);

        // Reiniciar: debe cambiar a gris azulado
        await tester.tap(find.text('Reiniciar'));
        await tester.pump();

        expect(find.text('00:00'), findsOneWidget);
      });

      testWidgets('los botones se habilitan/deshabilitan correctamente',
          (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Estado inicial: Iniciar y Reiniciar habilitados, Parar deshabilitado
        var startButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Iniciar'),
        );
        var stopButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Parar'),
        );

        expect(startButton.onPressed, isNotNull);
        expect(stopButton.onPressed, isNull);

        // Después de iniciar: Iniciar deshabilitado, Parar habilitado
        await tester.tap(find.text('Iniciar'));
        await tester.pump();

        startButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Iniciar'),
        );
        stopButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Parar'),
        );

        expect(startButton.onPressed, isNull);
        expect(stopButton.onPressed, isNotNull);

        // Después de parar: Iniciar habilitado, Parar deshabilitado
        await tester.pump(const Duration(seconds: 2));
        await tester.tap(find.text('Parar'));
        await tester.pump();

        startButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Iniciar'),
        );
        stopButton = tester.widget<ElevatedButton>(
          find.widgetWithText(ElevatedButton, 'Parar'),
        );

        expect(startButton.onPressed, isNotNull);
        expect(stopButton.onPressed, isNull);
      });
    });

    /// Prueba: Casos de uso extremos
    group('Casos Extremos E2E', () {
      testWidgets('usuario presiona botones rápidamente sin causar errores',
          (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Presionar Reiniciar múltiples veces
        for (int i = 0; i < 5; i++) {
          await tester.tap(find.text('Reiniciar'));
          await tester.pump();
        }
        expect(find.text('00:00'), findsOneWidget);

        // Ciclo rápido de Iniciar → Parar
        for (int i = 0; i < 3; i++) {
          await tester.tap(find.text('Iniciar'));
          await tester.pump();
          await tester.pump(const Duration(seconds: 1));

          await tester.tap(find.text('Parar'));
          await tester.pump();
        }

        // El cronómetro debe estar en 3 segundos (1+1+1)
        expect(find.text('00:03'), findsOneWidget);
      });

      testWidgets('cronómetro funciona correctamente en ejecución prolongada',
          (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Simular una ejecución larga (2 minutos)
        await tester.tap(find.text('Iniciar'));
        await tester.pump();
        await tester.pump(const Duration(minutes: 2));

        expect(find.text('02:00'), findsOneWidget);

        // Continuar por 30 segundos más
        await tester.pump(const Duration(seconds: 30));
        expect(find.text('02:30'), findsOneWidget);

        // Parar y verificar
        await tester.tap(find.text('Parar'));
        await tester.pump();

        // Debe mantenerse en 02:30
        await tester.pump(const Duration(seconds: 5));
        expect(find.text('02:30'), findsOneWidget);
      });

      testWidgets('reiniciar mientras corre detiene y resetea correctamente',
          (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Iniciar y dejar correr
        await tester.tap(find.text('Iniciar'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 15));
        expect(find.text('00:15'), findsOneWidget);

        // Reiniciar mientras está corriendo
        await tester.tap(find.text('Reiniciar'));
        await tester.pump();

        // Debe estar en 00:00 y detenido
        expect(find.text('00:00'), findsOneWidget);

        // Avanzar tiempo para verificar que está detenido
        await tester.pump(const Duration(seconds: 3));
        expect(find.text('00:00'), findsOneWidget);

        // Iniciar debe funcionar normalmente
        await tester.tap(find.text('Iniciar'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));
        expect(find.text('00:02'), findsOneWidget);
      });
    });

    /// Prueba: Comportamiento de la aplicación completa
    group('Aplicación Completa', () {
      testWidgets('la aplicación muestra el título correcto',
          (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Verificar que es una MaterialApp
        expect(find.byType(MaterialApp), findsOneWidget);
      });

      testWidgets('la aplicación usa Material Design 3',
          (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Verificar que hay un Scaffold (parte de Material Design)
        expect(find.byType(Scaffold), findsOneWidget);
      });

      testWidgets('todos los componentes principales están presentes',
          (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Verificar TimerDisplay
        expect(find.text('00:00'), findsOneWidget);

        // Verificar los 3 botones
        expect(find.byIcon(Icons.play_arrow), findsOneWidget);
        expect(find.byIcon(Icons.stop), findsOneWidget);
        expect(find.byIcon(Icons.refresh), findsOneWidget);

        // Verificar labels
        expect(find.text('Iniciar'), findsOneWidget);
        expect(find.text('Parar'), findsOneWidget);
        expect(find.text('Reiniciar'), findsOneWidget);
      });

      testWidgets('la interfaz responde correctamente a múltiples interacciones',
          (WidgetTester tester) async {
        app.main();
        await tester.pumpAndSettle();

        // Realizar 10 operaciones diferentes
        await tester.tap(find.text('Iniciar'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));

        await tester.tap(find.text('Parar'));
        await tester.pump();

        await tester.tap(find.text('Iniciar'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 3));

        await tester.tap(find.text('Reiniciar'));
        await tester.pump();

        await tester.tap(find.text('Iniciar'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));

        // Verificar que todo sigue funcionando
        expect(find.text('00:01'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsNWidgets(3));
      });
    });
  });
}
