import 'package:firebase_editor_gsoc/controllers/access_controller.dart';
import 'package:firebase_editor_gsoc/controllers/data_visualization.dart';
import 'package:firebase_editor_gsoc/controllers/history_controller.dart';
import 'package:firebase_editor_gsoc/controllers/notification_services.dart';
import 'package:firebase_editor_gsoc/controllers/recent_entries.dart';
import 'package:firebase_editor_gsoc/controllers/token_controller.dart';
import 'package:firebase_editor_gsoc/controllers/user_controller.dart';
import 'package:firebase_editor_gsoc/widgets/custom_drawer.dart';
import 'package:firebase_editor_gsoc/views/home/help.dart';
import 'package:firebase_editor_gsoc/views/projects/list_projects.dart';
import 'package:firebase_editor_gsoc/views/user_profile/user_profile_view.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Import the intl package for date formatting

/// The HomeScreen widget is the main screen of the application.
/// It displays user information, recent entries, and a bar chart of operations analysis.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// The state class for HomeScreen where the main logic is implemented.
class _HomeScreenState extends State<HomeScreen> {
  // Controllers for managing user data, access tokens, and notifications
  final userController = Get.put(UserController());
  final accessController = Get.put(AccessController());
  final tokenController = Get.put(TokenController());

  // Service classes for handling notifications, data visualization, and recent entries
  NotificationServices notificationServices = NotificationServices();
  final DataVisualizationService _dataVisualizationService = DataVisualizationService();
  RecentEntryService recentEntryService = RecentEntryService();

  // Variables to hold chart data and recent entries
  Map<String, int> _chartData = {};
  List<Map<String, dynamic>> _recentEntries = [];

  /// This method loads the chart data from Firebase and processes it for display.
  Future<void> _loadData() async {
    List<Map<String, dynamic>> firebaseData = await _dataVisualizationService.fetchFilteredData();
    setState(() {
      _chartData = processDataForChart(firebaseData);
    });
  }

  /// This method loads the recent entries data from Firebase.
  Future<void> _loadRecentEntries() async {
    List<Map<String, dynamic>> recentEntries = await recentEntryService.fetchRecentEntries();
    setState(() {
      _recentEntries = recentEntries;
    });
  }

  /// This method is called when the widget is first created.
  @override
  void initState() {
    super.initState();

    // Request notification permission and set up notifications
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    notificationServices.setUpInteractMessage(context);
    // notificationServices.isTokenRefresh(); // Commented out, can be used if needed

    // Fetch access token for sending notifications
    tokenController.fetchAccessTokenData();

    // Create a history array for the user if it doesn't exist
    createHistoryArrayIfNotExists();

    // Load chart data and recent entries
    _loadData();
    _loadRecentEntries();

    // Store the device token for notifications
    userController.storeDeviceToken();
  }

