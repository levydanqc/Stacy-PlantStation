import 'package:flutter/material.dart';
import 'package:stacy_frontend/src/services/logger.dart';

void buildSettingsMenu(context) {
  log.info('Menu button pressed');
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Menu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Settings'),
              onTap: () {
                log.info('Settings menu item tapped');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Account'),
              onTap: () {
                log.info('Account menu item tapped');
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: Icon(Icons.add, color: Colors.white),
              title: Text('Add a new plant'),
              onTap: () {
                log.info('Add a new plant menu item tapped');
                Navigator.pop(context);
              },
              tileColor: Colors.teal.shade600,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
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
