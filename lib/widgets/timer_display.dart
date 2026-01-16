import 'package:flutter/material.dart';
import '../utils/time_formatter.dart';

class TimerDisplay extends StatelessWidget {
  final Duration elapsedTime;
  final bool isRunning;

  const TimerDisplay({
    super.key,
    required this.elapsedTime,
    required this.isRunning,
  });

  @override
  Widget build(BuildContext context) {
    final timeString = TimeFormatter.formatDuration(elapsedTime);
    final screenSize = MediaQuery.of(context).size;

    // Calculate font size based on screen width (responsive)
    final fontSize = screenSize.width * 0.25;

    return Container(
      color: _getBackgroundColor(),
      child: Center(
        child: Text(
          timeString,
          style: TextStyle(
            fontSize: fontSize.clamp(48.0, 300.0),
            fontWeight: FontWeight.bold,
            fontFamily: 'monospace',
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (isRunning) {
      return Colors.green.shade700;
    } else if (elapsedTime.inSeconds > 0) {
      return Colors.orange.shade700;
    } else {
      return Colors.blueGrey.shade700;
    }
  }
}
