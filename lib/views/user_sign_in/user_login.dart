import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_editor_gsoc/controllers/access_controller.dart';
import 'package:firebase_editor_gsoc/controllers/token_controller.dart';
import 'package:firebase_editor_gsoc/views/home/home_screen.dart';
import 'package:firebase_editor_gsoc/utils/utils.dart';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:http/http.dart' as http;
import 'package:glassmorphism/glassmorphism.dart';

import '../../controllers/user_controller.dart';

/// The LoginScreen widget is responsible for handling user authentication using Google Sign-In.
class LoginScreen extends StatefulWidget {
  LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

/// The state class for LoginScreen where the main logic for Google Sign-In is implemented.
class _LoginScreenState extends State<LoginScreen> {
  // Controllers for managing access tokens and user data.
  final accessController = Get.put(AccessController());
  final userController = Get.put(UserController()); // Initialize UserController
  final tokenController = Get.put(TokenController());

  User? _user; // Holds the currently signed-in user
  bool _isSigningIn =
  false; // Indicates whether the user is currently signing in

  /// This method is called when the widget is first created.
  @override
  void initState() {
    super.initState();
    // Listen for authentication state changes and update the user accordingly.
    userController.auth.authStateChanges().listen((event) {
      setState(() {
        userController.user = event;
        _user = event;
      });
    });
  }

  /// The build method defines the UI of the LoginScreen.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue, // Background color of the screen
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GlassmorphicContainer(
            width: double.infinity,
            height: 600,
            borderRadius: 20,
            blur: 20,
            alignment: Alignment.center,
            border: 2,
            linearGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
              stops: [0.1, 1],
            ),
            borderGradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.5),
                Colors.white.withOpacity(0.5),
              ],
            ),
            // Display user information if signed in, otherwise show the Google Sign-In button
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: userController.user != null
                  ? _userInfo() // If user is signed in, display user information
                  : _googleSignInButton(), // Otherwise, display Google Sign-In button
            ),
          ),
        ),
      ),
    );
  }

  /// This widget displays the Google Sign-In button and handles the sign-in process.
  Widget _googleSignInButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // Application title
        Column(
          children: [
            Text(
              'Firebase',
              style: Theme.of(context).textTheme.displayLarge,
            ),
            Stack(
              children: [
                Container(
                  height: 70,
                  width: 200,
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(1.0),
                    shape: BoxShape.rectangle,
                    borderRadius: BorderRadius.circular(40),
                  ),
                ),
                Positioned.fill(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Editor',
                      style: Theme.of(context).textTheme.displayLarge,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        const Spacer(), // Pushes the content below to the center
        // Google Sign-In button and sign-in status
        Column(
          children: [
            const Text(
              "Sign in to your Firebase Account!",
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 18.0,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20.0),
            // Show a loading indicator if signing in, otherwise show the Google Sign-In button
            if (_isSigningIn)
              const Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20.0),
                  Text(
                    "Signing in...",
                    style: TextStyle(color: Colors.white, fontSize: 18.0),
                  ),
                ],
              )
            else
              SizedBox(
                height: 45,
                child: SignInButton(
                  Buttons.google,
                  text: "Sign in With Google",
                  onPressed: _handleGoogleSignIn, // Handle Google Sign-In
                ),
              ),
          ],
        ),
        const Spacer(), // Pushes the content above to the center
        // Footer with developer credits
        const Padding(
          padding: EdgeInsets.only(bottom: 20.0),
          child: Text(
            "By CCExtractor Development",
            style: TextStyle(color: Colors.white, fontSize: 18.0),
          ),
        ),
      ],
    );
  }

  /// This widget displays user information after successful sign-in.
  Widget _userInfo() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Welcome!",
          style: TextStyle(
            fontSize: 45.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          "${userController.user!.displayName}",
          style: const TextStyle(
            fontSize: 25.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20.0),
        // Display user profile picture
        Container(
          height: 150,
          width: 150,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.amber, width: 3),
          ),
          child: ClipOval(
            child: Image.network(
              userController.user!.photoURL!,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Divider(height: 12.0, color: Colors.amber),
        const SizedBox(height: 20),
        // Display user details (Username and Email)
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.amber, width: 2.0),
                  color: Colors.white),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Username: ${userController.user!.displayName}",
                  style: const TextStyle(fontSize: 14.0, color: Colors.black87),
                ),
              ),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10.0),
                  border: Border.all(color: Colors.amber, width: 2.0),
                  color: Colors.white),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Text(
                  "Email Id: ${userController.user!.email!}",
                  style: const TextStyle(fontSize: 14.0, color: Colors.black87),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 40),
        // Buttons to navigate to Home screen or sign out
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                Get.offAll(const HomeScreen());
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize
                    .min, // Adjusts the size of the row to the content
                children: [
                  Icon(Icons.home, color: Colors.black), // Home icon
                  SizedBox(width: 8.0), // Space between the icon and the text
                  Text("Home", style: TextStyle(color: Colors.black)),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                userController.handleLogout(); // Handle logout
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize
                    .min, // Adjusts the size of the row to the content
                children: [
                  Icon(Icons.logout, color: Colors.black), // Logout icon
                  SizedBox(width: 8.0), // Space between the icon and the text
                  Text("Logout", style: TextStyle(color: Colors.black)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Handles Google Sign-In process and authentication.
  void _handleGoogleSignIn() async {
    setState(() {
      _isSigningIn = true; // Start loading
    });

    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
        'https://www.googleapis.com/auth/cloud-platform',
        'https://www.googleapis.com/auth/datastore',
        'https://www.googleapis.com/auth/firebase.messaging'
      ]);

      await googleSignIn.signOut(); // Ensure previous account is signed out

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        _logSignInCancel(); // Custom method to log cancellation
        setState(() {
          _isSigningIn = false; // Stop loading
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth =
      await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with Google credentials
      final UserCredential userCredential =
      await userController.auth.signInWithCredential(credential);

      final String? googleAccessToken = googleAuth.accessToken;

      await tokenController.saveTokenData('accessToken', googleAccessToken!);

    } catch (error, stacktrace) {
      // Improved error handling
      _logSignInError(error, stacktrace);
      showToast("Error during Google sign-in: $error");
    } finally {
      setState(() {
        _isSigningIn = false; // Stop loading
      });
    }
  }

  void _logSignInCancel() {
    print("User canceled the Google sign-in process.");
  }

  void _logSignInError(dynamic error, StackTrace stacktrace) {
    print("Error during Google sign-in: $error");
    print("Stacktrace: $stacktrace");
  }


  /// Validates the Google access token by sending a request to Google's OAuth2 API.
  Future<bool> isTokenValid(String accessToken) async {
    final String url =
        'https://oauth2.googleapis.com/tokeninfo?access_token=$accessToken';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> tokenInfo = json.decode(response.body);
        print('Token Info: $tokenInfo');
        return true; // Return true if the token is valid
      } else {
        print('Invalid token. Status Code: ${response.statusCode}');
        return false; // Return false if the token is invalid
      }
    } catch (error) {
      print('Error validating token: $error'); // Log any errors
      return false;
    }
  }
}