  /// Utility method to format date and time strings.
  String formatDateTime(String dateTimeStr) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
    } catch (e) {
      return 'Error';
    }
  }

  /// The build method defines the UI of the HomeScreen.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
      ),
      drawer: CustomDrawer(), // Custom navigation drawer
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // Container displaying user profile information
              Container(
                width: double.infinity,
                height: 150.0,
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.blueAccent,
                  borderRadius: BorderRadius.circular(15.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3), // Shadow positioning
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // User profile picture
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 70,
                          width: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.amber, width: 3),
                          ),
                          child: ClipOval(
                            child: Image.network(
                              userController.user!.photoURL!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      width: 20.0,
                    ),
                    // User display name and email
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "You are currently signed in as:",
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          userController.user!.displayName ?? "", // User name
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20.0,
                              fontWeight: FontWeight.bold),
                        ),
                        Text(
                          userController.user!.email ?? "", // User email
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 16,
              ),
              // Container with quick access buttons for Projects, Profile, and Help
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.0),
                  border: Border.all(
                    color: Colors.amber, // Border color
                    width: 2.0, // Border width
                  ),
                ),
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    // Button to navigate to Projects page
                    _buildCircleButton(
                      icon: Icons.list,
                      label: 'Projects',
                      onPressed: () {
                        Get.to(const ProjectsPage());
                      },
                    ),
                    // Button to navigate to User Profile page
                    _buildCircleButton(
                      icon: Icons.account_circle_rounded,
                      label: 'Profile',
                      onPressed: () {
                        Get.to(UserProfileView());
                      },
                    ),
                    // Button to navigate to Help page
                    _buildCircleButton(
                      icon: Icons.help,
                      label: 'Help',
                      onPressed: () {
                        Get.to(const HelpPage());
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16), // Space between the two containers

              // Container displaying the Operations Analysis header
              Container(
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                width: double.infinity,
                height: 50.0,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Operations Analysis (Last 30 days)",
                    style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              const SizedBox(
                height: 20.0,
              ),
              // Bar chart displaying operations data
              Stack(
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal, // Enable horizontal scrolling
                    child: Row(
                      children: [
                        Container(
                          width: _chartData.length * 60.0 <
                              MediaQuery.of(context).size.width
                              ? MediaQuery.of(context).size.width
                              : _chartData.length * 60.0, // Dynamic width based on the number of entries
                          height: 300, // Fixed height for the chart
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(15.0),
                            border: Border.all(
                                color: Colors.blueAccent, width: 4.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: _chartData.isEmpty
                                ? const Center(
                                child: Text(
                                  "No operations data available!",
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                )) // Displayed if no chart data is available
                                : BarChart(
                              BarChartData(
                                alignment: BarChartAlignment.spaceAround,
                                maxY: _getMaxY(), // Calculate the max value for the y-axis
                                barGroups: _chartData.entries.map((entry) {
                                  return BarChartGroupData(
                                    x: entry.key.hashCode,
                                    barRods: [
                                      BarChartRodData(
                                        toY: entry.value.toDouble(),
                                        width: 15,
                                        borderRadius: BorderRadius.circular(4),
                                        rodStackItems: [],
                                        color: Colors.blueAccent,
                                      ),
                                    ],
                                  );
                                }).toList(),
                                titlesData: FlTitlesData(
                                  bottomTitles: AxisTitles(
                                    axisNameWidget: const Text(
                                      'Projects/Collections', // Title for the x-axis
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    axisNameSize: 30, // Space for the x-axis title
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      getTitlesWidget: (value, meta) {
                                        return SideTitleWidget(
                                          axisSide: meta.axisSide,
                                          child: Text(
                                            _chartData.keys.elementAt(value.toInt() %
                                                _chartData.length),
                                            style: const TextStyle(
                                                fontSize: 10),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  leftTitles: AxisTitles(
                                    axisNameWidget: const Text(
                                      'Operations Count', // Title for the y-axis
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    axisNameSize: 30, // Space for the y-axis title
                                    sideTitles: SideTitles(
                                      showTitles: true,
                                      reservedSize: 40,
                                      getTitlesWidget: (value, meta) {
                                        return SideTitleWidget(
                                          axisSide: meta.axisSide,
                                          child: Text(
                                            value.toInt().toString(),
                                            style: const TextStyle(
                                                fontSize: 10),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                  topTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                  rightTitles: const AxisTitles(
                                    sideTitles: SideTitles(showTitles: false),
                                  ),
                                ),
                                gridData: const FlGridData(show: false), // Disable grid lines
                                borderData: FlBorderData(
                                  show: true,
                                  border: Border.all(
                                      color: const Color(0xff37434d),
                                      width: 1),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 20.0,
              ),
              // Container displaying the Recently Accessed header
              Container(
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                width: double.infinity,
                height: 50.0,
                child: const Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(
                    "Recently Accessed",
                    style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
              // Display recent entries or a message if no data is available
              Container(
                padding: const EdgeInsets.all(16.0),
                child: _recentEntries.isEmpty
                    ? const Center(
                  child: Text(
                    'No data available',
                    style: TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                )
                    : Column(
                  children: List.generate(
                    _recentEntries.length,
                        (index) {
                      var entry = _recentEntries[index];
                      return Column(
                        children: [
                          _buildTextTile(
                            title: entry['projectName'] ?? 'Unknown Project',
                            subtitle: 'Database: ${entry['databaseName'] ?? 'Unknown'}\n'
                                'Collection: ${entry['collectionName'] ?? 'Unknown'}\n'
                                'Update Time: ${formatDateTime(entry['updateTime'])}',
                          ),
                          const SizedBox(height: 16),
                        ],
                      );
                    },
                  ),
                ),
              ),
              const Divider(), // Divider between sections
            ],
          ),
        ),
      ),
    );
  }

  /// Helper method to get the maximum y-value for the bar chart.
  double _getMaxY() {
    if (_chartData.isEmpty) return 1;
    return _chartData.values.reduce((a, b) => a > b ? a : b).toDouble() + 1;
  }

  /// Helper method to build circular buttons with icons and labels.
  Widget _buildCircleButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueAccent,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(height: 8), // Space between icon and text
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }

  /// Helper method to build text tiles for displaying project information.
  Widget _buildTextTile({
    required String title,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(8.0),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.blueAccent),
        // Uncomment to add shadow to the container
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.withOpacity(0.5),
        //     spreadRadius: 1,
        //     blurRadius: 5,
        //     offset: const Offset(0, 2), // Shadow positioning
        //   ),
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8), // Space between title and subtitle
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
        ],
      ),
    );
  }
}
