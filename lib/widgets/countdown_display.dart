import 'package:flutter/material.dart';
import '../utils/time_formatter.dart';

class CountdownDisplay extends StatelessWidget {
  final Duration remainingTime;
  final bool isRunning;

  const CountdownDisplay({
    super.key,
    required this.remainingTime,
    required this.isRunning,
  });

  @override
  Widget build(BuildContext context) {
    final timeString = TimeFormatter.formatDuration(remainingTime);
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
    if (remainingTime.inSeconds <= 0) {
      return Colors.red.shade700;
    } else if (remainingTime.inSeconds <= 30) {
      return Colors.orange.shade700;
    } else if (isRunning) {
      return Colors.green.shade700;
    } else {
      return Colors.blueGrey.shade700;
    }
  }
}
