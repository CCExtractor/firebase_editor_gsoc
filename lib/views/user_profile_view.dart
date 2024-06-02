import 'package:flutter/material.dart';
import '../models/user.dart';


class UserProfileView extends StatelessWidget {
  final User user;

  UserProfileView({required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Profile'),
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
                  backgroundImage: NetworkImage(user.imageUrl),
                ),
                SizedBox(width: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 24.0),
            Text(
              'What are you looking for?',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.0),
            Expanded(
              child: Column(
                children: [
                  ListTile(
                    leading: Icon(Icons.storage_rounded),
                    title: Text('Your Databases'),
                    onTap: () {
                      // Handle tap
                      print('Service 1 tapped');
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.format_align_center_rounded),
                    title: Text('Your Schemas'),
                    onTap: () {
                      // Handle tap
                      print('Service 2 tapped');
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.history_rounded),
                    title: Text('Edit History'),
                    onTap: () {
                      // Handle tap
                      print('Service 3 tapped');
                    },
                  ),
                  ListTile(
                    leading: Icon(Icons.logout),
                    title: Text('Logout'),
                    onTap: () {
                      // Handle tap
                      print('Service 4 tapped');
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
