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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome'),
        actions: <Widget>[
          userController.user != null
              ? IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: () {
                    userController.handleLogout();
                  },
                )
              : Container(),
        ],
      ),
      body: userController.user != null ? _userInfo() : _googleSignInButton(),
    );
  }

  Widget _googleSignInButton() {
    return Center(
      child: SizedBox(
        height: 35,
        child: SignInButton(
          Buttons.google,
          text: "Sign in With Google",
          onPressed: () {
            // _showButtonPressDialog(context, 'Google');
            _handleGoogleSignIn();
          },
        ),
      ),
    );
  }

  Widget _userInfo() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 800.0,
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [

            Text("Welcome to Firebase Editor", style: TextStyle(fontSize: 24.0),),
            Divider(),

            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Container(
                    height: 100,
                    width: 100,
                    child: ClipOval(
                      child: Image.network(
                        userController.user!.photoURL!,
                        fit: BoxFit.cover,
                        width: 100.0,
                        height: 100.0,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(userController.user!.displayName ?? ""),
                        Text(userController.user!.email!),
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
                            ),
                            child: const Text("Go to Home")),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleGoogleSignIn() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
        'https://www.googleapis.com/auth/cloud-platform',
        'https://www.googleapis.com/auth/datastore',
        'https://www.googleapis.com/auth/firebase.messaging'
      ]);

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
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
      // final User user = userCredential.user!;
      final String? googleAccessToken = googleAuth.accessToken;
      // accessController.accessToken.text = googleAccessToken!;

      // save/update google access token to database for persistence of sessions
      await tokenController.saveTokenData('accessToken', googleAccessToken!);

      print('Google Access Token: $googleAccessToken');
      if (await isTokenValid(googleAccessToken)) {
        print('Token is valid');
        // callFirestoreAPI(googleAccessToken);
      } else {
        print('Invalid access token');
      }
    } catch (error) {
      print(error);
      print('Error during Google sign-in: $error');
      // Handle sign-in errors here, such as showing an alert dialog
      // or taking appropriate action based on the error.
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
