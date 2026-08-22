import 'package:flutter/material.dart';

// TODO(contract-v1.1): replace with values read from the Status characteristic
// once Charter §6 is extended to carry pressure thresholds.
class PressureZones {
  static const int normalMax = 1800;
  static const int elevatedMax = 2800;
  static const int adcMax = 4095;
}

class PressureGauge extends StatelessWidget {
  const PressureGauge({super.key, required this.pressure});
  final int pressure;

  Color _zoneColor() {
    if (pressure <= PressureZones.normalMax) return Colors.green;
    if (pressure <= PressureZones.elevatedMax) return Colors.amber;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    final fraction = (pressure / PressureZones.adcMax).clamp(0.0, 1.0);
    return Column(
      children: [
        Text('Pressure', style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 24,
            backgroundColor: Colors.grey.shade300,
            valueColor: AlwaysStoppedAnimation(_zoneColor()),
          ),
        ),
        const SizedBox(height: 4),
        Text('$pressure / ${PressureZones.adcMax}'),
      ],
    );
  }
}
