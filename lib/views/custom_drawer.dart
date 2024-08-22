import 'package:firebase_editor_gsoc/controllers/user_controller.dart';
import 'package:firebase_editor_gsoc/home_screen.dart';
import 'package:firebase_editor_gsoc/views/define_schema.dart';
import 'package:firebase_editor_gsoc/views/list_projects.dart';
import 'package:firebase_editor_gsoc/views/list_schemas.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../user_profile.dart';

class CustomDrawer extends StatelessWidget {
  CustomDrawer({super.key});

  final userController = Get.put(UserController());

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.amber,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [

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

                const SizedBox(width: 20.0,),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      userController.user!.displayName ?? "", // User name
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                    Text(
                      userController.user!.email ?? "", // User email
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              // Handle tap
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const HomeScreen(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.account_circle_rounded),
            title: const Text('My Account'),
            onTap: () {
              // Handle tap
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfile(),
                ),
              );
            },
          ),
          // const Divider(),
          // ListTile(
          //   leading: const Icon(Icons.format_align_center_outlined),
          //   title: const Text('New Schema'),
          //   onTap: () {
          //     // Handle tap
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => const DefineSchema(),
          //       ),
          //     );
          //   },
          // ),
          const Divider(),
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
          // Divider(),
          // ListTile(
          //   leading: Icon(Icons.storage_rounded),
          //   title: Text('Your Databases'),
          //   onTap: () {
          //     // Handle tap
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) => ProjectDetailsScreen(),
          //       ),
          //     );
          //   },
          // ),
          // const Divider(),
          // ListTile(
          //   leading: const Icon(Icons.format_align_left_rounded),
          //   title: const Text('Your Schemas'),
          //   onTap: () {
          //     // Handle tap
          //     Navigator.push(
          //       context,
          //       MaterialPageRoute(
          //         builder: (context) =>const HomeScreen(),
          //       ),
          //     );
          //   },
          // ),
          // const Divider(),
          // ListTile(
          //   leading: const Icon(Icons.settings),
          //   title: const Text('Settings'),
          //   onTap: () {
          //     // Handle tap
          //     Navigator.pop(context); // Close the drawer
          //     // Navigate to settings screen or perform any other action
          //   },
          // ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Help'),
            onTap: () {
              // Handle tap
              Navigator.pop(context); // Close the drawer
              // Navigate to help screen or perform any other action
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout_rounded),
            title: const Text('Logout'),
            onTap: () {
              // Handle tap
                  userController.handleLogout();
            },
          ),
        ],
      ),

    );
  }
}
