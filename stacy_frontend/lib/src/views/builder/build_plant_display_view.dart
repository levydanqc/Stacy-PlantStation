import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'package:stacy_frontend/src/models/plant.dart';
import 'package:stacy_frontend/src/services/logger.dart';
import 'package:stacy_frontend/src/utilities/constants.dart';
import 'package:stacy_frontend/src/widgets/home/build_plant_selector_menu.dart';
import 'package:stacy_frontend/src/widgets/home/build_settings_menu.dart';
import 'package:stacy_frontend/src/widgets/plant/plant_card.dart';

Widget buildPlantsDisplayView(
    BuildContext context,
    List<Plant> plants,
    PageController pageController,
    int currentPage,
    Function(int, [bool]) switchPlant) {
  log.info('Building Plants Display View with currentPage: $currentPage');
  return Scaffold(
    backgroundColor: bgColor,
    appBar: AppBar(
      backgroundColor: bgColor,
      elevation: 0,
      leading: IconButton(
        icon: Icon(Icons.menu, color: Colors.grey.shade800),
        onPressed: () => buildSettingsMenu(context),
      ),
      title: TextButton.icon(
        // Go to PlantSelectorView and pass the plants and currentPage
        onPressed: () => buildPlantSelectorMenu(context, plants, switchPlant),
        label: Text(plants[currentPage].plantName),
        icon: Icon(Icons.keyboard_arrow_down_rounded,
            color: Colors.grey.shade800),
        style: TextButton.styleFrom(
          foregroundColor: Colors.grey.shade800,
          textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(Icons.notifications_none, color: Colors.grey.shade800),
          onPressed: () {
            // TODO: Navigate to notifications
            log.info('Notifications button pressed');
          },
        ),
      ],
    ),
    body: Container(
      margin: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SmoothPageIndicator(
            controller: pageController,
            count: plants.length,
            effect: ExpandingDotsEffect(
              activeDotColor: Colors.teal.shade600,
              dotColor: Colors.grey.shade300,
              dotHeight: 8,
              dotWidth: 8,
              expansionFactor: 3, // Make the active dot bigger
            ),
          ),
          Expanded(
            child: PageView.builder(
              controller: pageController,
              itemCount: plants.length,
              itemBuilder: (context, index) {
                return PlantCard(
                    plant: plants[index]); // Custom Plant Card Widget
              },
            ),
          ),
        ],
      ),
    ),
  );
}
