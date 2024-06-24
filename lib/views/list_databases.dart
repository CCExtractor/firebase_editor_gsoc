import 'dart:convert';
import 'package:firebase_editor_gsoc/API/fetch_databases.dart';
import 'package:firebase_editor_gsoc/views/user_collections.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;


class ProjectDetailsScreen extends StatefulWidget {
  final String projectId;
  final String accessToken;

  ProjectDetailsScreen({required this.projectId, required this.accessToken});

  @override
  _ProjectDetailsScreenState createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _databaseInfo;
  late String _error;

  @override
  void initState() {
    super.initState();
    _fetchDatabaseInfo();
  }

  void _fetchDatabaseInfo() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Call the static method from DatabaseApiService to fetch database info
      Map<String, dynamic> response = await fetchDatabaseInfo(widget.projectId, widget.accessToken);

      setState(() {
        _databaseInfo = response;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'Error fetching database info: $error';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Database Details'),
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Fetching your databases...'),
          ],
        ),
      )
          : _databaseInfo != null
          ? ListView(
        children: [
      ListTile(
      title: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Name: ${_databaseInfo!['displayName']}'),
          SizedBox(height: 4), // Adjust spacing as needed
          Text('Created Time: ${_databaseInfo!['createTime']}'),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 8), // Adjust spacing between title and subtitle
          Text('Updated Time: ${_databaseInfo!['updateTime']}'),
        ],
      ),
      trailing: ElevatedButton(
        onPressed: () {
          // Add your onPressed functionality here

          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => UserCollectionsPage(
                  projectId: widget.projectId,
                  displayName: _databaseInfo!['displayName'],
                  accessToken: widget.accessToken,

                )
            ),
          );

          print('Button tapped');
        },
        child: Text('Action'),
      ),
    ),
          // Add more ListTile widgets for other fields as needed
        ],
      )
          : Center(
        child: Text(_error.isNotEmpty ? _error : 'No database information found.'),
      ),
    );
  }
}
