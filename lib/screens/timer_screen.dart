import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/timer_display.dart';

class TimerScreen extends StatefulWidget {
  const TimerScreen({super.key});

  @override
  State<TimerScreen> createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen> {
  Duration _elapsedTime = Duration.zero;
  Timer? _timer;
  bool _isRunning = false;
  int? _timeLimitMinutes; // Optional time limit in minutes

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() {
    if (_isRunning) return;

    setState(() {
      _isRunning = true;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _elapsedTime = _elapsedTime + const Duration(seconds: 1);
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    setState(() {
      _isRunning = false;
    });
  }

  void _resetTimer() {
    _stopTimer();
    setState(() {
      _elapsedTime = Duration.zero;
    });
  }

  Future<void> _showTimeLimitDialog() async {
    final TextEditingController controller = TextEditingController(
      text: _timeLimitMinutes?.toString() ?? '',
    );

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Límite de Tiempo'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Ingresa el límite de tiempo en minutos (opcional):'),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Minutos',
                  hintText: 'Ej: 5, 10, 30...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  _timeLimitMinutes = null;
                });
                Navigator.of(context).pop();
              },
              child: const Text('Borrar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = int.tryParse(controller.text);
                if (value != null && value > 0) {
                  setState(() {
                    _timeLimitMinutes = value;
                  });
                }
                Navigator.of(context).pop();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen timer display
          TimerDisplay(
            elapsedTime: _elapsedTime,
            isRunning: _isRunning,
            timeLimitMinutes: _timeLimitMinutes,
          ),

          // Settings button at top right
          Positioned(
            top: 48,
            right: 24,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: _showTimeLimitDialog,
                icon: const Icon(Icons.settings, size: 32),
                color: Colors.white,
                tooltip: 'Configurar límite de tiempo',
              ),
            ),
          ),

          // Time limit indicator (if set)
          if (_timeLimitMinutes != null)
            Positioned(
              top: 48,
              left: 24,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Límite: $_timeLimitMinutes min',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

          // Control buttons overlay at bottom left
          Positioned(
            bottom: 32,
            left: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Start Button
                _buildControlButton(
                  onPressed: _isRunning ? null : _startTimer,
                  icon: Icons.play_arrow,
                  label: 'Iniciar',
                  color: Colors.green,
                ),
                const SizedBox(height: 12),

                // Stop Button
                _buildControlButton(
                  onPressed: _isRunning ? _stopTimer : null,
                  icon: Icons.stop,
                  label: 'Parar',
                  color: Colors.red,
                ),
                const SizedBox(height: 12),

                // Reset Button
                _buildControlButton(
                  onPressed: _resetTimer,
                  icon: Icons.refresh,
                  label: 'Reiniciar',
                  color: Colors.blue,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required VoidCallback? onPressed,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon, size: 28),
      label: Text(label, style: const TextStyle(fontSize: 18)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        disabledBackgroundColor: Colors.grey.shade600,
      ),
    );
  }
}
