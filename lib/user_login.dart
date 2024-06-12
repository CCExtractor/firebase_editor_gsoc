import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_editor_gsoc/home_screen.dart';
import 'package:firebase_editor_gsoc/models/login.dart';
import 'package:flutter/material.dart';
import 'package:sign_in_button/sign_in_button.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _model = LoginModel();
  final _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  User? _user;

  @override
  void initState(){
    super.initState();
    _auth.authStateChanges().listen((event) {
      setState(() {
        _user = event;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Login'),
      ),
      body: _user != null ? _userInfo() : _googleSignInButton(),
    );
  }

  Widget _googleSignInButton(){
    return Center(
      child: SizedBox(
        height: 15,
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
      height: 20,
      child: Text("Logged In successfully", style: TextStyle(color: Colors.black, fontSize: 20.0),),
    );
  }

  // handle google sign in
  void _handleGoogleSignIn() {
    try{
      GoogleAuthProvider _googleAuthProvider = GoogleAuthProvider();
      _auth.signInWithProvider(_googleAuthProvider);
    }
    catch (error) {
      print(error);
    }

  }

}