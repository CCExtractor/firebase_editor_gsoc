import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';

class DataVisualizationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<Map<String, dynamic>>> fetchFilteredData() async {
    try {
      User? user = _auth.currentUser; // Get the current user
      if (user == null) {
        print('No user is logged in');
        return [];
      }

      String userId = user.uid; // Get the user's UID
      DateTime now = DateTime.now();
      DateTime thirtyDaysAgo = now.subtract(Duration(days: 30));

      // Fetch the document for the specific user
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(userId).get();

      List<Map<String, dynamic>> filteredData = [];

      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;

        // Assuming the history data is stored in an array named 'history'
        if (data.containsKey('history')) {
          List<dynamic> history = data['history'];

          // Filter history entries from the last 30 days
          for (var entry in history) {
            if (entry is Map<String, dynamic>) {
              DateTime updateTime = DateTime.parse(entry['updateTime']);
              if (updateTime.isAfter(thirtyDaysAgo)) {
                filteredData.add({
                  'projectName': _extractProjectName(entry['documentPath']),
                  'collectionName': _extractCollectionName(entry['documentPath']),
                  'updateTime': updateTime,
                });
              }
            }
          }
        }
      }

      return filteredData;
    } catch (e) {
      print('Error fetching data: $e');
      return [];
    }
  }

  String _extractProjectName(String documentPath) {
    // Extract project name from document path
    List<String> parts = documentPath.split('/');
    return parts[1]; // Assuming the project name is at index 1
  }

  String _extractCollectionName(String documentPath) {
    // Extract collection name from document path
    List<String> parts = documentPath.split('/');
    return parts[5]; // Assuming the collection name is at index 5
  }
}


Map<String, int> processDataForChart(List<Map<String, dynamic>> data) {
  Map<String, int> groupedData = {};

  for (var entry in data) {
    String key = '${entry['projectName']}/${entry['collectionName']}';
    if (groupedData.containsKey(key)) {
      groupedData[key] = groupedData[key]! + 1;
    } else {
      groupedData[key] = 1;
    }
  }

  return groupedData;
}

