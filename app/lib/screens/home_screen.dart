import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/session_provider.dart';
import '../widgets/pressure_gauge.dart';
import '../widgets/sensor_line_chart.dart';
import '../widgets/pen_status_indicator.dart';
import '../widgets/session_stats_bar.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final session = context.watch<SessionProvider>();
    final latest = session.latest;

    return Scaffold(
      appBar: AppBar(title: const Text('Live Session')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SessionStatsBar(
              elapsed: session.elapsed,
              highPressureEvents: session.highPressureEventCount,
            ),
            const SizedBox(height: 16),
            if (latest != null) ...[
              PenStatusIndicator(penDown: latest.penDown),
              const SizedBox(height: 16),
              PressureGauge(pressure: latest.pressure),
              const SizedBox(height: 16),
              SensorLineChart(samples: session.recentSamples),
            ] else
              const Expanded(
                child: Center(child: Text('Connect a pen to begin')),
              ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                if (session.state != SessionState.recording)
                  ElevatedButton(
                    onPressed: session.startSession,
                    child: const Text('Start'),
                  )
                else
                  ElevatedButton(
                    onPressed: session.endSession,
                    child: const Text('Stop'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
