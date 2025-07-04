import 'package:flutter/material.dart';

import 'package:fl_chart/fl_chart.dart';
import 'package:stacy_frontend/src/utilities/constants.dart';
import 'package:stacy_frontend/src/utilities/graph_axis_titles.dart';

class PlantGraph extends StatelessWidget {
  const PlantGraph({
    super.key,
    required this.mainLineColor,
    required this.belowLineColor,
    required this.aboveLineColor,
    required this.points,
  });

  final Color mainLineColor;
  final Color belowLineColor;
  final Color aboveLineColor;
  final List<FlSpot> points;

  Widget bottomTitleWidgets(double value, TitleMeta meta) {
    return graphBottomDatetimeConversion(value, meta);
  }
  // switch (value.toInt()) {
  //   case 0:
  //     text = 'Jan';
  //     break;
  //   case 1:
  //     text = 'Feb';
  //     break;
  //   case 2:
  //     text = 'Mar';
  //     break;
  //   case 3:
  //     text = 'Apr';
  //     break;
  //   case 4:
  //     text = 'May';
  //     break;
  //   case 5:
  //     text = 'Jun';
  //     break;
  //   case 6:
  //     text = 'Jul';
  //     break;
  //   case 7:
  //     text = 'Aug';
  //     break;
  //   case 8:
  //     text = 'Sep';
  //     break;
  //   case 9:
  //     text = 'Oct';
  //     break;
  //   case 10:
  //     text = 'Nov';
  //     break;
  //   case 11:
  //     text = 'Dec';
  //     break;
  //   default:
  //     return const SizedBox.shrink();
  // }
  // return SideTitleWidget(
  //   meta: meta,
  //   space: 4,
  //   child: Text(
  //     text,
  //     style: TextStyle(
  //       fontSize: 10,
  //       color: blackColor,
  //       fontWeight: FontWeight.bold,
  //     ),
  //   ),
  // );
  // }

  Widget leftTitleWidgets(double value, TitleMeta meta) {
    TextStyle style = TextStyle(
      color: blackColor,
      fontSize: 12,
    );
    // return nothing for odd values
    if (value.toInt() % 2 != 0) {
      return const SizedBox.shrink();
    }
    return SideTitleWidget(
      meta: meta,
      child: Text(
        value.toInt().toString(),
        style: style,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const cutOffYValue = 28.0;

    return AspectRatio(
      aspectRatio: 2,
      child: Padding(
        padding: const EdgeInsets.only(
          left: 12,
          right: 28,
          top: 22,
          bottom: 12,
        ),
        child: LineChart(
          LineChartData(
            lineTouchData: const LineTouchData(enabled: false),
            lineBarsData: [
              LineChartBarData(
                spots: points,
                isCurved: true,
                barWidth: 2,
                color: mainLineColor,
                belowBarData: BarAreaData(
                  show: true,
                  color: aboveLineColor.withAlpha(50),
                  cutOffY: cutOffYValue,
                  applyCutOffY: true,
                ),
                aboveBarData: BarAreaData(
                  show: true,
                  color: belowLineColor.withAlpha(50),
                  cutOffY: cutOffYValue,
                  applyCutOffY: true,
                ),
                dotData: const FlDotData(
                  show: false,
                ),
              ),
            ],
            // set the minimum to the smallest y value minus 2
            maxY: points.isNotEmpty
                ? points.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 2
                : 0,
            titlesData: FlTitlesData(
              show: true,
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                axisNameWidget: Text(
                  '2019',
                  style: TextStyle(
                    fontSize: 10,
                    color: blackColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 18,
                  interval: 1,
                  getTitlesWidget: bottomTitleWidgets,
                ),
              ),
              leftTitles: AxisTitles(
                axisNameSize: 20,
                axisNameWidget: Text(
                  'Value',
                  style: TextStyle(
                    color: blackColor,
                  ),
                ),
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  reservedSize: 40,
                  getTitlesWidget: leftTitleWidgets,
                ),
              ),
            ),
            borderData: FlBorderData(
              show: true,
              border: Border.all(
                color: Colors.white,
              ),
            ),
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1,
              checkToShowHorizontalLine: (double value) {
                return value == 1 || value == 6 || value == 4 || value == 5;
              },
            ),
          ),
        ),
      ),
    );
  }
}
