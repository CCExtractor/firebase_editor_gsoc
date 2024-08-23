import 'package:firebase_editor_gsoc/controllers/token_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../user_login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// The `UserController` class manages user-related operations, including
/// authentication, logout, project ID management, and storing device tokens
/// for push notifications. It uses Firebase Authentication, Firestore,
/// and Firebase Messaging services.
class UserController extends GetxController {
  User? user; // The current authenticated user.

  final FirebaseAuth auth =
      FirebaseAuth.instance; // Firebase Authentication instance.

  /// Sets the current user in the controller.
  ///
  /// [user]: The user object to be set as the current user.
  void setUser(User? user) {
    this.user = user;
  }

  /// Handles user logout from the application.
  ///
  /// This method signs the user out from both Google and Firebase Authentication.
  /// After signing out, it redirects the user to the login screen.
  Future<void> handleLogout() async {
    try {
      await GoogleSignIn().signOut(); // Sign out from Google.
      await auth.signOut(); // Sign out from Firebase Authentication.
      Get.offAll(LoginScreen()); // Redirect to the login screen.
    } catch (error) {
      // Handle any errors that occur during the logout process.
    }
  }

  /// Adds a project ID to the user's Firestore document if it does not already exist.
  ///
  /// This method checks if the specified project ID is already present in the user's
  /// 'projectIds' array in Firestore. If not, it adds the project ID to the array.
  ///
  /// [projectId]: The project ID to be added to the user's document.
  Future<void> addProjectIdIfNotExists(String projectId) async {
    try {
      // Get the current user's ID.
      final String userId = FirebaseAuth.instance.currentUser!.uid;

      // Reference to the user's document in Firestore.
      final DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(userId);

      // Get the user's document.
      final DocumentSnapshot userDocSnapshot = await userDocRef.get();

      if (userDocSnapshot.exists) {
        // Cast the document data to a Map to access fields.
        Map<String, dynamic> userData =
            userDocSnapshot.data() as Map<String, dynamic>;

        // Initialize the 'projectIds' list if it doesn't exist.
        List<dynamic> projectIds =
            userData.containsKey('projectIds') ? userData['projectIds'] : [];

        // Check if the projectId is already in the array.
        if (!projectIds.contains(projectId)) {
          // Add the projectId to the array.
          projectIds.add(projectId);

          // Update the user's document with the new projectIds array.
          await userDocRef.update({
            'projectIds': projectIds,
          });
        }
      } else {
        // If the user's document does not exist, create it with the projectId.
        await userDocRef.set({
          'projectIds': [projectId],
        });
      }
    } catch (error) {
      throw Exception("Failed to add Project ID.");
    }
  }

  /// Stores the device token for push notifications in the user's Firestore document.
  ///
  /// This method retrieves the current device's FCM token and stores it in the
  /// user's Firestore document. It also sets up a listener to update the token
  /// in Firestore if it is refreshed.
  Future<void> storeDeviceToken() async {
    try {
      // Get the current user's ID.
      final String userId = FirebaseAuth.instance.currentUser!.uid;

      // Get the device token from Firebase Messaging.
      final String? deviceToken = await FirebaseMessaging.instance.getToken();

      if (deviceToken == null) {
        throw Exception("Failed to get device token.");
      }

      // Reference to the user's document in Firestore.
      final DocumentReference userDocRef =
          FirebaseFirestore.instance.collection('users').doc(userId);

      // Update the user's document with the new device token.
      await userDocRef.update({
        'deviceToken': deviceToken,
      });

      // Listen for token refresh and update it in Firestore.
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        await userDocRef.update({
          'deviceToken': newToken,
        });
      });
    } catch (error) {
      throw Exception("Failed to store device token.");
    }
  }
}
