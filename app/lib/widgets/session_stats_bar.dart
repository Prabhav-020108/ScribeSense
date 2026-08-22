import 'package:flutter/material.dart';

class SessionStatsBar extends StatelessWidget {
  const SessionStatsBar({
    super.key,
    required this.elapsed,
    required this.highPressureEvents,
  });
  final Duration elapsed;
  final int highPressureEvents;

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('⏱ ${_fmt(elapsed)}'),
        Text('⚡ $highPressureEvents high-pressure events'),
      ],
    );
  }
}
