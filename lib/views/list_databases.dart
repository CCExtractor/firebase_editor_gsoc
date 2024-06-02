import 'package:firebase_editor_gsoc/views/define_schema.dart';
import 'package:flutter/material.dart';

class DatabaseList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Database List'),
      ),
      body: ListView.builder(
        itemCount: databaseList.length,
        itemBuilder: (context, index) {
          final database = databaseList[index];
          return Container(
            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: ListTile(
              leading: Icon(Icons.edit, color: Colors.blue),
              title: Text(database.databaseName),
              subtitle: Text(database.projectName),
              trailing: Text('Last Edited: ${database.lastEdited}'),
              onTap: () {
                // Handle tap
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DefineSchema(),
                  ),
                );
                print('Tapped on ${database.databaseName}');
              },
            ),
          );
        },
      ),
    );
  }
}

class Database {
  final String databaseName;
  final String projectName;
  final String lastEdited;

  Database({
    required this.databaseName,
    required this.projectName,
    required this.lastEdited,
  });
}

// Example data
List<Database> databaseList = [
  Database(
    databaseName: 'Database 1',
    projectName: 'Project 1',
    lastEdited: '2022-06-01',
  ),
  Database(
    databaseName: 'Database 2',
    projectName: 'Project 2',
    lastEdited: '2022-06-02',
  ),
  Database(
    databaseName: 'Database 3',
    projectName: 'Project 3',
    lastEdited: '2022-06-03',
  ),
];