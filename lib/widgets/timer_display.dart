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

    return Container(
      color: _getBackgroundColor(),
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SizedBox(
              width: constraints.maxWidth * 0.95,
              height: constraints.maxHeight * 0.9,
              child: FittedBox(
                fit: BoxFit.contain,
                child: Text(
                  timeString,
                  style: TextStyle(
                    fontSize: 300,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'monospace',
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        },
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
