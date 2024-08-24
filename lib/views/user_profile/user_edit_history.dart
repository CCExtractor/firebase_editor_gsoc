import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_editor_gsoc/controllers/user_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

/// The HistoryPage widget displays a list of user's edit history records retrieved from Firestore.
class HistoryPage extends StatelessWidget {
  HistoryPage({super.key});

  // GetX controller to manage user data
  final userController = Get.put(UserController());

  /// Formats a timestamp string into a human-readable date and time format.
  /// Returns a string formatted as 'dd-MM-yyyy | HH:mm'.
  String formattedDateTime(String timestampString) {
    DateTime dateTime = DateTime.parse(timestampString);
    String formattedDate = DateFormat('dd-MM-yyyy')
        .format(dateTime); // Format date as 'dd-MM-yyyy'
    String formattedTime =
        DateFormat('HH:mm').format(dateTime); // Format time as 'HH:mm'
    return '$formattedDate | $formattedTime';
  }

  /// Extracts the Project ID from the document path.
  /// The document path is expected to follow a structure where 'projects' is followed by the project ID.
  /// Returns the project ID or an empty string if not found.
  String extractProjectId(String documentPath) {
    List<String> parts = documentPath.split('/');
    if (parts.length >= 2 && parts[0] == 'projects') {
      return parts[1];
    } else {
      return '';
    }
  }

  /// Extracts the Database ID from the document path.
  /// The document path is expected to follow a structure where 'databases' is followed by the database ID.
  /// Returns the database ID or an empty string if not found.
  String extractDatabaseId(String documentPath) {
    List<String> parts = documentPath.split('/');
    if (parts.length >= 4 && parts[2] == 'databases') {
      return parts[3];
    } else {
      return '';
    }
  }

  /// Extracts the Collection ID from the document path.
  /// The document path is expected to follow a structure where 'documents' is followed by the collection ID.
  /// Returns the collection ID or an empty string if not found.
  String extractCollectionId(String documentPath) {
    List<String> parts = documentPath.split('/');
    if (parts.length >= 6 && parts[4] == 'documents') {
      return parts[5];
    } else {
      return '';
    }
  }

  /// Extracts the Document ID from the document path.
  /// The document path is expected to have the document ID as the seventh element.
  /// Returns the document ID or an empty string if not found.
  String extractDocumentId(String documentPath) {
    List<String> parts = documentPath.split('/');
    if (parts.length >= 7) {
      return parts[6];
    } else {
      return '';
    }
  }

  /// The build method defines the UI of the HistoryPage.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'), // Title of the AppBar
      ),
      body: StreamBuilder<DocumentSnapshot>(
        // Stream to listen for real-time updates to the user's document in Firestore
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userController.user!.uid)
            .snapshots(),
        builder: (context, snapshot) {
          // Handle any errors that occur while fetching the data
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          // Display a loading indicator while waiting for data
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Retrieve the history data from the user's document
          List<dynamic> history = snapshot.data!.get('history');

          // Sort history entries by updateTime in descending order
          history.sort((a, b) => DateTime.parse(b['updateTime'])
              .compareTo(DateTime.parse(a['updateTime'])));

          // Build a ListView to display the history entries
          return ListView.builder(
            itemCount: history.length, // Number of history entries
            itemBuilder: (context, index) {
              Map<String, dynamic> historyEntry =
                  history[index]; // Current history entry
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      10.0), // Rounded corners for the card
                ),
                elevation: 4.0, // Shadow elevation of the card
                margin: const EdgeInsets.all(8.0), // Margin around the card
                child: ListTile(
                  title: const Text('Details'), // Title of the ListTile
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display extracted information from the document path
                      Text(
                          "Project ID: ${extractProjectId(historyEntry['documentPath'])}"),
                      Text(
                          "Database ID: ${extractDatabaseId(historyEntry['documentPath'])}"),
                      Text(
                          "Collection ID: ${extractCollectionId(historyEntry['documentPath'])}"),
                      Text(
                          "Document ID: ${extractDocumentId(historyEntry['documentPath'])}"),
                      const Divider(), // Divider between sections
                      // Display other details about the history entry
                      Text('Field: ${historyEntry['updatedField']}'),
                      Text(
                          'Update Time: ${formattedDateTime(historyEntry['updateTime'])}'),
                      Text('Operation Type: ${historyEntry['operationType']}'),
                      Text('Edited By: ${historyEntry['editedBy']}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
