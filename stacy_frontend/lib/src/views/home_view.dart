// screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// import 'package:plant_monitor_app/services/auth_service.dart';
// import 'package:plant_monitor_app/api_manager.dart';
import 'package:stacy_frontend/src/models/plant.dart';
import 'package:stacy_frontend/src/services/logger.dart';
import 'package:stacy_frontend/src/utilities/manager/api_manager.dart';
import 'package:stacy_frontend/src/widgets/home/home_no_plants_view.dart';
import 'package:stacy_frontend/src/widgets/home/home_show_plants.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

// ignore: must_be_immutable
class HomeView extends StatefulWidget {
  static const String routeName = '/home';
  int currentPage = 0;

  HomeView({super.key, this.currentPage = 0});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late Future<List<Plant>> _plantsFuture;
  late PageController _pageController;

  final String _webSocketUrl = dotenv.env['WEBSOCKET_URL']!;
  List<Map<String, dynamic>> _weatherData = [];
  WebSocketChannel? _channel;
  String _connectionStatus = "Connecting...";
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();

    _plantsFuture = ApiManager.getUserPlants();
    _pageController = PageController(initialPage: widget.currentPage);

    _pageController.addListener(() {
      setState(() {
        widget.currentPage = _pageController.page!.round();
      });
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<bool> hasPlantInDatabase() async {
    final plants = await _plantsFuture;
    return plants.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: FutureBuilder<List<Plant>>(
      future: _plantsFuture,
      builder: (context, snapshot) {
        log.fine('FutureBuilder state: ${snapshot.connectionState}');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.teal.shade600),
            ),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, color: Colors.red, size: 50),
                const SizedBox(height: 10),
                Text('Error loading plants: ${snapshot.error}'),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _plantsFuture =
                          ApiManager.getUserPlants(); // Retry fetching
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Retry',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            ),
          );
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return buildNoPlantsView(context);
        } else {
          final plants = snapshot.data!;
          return buildPlantsDisplayView(
              context, plants, _pageController, widget.currentPage);
        }
      },
    )
        // child: Scaffold(
        //   backgroundColor: Colors.white,
        //   appBar: AppBar(
        //     backgroundColor: Colors.white,
        //     elevation: 0,
        //     leading: IconButton(
        //       icon: Icon(Icons.menu, color: Colors.grey.shade800),
        //       onPressed: () => _buildMenu(context),
        //     ),
        //     title: Text(
        //       'My Plants',
        //       style: TextStyle(
        //         color: Colors.grey.shade800,
        //         fontWeight: FontWeight.bold,
        //         fontSize: 20,
        //       ),
        //     ),
        //     centerTitle: false,
        //     actions: [
        //       IconButton(
        //         icon: Icon(Icons.notifications_none, color: Colors.grey.shade800),
        //         onPressed: () {
        //           // TODO: Navigate to notifications
        //           log.info('Notifications button pressed');
        //         },
        //       ),
        //       IconButton(
        //         icon: const Icon(Icons.logout, color: Colors.grey),
        //         onPressed: () async {
        //           await StorageManager().logout();
        //           GoRouter.of(context).go(WelcomeView.routeName);
        //         },
        //       ),
        //     ],
        //   ),
        //   body: FutureBuilder<List<Plant>>(
        //     future: _plantsFuture,
        //     builder: (context, snapshot) {
        //       log.fine('FutureBuilder state: ${snapshot.connectionState}');
        //       if (snapshot.connectionState == ConnectionState.waiting) {
        //         return Center(
        //           child: CircularProgressIndicator(
        //             valueColor:
        //                 AlwaysStoppedAnimation<Color>(Colors.teal.shade600),
        //           ),
        //         );
        //       } else if (snapshot.hasError) {
        //         return Center(
        //           child: Column(
        //             mainAxisAlignment: MainAxisAlignment.center,
        //             children: [
        //               Icon(Icons.error_outline, color: Colors.red, size: 50),
        //               const SizedBox(height: 10),
        //               Text('Error loading plants: ${snapshot.error}'),
        //               const SizedBox(height: 20),
        //               ElevatedButton(
        //                 onPressed: () {
        //                   setState(() {
        //                     _plantsFuture =
        //                         ApiManager.getUserPlants(); // Retry fetching
        //                   });
        //                 },
        //                 style: ElevatedButton.styleFrom(
        //                   backgroundColor: Colors.teal,
        //                   shape: RoundedRectangleBorder(
        //                       borderRadius: BorderRadius.circular(8)),
        //                 ),
        //                 child: const Text('Retry',
        //                     style: TextStyle(color: Colors.white)),
        //               ),
        //             ],
        //           ),
        //         );
        //       } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        //         // No plants in the database
        //         return _buildNoPlantsView(context);
        //       } else {
        //         // Plants exist, display them
        //         final plants = snapshot.data!;
        //         log.info('Plants loaded successfully: ${plants.length}');
        //         log.info('Plants: ${plants.map((p) => p.plantName).join(', ')}');
        //         return _buildPlantsDisplayView(context, plants);
        //       }
        //     },
        //   ),
        // ),
        );
  }
}
