import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stacy_frontend/src/services/logger.dart';
import 'package:stacy_frontend/src/utilities/constants.dart';
import 'package:stacy_frontend/src/utilities/manager/secure_storage_manager.dart';
import 'package:stacy_frontend/src/utilities/manager/storage_manager.dart';
import 'package:stacy_frontend/src/views/add_plant_view.dart';
import 'package:stacy_frontend/src/views/welcome/loading_view.dart';

void buildSettingsMenu(context) {
  log.info('Menu button pressed');
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        backgroundColor: Colors.white,
        title: Row(
          children: [
            Text('Menu', style: TextStyle(color: blackColor)),
            Spacer(),
            IconButton(
              icon: Icon(Icons.close, color: Colors.black),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text('Settings', style: TextStyle(color: blackColor)),
              leading: Icon(Icons.settings, color: Colors.black),
              onTap: () {
                log.info('Settings menu item tapped');
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Account', style: TextStyle(color: blackColor)),
              leading: Icon(Icons.account_circle, color: Colors.black),
              onTap: () {
                log.info('Account menu item tapped');
                Navigator.pop(context);
              },
            ),
            SizedBox(height: 30),
            ListTile(
              leading: Icon(Icons.add, color: Colors.white),
              title: Text('Add a new plant'),
              onTap: () {
                log.info('Add a new plant menu item tapped');
                Navigator.pop(context);
                GoRouter.of(context).push(AddPlantView.routeName);
              },
              tileColor: accentColor,
              textColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            SizedBox(height: 30),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red.shade800),
              title:
                  Text('Logout', style: TextStyle(fontWeight: FontWeight.bold)),
              onTap: () async {
                log.info('Logout button pressed');
                await StorageManager().logout();
                await SecureStorageManager().logout();
                if (context.mounted) {
                  GoRouter.of(context).go(LoadingView.routeName);
                }
              },
              textColor: Colors.red.shade800,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              'Close',
              style: TextStyle(
                color: Colors.blue,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    },
  );
}
