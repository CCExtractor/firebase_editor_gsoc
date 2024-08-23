import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A service class that manages recent entries for the authenticated user.
/// It allows updating and fetching recent entries in the user's Firestore document.
class RecentEntryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Updates the recent entries list in the user's Firestore document.
  ///
  /// This method checks if the current user's Firestore document contains a list
  /// of recent entries. If the list exists, it checks whether the new entry already
  /// exists in the list. If it exists, the `updateTime` is updated. If it doesn't
  /// exist, the new entry is added to the list. The method ensures that only the
  /// three most recent entries are stored, removing the oldest entry if necessary.
  ///
  /// [newEntry]: A map containing the details of the new entry to be added or updated.
  Future<void> updateRecentEntries(Map<String, dynamic> newEntry) async {
    try {
      User? user = _auth.currentUser; // Get the current user.
      if (user == null) {
        return; // Exit if the user is not authenticated.
      }

      String userId = user.uid; // Get the user's UID.

      // Reference to the user's document in Firestore.
      DocumentReference userDocRef = _firestore.collection('users').doc(userId);

      // Get the user's current document data.
      DocumentSnapshot userDoc = await userDocRef.get();

      if (userDoc.exists) {
        // If the document exists, retrieve the current list of recent entries.
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        List<dynamic> recentEntries = data['recentEntries'] ?? [];

        // Check if the new entry already exists in the list.
        bool entryExists = false;
        for (var entry in recentEntries) {
          if (entry['projectName'] == newEntry['projectName'] &&
              entry['databaseName'] == newEntry['databaseName'] &&
              entry['collectionName'] == newEntry['collectionName']) {
            // Update the updateTime if the entry exists.
            entry['updateTime'] = newEntry['updateTime'];
            entryExists = true;
            break;
          }
        }

        if (!entryExists) {
          // Add the new entry if it doesn't exist.
          recentEntries.add(newEntry);

          // Ensure only the three most recent entries are stored.
          if (recentEntries.length > 3) {
            recentEntries.removeAt(0); // Remove the oldest entry.
          }
        }

        // Update the user's document with the new recent entries list.
        await userDocRef.update({'recentEntries': recentEntries});
      } else {
        // If the document does not exist, create it with the new entry.
        await userDocRef.set({
          'recentEntries': [newEntry],
        });
      }
    } catch (e) {
      // Handle errors (optional: add logging or error reporting here).
    }
  }

  /// Fetches the recent entries list from the user's Firestore document.
  ///
  /// This method retrieves the current user's recent entries from their Firestore
  /// document. If the document exists and contains recent entries, it returns
  /// a list of maps representing these entries. If the document does not exist
  /// or if there are no recent entries, it returns an empty list.
  ///
  /// Returns a list of maps, where each map contains the details of a recent entry.
  Future<List<Map<String, dynamic>>> fetchRecentEntries() async {
    try {
      User? user = _auth.currentUser; // Get the current user.
      if (user == null) {
        return []; // Return an empty list if the user is not authenticated.
      }

      String userId = user.uid; // Get the user's UID.

      // Reference to the user's document in Firestore.
      DocumentReference userDocRef = _firestore.collection('users').doc(userId);

      // Get the user's current document data.
      DocumentSnapshot userDoc = await userDocRef.get();

      if (userDoc.exists) {
        // If the document exists, retrieve the recent entries.
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        List<dynamic> recentEntries = data['recentEntries'] ?? [];

        // Convert the dynamic list to a list of map entries.
        List<Map<String, dynamic>> entriesList =
            recentEntries.cast<Map<String, dynamic>>();

        return entriesList; // Return the list of recent entries.
      } else {
        return []; // Return an empty list if the document does not exist.
      }
    } catch (e) {
      return []; // Return an empty list in case of an error.
    }
  }

  /// Triggers an update to the recent entries list with a new entry.
  ///
  /// This method creates a new entry with the specified project, database,
  /// and collection IDs, along with the current time as the `updateTime`.
  /// It then calls `updateRecentEntries` to add this new entry to the user's
  /// recent entries list in Firestore.
  ///
  /// [projectId]: The ID of the project related to the recent entry.
  /// [databaseId]: The ID of the database related to the recent entry.
  /// [collectionId]: The ID of the collection related to the recent entry.
  void triggerRecentEntry(
      String projectId, String databaseId, String collectionId) async {
    Map<String, dynamic> newEntry = {
      'projectName': projectId,
      'databaseName': databaseId,
      'collectionName': collectionId,
      'updateTime': DateTime.now().toIso8601String(),
    };
    await updateRecentEntries(newEntry);
  }
}
