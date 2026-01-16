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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen timer display
          TimerDisplay(
            elapsedTime: _elapsedTime,
            isRunning: _isRunning,
          ),

          // Control buttons overlay at bottom
          Positioned(
            bottom: 48,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Start Button
                _buildControlButton(
                  onPressed: _isRunning ? null : _startTimer,
                  icon: Icons.play_arrow,
                  label: 'Iniciar',
                  color: Colors.green,
                ),
                const SizedBox(width: 24),

                // Stop Button
                _buildControlButton(
                  onPressed: _isRunning ? _stopTimer : null,
                  icon: Icons.stop,
                  label: 'Parar',
                  color: Colors.red,
                ),
                const SizedBox(width: 24),

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
