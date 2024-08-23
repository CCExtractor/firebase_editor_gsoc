import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// A service class responsible for fetching and processing user-specific data
/// for visualization purposes from Firebase Firestore.
class DataVisualizationService {
  // Firebase Firestore instance for database operations.
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Firebase Authentication instance for user authentication.
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Fetches and filters user data from Firestore based on the last 30 days.
  ///
  /// This function retrieves the current user's data from the 'users' collection
  /// in Firestore. It specifically looks at the 'history' field, which is expected
  /// to be an array of history entries. Each entry in the 'history' array is filtered
  /// to include only those that were updated within the last 30 days.
  ///
  /// The function returns a list of maps, where each map contains:
  /// - `projectName`: The name of the project extracted from the document path.
  /// - `collectionName`: The name of the collection extracted from the document path.
  /// - `updateTime`: The time the entry was last updated.
  ///
  /// Returns an empty list if the user is not authenticated, if no data is found,
  /// or if an error occurs during the process.
  Future<List<Map<String, dynamic>>> fetchFilteredData() async {
    try {
      // Get the currently authenticated user.
      User? user = _auth.currentUser;

      if (user == null) {
        // Return an empty list if the user is not authenticated.
        return [];
      }

      // Get the user's unique identifier (UID).
      String userId = user.uid;

      // Calculate the date 30 days ago from the current time.
      DateTime now = DateTime.now();
      DateTime thirtyDaysAgo = now.subtract(const Duration(days: 30));

      // Fetch the document from the 'users' collection for the current user.
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(userId).get();

      // Initialize an empty list to hold the filtered data.
      List<Map<String, dynamic>> filteredData = [];

      if (userDoc.exists) {
        // Extract the document data as a map.
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

        // Check if the 'history' field exists in the document.
        if (data.containsKey('history')) {
          List<dynamic> history = data['history'];

          // Filter the history entries to include only those updated within the last 30 days.
          for (var entry in history) {
            if (entry is Map<String, dynamic>) {
              DateTime updateTime = DateTime.parse(entry['updateTime']);
              if (updateTime.isAfter(thirtyDaysAgo)) {
                // Add the filtered entry to the result list.
                filteredData.add({
                  'projectName': _extractProjectName(entry['documentPath']),
                  'collectionName':
                      _extractCollectionName(entry['documentPath']),
                  'updateTime': updateTime,
                });
              }
            }
          }
        }
      }

      // Return the filtered data.
      return filteredData;
    } catch (e) {
      // Return an empty list in case of an error.
      return [];
    }
  }

  /// Extracts the project name from a Firestore document path.
  ///
  /// The document path is expected to follow a specific structure, and this
  /// function extracts the project name based on the assumption that it is
  /// located at index 1 in the path segments.
  ///
  /// [documentPath]: The full Firestore document path.
  ///
  /// Returns the extracted project name.
  String _extractProjectName(String documentPath) {
    List<String> parts = documentPath.split('/');
    return parts[1]; // Assuming the project name is at index 1.
  }

  /// Extracts the collection name from a Firestore document path.
  ///
  /// The document path is expected to follow a specific structure, and this
  /// function extracts the collection name based on the assumption that it is
  /// located at index 5 in the path segments.
  ///
  /// [documentPath]: The full Firestore document path.
  ///
  /// Returns the extracted collection name.
  String _extractCollectionName(String documentPath) {
    List<String> parts = documentPath.split('/');
    return parts[5]; // Assuming the collection name is at index 5.
  }
}

/// Processes the filtered data to prepare it for chart visualization.
///
/// This function groups the data by project and collection names, counting the
/// number of occurrences for each unique combination. The result is a map where
/// the keys are strings in the format 'projectName/collectionName', and the values
/// are the counts of how many times each combination appears in the data.
///
/// [data]: A list of maps, where each map contains the fields 'projectName', 'collectionName', and 'updateTime'.
///
/// Returns a [Map<String, int>] where the keys are the concatenated project and collection names,
/// and the values are the counts of occurrences.
Map<String, int> processDataForChart(List<Map<String, dynamic>> data) {
  Map<String, int> groupedData = {};

  for (var entry in data) {
    // Create a key in the format 'projectName/collectionName'.
    String key = '${entry['projectName']}/${entry['collectionName']}';

    // Increment the count for this key in the map.
    if (groupedData.containsKey(key)) {
      groupedData[key] = groupedData[key]! + 1;
    } else {
      groupedData[key] = 1;
    }
  }

  // Return the grouped data for chart visualization.
  return groupedData;
}
