import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_editor_gsoc/controllers/user_controller.dart';
import 'package:get/get.dart';

final userController = Get.put(UserController());

Future<void> createHistoryArrayIfNotExists() async {
  // Reference to the user document in Firestore
  DocumentReference userRef = FirebaseFirestore.instance.collection('users').doc(userController.user!.uid);

  // Add the 'history' field to the document
  await userRef.set({'history': FieldValue.arrayUnion([])}, SetOptions(merge: true));
  print('Created history array for user ${userController.user!.uid}');
}

void insertHistory(String documentPath, String updatedField, DateTime updateTime, String operationType) async {
  // Ensure history array exists
  // await createHistoryArrayIfNotExists();

  // Access Firestore instance
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Reference to the document where history array resides
  DocumentReference userDocRef = firestore.collection('users').doc(userController.user!.uid);

  // Get current data of the document
  DocumentSnapshot userSnapshot = await userDocRef.get();

  // Retrieve or initialize the 'history' array
  List<dynamic> historyArray = userSnapshot.get('history') ?? [];

  // Create the new history map
  Map<String, dynamic> historyEntry = {
    'documentPath': documentPath,
    'updatedField': updatedField,
    'updateTime': updateTime.toUtc().toIso8601String(),
    'operationType': operationType,
    'editedBy' : userController.user?.email,
  };

  // Add the new history entry to the array
  historyArray.add(historyEntry);

  // Update the 'history' array in Firestore
  await userDocRef.set({
    'history': historyArray,
  }, SetOptions(merge: true)); // Use merge: true to merge with existing document if it exists

  print('History entry added successfully.');
}
