import 'package:firebase_editor_gsoc/views/list_documents_details.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DocumentsPage extends StatefulWidget {
  final String accessToken;
  final String projectId;
  final String databaseId;
  final String collectionId;

  DocumentsPage({
    required this.accessToken,
    required this.projectId,
    required this.databaseId,
    required this.collectionId,
  });

  @override
  _DocumentsPageState createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> {
  bool _isLoading = true;
  List<dynamic> _documents = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDocuments();
  }

  void _fetchDocuments() async {
    String parent = 'projects/${widget.projectId}/databases/${widget.databaseId}/documents';
    String url = 'https://firestore.googleapis.com/v1/$parent/${widget.collectionId}';
    Map<String, String> headers = {
      'Authorization': 'Bearer ${widget.accessToken}',
      'Accept': 'application/json',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        setState(() {
          _documents = data['documents'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to call Firestore API. Status Code: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (error) {
      setState(() {
        _error = 'Error calling Firestore API: $error';
        _isLoading = false;
      });
    }
  }


  void _showDocumentDetails(String documentPath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentDetailsPage(
          accessToken: widget.accessToken,
          projectId: widget.projectId,
          databaseId: widget.databaseId,
          collectionId: widget.collectionId,
          documentPath: documentPath,
        ),
      ),
    );
  }


  String _formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
  }


  String extractDisplayName(String documentName) {
    List<String> parts = documentName.split("${widget.collectionId}/");
    String displayName = parts.last;
    return displayName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Documents'),
      ),
      body: _isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading documents...'),
          ],
        ),
      )
          : _error != null
          ? Center(child: Text(_error!))
          : ListView.builder(
        itemCount: _documents.length,
        itemBuilder: (context, index) {
          var document = _documents[index];
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
              title: Text("Document ID: ${extractDisplayName(document['name'])}"),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Created Time: ${_formatDateTime(document['createTime'])}'),
                  Text('Updated Time: ${_formatDateTime(document['updateTime'])}'),

                  ElevatedButton(
                    onPressed: () {
                      // Define your button action here
                      print(document['name']);
                      _showDocumentDetails(document['name']);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.amber, // Set the background color
                    ),
                    child: Text('View Fields'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
