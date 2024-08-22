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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: userController.user != null
            ? const Text("Firebase Editor")
            : const Text("Login"),
      ),
      backgroundColor: Colors.amber,
      body: userController.user != null ? _userInfo() : _googleSignInButton(),
    );
  }

  // Widget _googleSignInButton() {
  //   return Center(
  //     child: Column(
  //       mainAxisAlignment: MainAxisAlignment.center,
  //       children: [
  //         const Text(
  //           "Sign in to your Firebase Account!",
  //           style: TextStyle(
  //               color: Colors.white,
  //               fontWeight: FontWeight.bold,
  //               fontSize: 20.0),
  //         ),
  //         const SizedBox(
  //           height: 20.0,
  //         ),
  //         SizedBox(
  //           height: 35,
  //           child: SignInButton(
  //             Buttons.google,
  //             text: "Sign in With Google",
  //             onPressed: () {
  //               // _showButtonPressDialog(context, 'Google');
  //               _handleGoogleSignIn();
  //             },
  //           ),
  //         ),
  //       ],
  //     ),
  //   );
  // }
  Widget _googleSignInButton() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Sign in to your Firebase Account!",
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20.0),
          ),
          const SizedBox(
            height: 20.0,
          ),
          if (_isSigningIn)
            Column(
              children: [
                const CircularProgressIndicator(), // Show CircularProgressIndicator
                const SizedBox(height: 20.0),
                const Text(
                  "Signing in...",
                  style: TextStyle(color: Colors.white, fontSize: 18.0),
                ),
              ],
            )
          else
            SizedBox(
              height: 35,
              child: SignInButton(
                Buttons.google,
                text: "Sign in With Google",
                onPressed: _handleGoogleSignIn,
              ),
            ),
        ],
      ),
    );
  }


  Widget _userInfo() {
    return SingleChildScrollView(
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 800.0,
        child: Padding(
          padding: const EdgeInsets.all(18.0),
          child: Column(
            children: [
              Container(
                  width: double.infinity,
                  height: 100.0,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Center(
                        child: Text(
                      "Welcome ${userController.user!.displayName}!",
                      style: const TextStyle(
                          fontSize: 30.0,
                          color: Colors.white,
                          fontWeight: FontWeight.bold),
                    )),
                  )),
              const SizedBox(
                height: 20.0,
              ),
              Center(
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10.0),
                    border: Border.all(color: Colors.grey),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 4,
                        blurRadius: 5,
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const SizedBox(
                            height: 50.0,
                          ),
                          Container(
                            height: 200,
                            width: 200,
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
                          const Divider(),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5.0),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          "Username: ${userController.user!.displayName}" ??
                                              ""),
                                    )),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(5.0),
                                      border: Border.all(color: Colors.grey),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Text(
                                          "Email Id: ${userController.user!.email!}"),
                                    )),
                              ),
                              const SizedBox(
                                height: 40.0,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const HomeScreen(),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                      ),
                                      child: const Text(
                                        "Home",
                                        style: TextStyle(color: Colors.white),
                                      )),
                                  const SizedBox(
                                    width: 30.0,
                                  ),
                                  ElevatedButton(
                                      onPressed: () {
                                        userController.handleLogout();
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.blue,
                                      ),
                                      child: const Text(
                                        "Logout",
                                        style: TextStyle(color: Colors.white),
                                      )),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // void _handleGoogleSignIn() async {
  //   try {
  //     final GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
  //       'https://www.googleapis.com/auth/cloud-platform',
  //       'https://www.googleapis.com/auth/datastore',
  //       'https://www.googleapis.com/auth/firebase.messaging'
  //     ]);
  //
  //     await googleSignIn.signOut(); // Ensure previous account is signed out
  //
  //     final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
  //     if (googleUser == null) {
  //       // The user canceled the sign-in
  //       return;
  //     }
  //
  //     final GoogleSignInAuthentication googleAuth =
  //         await googleUser.authentication;
  //     final OAuthCredential credential = GoogleAuthProvider.credential(
  //       accessToken: googleAuth.accessToken,
  //       idToken: googleAuth.idToken,
  //     );
  //
  //     final UserCredential userCredential =
  //         await userController.auth.signInWithCredential(credential);
  //     // final User user = userCredential.user!;
  //     final String? googleAccessToken = googleAuth.accessToken;
  //     // accessController.accessToken.text = googleAccessToken!;
  //
  //     // save/update google access token to database for persistence of sessions
  //     await tokenController.saveTokenData('accessToken', googleAccessToken!);
  //
  //     print('Google Access Token: $googleAccessToken');
  //     if (await isTokenValid(googleAccessToken)) {
  //       print('Token is valid');
  //       // callFirestoreAPI(googleAccessToken);
  //     } else {
  //       print('Invalid access token');
  //     }
  //   } catch (error) {
  //     print(error);
  //     print('Error during Google sign-in: $error');
  //     // Handle sign-in errors here, such as showing an alert dialog
  //     // or taking appropriate action based on the error.
  //   }
  // }

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
