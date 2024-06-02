import 'package:firebase_editor_gsoc/home_screen.dart';
import 'package:firebase_editor_gsoc/views/database_overview.dart';
import 'package:firebase_editor_gsoc/views/define_schema.dart';
import 'package:firebase_editor_gsoc/views/list_databases.dart';
import 'package:firebase_editor_gsoc/views/list_schemas.dart';
import 'package:flutter/material.dart';

import '../user_profile.dart';

class CustomDrawer extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
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
            leading: Icon(Icons.home),
            title: Text('Home'),
            onTap: () {
              // Handle tap
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeScreen(),
                ),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.account_circle_rounded),
            title: Text('My Account'),
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
          Divider(),
          ListTile(
            leading: Icon(Icons.format_align_center_outlined),
            title: Text('New Schema'),
            onTap: () {
              // Handle tap
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DefineSchema(),
                ),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.storage_rounded),
            title: Text('Your Databases'),
            onTap: () {
              // Handle tap
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DatabaseList(),
                ),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.format_align_left_rounded),
            title: Text('Your Schemas'),
            onTap: () {
              // Handle tap
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>SchemaList(),
                ),
              );
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              // Handle tap
              Navigator.pop(context); // Close the drawer
              // Navigate to settings screen or perform any other action
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.help),
            title: Text('Help'),
            onTap: () {
              // Handle tap
              Navigator.pop(context); // Close the drawer
              // Navigate to help screen or perform any other action
            },
          ),
          Divider(),
          ListTile(
            leading: Icon(Icons.logout_rounded),
            title: Text('Logout'),
            onTap: () {
              // Handle tap
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DefineSchema(),
                ),
              );
            },
          ),
        ],
      ),

    );
  }
}
