import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RecentEntryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> updateRecentEntries(Map<String, dynamic> newEntry) async {
    try {
      User? user = _auth.currentUser; // Get the current user
      if (user == null) {
        print('No user is logged in');
        return;
      }

      String userId = user.uid; // Use the user's UID

      // Reference to the user's document
      DocumentReference userDocRef = _firestore.collection('users').doc(userId);

      // Get the user's current data
      DocumentSnapshot userDoc = await userDocRef.get();

      if (userDoc.exists) {
        // If the document exists, retrieve the current list of recent entries
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        List<dynamic> recentEntries = data['recentEntries'] ?? [];

        // Check if the new entry already exists in the list
        bool entryExists = false;
        for (var entry in recentEntries) {
          if (entry['projectName'] == newEntry['projectName'] &&
              entry['databaseName'] == newEntry['databaseName'] &&
              entry['collectionName'] == newEntry['collectionName']) {
            // Update the updateTime if the entry exists
            entry['updateTime'] = newEntry['updateTime'];
            entryExists = true;
            break;
          }
        }

        if (!entryExists) {
          // Add the new entry if it doesn't exist
          recentEntries.add(newEntry);

          // Ensure only the three most recent entries are stored
          if (recentEntries.length > 3) {
            recentEntries.removeAt(0); // Remove the oldest entry
          }
        }

        // Update the user's document with the new recent entries list
        await userDocRef.update({'recentEntries': recentEntries});
      } else {
        // If the document does not exist, create it with the new entry
        await userDocRef.set({
          'recentEntries': [newEntry],
        });
      }
    } catch (e) {
      print('Error updating recent entries: $e');
    }
  }


  Future<List<Map<String, dynamic>>> fetchRecentEntries() async {
    try {
      User? user = _auth.currentUser; // Get the current user
      if (user == null) {
        print('No user is logged in');
        return [];
      }

      String userId = user.uid; // Use the user's UID

      // Reference to the user's document
      DocumentReference userDocRef = _firestore.collection('users').doc(userId);

      // Get the user's current data
      DocumentSnapshot userDoc = await userDocRef.get();

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        List<dynamic> recentEntries = data['recentEntries'] ?? [];

        // Convert dynamic list to list of map entries
        List<Map<String, dynamic>> entriesList = recentEntries.cast<Map<String, dynamic>>();

        return entriesList;
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching recent entries: $e');
      return [];
    }
  }

  void triggerRecentEntry(String projectId, String databaseId, String collectionId) async{
    Map<String, dynamic> newEntry = {
    'projectName': projectId,
    'databaseName': databaseId,
    'collectionName': collectionId,
    'updateTime': DateTime.now().toIso8601String(),
  };
  await updateRecentEntries(newEntry);
  }
}


