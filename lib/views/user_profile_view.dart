import 'package:firebase_editor_gsoc/controllers/user_controller.dart';
import 'package:firebase_editor_gsoc/views/list_projects.dart';
import 'package:firebase_editor_gsoc/views/user_edit_history.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class UserProfileView extends StatelessWidget {


 UserProfileView({super.key});
  final userController = Get.put(UserController());
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundImage: NetworkImage(userController.user!.photoURL ?? ""),
                ),
                const SizedBox(width: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userController.user!.displayName ?? "",
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      userController.user!.email ?? "",
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24.0),
            const Text(
              'What are you looking for?',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8.0),
            Expanded(
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.storage_rounded),
                    title: const Text('Your Projects'),
                    onTap: () {
                      // Handle tap
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ProjectsPage(),
                        ),
                      );

                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: const Icon(Icons.account_circle_rounded),
                    title: const Text('Switch Accounts'),
                    onTap: () {
                      userController.handleLogout();
                    },
                  ),
                  Divider(),
                  ListTile(
                    leading: const Icon(Icons.history_rounded),
                    title: const Text('Edit History'),
                    onTap: () {
                      // Handle tap
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HistoryPage(),
                        ),
                      );
                    },
                  ),
                  // Divider(),
                  // ListTile(
                  //   leading: const Icon(Icons.logout),
                  //   title: const Text('Logout'),
                  //   onTap: () {
                  //     // Handle tap
                  //     userController.handleLogout();
                  //   },
                  // ),
                  Divider(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
