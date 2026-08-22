import 'package:flutter/material.dart';

class PenStatusIndicator extends StatelessWidget {
  const PenStatusIndicator({super.key, required this.penDown});
  final bool penDown;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          penDown ? Icons.edit : Icons.edit_off,
          color: penDown ? Colors.green : Colors.grey,
        ),
        const SizedBox(width: 6),
        Text(penDown ? 'Pen down' : 'Pen up'),
      ],
    );
  }
}
