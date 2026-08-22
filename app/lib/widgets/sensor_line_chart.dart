import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

import '../models/sensor_sample.dart';

class SensorLineChart extends StatelessWidget {
  const SensorLineChart({super.key, required this.samples});
  final List<SensorSample> samples;

  List<FlSpot> _spots(int Function(SensorSample) pick) => [
    for (var i = 0; i < samples.length; i++)
      FlSpot(i.toDouble(), pick(samples[i]).toDouble()),
  ];

  @override
  Widget build(BuildContext context) {
    if (samples.isEmpty) {
      return const Center(child: Text('Waiting for pen data…'));
    }
    return SizedBox(
      height: 180,
      child: LineChart(
        LineChartData(
          minY: -2000,
          maxY: 2000,
          titlesData: const FlTitlesData(show: false),
          gridData: const FlGridData(show: true),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: _spots((s) => s.ax),
              color: Colors.red,
              dotData: const FlDotData(show: false),
            ),
            LineChartBarData(
              spots: _spots((s) => s.ay),
              color: Colors.green,
              dotData: const FlDotData(show: false),
            ),
            LineChartBarData(
              spots: _spots((s) => s.az),
              color: Colors.blue,
              dotData: const FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
