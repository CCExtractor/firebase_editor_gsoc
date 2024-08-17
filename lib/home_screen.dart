import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_editor_gsoc/controllers/controllers.dart';
import 'package:firebase_editor_gsoc/controllers/data_visualization.dart';
import 'package:firebase_editor_gsoc/controllers/history.dart';
import 'package:firebase_editor_gsoc/controllers/notification_services.dart';
import 'package:firebase_editor_gsoc/controllers/recent_entries.dart';
import 'package:firebase_editor_gsoc/controllers/token_controller.dart';
import 'package:firebase_editor_gsoc/controllers/user_controller.dart';
import 'package:firebase_editor_gsoc/views/custom_drawer.dart';
import 'package:firebase_editor_gsoc/views/list_projects.dart';
import 'package:firebase_editor_gsoc/views/user_profile_view.dart';
import 'package:firebase_editor_gsoc/views/utils/utils.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Import the intl package
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final userController = Get.put(UserController());

  final accessController = Get.put(AccessController());

  final tokenController = Get.put(TokenController());

  NotificationServices notificationServices = NotificationServices();

  final DataVisualizationService _dataVisualizationService =
      DataVisualizationService();

  RecentEntryService recentEntryService = RecentEntryService();
  Map<String, int> _chartData = {};
  List<Map<String, dynamic>> _recentEntries = [];

  Future<void> _loadData() async {
    List<Map<String, dynamic>> firebaseData =
        await _dataVisualizationService.fetchFilteredData();
    setState(() {
      _chartData = processDataForChart(firebaseData);
    });
  }


  Future<void> _loadRecentEntries() async {
    List<Map<String, dynamic>> recentEntries = await recentEntryService.fetchRecentEntries();
    setState(() {
      _recentEntries = recentEntries;
    });
  }

  @override
  void initState() {
    super.initState();
    notificationServices.requestNotificationPermission();
    notificationServices.firebaseInit(context);
    notificationServices.setUpInteractMessage(context);
    // notificationServices.isTokenRefresh();

    // you need access token first before sending the notification
    // fetch and set access token
    tokenController.fetchAccessTokenData();

    // create history for user
    createHistoryArrayIfNotExists();

    // notificationServices.getDeviceToken().then((value) {
    //   print("DEVICE TOKEN: ");
    //   print(value);
    //   // notificationServices.sendNotification(value, accessController.accessToken.text);
    //   // notificationServices.sendNotification(value, "hellos-bc256", "(default)", "bookings", "IfiJOChIueO65UDYPA9Z");
    // });

    _loadData();
    _loadRecentEntries();

    // call store device token fucntion
    userController.storeDeviceToken();
  }


  String formatDateTime(String dateTimeStr) {
    try {
      DateTime dateTime = DateTime.parse(dateTimeStr);
      return DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
    } catch (e) {
      print('Error parsing date: $e');
      return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
      ),
      drawer: CustomDrawer(),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: _chartData.isEmpty
              ? Center(child: CircularProgressIndicator())
              : Column(
                  children: [
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
                            offset: const Offset(
                                0, 3), // changes position of shadow
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 40,
                                backgroundImage: NetworkImage(
                                    userController.user!.photoURL ??
                                        ""), // User image URL
                              ),
                            ],
                          ),
                          const SizedBox(
                            width: 20.0,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [

                              Text("You are currently signed in as:", style: TextStyle(color: Colors.white),),
                              Text(
                                userController.user!.displayName ??
                                    "", // User name
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
                    SizedBox(
                      height: 16,
                    ),
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
                          _buildCircleButton(
                            icon: Icons.list,
                            label: 'Projects',
                            onPressed: () {
                              Get.to(ProjectsPage());
                              // Add your logic here
                            },
                          ),
                          _buildCircleButton(
                            icon: Icons.account_circle_rounded,
                            label: 'Profile',
                            onPressed: () {
                              Get.to(UserProfileView());
                              // Add your logic here
                            },
                          ),
                          _buildCircleButton(
                            icon: Icons.help,
                            label: 'Help',
                            onPressed: () {
                              showToast("coming soon");
                              // Add your logic here
                            },
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 16), // Space between the two containers

                    Container(
                      decoration: BoxDecoration(
                        color: Colors.amber,
                      ),
                      width: double.infinity,
                      height: 50.0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Operations Analysis (Last 30 days)", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
                      ),
                    ),
                    SizedBox(height: 20.0,),
                    Container(
                      width: MediaQuery.of(context).size.width *
                          0.9, // 80% of the screen width
                      height: 300, // Fixed height for the chart
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(15.0),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5),
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3), // Shadow position
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: BarChart(
                          BarChartData(
                            alignment: BarChartAlignment.spaceAround,
                            maxY: _getMaxY(),
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
                                axisNameWidget: Text(
                                  'Projects/Collections', // Title for the x-axis
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                                axisNameSize: 30, // Space for the x-axis title
                                sideTitles: SideTitles(
                                  showTitles: true,
                                  getTitlesWidget: (value, meta) {
                                    return SideTitleWidget(
                                      axisSide: meta.axisSide,
                                      child: Text(
                                        _chartData.keys.elementAt(value.toInt() % _chartData.length),
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              leftTitles: AxisTitles(
                                axisNameWidget: Text(
                                  'Operations Count', // Title for the y-axis
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
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
                                        style: TextStyle(fontSize: 10),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              topTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                              rightTitles: AxisTitles(
                                sideTitles: SideTitles(showTitles: false),
                              ),
                            ),
                            gridData: FlGridData(show: false),
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
                    SizedBox(height: 20.0,),
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.amber,
                      ),
                      width: double.infinity,
                      height: 50.0,
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text("Recently Accessed", style: TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold),),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: List.generate(
                          _recentEntries.length,
                              (index) {
                            var entry = _recentEntries[index];
                            return Column(
                              children: [
                                _buildTextTile(
                                  title: entry['projectName'] ?? 'Unknown Project',
                                  subtitle:
                                  'Database: ${entry['databaseName'] ?? 'Unknown'}\n'
                                      'Collection: ${entry['collectionName'] ?? 'Unknown'}\n'
                                      'Update Time: ${formatDateTime(entry['updateTime'])}',
                                ),
                                SizedBox(height: 16),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                    Divider(),
                  ],
                ),
        ),
      ),
    );
  }

  double _getMaxY() {
    if (_chartData.isEmpty) return 1;
    return _chartData.values.reduce((a, b) => a > b ? a : b).toDouble() + 1;
  }

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
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blueAccent,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 30,
            ),
          ),
          SizedBox(height: 8), // Space between icon and text
          Text(
            label,
            style: TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }

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
        // boxShadow: [
        //   BoxShadow(
        //     color: Colors.grey.withOpacity(0.5),
        //     spreadRadius: 1,
        //     blurRadius: 5,
        //     offset: const Offset(0, 2), // changes position of shadow
        //   ),
        // ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8), // Space between title and subtitle
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
