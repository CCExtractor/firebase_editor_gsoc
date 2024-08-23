import 'package:firebase_editor_gsoc/views/custom_drawer.dart';
import 'package:firebase_editor_gsoc/views/list_documents.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

/// UserCollectionsPage displays and manages collections within a specific project for the authenticated user.
class UserCollectionsPage extends StatefulWidget {
  final String projectId;      // The ID of the project
  final String displayName;    // The display name of the database
  final String accessToken;    // The access token for authentication

  const UserCollectionsPage({
    super.key,
    required this.projectId,
    required this.displayName,
    required this.accessToken,
  });

  @override
  _UserCollectionsPageState createState() => _UserCollectionsPageState();
}

class _UserCollectionsPageState extends State<UserCollectionsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;          // Firebase authentication instance
  final FirebaseFirestore _firestore = FirebaseFirestore.instance; // Firestore instance
  late User? user;                                           // The currently authenticated user
  List<String> collections = [];                             // List to hold collection names
  bool _isLoading = false;                                   // Loading state flag

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;    // Get the current user
    _fetchCollections();         // Fetch collections for the user
  }

  /// Navigates to the DocumentsPage for the specified collection.
  void _showDocuments(String collectionId) {
    Get.to(
      DocumentsPage(
        accessToken: widget.accessToken,
        projectId: widget.projectId,
        databaseId: widget.displayName,
        collectionId: collectionId,
      ),
    );
  }

  /// Fetches the collections from Firestore for the current user.
  Future<void> _fetchCollections() async {
    setState(() {
      _isLoading = true; // Set loading state to true
    });

    if (user != null) {
      // Get the user's document from Firestore
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user!.uid).get();
      if (userDoc.exists) {
        // Extract project data
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

    setState(() {
      _isLoading = false; // Set loading state to false
    });
  }

  /// Adds a new collection to Firestore for the current user.
  void _addCollection(String collectionName) async {
    if (user != null) {
      DocumentReference userDocRef = _firestore.collection('users').doc(user!.uid);
      DocumentSnapshot userDoc = await userDocRef.get();

      // Prepare the data to add the new collection
      Map<String, dynamic> projectData = {
        widget.projectId: {
          widget.displayName: FieldValue.arrayUnion([collectionName])
        }
      };

      // Add the collection to Firestore, merging if necessary
      if (userDoc.exists) {
        await userDocRef.set(projectData, SetOptions(merge: true));
      } else {
        await userDocRef.set(projectData);
      }

      _fetchCollections(); // Refresh the collections list
    }
  }

  /// Deletes a collection from Firestore for the current user.
  void _deleteCollection(String collectionName) async {
    if (user != null) {
      DocumentReference userDocRef = _firestore.collection('users').doc(user!.uid);
      DocumentSnapshot userDoc = await userDocRef.get();

      // Prepare the data to remove the collection
      Map<String, dynamic> projectData = {
        widget.projectId: {
          widget.displayName: FieldValue.arrayRemove([collectionName])
        }
      };

      // Remove the collection from Firestore
      if (userDoc.exists) {
        await userDocRef.set(projectData, SetOptions(merge: true));
      }

      _fetchCollections(); // Refresh the collections list
    }
  }

  /// Displays a confirmation dialog before deleting a collection.
  void _showDeleteConfirmationDialog(String collectionName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Collection'),
          content: Text('Are you sure you want to delete the collection "$collectionName"?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteCollection(collectionName); // Delete the collection
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  /// Displays a dialog to add a new collection.
  void _showAddCollectionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        String collectionName = ''; // Variable to store the collection name
        return AlertDialog(
          title: const Text('Add Collection'),
          content: TextField(
            onChanged: (value) {
              collectionName = value; // Update the collection name
            },
            decoration: const InputDecoration(
              hintText: 'Enter your Collection Name',
              hintStyle: TextStyle(fontSize: 12.0),
            ),
          ),
          actions: [
            const Text("Note: Collection Name is Case Sensitive"),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    _addCollection(collectionName); // Add the collection
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  /// The build method defines the UI of the UserCollectionsPage.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.displayName}: Collections'), // Display the database name in the title
      ),
      drawer: CustomDrawer(), // Custom navigation drawer
      body: Stack(
        children: [
          // Display a message and button if there are no collections and not loading
          if (collections.isEmpty && !_isLoading)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('No Data'),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: _showAddCollectionDialog, // Show dialog to add collection
                    child: const Text('Add Collection'),
                  ),
                ],
              ),
            ),
          // Display the list of collections if they are available
          if (collections.isNotEmpty)
            ListView.builder(
              itemCount: collections.length + 1, // Add one for the 'Add Collection' button
              itemBuilder: (context, index) {
                if (index == collections.length) {
                  return Center(
                    child: ElevatedButton(
                      onPressed: _showAddCollectionDialog, // Show dialog to add collection
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber, // Set the background color
                      ),
                      child: const Text('Add Collection'),
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
                        offset: const Offset(0, 3), // Changes position of shadow
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text("Collection: ${collections[index]}"), // Display collection name
                    subtitle: Row(
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            _showDocuments(collections[index]); // Show documents in the collection
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber, // Set the background color
                          ),
                          child: const Text('Documents'),
                        ),
                        const SizedBox(width: 8.0), // Space between buttons
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.grey),
                          onPressed: () {
                            _showDeleteConfirmationDialog(collections[index]); // Confirm deletion
                          },
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          // Display a loading indicator while collections are being fetched
          if (_isLoading)
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(), // Loading spinner
                  SizedBox(height: 20),
                  Text('Loading collections...'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
