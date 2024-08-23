import 'package:firebase_editor_gsoc/controllers/user_controller.dart';
import 'package:firebase_editor_gsoc/views/list_projects.dart';
import 'package:firebase_editor_gsoc/views/user_edit_history.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// The UserProfileView widget displays the user's profile information and provides options to view projects,
/// switch accounts, and view edit history.
class UserProfileView extends StatelessWidget {
  UserProfileView({super.key});

  // Instantiate UserController using GetX for state management
  final userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'), // Title of the AppBar
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0), // Padding around the body content
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row to display user's profile picture and basic information
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(userController.user!.photoURL ??
                      ""), // User's profile picture
                ),
                const SizedBox(width: 16.0),
                // Column to display user's name and email
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userController.user!.displayName ??
                          "", // User's display name
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userController.user!.email ?? "", // User's email
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey[
                            600], // Slightly grey color for the email text
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(
                height:
                    24.0), // Space between the profile info and the next section
            const Text(
              'What are you looking for?', // Section header
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
                height: 8.0), // Space between the header and the list
            Expanded(
              // Column for the list of options available in the user profile
              child: Column(
                children: [
                  // ListTile for navigating to the user's projects
                  ListTile(
                    leading: const Icon(
                        Icons.storage_rounded), // Icon representing projects
                    title: const Text('Your Projects'), // Option title
                    onTap: () {
                      // Navigate to ProjectsPage when tapped
                      Get.to(const ProjectsPage());
                    },
                  ),
                  const Divider(), // Divider between options

                  // ListTile for switching accounts
                  ListTile(
                    leading: const Icon(Icons
                        .account_circle_rounded), // Icon representing account switch
                    title: const Text('Switch Accounts'), // Option title
                    onTap: () {
                      userController
                          .handleLogout(); // Logout the user when tapped
                    },
                  ),
                  const Divider(), // Divider between options

                  // ListTile for viewing the edit history
                  ListTile(
                    leading: const Icon(
                        Icons.history_rounded), // Icon representing history
                    title: const Text('Edit History'), // Option title
                    onTap: () {
                      // Navigate to HistoryPage when tapped
                    Get.to(HistoryPage());
                    },
                  ),
                  const Divider(), // Divider at the end
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
