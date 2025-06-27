import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

Widget graphBottomDatetimeConversion(double millisSecDouble, TitleMeta meta) {
  final DateTime dateTime =
      DateTime.fromMillisecondsSinceEpoch(millisSecDouble.toInt());
  final String formattedDate =
      '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  return SideTitleWidget(
    meta: meta,
    space: 4.0,
    child: Text(
      formattedDate,
      style: const TextStyle(
        fontSize: 10,
        color: Colors.grey,
      ),
    ),
  );
}
