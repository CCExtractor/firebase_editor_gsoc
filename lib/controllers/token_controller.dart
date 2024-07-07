import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_editor_gsoc/controllers/controllers.dart';
import 'package:firebase_editor_gsoc/controllers/user_controller.dart';
import 'package:get/get.dart';

class TokenController extends GetxController{

  final userController = Get.put(UserController());
  final accessController = Get.put(AccessController());

  Future<void> saveTokenData(String fieldName, String fieldValue) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userController.user!.uid)
          .update({fieldName: fieldValue});
      print("Field $fieldName updated successfully!");
    } catch (e) {
      print("Error updating field $fieldName: $e");
    }
  }


  Future<void> fetchAccessTokenData() async {
    try {
      DocumentSnapshot docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userController.user!.uid)
          .get();

      if (docSnapshot.exists) {
        var data = docSnapshot.data() as Map<String, dynamic>;
        if (data.containsKey('accessToken')) {
          accessController.accessToken.text = data['accessToken'];
        } else {
          print("Field accessToken not found in the document.");
        }
      } else {
        print("No data found for this user.");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }
  }

}

