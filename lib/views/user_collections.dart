import 'package:firebase_editor_gsoc/views/list_documents.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserCollectionsPage extends StatefulWidget {
  final String projectId;
  final String displayName;
  final String accessToken;

  UserCollectionsPage({
    required this.projectId,
    required this.displayName,
    required this.accessToken,});

  @override
  _UserCollectionsPageState createState() => _UserCollectionsPageState();
}

class _UserCollectionsPageState extends State<UserCollectionsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late User? user;
  List<String> collections = [];

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _fetchCollections();
  }

  void _showDocuments(String collectionId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentsPage(
          accessToken: widget.accessToken,
          projectId: widget.projectId,
          databaseId: widget.displayName,
          collectionId: collectionId,
        ),
      ),
    );
  }


  Future<void> _fetchCollections() async {
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user!.uid).get();
      if (userDoc.exists) {
        Map<String, dynamic>? data = userDoc.data() as Map<String, dynamic>?;
        if (data != null && data.containsKey(widget.projectId)) {
          Map<String, dynamic> projectData = data[widget.projectId];
          if (projectData.containsKey(widget.displayName)) {
            setState(() {
              collections = List<String>.from(projectData[widget.displayName] ?? []);
            });
          }
        }
      }
    }
  }

  void _addCollection(String collectionName) async {
    if (user != null) {
      DocumentReference userDocRef = _firestore.collection('users').doc(user!.uid);
      DocumentSnapshot userDoc = await userDocRef.get();

      Map<String, dynamic> projectData = {
        widget.projectId: {
          widget.displayName: FieldValue.arrayUnion([collectionName])
        }
      };

      if (userDoc.exists) {
        await userDocRef.set(projectData, SetOptions(merge: true));
      } else {
        await userDocRef.set(projectData);
      }

      _fetchCollections();
    }
  }

  void _showAddCollectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String collectionName = '';
        return AlertDialog(
          title: Text('Add Collection'),
          content: TextField(
            onChanged: (value) {
              collectionName = value;
            },
            decoration: InputDecoration(hintText: 'Collection Name/ID'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _addCollection(collectionName);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Collections for ${widget.displayName}'),
      ),
      body: collections.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('No Data'),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _showAddCollectionDialog,
              child: Text('Add Collection'),
            ),
          ],
        ),
      )
          : ListView.builder(
        itemCount: collections.length + 1, // Add one for the button
        itemBuilder: (context, index) {
          if (index == collections.length) {
            return Center(
              child: ElevatedButton(
                onPressed: _showAddCollectionDialog,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber, // Set the background color
                ),
                child: Text('Add Collection'),
              ),
            );
          }
          return Container(
            margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 5,
                  offset: Offset(0, 3), // changes position of shadow
                ),
              ],
            ),
            child: ListTile(
              title: Text("Collection: ${collections[index]}"),
              trailing: ElevatedButton(
                onPressed: () {
                  // Define your button action here
                  _showDocuments(collections[index]);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber, // Set the background color
                ),
                child: Text('Documents'),
              ),
            ),
          );
        },
      ),
    );
  }
}
