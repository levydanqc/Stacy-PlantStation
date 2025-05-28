// screens/home_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// import 'package:smooth_page_indicator/smooth_page_indicator.dart';
// import 'package:plant_monitor_app/services/auth_service.dart';
// import 'package:plant_monitor_app/api_manager.dart';
import 'package:stacy_frontend/src/models/plant.dart';
import 'package:stacy_frontend/src/services/logger.dart';
import 'package:stacy_frontend/src/utilities/manager/api_manager.dart';
import 'package:stacy_frontend/src/utilities/manager/storage_manager.dart';
import 'package:stacy_frontend/src/views/welcome/welcome_view.dart';

class HomeView extends StatefulWidget {
  static const String routeName = '/home';
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  late Future<List<Plant>> _plantsFuture;
  final PageController _pageController = PageController();
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _plantsFuture = ApiManager.getUserPlants();
    _pageController.addListener(() {
      setState(() {
        _currentPage = _pageController.page!.round();
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
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, color: Colors.grey.shade800),
          onPressed: () {
            // TODO: Open a drawer or side menu
            log.info('Menu button pressed');
          },
        ),
        title: Text(
          'YOUR PLANTS',
          style: TextStyle(
            color: Colors.grey.shade800,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none, color: Colors.grey.shade800),
            onPressed: () {
              // TODO: Navigate to notifications
              log.info('Notifications button pressed');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey),
            onPressed: () async {
              await StorageManager().logout();
              GoRouter.of(context).go(WelcomeView.routeName);
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Plant>>(
        future: _plantsFuture,
        builder: (context, snapshot) {
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
            // No plants in the database
            return _buildNoPlantsView(context);
          } else {
            // Plants exist, display them
            final plants = snapshot.data!;
            return _buildPlantsDisplayView(context, plants);
          }
        },
      ),
      // Optional: A persistent bottom navigation bar if you need one
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.teal.shade600,
        unselectedItemColor: Colors.grey,
        currentIndex: 0,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
        onTap: (index) {
          // Handle tab changes here
          log.info('Bottom nav tab $index pressed');
          // Example for Dashboard button, based on provided UI
          if (index == 1) {
            // Assuming Dashboard is index 1
            // GoRouter.of(context).push('/dashboard'); // Navigate to dashboard
          }
        },
      ),
    );
  }

  Widget _buildNoPlantsView(BuildContext context) {
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

  Widget _buildPlantsDisplayView(BuildContext context, List<Plant> plants) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
          child: Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              width: 150, // Adjust width as needed
              height: 45,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Navigate to 'Add New Plant' screen
                  log.info('Add new pot button pressed');
                  // GoRouter.of(context).push('/add_new_plant');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal.shade600,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
                icon: const Icon(Icons.add, color: Colors.white),
                label: const Text(
                  'Add new pot',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: plants.length,
            itemBuilder: (context, index) {
              return _PlantCard(
                  plant: plants[index]); // Custom Plant Card Widget
            },
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            'Swipe to view your plants',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        // Center(
        //   child: SmoothPageIndicator(
        //     controller: _pageController,
        //     count: plants.length,
        //     effect: ExpandingDotsEffect(
        //       activeDotColor: Colors.teal.shade600,
        //       dotColor: Colors.grey.shade300,
        //       dotHeight: 8,
        //       dotWidth: 8,
        //       expansionFactor: 3, // Make the active dot bigger
        //     ),
        //   ),
        // ),
        const SizedBox(height: 20),
      ],
    );
  }
}

// Custom Widget for a single Plant Card, inspired by the UI
class _PlantCard extends StatelessWidget {
  final Plant plant;
  const _PlantCard({required this.plant});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to Plant Detail Screen
        log.info('Plant ${plant.plantName} tapped');
        // GoRouter.of(context).push('/plant_detail/${plant.id}');
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10),
        padding: const EdgeInsets.all(15.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade200,
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // ClipRRect(
                //   borderRadius: BorderRadius.circular(15),
                //   child: Image.asset(
                //     plant.imageUrl,
                //     width: 100,
                //     height: 100,
                //     fit: BoxFit.cover,
                //   ),
                // ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            plant.plantName,
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.teal.shade800,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Icon(
                          //   plant.healthPercentage > 70
                          //       ? Icons.check_circle_rounded
                          //       : Icons.warning_rounded,
                          //   color: plant.healthPercentage > 70
                          //       ? Colors.green
                          //       : Colors.amber,
                          //   size: 20,
                          // ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      // Text(
                      //   plant.scientificName,
                      //   style: TextStyle(
                      //     fontSize: 16,
                      //     color: Colors.grey.shade600,
                      //   ),
                      // ),
                      // const SizedBox(height: 15),
                      // _buildProgressBar(
                      //   label: 'Health',
                      //   value: plant.healthPercentage,
                      //   color: Colors.green.shade400,
                      // ),
                      // const SizedBox(height: 10),
                      // _buildProgressBar(
                      //   label: 'Water',
                      //   value: plant.wateringLevel,
                      //   color: Colors.blue.shade400,
                      // ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                // Three dots icon for more options, similar to UI
                Align(
                  alignment: Alignment.topRight,
                  child: IconButton(
                    icon: Icon(Icons.more_vert, color: Colors.grey.shade500),
                    onPressed: () {
                      log.info('More options for ${plant.plantName}');
                      // TODO: Show options menu
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            // Plant Indicators section, inspired by detail view
            Text(
              'PLANT\'S INDICATORS',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildIndicatorItem(Icons.thermostat, 'Temp',
                    '${plant.plantData.last.temperature}°C', Colors.red),
                _buildIndicatorItem(Icons.water_drop, 'Humidity',
                    '${plant.plantData.last.humidity}%', Colors.blue),
                // _buildIndicatorItem(Icons.light_mode, 'Light',
                //     '${plant.plantData.last.moisture}%', Colors.orange),
              ],
            ),
            const SizedBox(height: 20),
            // Watering Schedule, inspired by detail view
            Text(
              'WATERING SCHEDULE',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 10),
            _buildWateringSchedule(),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar({
    required String label,
    required int value,
    required Color color,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 60, // Fixed width for label
          child: Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: LinearProgressIndicator(
            value: value / 100,
            backgroundColor: color.withOpacity(0.2),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius:
                BorderRadius.circular(10), // Rounded corners for progress bar
            minHeight: 8,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          '$value%',
          style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
        ),
      ],
    );
  }

  Widget _buildIndicatorItem(
      IconData icon, String label, String value, Color iconColor) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 30),
        const SizedBox(height: 5),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
        Text(
          value,
          style: TextStyle(
              color: Colors.grey.shade800,
              fontWeight: FontWeight.bold,
              fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildWateringSchedule() {
    // This is a simplified representation based on the UI.
    // In a real app, this would be dynamic based on plant's actual schedule.
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildDayCircle('M', false),
        _buildDayCircle('T', true), // Highlighted for today/next watering
        _buildDayCircle('W', false),
        _buildDayCircle('T', false),
        _buildDayCircle('F', false),
        _buildDayCircle('S', false),
        _buildDayCircle('S', false),
      ],
    );
  }

  Widget _buildDayCircle(String day, bool isHighlighted) {
    return Container(
      width: 35,
      height: 35,
      decoration: BoxDecoration(
        color: isHighlighted ? Colors.teal.shade200 : Colors.grey.shade100,
        shape: BoxShape.circle,
        border: Border.all(
          color: isHighlighted ? Colors.teal.shade600 : Colors.grey.shade300,
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          day,
          style: TextStyle(
            color: isHighlighted ? Colors.teal.shade800 : Colors.grey.shade600,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
