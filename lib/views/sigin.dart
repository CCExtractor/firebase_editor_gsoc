import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_editor_gsoc/home_screen.dart';



class SignInScreen extends StatelessWidget {
  final GoogleSignIn googleSignIn = GoogleSignIn();

  void _handleSignIn(BuildContext context) async {
    try {
      print("IN SIGN IN METHOD");
      await googleSignIn.signIn();
      // Navigate to the next screen or perform other actions after successful sign-in
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (error) {
      print('Error signing in with Google: $error');
      // Handle sign-in error
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Sign In'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () => _handleSignIn(context),
          child: Text('Sign in with Google'),
        ),
      ),
    );
  }
}