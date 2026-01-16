import 'dart:async';
import 'package:flutter/material.dart';
import '../widgets/countdown_display.dart';

class CountdownScreen extends StatefulWidget {
  final int durationMinutes;

  const CountdownScreen({
    super.key,
    required this.durationMinutes,
  });

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> {
  late Duration _remainingTime;
  Timer? _timer;
  bool _isRunning = false;

  @override
  void initState() {
    super.initState();
    _remainingTime = Duration(minutes: widget.durationMinutes);
  }

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
        if (_remainingTime.inSeconds > 0) {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        } else {
          _stopTimer();
        }
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
      _remainingTime = Duration(minutes: widget.durationMinutes);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Full-screen countdown display
          CountdownDisplay(
            remainingTime: _remainingTime,
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

          // Back button at top-left
          Positioned(
            top: 16,
            left: 16,
            child: SafeArea(
              child: IconButton(
                onPressed: () {
                  _stopTimer();
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black45,
                ),
              ),
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
