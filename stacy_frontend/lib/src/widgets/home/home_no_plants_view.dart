import 'package:flutter/material.dart';
import 'package:stacy_frontend/src/services/logger.dart';

Widget buildNoPlantsView(BuildContext context) {
  return Padding(
    padding: const EdgeInsets.all(30.0),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Icon(Icons.nature, size: 100, color: Colors.teal.shade300),
        const SizedBox(height: 20),
        Text(
          'No plants added yet!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.teal.shade700,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'It looks like you haven\'t added any plants to your account. Let\'s get started!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 40),
        SizedBox(
          height: 55,
          child: ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to 'Add Device' or 'Add Plant' screen
              log.info('Add Device button pressed');
              // GoRouter.of(context).push('/add_device');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 5,
            ),
            icon: const Icon(Icons.add_circle_outline, color: Colors.white),
            label: const Text(
              'Add Your First Plant / Device',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
