import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DocumentDetailsPage extends StatefulWidget {
  final String accessToken;
  final String documentPath;
  final String projectId;
  final String databaseId;
  final String collectionId;

  const DocumentDetailsPage({super.key,
    required this.accessToken,
    required this.documentPath,
    required this.projectId,
    required this.databaseId,
    required this.collectionId,
  });

  @override
  _DocumentDetailsPageState createState() => _DocumentDetailsPageState();
}

class _DocumentDetailsPageState extends State<DocumentDetailsPage> {
  bool _isLoading = true;
  Map<String, dynamic>? _documentDetails;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDocumentDetails();
  }

  void _fetchDocumentDetails() async {
    String url = 'https://firestore.googleapis.com/v1/${widget.documentPath}';
    Map<String, String> headers = {
      'Authorization': 'Bearer ${widget.accessToken}',
      'Accept': 'application/json',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        print(data);
        setState(() {
          _documentDetails = data;
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

  void _showEditDialog(String fieldName, String fieldType, String fieldValue) {
    String newFieldType = fieldType;
    String newFieldValue = fieldValue;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Field'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: fieldName),
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Field Name'),
              ),
              TextField(
                controller: TextEditingController(text: newFieldType),
                onChanged: (value) {
                  newFieldType = value;
                },
                decoration: const InputDecoration(labelText: 'Field Type'),
              ),
              TextField(
                controller: TextEditingController(text: newFieldValue),
                onChanged: (value) {
                  newFieldValue = value;
                },
                decoration: const InputDecoration(labelText: 'Field Value'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateField(fieldName, newFieldType, newFieldValue);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _updateField(String fieldName, String fieldType, String fieldValue) async {
    Map<String, dynamic> fields = _documentDetails!['fields'];
    fields[fieldName] = {fieldType: fieldValue};

    String url = 'https://firestore.googleapis.com/v1/${widget.documentPath}?updateMask.fieldPaths=$fieldName';
    Map<String, String> headers = {
      'Authorization': 'Bearer ${widget.accessToken}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    Map<String, dynamic> body = {
      "fields": fields,
    };

    try {
      final response = await http.patch(Uri.parse(url), headers: headers, body: json.encode(body));

      if (response.statusCode == 200) {
        setState(() {
          _documentDetails!['fields'] = fields;
        });
        print('Field updated successfully');
      } else {
        print('Failed to update field. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error updating field: $error');
    }
  }

  void _showViewDialog(String fieldName, dynamic fieldValue) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('View Field'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Field Name: $fieldName'),
                const SizedBox(height: 8),
                const Text('Field Value:'),
                const SizedBox(height: 8),
                if (fieldValue is Map) ...[
                  for (var entry in fieldValue.entries)
                    // print('${entry.key}: ${entry.value}')
                    Text('${entry.key}: ${entry.value}')
                ] else if (fieldValue is List) ...[
                  for (var item in fieldValue) Text(item.toString())
                ] else
                  Text(fieldValue.toString()),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void _showMapDialog(String fieldName, Map<String, dynamic> fieldValue) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Field: $fieldName'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: _buildMapEntries(fieldValue['fields']),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildMapEntries(Map<String, dynamic> mapValue) {
    List<Widget> widgets = [];

    for (var entry in mapValue.entries) {
      String key = entry.key;
      dynamic value = entry.value;

      if (value is Map<String, dynamic>) {
        widgets.add(ListTile(
          title: Text('$key:'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildMapEntries(value),
          ),
        ));
      } else {
        widgets.add(ListTile(
          title: Text('$key: $value'),
        ));
      }
    }

    return widgets;
  }


  void _showArrayDialog(String fieldName, List<dynamic> arrayValue) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Field: $fieldName'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: arrayValue.map((item) {
                String itemType = item.keys.first;
                dynamic itemValue = item[itemType];

                return ListTile(
                  title: Text('Type: $itemType'),
                  subtitle: Text('Value: $itemValue'),
                );
              }).toList(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
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
        title: const Text('Document Details'),
      ),
      body: _isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading document details...'),
          ],
        ),
      )
          : _error != null
          ? Center(child: Text(_error!))
          : _documentDetails != null
          ? Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Document ID: ${extractDisplayName(_documentDetails!['name'])}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("Collection Name: ${widget.collectionId}"),
              const SizedBox(height: 8),
              Text('Created Time: ${_formatDateTime(_documentDetails!['createTime'])}'),
              Text('Updated Time: ${_formatDateTime(_documentDetails!['updateTime'])}'),
              const SizedBox(height: 16),
              const Text('Fields:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (_documentDetails!['fields'] != null)
                ..._documentDetails!['fields'].entries.map((entry) {
                  String fieldName = entry.key;
                  Map<String, dynamic> fieldData = entry.value;
                  String fieldType;
                  dynamic displayValue;
                  dynamic fieldValue;

                  if (fieldData.containsKey('stringValue')) {
                    fieldType = 'stringValue';
                    fieldValue = fieldData['stringValue'];
                    displayValue = fieldValue;
                  } else if (fieldData.containsKey('integerValue')) {
                    fieldType = 'integerValue';
                    fieldValue = fieldData['integerValue'];
                    displayValue = fieldValue;
                  } else if (fieldData.containsKey('timestampValue')) {
                    fieldType = 'timestampValue';
                    fieldValue = fieldData['timestampValue'];
                    displayValue = fieldValue;
                  } else if (fieldData.containsKey('mapValue')) {
                    fieldType = 'mapValue';
                    fieldValue = fieldData['mapValue'];
                    displayValue = 'Map';
                  } else if (fieldData.containsKey('arrayValue')) {
                    fieldType = 'arrayValue';
                    fieldValue = fieldData['arrayValue'];
                    displayValue = 'Array';
                    print(fieldValue);
                  } else if (fieldData.containsKey('geoPointValue')) {
                    fieldType = 'geoPointValue';
                    fieldValue = fieldData['geoPointValue'];
                    displayValue = 'GeoPoint';
                  } else if (fieldData.containsKey('nullValue')) {
                    fieldType = 'nullValue';
                    fieldValue = fieldData['nullValue'];
                    displayValue = fieldValue;
                  } else if (fieldData.containsKey("booleanValue")) {
                    fieldType = 'booleanValue';
                    fieldValue = fieldData['booleanValue'];
                    displayValue = fieldValue;
                  } else if (fieldData.containsKey("referenceValue")) {
                    fieldType = 'referenceValue';
                    fieldValue = fieldData['referenceValue'];
                    displayValue = fieldValue;
                  } else {
                    // Handle unsupported types or unexpected data structure
                    fieldType = 'unsupported';
                    fieldValue = 'Unsupported';
                    displayValue = fieldValue;
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
                          offset: const Offset(0, 3), // changes position of shadow
                        ),
                      ],
                    ),
                    child: ListTile(
                      title: Text('$fieldName ($fieldType): $displayValue'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (fieldType == 'mapValue')
                            IconButton(onPressed: () {
                              _showMapDialog(fieldName, fieldValue);
                            }, icon: const Icon(Icons.remove_red_eye)),
                          if (fieldType == 'arrayValue')
                            IconButton(
                              icon: const Icon(Icons.remove_red_eye),
                              onPressed: () {
                                _showViewDialog(fieldName, fieldValue);
                              },
                            ),
                          if (fieldType == 'geoPointValue')
                            IconButton(
                              icon: const Icon(Icons.remove_red_eye),
                              onPressed: () {
                                _showViewDialog(fieldName, fieldValue);
                              },
                            ),
                          if (fieldType != 'mapValue' &&
                              fieldType != 'arrayValue' &&
                              fieldType != 'geoPointValue')
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _showEditDialog(fieldName, fieldType, fieldValue);
                              },
                            ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              // Define your delete action here
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
      )
          : const Center(child: Text('No document details found.')),
    );
  }
}
