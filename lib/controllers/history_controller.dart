import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_editor_gsoc/controllers/user_controller.dart';
import 'package:get/get.dart';

final userController = Get.put(UserController());

/// Function to create a 'history' array field in the user's Firestore document if it doesn't already exist.
/// This ensures that the user's document has a field to store history entries.
///
/// @return A Future that completes when the operation is finished, either successfully or with an error.
Future<void> createHistoryArrayIfNotExists() async {
  // Reference to the user document in Firestore
  DocumentReference userRef = FirebaseFirestore.instance
      .collection('users')
      .doc(userController.user!.uid);

  // Add the 'history' field to the document
  await userRef
      .set({'history': FieldValue.arrayUnion([])}, SetOptions(merge: true));
}

/// Function to insert a new history entry into the user's 'history' array in Firestore.
/// The history entry contains details about a document update, including the document path,
/// the field that was updated, the time of the update, and the type of operation performed.
///
/// @param documentPath The path of the Firestore document that was updated.
/// @param updatedField The name of the field that was updated in the document.
/// @param updateTime The DateTime of the update operation, converted to UTC and ISO8601 string format.
/// @param operationType The type of operation performed (e.g., 'create', 'update', 'delete').
///
/// @return A Future that completes when the history entry is successfully inserted into Firestore.
void insertHistory(String documentPath, String updatedField,
    DateTime updateTime, String operationType) async {
  // Ensure history array exists
  // await createHistoryArrayIfNotExists();

  // Access Firestore instance
  FirebaseFirestore firestore = FirebaseFirestore.instance;

  // Reference to the document where history array resides
  DocumentReference userDocRef =
      firestore.collection('users').doc(userController.user!.uid);

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
    'editedBy': userController.user?.email,
  };

  // Add the new history entry to the array
  historyArray.add(historyEntry);

  // Update the 'history' array in Firestore
  await userDocRef.set(
      {
        'history': historyArray,
      },
      SetOptions(
          merge:
              true)); // Use merge: true to merge with existing document if it exists
}
