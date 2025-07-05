import 'package:flutter/material.dart';

import 'package:stacy_frontend/src/services/logger.dart';
import 'package:stacy_frontend/src/utilities/constants.dart';
import 'package:stacy_frontend/src/widgets/home/build_settings_menu.dart';

class PlantOverviewView extends StatefulWidget {
  const PlantOverviewView({super.key});
  static const String routeName = '/overview';

  @override
  State<PlantOverviewView> createState() => _PlantOverviewViewState();
}

class _PlantOverviewViewState extends State<PlantOverviewView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: offWhite,
      appBar: AppBar(
        backgroundColor: offWhite,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.grey.shade800),
          onPressed: () => {buildSettingsMenu(context)},
        ),
        scrolledUnderElevation: 0,
        actions: [
          // Text button icon to add a new plant
          TextButton.icon(
            onPressed: () {},
            label: Text(
              'Add Plant',
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            icon: Icon(Icons.add, color: Colors.white),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white,
              backgroundColor: accentColor,
              textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          SizedBox(width: 30),
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.grey.shade800),
            onPressed: () {
              // TODO: Navigate to notifications
              log.info('Notifications button pressed');
            },
          ),
          SizedBox(width: 30),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.fromLTRB(30.0, 50.0, 30.0, 0.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Text(
              "Stacy's Friends 🪴",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: blackColor,
              ),
            ),
            SizedBox(height: 30),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(right: 100),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Card(
                    color: offWhite,
                    margin: const EdgeInsets.only(bottom: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(
                        color: primaryColor,
                      ),
                    ),
                    elevation: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              Container(
                                width: 100.0,
                                height: 75.0,
                                decoration: BoxDecoration(
                                  color: primaryColor.withAlpha(200),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              SizedBox(
                                height: 150.0,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.asset(
                                    'assets/images/plants/plant_${(index + 1) % 13}.png',
                                    width: 100.0,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text('Plant ${index + 1}',
                                        style: TextStyle(
                                            color: blackColor,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 22)),
                                    const SizedBox(width: 4),
                                    Icon(
                                      false
                                          ? Icons.warning_amber
                                          : Icons.verified,
                                      size: 16,
                                      color: true ? Colors.red : Colors.grey,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                              ],
                            ),
                          ),
                          const SizedBox(width: 20),
                          Icon(
                            switch (65) {
                              >= 80 => Icons.battery_full_rounded,
                              >= 60 => Icons.battery_5_bar_outlined,
                              >= 40 => Icons.battery_3_bar_outlined,
                              >= 20 => Icons.battery_2_bar_outlined,
                              _ => Icons.battery_alert_outlined,
                            },
                            color: switch (65) {
                              >= 80 => Colors.green,
                              >= 60 => Colors.yellow.shade700,
                              >= 40 => Colors.orange,
                              >= 20 => Colors.red,
                              _ => Colors.redAccent,
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
