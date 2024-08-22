import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_editor_gsoc/controllers/controllers.dart';
import 'package:firebase_editor_gsoc/controllers/token_controller.dart';
import 'package:firebase_editor_gsoc/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:http/http.dart' as http;
import 'package:glassmorphism/glassmorphism.dart';

import 'controllers/user_controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final accessController = Get.put(AccessController());
  final userController = Get.put(UserController()); // Initialize UserController
  final tokenController = Get.put(TokenController());

  // final FirebaseAuth _auth = FirebaseAuth.instance;
  final String googleAccessToken = "";
  User? _user;
  bool _isSigningIn = false;

  @override
  void initState() {
    super.initState();
    userController.auth.authStateChanges().listen((event) {
      setState(() {
        userController.user = event;
        _user = event;
      });
    });
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       title: userController.user != null
  //           ? const Text("Firebase Editor")
  //           : const Text("Login"),
  //     ),
  //     backgroundColor: Colors.amber,
  //     body: userController.user != null ? _userInfo() : _googleSignInButton(),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
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
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: userController.user != null
                  ? _userInfo()
                  : _googleSignInButton(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _googleSignInButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
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
        Spacer(), // Pushes the content below to the center
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
                  onPressed: _handleGoogleSignIn,
                ),
              ),
          ],
        ),
        Spacer(), // Pushes the content above to the center
        Padding(
          padding: const EdgeInsets.only(bottom: 20.0),
          child: Text(
            "By: CCExtractor Development",
            style: TextStyle(color: Colors.white, fontSize: 18.0),
          ),
        ),
      ],
    );
  }



  Widget _userInfo() {
    return Column(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Welcome!",
          style: const TextStyle(
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
        Divider(height: 12.0, color: Colors.amber),
        const SizedBox(height: 20),
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(color: Colors.amber, width: 2.0),
                color: Colors.white
              ),
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
                  color: Colors.white
              ),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomeScreen(),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child:  const Row(
                mainAxisSize: MainAxisSize.min, // Adjusts the size of the row to the content
                children: [
                  Icon(Icons.home, color: Colors.black), // Choose your preferred icon and color
                  SizedBox(width: 8.0), // Adds some space between the icon and the text
                  Text(
                    "Home",
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () {
                userController.handleLogout();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min, // Adjusts the size of the row to the content
                children: [
                  Icon(Icons.logout, color: Colors.black), // Choose your preferred icon and color
                  SizedBox(width: 8.0), // Adds some space between the icon and the text
                  Text(
                    "Logout",
                    style: TextStyle(color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

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

      final UserCredential userCredential =
          await userController.auth.signInWithCredential(credential);
      final String? googleAccessToken = googleAuth.accessToken;

      await tokenController.saveTokenData('accessToken', googleAccessToken!);

      print('Google Access Token: $googleAccessToken');
      if (await isTokenValid(googleAccessToken)) {
        print('Token is valid');
      } else {
        print('Invalid access token');
      }
    } catch (error) {
      print('Error during Google sign-in: $error');
    } finally {
      setState(() {
        _isSigningIn = false; // Stop loading
      });
    }
  }

  Future<bool> isTokenValid(String accessToken) async {
    final String url =
        'https://oauth2.googleapis.com/tokeninfo?access_token=$accessToken';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final Map<String, dynamic> tokenInfo = json.decode(response.body);
        print('Token Info: $tokenInfo');
        return true; // You can add additional checks here if needed
      } else {
        print('Invalid token. Status Code: ${response.statusCode}');
        return false;
      }
    } catch (error) {
      print('Error validating token: $error');
      return false;
    }
  }
}
