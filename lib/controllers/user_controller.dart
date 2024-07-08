import 'package:firebase_editor_gsoc/controllers/token_controller.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../user_login.dart';

class UserController extends GetxController {
  User? user;

  final FirebaseAuth auth = FirebaseAuth.instance;

  void setUser(User? user) {
    this.user = user;
  }


  // handle logout
  void handleLogout() {
    try {
     auth.signOut();
     Get.offAll(const LoginScreen()); // Replace LoginScreen with your desired screen
    } catch (error) {
      print(error);
    }
  }


}