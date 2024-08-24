import 'package:flutter/material.dart';
import 'package:firebase_editor_gsoc/views/schemas/define_schema.dart';

class SchemaList extends StatelessWidget {
  const SchemaList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Schema List'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: schemaList.length,
              itemBuilder: (context, index) {
                final schema = schemaList[index];
                return Container(
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.amber[300],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ListTile(
                    leading: const Icon(Icons.remove_red_eye, color: Colors.white),
                    title: Text(schema.schemaName),
                    subtitle: Text(schema.projectName),
                    trailing: Text('Last Edited: ${schema.lastEdited}'),
                    onTap: () {
                      // Handle tap
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const DefineSchema(),
                        ),
                      );
                      print('Tapped on ${schema.schemaName}');
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                // Handle the button press
                Navigator.push(
                    context,
                    MaterialPageRoute(
                    builder: (context) => const DefineSchema(),
                )
                );
                print('Button Pressed');
              },

              child: const Text('Add New Schema'),
            ),
          ),
        ],
      ),
    );
  }
}

class Schema {
  final String schemaName;
  final String projectName;
  final String lastEdited;

  Schema({
    required this.schemaName,
    required this.projectName,
    required this.lastEdited,
  });
}

// Example data
List<Schema> schemaList = [
  Schema(
    schemaName: 'Schema 1',
    projectName: 'Project 1',
    lastEdited: '2022-06-01',
  ),
  Schema(
    schemaName: 'Schema 2',
    projectName: 'Project 2',
    lastEdited: '2022-06-02',
  ),
  Schema(
    schemaName: 'Schema 3',
    projectName: 'Project 3',
    lastEdited: '2022-06-03',
  ),
];
