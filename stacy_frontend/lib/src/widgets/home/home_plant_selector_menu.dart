import 'package:flutter/material.dart';
import 'package:stacy_frontend/src/models/plant.dart';
import 'package:stacy_frontend/src/services/logger.dart';

void buildPlantSelectorMenu(
    context, List<Plant> plants, Function(int, [bool]) onPlantSelected) {
  log.info('Plant selector button pressed');
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Select a plant'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (int i = 0; i < plants.length; i++)
              ListTile(
                title: Text(plants[i].plantName),
                onTap: () {
                  log.info('Selected plant: ${plants[i]}');
                  Navigator.pop(context);
                  onPlantSelected(i, true);
                },
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text('Close'),
          ),
        ],
      );
    },
  );
}
