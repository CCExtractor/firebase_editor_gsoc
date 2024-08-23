import 'package:firebase_editor_gsoc/API/fetch_databases.dart';
import 'package:firebase_editor_gsoc/views/custom_drawer.dart';
import 'package:firebase_editor_gsoc/views/user_collections.dart';
import 'package:flutter/material.dart';

/// ProjectDetailsScreen is a stateful widget that displays details about a specific
/// Firebase project, including its associated databases. Users can view and interact
/// with the details, such as navigating to the collections associated with the project.
class ProjectDetailsScreen extends StatefulWidget {
  final String projectId; // The ID of the Firebase project
  final String accessToken; // The access token for API requests

  const ProjectDetailsScreen(
      {super.key, required this.projectId, required this.accessToken});

  @override
  _ProjectDetailsScreenState createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  bool _isLoading = true; // Loading state flag
  Map<String, dynamic>? _databaseInfo; // Holds the fetched database information
  late String _error; // Error message in case of failure

  /// The initState method is called when the widget is first created.
  /// It initializes the process of fetching the database information.
  @override
  void initState() {
    super.initState();
    _fetchDatabaseInfo(); // Fetch the database information on initialization
  }

  /// Fetches the database information using the provided project ID and access token.
  /// Sets the loading state and handles success or failure.
  void _fetchDatabaseInfo() async {
    setState(() {
      _isLoading = true; // Set loading state to true
    });

    try {
      // Call the API to fetch the database information
      Map<String, dynamic> response =
          await fetchDatabaseInfo(context, widget.projectId, widget.accessToken);

      setState(() {
        _databaseInfo = response; // Store the fetched database info
        _isLoading = false; // Set loading state to false
      });
    } catch (error) {
      setState(() {
        _error =
            'Error fetching database info: $error'; // Store the error message
        _isLoading = false; // Set loading state to false
      });
    }
  }

  /// The build method defines the UI of the ProjectDetailsScreen.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Database Details'), // Title of the AppBar
      ),
      drawer: CustomDrawer(), // Custom navigation drawer
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(), // Loading spinner
                  SizedBox(height: 20),
                  Text('Fetching your databases...'), // Loading message
                ],
              ),
            )
          : _databaseInfo != null
              ? ListView(
                  children: [
                    Container(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                          vertical: 8.0), // Margin around the container
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                            15.0), // Rounded corners for the container
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.5), // Shadow color
                            spreadRadius: 2,
                            blurRadius: 5,
                            offset: const Offset(0, 3), // Position of shadow
                          ),
                        ],
                      ),
                      child: ListTile(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Display the name of the database
                            Text('Name: ${_databaseInfo!['displayName']}'),
                            const SizedBox(
                                height: 4), // Space between text elements
                            // Display the creation time of the database
                            Text(
                                'Created Time: ${_databaseInfo!['formattedCreateTime']}'),
                            // Display the last updated time of the database
                            Text(
                                'Updated Time: ${_databaseInfo!['formattedUpdateTime']}'),

                            // Button to view the collections within the database
                            ElevatedButton(
                              onPressed: () {
                                // Navigate to the UserCollectionsPage when the button is pressed
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UserCollectionsPage(
                                            projectId: widget.projectId,
                                            displayName:
                                                _databaseInfo!['displayName'],
                                            accessToken: widget.accessToken,
                                          )),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors
                                    .amber, // Set the background color of the button
                              ),
                              child: const Text(
                                'View Collections',
                                style: TextStyle(
                                    fontSize: 14.0), // Button text size
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Additional ListTile widgets can be added here for other fields if needed
                  ],
                )
              : Center(
                  // Display an error message if there is an error or no data
                  child: Text(_error.isNotEmpty
                      ? _error
                      : 'No database information found.'),
                ),
    );
  }
}
