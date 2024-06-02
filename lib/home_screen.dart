
import 'package:firebase_editor_gsoc/views/circle_widget.dart';
import 'package:firebase_editor_gsoc/views/custom_drawer.dart';
import 'package:firebase_editor_gsoc/views/define_schema.dart';
import 'package:flutter/material.dart';
import 'user_profile.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: CustomDrawer(),
      appBar: AppBar(
        title: Text('Home'),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [

            Icon(Icons.handyman),
            Text("Under Developement",
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                color: Colors.grey,
                fontSize: 30.0
              )
              ,)
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => UserProfile(),
            //       ),
            //     );
            //   },
            //   child: Text('Go to User Profile'),
            // ),
            //
            // ElevatedButton(
            //   onPressed: () {
            //     Navigator.push(
            //       context,
            //       MaterialPageRoute(
            //         builder: (context) => DefineSchema(),
            //       ),
            //     );
            //   },
            //   child: Text('Go to Define Schema'),
            // ),
          ],
        ),
      ),
    );
  }
}
