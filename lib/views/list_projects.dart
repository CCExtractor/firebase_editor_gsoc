import 'package:firebase_editor_gsoc/API/fetch_projects.dart';
import 'package:firebase_editor_gsoc/controllers/controllers.dart';
import 'package:firebase_editor_gsoc/views/list_databases.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';


class ProjectsPage extends StatefulWidget {
  // final String accessToken;

//   ProjectsPage({
//
// });

  @override
  _ProjectsPageState createState() => _ProjectsPageState();
}

class _ProjectsPageState extends State<ProjectsPage> {
  late Future<Map<String, dynamic>> _projectsFuture;
  final _accessController = Get.put(AccessController());

  @override
  void initState() {
    super.initState();
    _projectsFuture = callFirebaseProjectsAPI(_accessController.accessToken.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Projects'),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _projectsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 20),
                  Text('Loading projects...'),
                ],
              ),
            );
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            List<dynamic> results = snapshot.data!['results'];
            return ListView.builder(
              itemCount: results.length,
              itemBuilder: (context, index) {
                var project = results[index];
                return ListTile(
                  title: Text(project['displayName']),
                  subtitle: Text(project['projectId']),
                  trailing: ElevatedButton(
                    onPressed: () {
                      // Add your on tap function here
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProjectDetailsScreen(
                            projectId: project['projectId'],
                            accessToken: _accessController.accessToken.text,
                          ),
                        ),
                      );
                      print('Button tapped for project ${project['projectId']}');
                    },
                    child: Text('Details'),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text('No projects found'));
          }
        },
      ),
    );
  }
}
