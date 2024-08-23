import 'package:flutter/material.dart';

class HelpPage extends StatelessWidget {
  const HelpPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Help"),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.help_outline, color: Colors.blue),
            title: const Text("How to Use"),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HowToUsePage()),
              );
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip_outlined, color: Colors.blue),
            title: const Text("Privacy Policy"),
            onTap: () {
              // Handle Privacy Policy tap
            },
          ),
          const Divider(),
        ],
      ),
    );
  }
}

class HowToUsePage extends StatelessWidget {
  const HowToUsePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("How to Use"),
      ),
      body: const Padding(
        padding: EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Your Projects",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "This section lists all the projects associated with the account you are currently signed in. "
                "In this section, you can navigate to project details, which lists down the databases of that particular project.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                "Adding Collections",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "After selecting a database, you can add collections. The collection name should exactly match "
                "the collection name in your Firebase project (case sensitive). In the collections, you can view "
                "the documents, create new documents, delete existing documents, and perform batch operations.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                "Batch Operations (Exclusive Feature)",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "Batch operations allow you to add or delete fields from multiple documents at once. You can even download "
                "the document data (single or multiple) in JSON format and use it in your other applications.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                "Version Control System (Exclusive Feature)",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "This app has a version control system that keeps track of updates in the database, listing details such as "
                "project ID, database ID, collection ID, document ID, the field that is updated, operation type (update, add, delete), "
                "time and date of the update, and the user who updated it. This ensures transparency, a feature that is not present in "
                "the Firebase console.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                "Real-time Notifications (Exclusive Feature)",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "Real-time notifications are sent to all users when a record is updated, a feature that is not available in the Firebase console.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                "Document Operations",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "You can go to each document to update field values and types, add or delete fields, and more.",
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              Text(
                "Analytics (Exclusive Feature)",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text(
                "View simple analytics of operations performed in the last 30 days. This feature provides insight into your database activity.",
                style: TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
