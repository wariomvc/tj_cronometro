import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tj_cronometro/widgets/timer_display.dart';

/// Suite de pruebas de widget para TimerDisplay
///
/// Estas pruebas verifican el comportamiento visual del widget TimerDisplay,
/// incluyendo los cambios de color de fondo según el estado del cronómetro,
/// el renderizado correcto del texto del tiempo, y el layout responsivo.
void main() {
  group('TimerDisplay', () {
    /// Prueba: Colores de fondo según estado
    group('Colores de Fondo', () {
      testWidgets('muestra fondo verde cuando está corriendo',
          (WidgetTester tester) async {
        // Crear widget con cronómetro corriendo
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TimerDisplay(
                elapsedTime: Duration(seconds: 5),
                isRunning: true,
              ),
            ),
          ),
        );

        // Buscar el Container y verificar su color
        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(TimerDisplay),
            matching: find.byType(Container),
          ),
        );

        expect(container.color, Colors.green.shade700);
      });

      testWidgets('muestra fondo naranja cuando está pausado con tiempo',
          (WidgetTester tester) async {
        // Crear widget con cronómetro pausado pero con tiempo acumulado
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TimerDisplay(
                elapsedTime: Duration(seconds: 10),
                isRunning: false,
              ),
            ),
          ),
        );

        // Verificar color naranja
        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(TimerDisplay),
            matching: find.byType(Container),
          ),
        );

        expect(container.color, Colors.orange.shade700);
      });

      testWidgets('muestra fondo gris azulado cuando está en cero',
          (WidgetTester tester) async {
        // Crear widget con cronómetro en estado inicial (0 segundos, no corriendo)
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TimerDisplay(
                elapsedTime: Duration.zero,
                isRunning: false,
              ),
            ),
          ),
        );

        // Verificar color gris azulado
        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(TimerDisplay),
            matching: find.byType(Container),
          ),
        );

        expect(container.color, Colors.blueGrey.shade700);
      });

      testWidgets('cambia de gris a verde cuando inicia desde cero',
          (WidgetTester tester) async {
        // Estado inicial: en cero, no corriendo (debe ser gris)
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TimerDisplay(
                elapsedTime: Duration.zero,
                isRunning: false,
              ),
            ),
          ),
        );

        var container = tester.widget<Container>(
          find.descendant(
            of: find.byType(TimerDisplay),
            matching: find.byType(Container),
          ),
        );
        expect(container.color, Colors.blueGrey.shade700);

        // Actualizar a corriendo (debe ser verde)
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TimerDisplay(
                elapsedTime: Duration(seconds: 1),
                isRunning: true,
              ),
            ),
          ),
        );

        container = tester.widget<Container>(
          find.descendant(
            of: find.byType(TimerDisplay),
            matching: find.byType(Container),
          ),
        );
        expect(container.color, Colors.green.shade700);
      });

      testWidgets('cambia de verde a naranja cuando se pausa',
          (WidgetTester tester) async {
        // Estado corriendo: verde
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TimerDisplay(
                elapsedTime: Duration(seconds: 8),
                isRunning: true,
              ),
            ),
          ),
        );

        var container = tester.widget<Container>(
          find.descendant(
            of: find.byType(TimerDisplay),
            matching: find.byType(Container),
          ),
        );
        expect(container.color, Colors.green.shade700);

        // Pausar: debe cambiar a naranja
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TimerDisplay(
                elapsedTime: Duration(seconds: 8),
                isRunning: false,
              ),
            ),
          ),
        );

        container = tester.widget<Container>(
          find.descendant(
            of: find.byType(TimerDisplay),
            matching: find.byType(Container),
          ),
        );
        expect(container.color, Colors.orange.shade700);
      });

      testWidgets('cambia de naranja a gris azulado cuando se reinicia',
          (WidgetTester tester) async {
        // Estado pausado con tiempo: naranja
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TimerDisplay(
                elapsedTime: Duration(seconds: 15),
                isRunning: false,
              ),
            ),
          ),
        );

        var container = tester.widget<Container>(
          find.descendant(
            of: find.byType(TimerDisplay),
            matching: find.byType(Container),
          ),
        );
        expect(container.color, Colors.orange.shade700);

        // Reiniciar a cero: debe cambiar a gris azulado
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TimerDisplay(
                elapsedTime: Duration.zero,
                isRunning: false,
              ),
            ),
          ),
        );

        container = tester.widget<Container>(
          find.descendant(
            of: find.byType(TimerDisplay),
            matching: find.byType(Container),
          ),
        );
        expect(container.color, Colors.blueGrey.shade700);
      });
    });

    /// Prueba: Renderizado de texto de tiempo
    group('Renderizado de Tiempo', () {
      testWidgets('muestra 00:00 para duración cero',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TimerDisplay(
                elapsedTime: Duration.zero,
                isRunning: false,
              ),
            ),
          ),
        );

        expect(find.text('00:00'), findsOneWidget);
      });

      testWidgets('muestra tiempo formateado correctamente',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TimerDisplay(
                elapsedTime: Duration(minutes: 2, seconds: 30),
                isRunning: true,
              ),
            ),
          ),
        );

        expect(find.text('02:30'), findsOneWidget);
      });

      testWidgets('actualiza el texto cuando cambia elapsedTime',
          (WidgetTester tester) async {
        // Tiempo inicial
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TimerDisplay(
                elapsedTime: Duration(seconds: 10),
                isRunning: true,
              ),
            ),
          ),
        );
        expect(find.text('00:10'), findsOneWidget);

        // Actualizar tiempo
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TimerDisplay(
                elapsedTime: Duration(seconds: 25),
                isRunning: true,
              ),
            ),
          ),
        );
        expect(find.text('00:25'), findsOneWidget);
        expect(find.text('00:10'), findsNothing);
      });

      testWidgets('muestra correctamente transiciones de minutos',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TimerDisplay(
                elapsedTime: Duration(seconds: 59),
                isRunning: true,
              ),
            ),
          ),
        );
        expect(find.text('00:59'), findsOneWidget);

        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TimerDisplay(
                elapsedTime: Duration(minutes: 1),
                isRunning: true,
              ),
            ),
          ),
        );
        expect(find.text('01:00'), findsOneWidget);
      });

      testWidgets('muestra correctamente tiempos largos',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TimerDisplay(
                elapsedTime: Duration(minutes: 25, seconds: 45),
                isRunning: false,
              ),
            ),
          ),
        );

        expect(find.text('25:45'), findsOneWidget);
      });
    });

    /// Prueba: Estilo del texto
    group('Estilo de Texto', () {
      testWidgets('el texto tiene color blanco',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TimerDisplay(
                elapsedTime: Duration(seconds: 5),
                isRunning: true,
              ),
            ),
          ),
        );

        final text = tester.widget<Text>(find.text('00:05'));
        expect(text.style?.color, Colors.white);
      });

      testWidgets('el texto usa fuente monospace',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TimerDisplay(
                elapsedTime: Duration(seconds: 5),
                isRunning: true,
              ),
            ),
          ),
        );

        final text = tester.widget<Text>(find.text('00:05'));
        expect(text.style?.fontFamily, 'monospace');
      });

      testWidgets('el texto tiene peso bold',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TimerDisplay(
                elapsedTime: Duration(seconds: 5),
                isRunning: true,
              ),
            ),
          ),
        );

        final text = tester.widget<Text>(find.text('00:05'));
        expect(text.style?.fontWeight, FontWeight.bold);
      });

      testWidgets('el texto tiene tamaño de fuente 300',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TimerDisplay(
                elapsedTime: Duration(seconds: 5),
                isRunning: true,
              ),
            ),
          ),
        );

        final text = tester.widget<Text>(find.text('00:05'));
        expect(text.style?.fontSize, 300);
      });
    });

    /// Prueba: Layout y estructura
    group('Layout y Estructura', () {
      testWidgets('contiene un Container como raíz',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TimerDisplay(
                elapsedTime: Duration.zero,
                isRunning: false,
              ),
            ),
          ),
        );

        expect(
          find.descendant(
            of: find.byType(TimerDisplay),
            matching: find.byType(Container),
          ),
          findsOneWidget,
        );
      });

      testWidgets('usa LayoutBuilder para responsividad',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TimerDisplay(
                elapsedTime: Duration.zero,
                isRunning: false,
              ),
            ),
          ),
        );

        expect(find.byType(LayoutBuilder), findsOneWidget);
      });

      testWidgets('usa FittedBox para ajustar el contenido',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TimerDisplay(
                elapsedTime: Duration.zero,
                isRunning: false,
              ),
            ),
          ),
        );

        final fittedBox = tester.widget<FittedBox>(find.byType(FittedBox));
        expect(fittedBox.fit, BoxFit.contain);
      });

      testWidgets('centra el contenido con Center widget',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TimerDisplay(
                elapsedTime: Duration.zero,
                isRunning: false,
              ),
            ),
          ),
        );

        expect(
          find.descendant(
            of: find.byType(LayoutBuilder),
            matching: find.byType(Center),
          ),
          findsOneWidget,
        );
      });

      testWidgets('el SizedBox usa 95% del ancho disponible',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 1000,
                height: 1000,
                child: TimerDisplay(
                  elapsedTime: Duration.zero,
                  isRunning: false,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final sizedBox = tester.widget<SizedBox>(
          find.descendant(
            of: find.byType(Center),
            matching: find.byType(SizedBox),
          ),
        );

        // 95% de 1000 = 950
        expect(sizedBox.width, 950.0);
      });

      testWidgets('el SizedBox usa 90% de la altura disponible',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 1000,
                height: 1000,
                child: TimerDisplay(
                  elapsedTime: Duration.zero,
                  isRunning: false,
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        final sizedBox = tester.widget<SizedBox>(
          find.descendant(
            of: find.byType(Center),
            matching: find.byType(SizedBox),
          ),
        );

        // 90% de 1000 = 900
        expect(sizedBox.height, 900.0);
      });
    });

    /// Prueba: Casos extremos
    group('Casos Extremos', () {
      testWidgets('maneja correctamente el estado isRunning=true con tiempo cero',
          (WidgetTester tester) async {
        // Caso extremo: corriendo pero aún en 0 (primer tick no ocurrido)
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TimerDisplay(
                elapsedTime: Duration.zero,
                isRunning: true,
              ),
            ),
          ),
        );

        // Debe mostrar verde (isRunning tiene prioridad)
        final container = tester.widget<Container>(
          find.descendant(
            of: find.byType(TimerDisplay),
            matching: find.byType(Container),
          ),
        );
        expect(container.color, Colors.green.shade700);
        expect(find.text('00:00'), findsOneWidget);
      });

      testWidgets('maneja duraciones muy largas correctamente',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TimerDisplay(
                elapsedTime: Duration(hours: 2, minutes: 30, seconds: 45),
                isRunning: false,
              ),
            ),
          ),
        );

        // 2h 30m 45s = 150 minutos 45 segundos = módulo 60 = 30:45
        expect(find.text('30:45'), findsOneWidget);
      });

      testWidgets('el widget se reconstruye correctamente al cambiar propiedades',
          (WidgetTester tester) async {
        // Primer estado
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TimerDisplay(
                elapsedTime: Duration(seconds: 5),
                isRunning: true,
              ),
            ),
          ),
        );

        expect(find.text('00:05'), findsOneWidget);
        var container = tester.widget<Container>(
          find.descendant(
            of: find.byType(TimerDisplay),
            matching: find.byType(Container),
          ),
        );
        expect(container.color, Colors.green.shade700);

        // Segundo estado (cambio completo)
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: TimerDisplay(
                elapsedTime: Duration(minutes: 1, seconds: 30),
                isRunning: false,
              ),
            ),
          ),
        );

        expect(find.text('01:30'), findsOneWidget);
        expect(find.text('00:05'), findsNothing);
        container = tester.widget<Container>(
          find.descendant(
            of: find.byType(TimerDisplay),
            matching: find.byType(Container),
          ),
        );
        expect(container.color, Colors.orange.shade700);
      });
    });
  });
}
