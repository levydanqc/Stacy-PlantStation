// Displays the users plants with minimal plant data in a list
// Go to HomeView page when clicking on a plant and pass the parameter
// of the index of the plant selected

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stacy_frontend/src/models/plant.dart';
import 'package:stacy_frontend/src/views/home_view.dart';

class PlantSelectorView extends StatelessWidget {
  static final routeName = '/plant-selector';
  final List<Plant> plants;
  final int currentPage;
  const PlantSelectorView(
      {super.key, required this.plants, required this.currentPage});

  @override
  Widget build(BuildContext context) {
    // Build a list of plant name with temperature and humidity only
    // when clicking on a plant, go to HomeView and pass the plant index
    return Scaffold(
      appBar: AppBar(
        title: Text(plants[currentPage].plantName),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: plants.length,
        itemBuilder: (context, index) {
          final plant = plants[index];
          return ListTile(
            title: Text(plant.plantName),
            subtitle: Text(
                'Temperature: ${plant.plantData.last.temperature}°C, Humidity: ${plant.plantData.last.humidity}%'),
            onTap: () {
              Navigator.of(context).pop();
              GoRouter.of(context).go(
                HomeView.routeName,
                extra: index,
              );
            },
          );
        },
      ),
    );
  }
}
