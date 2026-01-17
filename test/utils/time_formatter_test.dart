import 'package:flutter_test/flutter_test.dart';
import 'package:tj_cronometro/utils/time_formatter.dart';

/// Suite de pruebas unitarias para la clase TimeFormatter
///
/// Esta suite verifica que el formateador de tiempo convierte correctamente
/// objetos Duration a strings en formato MM:SS bajo diversos escenarios.
void main() {
  group('TimeFormatter', () {
    group('formatDuration', () {
      /// Prueba: Duración cero debe mostrar "00:00"
      test('formatea duración cero correctamente', () {
        final result = TimeFormatter.formatDuration(Duration.zero);
        expect(result, '00:00');
      });

      /// Prueba: Segundos individuales deben tener padding de ceros
      test('formatea segundos solamente con padding correcto', () {
        expect(TimeFormatter.formatDuration(const Duration(seconds: 5)), '00:05');
        expect(TimeFormatter.formatDuration(const Duration(seconds: 15)), '00:15');
        expect(TimeFormatter.formatDuration(const Duration(seconds: 45)), '00:45');
        expect(TimeFormatter.formatDuration(const Duration(seconds: 59)), '00:59');
      });

      /// Prueba: Minutos exactos sin segundos
      test('formatea minutos exactos correctamente', () {
        expect(TimeFormatter.formatDuration(const Duration(minutes: 1)), '01:00');
        expect(TimeFormatter.formatDuration(const Duration(minutes: 5)), '05:00');
        expect(TimeFormatter.formatDuration(const Duration(minutes: 10)), '10:00');
        expect(TimeFormatter.formatDuration(const Duration(minutes: 59)), '59:00');
      });

      /// Prueba: Combinación de minutos y segundos
      test('formatea minutos y segundos combinados correctamente', () {
        expect(
          TimeFormatter.formatDuration(const Duration(minutes: 1, seconds: 30)),
          '01:30',
        );
        expect(
          TimeFormatter.formatDuration(const Duration(minutes: 5, seconds: 45)),
          '05:45',
        );
        expect(
          TimeFormatter.formatDuration(const Duration(minutes: 12, seconds: 8)),
          '12:08',
        );
        expect(
          TimeFormatter.formatDuration(const Duration(minutes: 59, seconds: 59)),
          '59:59',
        );
      });

      /// Prueba: Límites de minutos (0-59 después del módulo 60)
      test('maneja el límite de 60 minutos correctamente', () {
        // 60 minutos debe reiniciar a 00:XX
        expect(
          TimeFormatter.formatDuration(const Duration(minutes: 60)),
          '00:00',
        );
        // 65 minutos debe mostrar 05:00
        expect(
          TimeFormatter.formatDuration(const Duration(minutes: 65)),
          '05:00',
        );
        // 90 minutos debe mostrar 30:00
        expect(
          TimeFormatter.formatDuration(const Duration(minutes: 90)),
          '30:00',
        );
      });

      /// Prueba: Duraciones en horas se convierten correctamente
      test('maneja duraciones de horas correctamente', () {
        // 1 hora = 60 minutos = 00:00 (después del módulo)
        expect(
          TimeFormatter.formatDuration(const Duration(hours: 1)),
          '00:00',
        );
        // 1 hora 5 minutos 30 segundos = 05:30 (después del módulo)
        expect(
          TimeFormatter.formatDuration(
            const Duration(hours: 1, minutes: 5, seconds: 30),
          ),
          '05:30',
        );
        // 2 horas 15 minutos 45 segundos = 15:45
        expect(
          TimeFormatter.formatDuration(
            const Duration(hours: 2, minutes: 15, seconds: 45),
          ),
          '15:45',
        );
      });

      /// Prueba: Valores en el límite (boundary values)
      test('maneja valores límite correctamente', () {
        // Segundo antes del minuto
        expect(
          TimeFormatter.formatDuration(const Duration(seconds: 59)),
          '00:59',
        );
        // Exactamente un minuto
        expect(
          TimeFormatter.formatDuration(const Duration(seconds: 60)),
          '01:00',
        );
        // Un segundo después del minuto
        expect(
          TimeFormatter.formatDuration(const Duration(seconds: 61)),
          '01:01',
        );
      });

      /// Prueba: Casos de uso típicos del cronómetro
      test('formatea correctamente casos de uso comunes', () {
        // 30 segundos - intervalo corto típico
        expect(
          TimeFormatter.formatDuration(const Duration(seconds: 30)),
          '00:30',
        );
        // 2 minutos 30 segundos - descanso corto
        expect(
          TimeFormatter.formatDuration(const Duration(minutes: 2, seconds: 30)),
          '02:30',
        );
        // 15 minutos - temporizador de trabajo
        expect(
          TimeFormatter.formatDuration(const Duration(minutes: 15)),
          '15:00',
        );
        // 25 minutos - técnica Pomodoro
        expect(
          TimeFormatter.formatDuration(const Duration(minutes: 25)),
          '25:00',
        );
      });

      /// Prueba: Milisegundos son ignorados (solo cuenta segundos completos)
      test('ignora milisegundos al formatear', () {
        expect(
          TimeFormatter.formatDuration(const Duration(seconds: 5, milliseconds: 999)),
          '00:05',
        );
        expect(
          TimeFormatter.formatDuration(const Duration(minutes: 1, seconds: 30, milliseconds: 500)),
          '01:30',
        );
      });
    });
  });
}
