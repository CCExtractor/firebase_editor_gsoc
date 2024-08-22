import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_editor_gsoc/controllers/user_controller.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

final userController = Get.put(UserController());

class HistoryPage extends StatelessWidget {

  String formattedDateTime(String timestampString) {
    DateTime dateTime = DateTime.parse(timestampString);
    String formattedDate = DateFormat('dd-MM-yyyy').format(dateTime); // Format date as 'dd-MM-yyyy'
    String formattedTime = DateFormat('HH:mm').format(dateTime); // Format time as 'HH:mm'
    return '$formattedDate | $formattedTime';
  }

  String extractProjectId(String documentPath) {
    List<String> parts = documentPath.split('/');
    if (parts.length >= 2 && parts[0] == 'projects') {
      return parts[1];
    } else {
      return '';
    }
  }

  String extractDatabaseId(String documentPath) {
    List<String> parts = documentPath.split('/');
    if (parts.length >= 4 && parts[2] == 'databases') {
      return parts[3];
    } else {
      return '';
    }
  }

  String extractCollectionId(String documentPath) {
    List<String> parts = documentPath.split('/');
    if (parts.length >= 6 && parts[4] == 'documents') {
      return parts[5];
    } else {
      return '';
    }
  }

  String extractDocumentId(String documentPath) {
    List<String> parts = documentPath.split('/');
    if (parts.length >= 7) {
      return parts[6];
    } else {
      return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('History'),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(userController.user!.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          List<dynamic> history = snapshot.data!.get('history');

          // Sort history entries by updateTime in descending order
          history.sort((a, b) => DateTime.parse(b['updateTime']).compareTo(DateTime.parse(a['updateTime'])));

          return ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              Map<String, dynamic> historyEntry = history[index];
              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                elevation: 4.0,
                margin: EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text('Details'),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Project ID: ${extractProjectId(historyEntry['documentPath'])}"),
                      Text("Database ID: ${extractDatabaseId(historyEntry['documentPath'])}"),
                      Text("Collection ID: ${extractCollectionId(historyEntry['documentPath'])}"),
                      Text("Document ID: ${extractDocumentId(historyEntry['documentPath'])}"),
                      Divider(),
                      Text('Field: ${historyEntry['updatedField']}'),
                      Text('Update Time: ${formattedDateTime(historyEntry['updateTime'])}'),
                      Text('Operation Type: ${historyEntry['operationType']}'),
                      Text('Edited By: ${historyEntry['editedBy']}')
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
