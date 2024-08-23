import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_editor_gsoc/controllers/access_controller.dart';
import 'package:firebase_editor_gsoc/controllers/user_controller.dart';
import 'package:get/get.dart';

/// The `TokenController` class manages the saving and fetching of token data
/// for the authenticated user in Firestore. It uses GetX for state management
/// and depends on `UserController` and `AccessController` to access user and
/// token information.
class TokenController extends GetxController {
  final userController = Get.put(UserController());
  final accessController = Get.put(AccessController());

  /// Saves token data to the authenticated user's Firestore document.
  ///
  /// This method updates the user's document in the 'users' collection of Firestore
  /// with the provided field name and value. It is typically used to save access
  /// tokens or other related data.
  ///
  /// [fieldName]: The name of the field to be updated in the user's Firestore document.
  /// [fieldValue]: The value to be saved in the specified field.
  ///
  /// Returns a [Future] that completes when the update operation is finished.
  /// Any errors during the update operation are silently caught.
  Future<void> saveTokenData(String fieldName, String fieldValue) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userController.user!.uid)
          .update({fieldName: fieldValue});
    } catch (e) {
      // Handle errors (optional: add logging or error reporting here).
    }
  }

  /// Fetches the access token data from the authenticated user's Firestore document.
  ///
  /// This method retrieves the user's document from the 'users' collection of Firestore
  /// and checks for the presence of an 'accessToken' field. If found, it updates
  /// the `accessController`'s `accessToken` field with the fetched value.
  ///
  /// Returns a [Future] that completes when the fetch operation is finished.
  /// Any errors during the fetch operation are silently caught.
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
          // Handle case where accessToken does not exist (optional).
        }
      } else {
        // Handle case where document does not exist (optional).
      }
    } catch (e) {
      // Handle errors (optional: add logging or error reporting here).
    }
  }
}
