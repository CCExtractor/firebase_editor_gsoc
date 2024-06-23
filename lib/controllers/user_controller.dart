import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserController extends GetxController {
  Rx<User?> user = Rx<User?>(null);

  void setUser(User? user) {
    this.user.value = user;
  }
}