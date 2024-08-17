import 'package:firebase_editor_gsoc/controllers/token_controller.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../user_login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


class UserController extends GetxController {
  User? user;

  final FirebaseAuth auth = FirebaseAuth.instance;

  void setUser(User? user) {
    this.user = user;
  }


  // handle logout
  void handleLogout() async{
    try {
     await GoogleSignIn().signOut(); // Sign out from Google
     auth.signOut();
     Get.offAll(const LoginScreen()); // Replace LoginScreen with your desired screen
    } catch (error) {
      print(error);
    }
  }


  Future<void> addProjectIdIfNotExists(String projectId) async {
    try {
      // Get the current user ID
      final String userId = FirebaseAuth.instance.currentUser!.uid;

      // Reference to the user's document in Firestore
      final DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

      // Get the user's document
      final DocumentSnapshot userDocSnapshot = await userDocRef.get();

      if (userDocSnapshot.exists) {
        // Cast the document data to a Map to access fields
        Map<String, dynamic> userData = userDocSnapshot.data() as Map<String, dynamic>;

        // Check if the 'projectIds' field exists and if not, initialize it as an empty list
        List<dynamic> projectIds = [];
        if (userData.containsKey('projectIds')) {
          projectIds = userData['projectIds'];
        }

        // Check if the projectId is already in the array
        if (!projectIds.contains(projectId)) {
          // Add the projectId to the array
          projectIds.add(projectId);

          // Update the user's document with the new projectIds array
          await userDocRef.update({
            'projectIds': projectIds,
          });

          print("Project ID added successfully.");
        } else {
          print("Project ID already exists in the array.");
        }
      } else {
        // If the user's document does not exist, create it with the projectId
        await userDocRef.set({
          'projectIds': [projectId],
        });

        print("User document created and Project ID added successfully.");
      }
    } catch (error) {
      print("Error adding Project ID: $error");
      throw Exception("Failed to add Project ID.");
    }
  }


  Future<void> storeDeviceToken() async {
    try {
      // Get the current user ID
      final String userId = FirebaseAuth.instance.currentUser!.uid;

      // Get the device token from Firebase Messaging
      final String? deviceToken = await FirebaseMessaging.instance.getToken();

      if (deviceToken == null) {
        throw Exception("Failed to get device token.");
      }

      // Reference to the user's document in Firestore
      final DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

      // Update the user's document with the new device token
      await userDocRef.update({
        'deviceToken': deviceToken,
      });

      print("Device token stored/updated successfully.");

      // Listen for token refresh and update it in Firestore
      FirebaseMessaging.instance.onTokenRefresh.listen((newToken) async {
        await userDocRef.update({
          'deviceToken': newToken,
        });

        print("Device token refreshed and updated successfully.");
      });

    } catch (error) {
      print("Error storing device token: $error");
      throw Exception("Failed to store device token.");
    }
  }


  // on Hold for now
  // Future<void> addDeviceTokenToProject(String projectId, String deviceToken) async {
  //   try {
  //     // Reference to the project document in Firestore
  //     final DocumentReference projectDocRef = FirebaseFirestore.instance.collection('projects').doc(projectId);
  //
  //     // Get the project's document
  //     final DocumentSnapshot projectDocSnapshot = await projectDocRef.get();
  //
  //     if (projectDocSnapshot.exists) {
  //       // Get the current deviceTokens array
  //       List<dynamic> deviceTokens = projectDocSnapshot.get('deviceTokens') ?? [];
  //
  //       // Check if the deviceToken is already in the array
  //       if (!deviceTokens.contains(deviceToken)) {
  //         // Add the deviceToken to the array
  //         deviceTokens.add(deviceToken);
  //
  //         // Update the project's document with the new deviceTokens array
  //         await projectDocRef.update({
  //           'deviceTokens': deviceTokens,
  //         });
  //
  //         print("Device token added to project successfully.");
  //       } else {
  //         print("Device token already exists in the project's array.");
  //       }
  //     } else {
  //       // If the project's document does not exist, create it with the deviceToken
  //       await projectDocRef.set({
  //         'deviceTokens': [deviceToken],
  //       });
  //
  //       print("Project document created and device token added successfully.");
  //     }
  //   } catch (error) {
  //     print("Error adding device token to project: $error");
  //     throw Exception("Failed to add device token to project.");
  //   }
  // }

}