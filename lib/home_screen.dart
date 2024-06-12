import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';


class HomeScreen extends StatelessWidget {
  final GoogleSignIn googleSignIn = GoogleSignIn();

  void _handleSignOut(BuildContext context) async {
    try {
      await googleSignIn.signOut();
      // Navigate to the sign-in screen after signing out
      Navigator.pop(context);
    } catch (error) {
      print('Error signing out: $error');
      // Handle sign-out error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => _handleSignOut(context),
          ),
        ],
      ),
      body: Center(
        child: Text('Welcome to Home Screen'),
      ),
    );
  }
}