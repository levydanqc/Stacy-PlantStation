import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:stacy_frontend/src/services/logger.dart';
import 'package:stacy_frontend/src/utilities/constants.dart';
import 'package:stacy_frontend/src/utilities/manager/storage_manager.dart';
import 'package:stacy_frontend/src/views/home_view.dart';
import 'package:stacy_frontend/src/views/welcome/welcome_view.dart';

class LoadingView extends StatefulWidget {
  static const String routeName = '/';
  const LoadingView({super.key});

  @override
  State<LoadingView> createState() => _LoadingViewState();
}

class _LoadingViewState extends State<LoadingView> {
  @override
  void initState() {
    super.initState();

    StorageManager().isLoggedIn().then((isLoggedIn) {
      if (isLoggedIn && mounted) {
        log.finer('Navigating to HomeView');
        GoRouter.of(context).go(HomeView.routeName);
      } else if (mounted) {
        log.finer('Navigating to WelcomeView');
        GoRouter.of(context).go(WelcomeView.routeName);
      }
    }).catchError((error) {
      log.severe('Error checking auth status: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/welcome_plant.png',
              width: 50.sw,
            ),
            const SizedBox(height: 30),
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.teal.shade600),
            ),
          ],
        ),
      ),
    );
  }
}
