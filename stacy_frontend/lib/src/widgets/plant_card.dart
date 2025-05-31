import 'package:flutter/material.dart';
import 'package:stacy_frontend/src/models/plant.dart';
import 'package:stacy_frontend/src/services/logger.dart';

class PlantCard extends StatelessWidget {
  final Plant plant;

  const PlantCard({super.key, required this.plant});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to Plant Detail Screen
        log.info('Plant ${plant.plantName} tapped');
        // GoRouter.of(context).push('/plant_detail/${plant.id}');
      },
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plant.plantName,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade800,
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                      const SizedBox(height: 5)
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.grey.shade500),
                    onPressed: () {
                      log.info('More options for ${plant.plantName}');
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
              children: [
                _buildIndicatorItem(Icons.thermostat, 'Temp',
                    '${plant.plantData.last.temperature}°C', Colors.red),
                _buildIndicatorItem(Icons.water_drop, 'Humidity',
                    '${plant.plantData.last.humidity}%', Colors.blue),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              'WATERING SCHEDULE',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 10),
            _buildWateringSchedule(),
          ],
        ),
      ),
    );
  }

  Widget _buildIndicatorItem(
      IconData icon, String label, String value, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 30),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        Text(
          value,
          style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildWateringSchedule() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildDayCircle('M', false),
        _buildDayCircle('T', true),
        _buildDayCircle('W', false),
        _buildDayCircle('T', false),
        _buildDayCircle('F', false),
        _buildDayCircle('S', false),
        _buildDayCircle('S', false),
      ],
    );
  }

  Widget _buildDayCircle(String day, bool isHighlighted) {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.teal.shade200 : Colors.grey.shade100,
        shape: BoxShape.circle,
        border: Border.all(
          color: isHighlighted ? Colors.teal.shade600 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          day,
          style: TextStyle(
            color: isHighlighted ? Colors.teal.shade800 : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
