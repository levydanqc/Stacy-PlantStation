import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:stacy_frontend/src/models/plant.dart';
import 'package:stacy_frontend/src/models/plant_data.dart';
import 'package:stacy_frontend/src/services/logger.dart';
import 'package:stacy_frontend/src/services/websocket.dart';
import 'package:stacy_frontend/src/utilities/manager/api_manager.dart';
import 'package:stacy_frontend/src/views/builder/build_plant_overview.dart';
import 'package:stacy_frontend/src/views/welcome/login_view.dart';
import 'package:stacy_frontend/src/views/builder/build_no_plants_view.dart';
import 'package:stacy_frontend/src/views/builder/build_plant_display_view.dart';

// ignore: must_be_immutable
class HomeView extends StatefulWidget {
  static const String routeName = '/home';
  int? id;

  HomeView({super.key, this.id});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late Future<List<Plant>> _plantsFuture;
  late PageController _pageController;

  final WebSocketService _webSocketService = WebSocketService();
  final List<Plant> _weatherData = [];

  @override
  void initState() {
    super.initState();
    log.fine('Initializing HomeView with id: ${widget.id}');

    try {
      _plantsFuture = ApiManager.getUserPlants();
    } on Exception catch (e) {
      if (e.toString() == "Invalid or expired token, user logged out") {
        log.warning('Invalid or expired token, navigating to LoginView');
        WidgetsBinding.instance.addPostFrameCallback((_) {
          GoRouter.of(context).go(LoginView.routeName);
        });
      }
    }
    _pageController = PageController(initialPage: widget.id ?? 0);

    if (widget.id != null) {
      switchPlant(widget.id!);
    }

    _pageController
        .addListener(() => switchPlant(_pageController.page!.round()));

    _webSocketService.connect();
    _subscribeToWebSocketService();
  }

  void switchPlant(int index, [bool isManual = false]) {
    log.fine('Switching to plant at index: $index');
    if (index >= 0 && index < _weatherData.length) {
      setState(() {
        widget.id = index;
        if (isManual) {
          _pageController.jumpToPage(index);
        }
        context.go('${HomeView.routeName}/${widget.id}');
      });
    } else {
      log.warning('Index out of bounds: $index');
    }
  }

  void _subscribeToWebSocketService() {
    _webSocketService.dataStream.listen((data) {
      if (mounted) {
        // Only update state if the widget is still in the tree
        if (data.containsKey('type')) {
          if (data['type'] == 'initial_data') {
            setState(() {
              _weatherData.clear();
              _weatherData.addAll((data['plants'] as List)
                  .map((plant) => Plant.fromJson(plant))
                  .toList());
            });
          } else if (data['type'] == 'update') {
            setState(() {
              final plantName = data['plants']['plant_name'];
              final existingPlantIndex = _weatherData
                  .indexWhere((plant) => plant.plantName == plantName);
              if (existingPlantIndex != -1) {
                _weatherData[existingPlantIndex].plantData.add(
                      PlantData.fromJson(data['plants']['plant_data']),
                    );
              } else {
                log.severe("Received update for unknown plant: $plantName");
              }
            });
          } else {
            log.warning("Received unknown data type: ${data['type']}");
            return;
          }
        } else {
          log.warning("Received unexpected data format: $data");
          return;
        }
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _webSocketService.disconnect();
    super.dispose();
  }

  Future<bool> hasPlantInDatabase() async {
    final plants = await _plantsFuture;
    return plants.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    log.fine('Building HomeView with params: id: ${widget.id}');
    return Builder(
      builder: _buildView,
    );
  }

  Widget _buildView(context) {
    log.finest('Run HomeView _buildView');

    if (_webSocketService.isConnected && _weatherData.isNotEmpty) {
      if (widget.id != null) {
        return buildPlantsDisplayView(
            context, _weatherData, _pageController, widget.id!, switchPlant);
      }
      return buildPlantOverviewView(context, _weatherData);
    } else if (_webSocketService.isConnected && _weatherData.isEmpty) {
      return buildNoPlantsView(context);
    } else if (!_webSocketService.isConnected) {
      return Column(
        children: [
          Text('Attempting to connect to the server...'),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Retry connection logic
              _webSocketService.connect();
              setState(() {});
            },
            child: Text('Retry Connection'),
          ),
        ],
      );
    } else {
      // Show loading indicator while connected but waiting for first data
      return Column(children: [
        Text('Connected. Waiting for data...'),
        SizedBox(height: 20),
        CircularProgressIndicator(),
      ]);
    }
  }
}
