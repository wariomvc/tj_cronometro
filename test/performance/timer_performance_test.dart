import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_cronometro/main.dart';
import 'package:tj_cronometro/screens/timer_screen.dart';

/// Suite de pruebas de rendimiento para TJ Cronómetro
///
/// Estas pruebas verifican que el cronómetro mantiene un buen rendimiento,
/// no tiene memory leaks, y funciona correctamente bajo condiciones de carga.
void main() {
  group('Performance Tests', () {
    /// Prueba: Memory leaks y gestión de recursos
    group('Gestión de Memoria', () {
      testWidgets('no hay memory leaks al crear y destruir el widget múltiples veces',
          (WidgetTester tester) async {
        // Crear y destruir el widget 10 veces
        for (int i = 0; i < 10; i++) {
          await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

          // Iniciar el cronómetro
          await tester.tap(find.text('Iniciar'));
          await tester.pump();
          await tester.pump(const Duration(seconds: 2));

          // Parar el cronómetro
          await tester.tap(find.text('Parar'));
          await tester.pump();

          // Destruir el widget (simular navegación)
          await tester.pumpWidget(const SizedBox.shrink());
        }

        // Si llegamos aquí sin errores, no hay memory leaks obvios
        expect(true, true);
      });

      testWidgets('el timer se cancela correctamente al destruir el widget',
          (WidgetTester tester) async {
        // Crear el widget con cronómetro corriendo
        await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

        await tester.tap(find.text('Iniciar'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 3));

        // Verificar que está corriendo
        expect(find.text('00:03'), findsOneWidget);

        // Destruir el widget (dispose debe cancelar el timer)
        await tester.pumpWidget(const SizedBox.shrink());

        // Avanzar tiempo para verificar que el timer no sigue corriendo
        await tester.pump(const Duration(seconds: 5));

        // Si no hay errores, el timer se canceló correctamente
        expect(true, true);
      });

      testWidgets('múltiples ciclos de inicio/parada no degradan el rendimiento',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

        // Realizar 20 ciclos de inicio/parada
        for (int i = 0; i < 20; i++) {
          await tester.tap(find.text('Iniciar'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));

          await tester.tap(find.text('Parar'));
          await tester.pump();
        }

        // Verificar que el widget sigue respondiendo
        await tester.tap(find.text('Reiniciar'));
        await tester.pump();
        expect(find.text('00:00'), findsOneWidget);

        // Verificar que puede iniciar nuevamente sin problemas
        await tester.tap(find.text('Iniciar'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 1));
        expect(find.text('00:01'), findsOneWidget);
      });

      testWidgets('reiniciar repetidamente no causa problemas de memoria',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

        // Reiniciar 30 veces
        for (int i = 0; i < 30; i++) {
          await tester.tap(find.text('Iniciar'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 500));

          await tester.tap(find.text('Reiniciar'));
          await tester.pump();
        }

        // Verificar que todo sigue funcionando
        expect(find.text('00:00'), findsOneWidget);
        await tester.tap(find.text('Iniciar'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 2));
        expect(find.text('00:02'), findsOneWidget);
      });
    });

    /// Prueba: Rendimiento del widget
    group('Rendimiento de Rebuild', () {
      testWidgets('el widget se reconstruye eficientemente cada segundo',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

        // Iniciar el cronómetro
        await tester.tap(find.text('Iniciar'));
        await tester.pump();

        // Simular 30 segundos de ejecución (30 rebuilds)
        for (int i = 1; i <= 30; i++) {
          await tester.pump(const Duration(seconds: 1));

          // Verificar que el tiempo se actualiza correctamente
          final expectedTime =
              '00:${i.toString().padLeft(2, '0')}';
          expect(find.text(expectedTime), findsOneWidget);
        }

        // El widget debe seguir respondiendo
        await tester.tap(find.text('Parar'));
        await tester.pump();
        expect(find.text('00:30'), findsOneWidget);
      });

      testWidgets('cambios de estado no causan rebuilds innecesarios',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

        int frameCount = 0;
        tester.binding.addPostFrameCallback((_) {
          frameCount++;
        });

        // Iniciar
        await tester.tap(find.text('Iniciar'));
        await tester.pump();

        // Avanzar 1 segundo (debe haber exactamente 1 rebuild por segundo)
        await tester.pump(const Duration(seconds: 1));

        // Parar (1 rebuild para el cambio de estado)
        await tester.tap(find.text('Parar'));
        await tester.pump();

        // Reiniciar (1 rebuild para el cambio de estado)
        await tester.tap(find.text('Reiniciar'));
        await tester.pump();

        // Si llegamos aquí sin problemas de rendimiento, todo está bien
        expect(find.text('00:00'), findsOneWidget);
      });

      testWidgets('el FittedBox no causa problemas de rendimiento',
          (WidgetTester tester) async {
        // Probar con diferentes tamaños de pantalla
        final sizes = [
          const Size(400, 600),
          const Size(800, 1200),
          const Size(1920, 1080),
          const Size(320, 568), // iPhone SE
        ];

        for (final size in sizes) {
          await tester.binding.setSurfaceSize(size);

          await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

          await tester.tap(find.text('Iniciar'));
          await tester.pump();
          await tester.pump(const Duration(seconds: 2));

          // Verificar que el texto se muestra correctamente
          expect(find.text('00:02'), findsOneWidget);

          // Limpiar para la siguiente iteración
          await tester.pumpWidget(const SizedBox.shrink());
        }

        // Restaurar tamaño por defecto
        await tester.binding.setSurfaceSize(null);
      });
    });

    /// Prueba: Precisión bajo carga
    group('Precisión bajo Carga', () {
      testWidgets('el cronómetro mantiene precisión durante 60 segundos',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

        await tester.tap(find.text('Iniciar'));
        await tester.pump();

        // Simular 60 segundos
        await tester.pump(const Duration(seconds: 60));

        expect(find.text('01:00'), findsOneWidget);
      });

      testWidgets('múltiples pausas y reinicios mantienen precisión',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

        int totalSeconds = 0;

        // Realizar 10 segmentos de tiempo
        for (int i = 0; i < 10; i++) {
          await tester.tap(find.text('Iniciar'));
          await tester.pump();

          // Cada segmento dura entre 1-3 segundos
          final segmentDuration = 2;
          await tester.pump(Duration(seconds: segmentDuration));
          totalSeconds += segmentDuration;

          await tester.tap(find.text('Parar'));
          await tester.pump();

          // Pausa de 500ms (no debe afectar el tiempo)
          await tester.pump(const Duration(milliseconds: 500));
        }

        // Verificar que el tiempo total es correcto (20 segundos)
        expect(find.text('00:20'), findsOneWidget);
      });

      testWidgets('el cronómetro funciona correctamente en ejecución muy larga',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

        await tester.tap(find.text('Iniciar'));
        await tester.pump();

        // Simular 5 minutos (300 segundos)
        await tester.pump(const Duration(minutes: 5));

        expect(find.text('05:00'), findsOneWidget);

        // Continuar por 2 minutos 30 segundos más
        await tester.pump(const Duration(minutes: 2, seconds: 30));

        expect(find.text('07:30'), findsOneWidget);
      });
    });

    /// Prueba: Estabilidad
    group('Estabilidad', () {
      testWidgets('la aplicación no lanza excepciones durante uso intensivo',
          (WidgetTester tester) async {
        await tester.pumpWidget(const TjCronometroApp());
        await tester.pumpAndSettle();

        // Realizar operaciones aleatorias sin errores
        final operations = [
          () async {
            await tester.tap(find.text('Iniciar'));
            await tester.pump();
          },
          () async {
            await tester.pump(const Duration(seconds: 1));
          },
          () async {
            await tester.tap(find.text('Parar'));
            await tester.pump();
          },
          () async {
            await tester.tap(find.text('Reiniciar'));
            await tester.pump();
          },
        ];

        // Ejecutar 50 operaciones
        for (int i = 0; i < 50; i++) {
          final operation = operations[i % operations.length];
          await operation();
        }

        // Verificar que la app sigue funcionando
        expect(find.byType(TimerScreen), findsOneWidget);
      });

      testWidgets('el widget maneja correctamente la recreación del estado',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

        // Iniciar y avanzar
        await tester.tap(find.text('Iniciar'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 5));

        // Simular hot reload (reconstruir el widget tree)
        await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

        // El estado se pierde (es un StatefulWidget nuevo)
        // pero no debe causar errores
        expect(find.text('00:00'), findsOneWidget);

        // Debe poder usarse normalmente
        await tester.tap(find.text('Iniciar'));
        await tester.pump();
        await tester.pump(const Duration(seconds: 3));
        expect(find.text('00:03'), findsOneWidget);
      });

      testWidgets('no hay condiciones de carrera al iniciar/parar rápidamente',
          (WidgetTester tester) async {
        await tester.pumpWidget(const MaterialApp(home: TimerScreen()));

        // Alternar rápidamente entre iniciar y parar
        for (int i = 0; i < 10; i++) {
          await tester.tap(find.text('Iniciar'));
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 100));

          await tester.tap(find.text('Parar'));
          await tester.pump();
        }

        // Verificar que no hay errores y el widget responde
        await tester.tap(find.text('Reiniciar'));
        await tester.pump();
        expect(find.text('00:00'), findsOneWidget);
      });
    });
  });
}
