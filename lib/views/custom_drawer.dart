import 'package:firebase_editor_gsoc/home_screen.dart';
import 'package:firebase_editor_gsoc/views/define_schema.dart';
import 'package:firebase_editor_gsoc/views/list_projects.dart';
import 'package:firebase_editor_gsoc/views/list_schemas.dart';
import 'package:flutter/material.dart';

import '../user_profile.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          const DrawerHeader(
            decoration: BoxDecoration(
              color: Colors.amber,
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
                      backgroundImage: NetworkImage('https://i.pinimg.com/564x/be/45/87/be45870b11faa9d507a7e9eeb557bc28.jpg'), // User image URL
                    ),
                  ],
                ),

                SizedBox(width: 20.0,),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'John Doe', // User name
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      'john.doe@example.com', // User email
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.format_align_center_outlined),
            title: const Text('New Schema'),
            onTap: () {
              // Handle tap
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DefineSchema(),
                ),
              );
            },
          ),
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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.format_align_left_rounded),
            title: const Text('Your Schemas'),
            onTap: () {
              // Handle tap
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>const SchemaList(),
                ),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Settings'),
            onTap: () {
              // Handle tap
              Navigator.pop(context); // Close the drawer
              // Navigate to settings screen or perform any other action
            },
          ),
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
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const DefineSchema(),
                ),
              );
            },
          ),
        ],
      ),

    );
  }
}
