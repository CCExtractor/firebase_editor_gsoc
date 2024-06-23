import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_editor_gsoc/controllers/controllers.dart';
import 'package:firebase_editor_gsoc/home_screen.dart';
import 'package:firebase_editor_gsoc/models/login.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_button/sign_in_button.dart';
import 'package:http/http.dart' as http;

import 'controllers/user_controller.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _model = LoginModel();
  final _formKey = GlobalKey<FormState>();
  final accessController = Get.put(AccessController());
  final userController = Get.put(UserController()); // Initialize UserController


  final FirebaseAuth _auth = FirebaseAuth.instance;
  final String googleAccessToken = "";

  User? _user;

  @override
  void initState(){
    super.initState();
    _auth.authStateChanges().listen((event) {
      setState(() {
        _user = event;
        // userController.user = event as Rx<User?>;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
        actions: <Widget>[
          _user != null ? IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: _handleLogout,
          ) : Container(),
        ],
      ),
      body: _user != null ? _userInfo() : _googleSignInButton(),
    );
  }

  Widget _googleSignInButton(){
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

  Widget _userInfo(){
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 800.0,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.max,
        children: [
                  Container(
                    height: 100,
                    width: 100,
                    child: Text(""),
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(_user!.photoURL!),
                      ),
                    ),
                  ),
          SizedBox(height: 20,),

          Text(_user!.email!),
          Text(_user!.displayName ?? ""),

          ElevatedButton(onPressed: () {

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(),
              ),
            );
          }, child: Text("Go to Home")),
        ],
      ),
    );
  }

  //


  // void _handleGoogleSignIn() async {
  //   try {
  //     GoogleAuthProvider googleProvider = GoogleAuthProvider();
  //     // Add the additional scopes
  //     googleProvider.addScope('https://www.googleapis.com/auth/cloud-platform');
  //     googleProvider.addScope('https://www.googleapis.com/auth/datastore');
  //
  //     final UserCredential userCredential = await _auth.signInWithProvider(googleProvider);
  //
  //     final OAuthCredential googleCredential = GoogleAuthProvider.credential(accessToken: userCredential.credential!.accessToken);
  //     final User user = userCredential.user!;
  //
  //     // Now you can use the googleCredential.accessToken to call Google APIs
  //     String googleAccessToken = googleCredential.accessToken!;
  //
  //
  //     if (googleAccessToken != null) {
  //       print('Google Access Token: $googleAccessToken');
  //       if (await isTokenValid(googleAccessToken)) {
  //         print('Token is valid');
  //         callFirestoreAPI(googleAccessToken);
  //       } else {
  //         print('Invalid access token');
  //       }
  //     } else {
  //       print('Google Access Token is null');
  //     }
  //
  //     print('Google Access Token: $googleAccessToken');
  //     // callFirestoreAPI(googleAccessToken);
  //     // fetchDocuments();
  //
  //     // Call Google APIs using the access token
  //       } catch (error) {
  //     print(error);
  //   }
  // }


  void _handleGoogleSignIn() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(scopes: [
        'https://www.googleapis.com/auth/cloud-platform',
        'https://www.googleapis.com/auth/datastore',
      ]);

      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        // The user canceled the sign-in
        return;
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User user = userCredential.user!;
      final String? googleAccessToken = googleAuth.accessToken;
      accessController.accessToken.text = googleAccessToken!;

      if (googleAccessToken != null) {
        print('Google Access Token: $googleAccessToken');
        if (await isTokenValid(googleAccessToken)) {
          print('Token is valid');
          // callFirestoreAPI(googleAccessToken);
        } else {
          print('Invalid access token');
        }
      } else {
        print('Google Access Token is null');
      }
    } catch (error) {
      print(error);
      print('Error during Google sign-in: $error');
      // Handle sign-in errors here, such as showing an alert dialog
      // or taking appropriate action based on the error.
    }
  }

  // Future<bool> isTokenValid(String accessToken) async {
  //   final String url = 'https://oauth2.googleapis.com/tokeninfo?access_token=$accessToken';
  //
  //   try {
  //     final response = await http.get(Uri.parse(url));
  //
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> tokenInfo = json.decode(response.body);
  //       print('Token Info: $tokenInfo');
  //       return true; // You can add additional checks here if needed
  //     } else {
  //       print('Invalid token. Status Code: ${response.statusCode}');
  //       return false;
  //     }
  //   } catch (error) {
  //     print('Error validating token: $error');
  //     return false;
  //   }
  // }

  Future<bool> isTokenValid(String accessToken) async {
    final String url = 'https://oauth2.googleapis.com/tokeninfo?access_token=$accessToken';

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

  void callFirestoreAPI(String accessToken) async {
    String parent = 'projects/car-rentals-f10a5/databases/(default)/documents';
    String collectionId = 'bookings';
    String url = 'https://firestore.googleapis.com/v1/$parent/$collectionId';

    Map<String, String> headers = {
      'Authorization': 'Bearer $accessToken',
      'Accept': 'application/json',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        print('Firestore API Response: ${response.body}');
      } else {
        print('Failed to call Firestore API. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error calling Firestore API: $error');
    }
  }

  // void callFirestoreAPI(String accessToken) async {
  //   String parent = 'projects/car-rentals-f10a5/databases/(default)';
  //   String collectionId = 'bookings';
  //   String apiKey = 'AIzaSyAO1F8fTW1EG88fnnTTFRJiKXH4I-MHlbI';
  //
  //   String url = 'https://firestore.googleapis.com/v1/$parent/$collectionId';
  //   Map<String, String> headers = {
  //     'Authorization': 'Bearer $accessToken',
  //     'Accept': 'application/json',
  //   };
  //
  //   try {
  //     final response = await http.get(Uri.parse(url), headers: headers);
  //
  //     if (response.statusCode == 200) {
  //       print('Firestore API Response: ${response.body}');
  //     } else {
  //       print('Failed to call Firestore API. Status Code: ${response.statusCode}');
  //     }
  //   } catch (error) {
  //     print('Error calling Firestore API: $error');
  //   }
  // }

  // handle logout
  void _handleLogout() {
    try {
      _auth.signOut();
    } catch (error) {
      print(error);
    }
  }


}