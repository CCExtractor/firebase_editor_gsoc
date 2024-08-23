import 'package:firebase_editor_gsoc/API/fetch_projects.dart';
import 'package:firebase_editor_gsoc/controllers/controllers.dart';
import 'package:firebase_editor_gsoc/controllers/user_controller.dart';
import 'package:firebase_editor_gsoc/views/custom_drawer.dart';
import 'package:firebase_editor_gsoc/views/list_databases.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// ProjectsPage is a stateful widget that displays a list of Firebase projects.
/// Users can view project details and navigate to the ProjectDetailsScreen for further actions.
class ProjectsPage extends StatefulWidget {
  // Route name for notification purposes
  static const route = '/list-projects';

  const ProjectsPage({super.key});

  @override
  _ProjectsPageState createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  late Future<Map<String, dynamic>>
      _projectsFuture; // Future to hold the projects data
  final _accessController =
      Get.put(AccessController()); // GetX controller for managing access token
  final userController =
      Get.put(UserController()); // GetX controller for managing user data

  /// The initState method is called when the widget is first created.
  /// It initializes the _projectsFuture with the result of calling the Firebase Projects API.
  @override
  void initState() {
    super.initState();
    _projectsFuture =
        callFirebaseProjectsAPI(_accessController.accessToken.text);
  }

  /// The build method defines the UI of the ProjectsPage.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'), // Title of the AppBar
      ),
      drawer: CustomDrawer(), // Custom navigation drawer
      body: FutureBuilder<Map<String, dynamic>>(
        future: _projectsFuture, // The future to wait on
        builder: (context, snapshot) {
          // Show a loading indicator while the future is being resolved
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(), // Loading spinner
                  SizedBox(height: 20),
                  Text('Loading projects...'), // Loading message
                ],
              ),
            );
          } else if (snapshot.hasError) {
            // Display an error message if an error occurred
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            // If the data is available, build a list of projects
            List<dynamic> results = snapshot
                .data!['results']; // Extract the list of projects from the data
            return ListView.builder(
              itemCount: results.length, // Number of projects to display
              itemBuilder: (context, index) {
                var project = results[index]; // Get the current project
                return Container(
                  margin: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0), // Margin around each project card
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(
                        15.0), // Rounded corners for the card
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
                    title: Text(
                        "Project Name: ${project['displayName']}"), // Display the project name
                    subtitle: Text(
                        "Project Id: ${project['projectId']}"), // Display the project ID
                    trailing: ElevatedButton(
                      onPressed: () {
                        // On tap, add the project ID to the user's data if it doesn't exist
                        userController
                            .addProjectIdIfNotExists(project['projectId']);
                        // Navigate to the ProjectDetailsScreen with the selected project's details
                        Get.to(ProjectDetailsScreen(
                          projectId: project['projectId'],
                          accessToken: _accessController.accessToken.text,
                        ));
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors
                            .amber, // Set the background color of the button
                      ),
                      child: const Text('Details'), // Button text
                    ),
                  ),
                );
              },
            );
          } else {
            // Display a message if no projects are found
            return const Center(child: Text('No projects found'));
          }
        },
      ),
    );
  }
}
