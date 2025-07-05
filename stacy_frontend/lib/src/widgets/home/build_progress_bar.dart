import 'package:flutter/material.dart';

Widget buildProgressBar({
  required String label,
  required int value,
  required Color color,
}) {
  return Row(
    children: [
      SizedBox(
        width: 60, // Fixed width for label
        child: Text(
          label,
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
      ),
      const SizedBox(width: 10),
      Expanded(
        child: LinearProgressIndicator(
          value: value / 100,
          backgroundColor: color.withOpacity(0.2),
          valueColor: AlwaysStoppedAnimation<Color>(color),
          borderRadius:
              BorderRadius.circular(10), // Rounded corners for progress bar
          minHeight: 8,
        ),
      ),
      const SizedBox(width: 10),
      Text(
        '$value%',
        style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
      ),
    ],
  );
}
