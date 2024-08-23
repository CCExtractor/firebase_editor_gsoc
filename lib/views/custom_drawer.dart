import 'package:firebase_editor_gsoc/controllers/user_controller.dart';
import 'package:firebase_editor_gsoc/home_screen.dart';
import 'package:firebase_editor_gsoc/views/help.dart';
import 'package:firebase_editor_gsoc/views/list_projects.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../user_profile.dart';

/// A custom drawer widget that provides easy navigation to different screens
/// within the application. It displays the user's profile information and offers
/// quick access to the home screen, user profile, projects, help, and logout functionality.
class CustomDrawer extends StatelessWidget {
  CustomDrawer({super.key});

  // Instantiating the UserController to access the user's information.
  final userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          /// The header section of the drawer displaying the user's profile picture, name, and email.
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.amber,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // User's profile picture.
                Container(
                  height: 80,
                  width: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blue, width: 3),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      userController.user!.photoURL!,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(
                  width: 20.0,
                ),
                // User's name and email.
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userController.user!.displayName ??
                          "", // User's display name
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 20.0,
                          fontWeight: FontWeight.bold),
                    ),
                    Text(
                      userController.user!.email ?? "", // User's email
                      style: const TextStyle(
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ],
            ),
          ),

          /// ListTile for Home navigation.
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              // Navigate to the home screen.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
              );
            },
          ),
          const Divider(),

          /// ListTile for navigating to the user's account page.
          ListTile(
            leading: const Icon(Icons.account_circle_rounded),
            title: const Text('My Account'),
            onTap: () {
              // Navigate to the user profile screen.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfile(),
                ),
              );
            },
          ),
          const Divider(),

          /// ListTile for navigating to the projects page.
          ListTile(
            leading: const Icon(Icons.storage_rounded),
            title: const Text('Your Projects'),
            onTap: () {
              // Navigate to the projects screen.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ProjectsPage(),
                ),
              );
            },
          ),
          const Divider(),

          /// ListTile for navigating to the help page.
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help'),
            onTap: () {
              // Navigate to the help page using GetX navigation.
              Get.to(const HelpPage());
            },
          ),
          const Divider(),

          /// ListTile for logging out the user.
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Logout'),
            onTap: () {
              // Handle logout and navigate to the login screen.
              userController.handleLogout();
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}
