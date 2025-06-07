import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:stacy_frontend/src/models/plant.dart';
import 'package:stacy_frontend/src/services/logger.dart';

import 'package:stacy_frontend/src/utilities/constants.dart';
import 'package:stacy_frontend/src/widgets/plant/plant_graph.dart';

enum PlantGraphType { temperature, humidity, moisture }

// ignore: must_be_immutable
class PlantCard extends StatefulWidget {
  final Plant plant;

  const PlantCard({super.key, required this.plant});

  @override
  State<PlantCard> createState() => _PlantCardState();
}

class _PlantCardState extends State<PlantCard> {
  PlantGraphType graphType = PlantGraphType.temperature;

  final List<Color> gradientColors = [Color(0xFF50E4FF), Color(0xFF2196F3)];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      scrollDirection: Axis.vertical,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const SizedBox(width: 15),
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        widget.plant.plantName,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal.shade800,
                        ),
                      ),
                      // Show Battery Percent with icon
                      const SizedBox(width: 25),
                      Icon(
                        switch (widget.plant.plantData.last.batteryPercentage) {
                          >= 80 => Icons.battery_full_rounded,
                          >= 60 => Icons.battery_5_bar_outlined,
                          >= 40 => Icons.battery_3_bar_outlined,
                          >= 20 => Icons.battery_2_bar_outlined,
                          _ => Icons.battery_alert_outlined,
                        },
                        color: switch (
                            widget.plant.plantData.last.batteryPercentage) {
                          >= 80 => Colors.green,
                          >= 60 => Colors.yellow.shade700,
                          >= 40 => Colors.orange,
                          >= 20 => Colors.red,
                          _ => Colors.redAccent,
                        },
                      ),
                      Text(
                        '${widget.plant.plantData.last.batteryPercentage.round()} %',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.grey.shade500),
                    onPressed: () {
                      log.info('More options for ${widget.plant.plantName}');
                      // TODO: Show options menu
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'PLANT\'S INDICATORS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildIndicatorItem(
                  Icons.thermostat,
                  'Temperature',
                  Column(
                    children: [
                      Text(
                        '${widget.plant.plantData.last.temperature} °C',
                        style: TextStyle(
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 14),
                      ),
                      Text(
                        '${widget.plant.plantData.last.hic} °C',
                        style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 13,
                            fontStyle: FontStyle.italic),
                      ),
                    ],
                  ),
                  Colors.red,
                ),
                _buildIndicatorItem(
                    Icons.water_drop,
                    'Humidity',
                    Text(
                      '${widget.plant.plantData.last.humidity} %',
                      style: TextStyle(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                    Colors.blue),
                _buildIndicatorItem(
                    Icons.opacity,
                    'Moisture',
                    Text(
                      '${widget.plant.plantData.last.moisture} %',
                      style: TextStyle(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                    Colors.green),
                _buildIndicatorItem(
                    Icons.speed,
                    'Pressure',
                    Text(
                      '${widget.plant.plantData.last.pressure} hPa',
                      style: TextStyle(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 14),
                    ),
                    Colors.purple),
              ],
            ),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    log.info(
                        'Show Temperature graph for ${widget.plant.plantName}');
                    setState(() {
                      graphType = PlantGraphType.temperature;
                    });
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text(
                    'Temperature',
                    style: TextStyle(
                      color: Colors.teal.shade800,
                      fontWeight: graphType == PlantGraphType.temperature
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                Text(' | ', style: TextStyle(color: Colors.grey.shade600)),
                TextButton(
                  onPressed: () {
                    log.info(
                        'Show Humidity graph for ${widget.plant.plantName}');
                    setState(() {
                      graphType = PlantGraphType.humidity;
                    });
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text(
                    'Humidity',
                    style: TextStyle(
                      color: Colors.teal.shade800,
                      fontWeight: graphType == PlantGraphType.humidity
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
                Text(' | ', style: TextStyle(color: Colors.grey.shade600)),
                TextButton(
                  onPressed: () {
                    log.info(
                        'Show Moisture graph for ${widget.plant.plantName}');
                    setState(() {
                      graphType = PlantGraphType.moisture;
                    });
                  },
                  style: TextButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: Text(
                    'Moisture',
                    style: TextStyle(
                      color: Colors.teal.shade800,
                      fontWeight: graphType == PlantGraphType.moisture
                          ? FontWeight.bold
                          : FontWeight.normal,
                    ),
                  ),
                ),
              ],
            ),
            PlantGraph(
              mainLineColor: blackColor,
              belowLineColor: Colors.green,
              aboveLineColor: Colors.red,
              points: _getGraphPoints(),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _getGraphPoints() {
    switch (graphType) {
      case PlantGraphType.temperature:
        return widget.plant.plantData
            .map((data) => FlSpot(
                data.timestamp.millisecondsSinceEpoch.toDouble(),
                data.temperature))
            .toList();
      case PlantGraphType.humidity:
        return widget.plant.plantData
            .map((data) => FlSpot(
                data.timestamp.millisecondsSinceEpoch.toDouble(),
                data.humidity))
            .toList();
      case PlantGraphType.moisture:
        return widget.plant.plantData
            .map((data) => FlSpot(
                data.timestamp.millisecondsSinceEpoch.toDouble(),
                data.moisture))
            .toList();
    }
  }

  Widget _buildIndicatorItem(
      IconData icon, String label, Widget value, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 30),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        value,
      ],
    );
  }
}
