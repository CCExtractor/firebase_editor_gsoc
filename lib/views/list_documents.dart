import 'dart:math';

import 'package:firebase_editor_gsoc/controllers/document_controller.dart';
import 'package:firebase_editor_gsoc/controllers/history.dart';
import 'package:firebase_editor_gsoc/controllers/notification_services.dart';
import 'package:firebase_editor_gsoc/views/list_documents_details.dart';
import 'package:firebase_editor_gsoc/views/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DocumentsPage extends StatefulWidget {
  final String accessToken;
  final String projectId;
  final String databaseId;
  final String collectionId;

  const DocumentsPage({super.key,
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
  final documentController = Get.put(DocumentController());
  NotificationServices notificationServices = NotificationServices();



  bool _isBatchOperation = false;
  List<String> _selectedDocuments = [];

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


  String generateRandomId(int length) {
    const String chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
    Random random = Random();
    return String.fromCharCodes(Iterable.generate(length, (_) => chars.codeUnitAt(random.nextInt(chars.length))));
  }


  Future<void> showCreateDocumentDialog(BuildContext context) async {
    String documentId = '';

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Create Document'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              TextField(
                controller: documentController.documentIdController,
                decoration: const InputDecoration(labelText: 'Document ID'),
                onChanged: (value) {
                  documentController.documentIdController.text = value;
                },
              ),
              const SizedBox(height: 10),
              TextButton(
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue, width: 2.0), // Change color and width as needed
                    borderRadius: BorderRadius.circular(8.0), // Optional: add border radius
                  ),
                    child: const Text('Auto ID'),
                ),
                onPressed: () {
                  setState(() {
                    documentId = generateRandomId(20);
                    documentController.documentIdController.text = documentId;
                  });

                  // Update the TextField with the generated ID
                  Navigator.of(context).pop();
                  showCreateDocumentDialog(context); // Reopen the dialog to show the updated ID
                },
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                // set document id to null
                documentController.documentIdController.text = "";
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Create'),
              onPressed: () {
                if (documentController.documentIdController.text.isNotEmpty) {
                  _checkAndCreateDocument(documentController.documentIdController.text, context);
                  Navigator.of(context).pop();
                } else {
                  _showErrorDialog(context, 'Please enter a Document ID.');
                }
              },
            ),
          ],
        );
      },
    );
  }



  void _checkAndCreateDocument(String documentId, BuildContext context) async {
    String documentPath = 'projects/${widget.projectId}/databases/${widget.databaseId}/documents/${widget.collectionId}/$documentId';
    String url = 'https://firestore.googleapis.com/v1/$documentPath';
    Map<String, String> headers = {
      'Authorization': 'Bearer ${widget.accessToken}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    // Check if document exists
    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      if (response.statusCode == 200) {
        // Document exists, show error
        _showErrorDialog(context, 'Document ID already exists. Please choose a different ID.');
      } else if (response.statusCode == 404) {
        // Document does not exist, create new document
        _createDocument(documentId, context);
      } else {
        _showErrorDialog(context, 'Error checking document ID: ${response.statusCode}');
      }
    } catch (error) {
      _showErrorDialog(context, 'Error checking document ID: $error');
    }
  }

  void _createDocument(String documentId, BuildContext context) async {
    String documentPath = 'projects/${widget.projectId}/databases/${widget.databaseId}/documents/${widget.collectionId}/$documentId';
    String url = 'https://firestore.googleapis.com/v1/$documentPath';
    Map<String, String> headers = {
      'Authorization': 'Bearer ${widget.accessToken}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    Map<String, dynamic> body = {
      // Add your document fields here
    };

    try {
      final response = await http.patch(Uri.parse(url), headers: headers, body: json.encode(body));
      if (response.statusCode == 200) {
        DateTime createTime = DateTime.now();
        insertHistory(documentPath, "Document - $documentId", createTime, 'create');

        // temp for state update!
        _fetchDocuments();

        // Clear the document ID controller after creating the document
        documentController.documentIdController.text = "";

        // Show a toast message
        showToast("Document Created Successfully!");
      } else {
        showErrorDialog(context, 'Failed to create document. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      showErrorDialog(context, 'Error creating document: $error');
    }
  }



  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  void _confirmDeleteDocument(String documentPath) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Are you sure you want to delete this document?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop(); // Dismiss the dialog
                _deleteDocument(documentPath); // Proceed with deletion
              },
            ),
          ],
        );
      },
    );
  }

  void _deleteDocument(String documentPath) async {
    String url = 'https://firestore.googleapis.com/v1/$documentPath';
    Map<String, String> headers = {
      'Authorization': 'Bearer ${widget.accessToken}',
      'Accept': 'application/json',
    };

    try {
      final response = await http.delete(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {

        // String docId =
        setState(() {
          _documents.removeWhere((doc) => doc['name'] == documentPath);

          DateTime deleteTime = DateTime.now();
          insertHistory(documentPath, "Document - ${extractDisplayName(documentPath)}", deleteTime, 'delete');
        });
        showToast('Document deleted successfully!');
      } else {
        showErrorDialog(context, 'Failed to delete document. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      showErrorDialog(context, 'Failed to delete document: $error');
    }
  }


 /// Fetch document details
  Future<Map<String, dynamic>> _fetchDocumentDetails(String documentPath) async {
    String url = 'https://firestore.googleapis.com/v1/$documentPath';
    Map<String, String> headers = {
      'Authorization': 'Bearer ${widget.accessToken}',
      'Accept': 'application/json',
    };

    try {
      final response = await http.get(Uri.parse(url), headers: headers);

      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        return data['fields'] ?? {};
      } else {
        showErrorDialog(context, 'Failed to fetch document details. Status Code: ${response.statusCode}');
        return {};
      }
    } catch (error) {
      showErrorDialog(context, 'Error fetching document details: $error');
      return {};
    }
  }

  String _updateTimeStampFieldValue(DateTime date, TimeOfDay time) {
    final DateTime newDateTime = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );
    return newDateTime.toUtc().toIso8601String();
  }

  /// FUNCTIONS FOR ADDING FIELD TO DOCUMENT
  void showAddFieldDialog(BuildContext context) async {
    String fieldName = '';
    String fieldType = 'stringValue'; // Default field type
    String fieldValue = '';
    bool fieldBoolValue = true; // default value
    TextEditingController fieldValueController = TextEditingController();
    TextEditingController latitudeController = TextEditingController();
    TextEditingController longitudeController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    List<Map<String, String>> arrayFields = []; // Store array fields
    List<Map<String, String>> mapFields = []; // Store map fields

    // Dropdown menu items for field types
    List<String> fieldTypes = [
      'stringValue',
      'integerValue',
      'booleanValue',
      // 'mapValue',
      // 'arrayValue',
      'nullValue',
      'timestampValue',
      'geoPointValue',
      'referenceValue',
    ];

    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: const Text('Add Field'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextField(
                      decoration: const InputDecoration(labelText: 'Field Name'),
                      onChanged: (value) {
                        fieldName = value;
                      },
                    ),
                    DropdownButtonFormField<String>(
                      value: fieldType,
                      items: fieldTypes.map((type) {
                        return DropdownMenuItem<String>(
                          value: type,
                          child: Text(
                            type,
                            style: const TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          fieldType = value!;
                          fieldValue = '';
                          fieldValueController.text = '';
                          latitudeController.clear();
                          longitudeController.clear();
                        });
                      },
                      decoration: const InputDecoration(labelText: 'Field Type'),
                    ),
                    if (fieldType == 'booleanValue')
                      DropdownButtonFormField<bool>(
                        value: fieldBoolValue,
                        items: const [
                          DropdownMenuItem<bool>(
                            value: true,
                            child: Text('true', style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal,
                            ),),
                          ),
                          DropdownMenuItem<bool>(
                            value: false,
                            child: Text('false', style: TextStyle(
                              fontSize: 14.0,
                              fontWeight: FontWeight.normal,
                            ),),
                          ),
                        ],
                        onChanged: (value) {
                          setState(() {
                            fieldBoolValue = value!;
                            fieldValue = value.toString();
                          });
                        },
                        decoration: const InputDecoration(labelText: 'Field Value'),
                      )
                    else if (fieldType == 'geoPointValue')
                      Column(
                        children: [
                          TextField(
                            controller: latitudeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Latitude'),
                            onChanged: (value) {
                              setState(() {
                                fieldValue = '${latitudeController.text},${longitudeController.text}';
                              });
                            },
                          ),
                          TextField(
                            controller: longitudeController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Longitude'),
                            onChanged: (value) {
                              setState(() {
                                fieldValue = '${latitudeController.text},${longitudeController.text}';
                              });
                            },
                          ),
                        ],
                      )
                    else if (fieldType == 'timestampValue')
                        Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                      color: Colors.blue,
                                      width: 2.0), // Change color and width as needed
                                ),
                                child: ListTile(
                                  title: const Text('Date'),
                                  subtitle: Text(selectedDate.toString().split(' ')[0]),
                                  trailing: const Icon(Icons.calendar_month_outlined),
                                  onTap: () async {
                                    final DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: selectedDate,
                                      firstDate: DateTime(1900),
                                      lastDate: DateTime(2100),
                                    );
                                    if (pickedDate != null && pickedDate != selectedDate) {
                                      setState(() {
                                        selectedDate = pickedDate;
                                        fieldValue = _updateTimeStampFieldValue(selectedDate, selectedTime);
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  border: Border.all(
                                      color: Colors.blue,
                                      width: 2.0), // Change color and width as needed
                                ),
                                child: ListTile(
                                  title: const Text('Time'),
                                  subtitle: Text(selectedTime.format(context)),
                                  trailing: const Icon(Icons.watch_later_outlined),
                                  onTap: () async {
                                    final TimeOfDay? pickedTime = await showTimePicker(
                                      context: context,
                                      initialTime: selectedTime,
                                    );
                                    if (pickedTime != null && pickedTime != selectedTime) {
                                      setState(() {
                                        selectedTime = pickedTime;
                                        fieldValue = _updateTimeStampFieldValue(selectedDate, selectedTime);
                                      });
                                    }
                                  },
                                ),
                              ),
                            ),
                            if (fieldValue.isNotEmpty)
                              Text('Selected DateTime: $fieldValue'),
                          ],
                        )
                      else if (fieldType == 'nullValue')
                          TextField(
                            controller: fieldValueController,
                            readOnly: true,
                            decoration: const InputDecoration(labelText: 'Field Value'),
                            onChanged: (value) {
                              setState(() {
                                fieldValue = 'null';
                              });
                            },
                          )
                        else if (fieldType == 'arrayValue' || fieldType == 'mapValue')
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text("You can add fields after creating the $fieldType"),
                            )
                          else TextField(
                              controller: fieldValueController,
                              onChanged: (value) {
                                fieldValue = value;
                              },
                              decoration: const InputDecoration(labelText: 'Field Value'),
                            ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: const Text('Cancel'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: const Text('Add'),
                  onPressed: () {
                    // if(fieldType == 'arrayValue' || fieldType == "mapValue") {
                    //   // since we are creating empty array and empty map, field value won't matter
                    //   _addField(fieldName, fieldType, fieldType);
                    // } else {
                    //   _addField(fieldName, fieldType, fieldValue);
                    // }
                    _addFieldToSelectedDocuments(fieldName, fieldType, fieldValue);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }


  /// you can use this to add or update both
  Future<void> _addFieldToSelectedDocuments(String fieldName, String fieldType, dynamic fieldValue) async {
    if (_selectedDocuments.isEmpty) {
      showErrorDialog(context, 'No documents selected for batch update.');
      return;
    }

    String url = 'https://firestore.googleapis.com/v1/projects/${widget.projectId}/databases/${widget.databaseId}/documents:batchWrite';
    Map<String, String> headers = {
      'Authorization': 'Bearer ${widget.accessToken}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    List<Map<String, dynamic>> writes = [];
    for (var documentPath in _selectedDocuments) {
      Map<String, dynamic> existingFields = await _fetchDocumentDetails(documentPath);


      dynamic formattedValue;
      try {
        switch (fieldType) {
          case 'stringValue':
            formattedValue = {'stringValue': fieldValue};
            break;
          case 'integerValue':
            formattedValue = {'integerValue': int.parse(fieldValue)};
            break;
          case 'booleanValue':
            formattedValue = {'booleanValue': fieldValue.toLowerCase() == 'true' || fieldValue.toLowerCase() == 'false'};
            break;
          case 'mapValue':
            formattedValue = {'mapValue': {'fields': {}}}; // Create an empty map
            break;
          case 'arrayValue':
            formattedValue = {'arrayValue': {'values': []}}; // Create an empty array
            break;
          case 'nullValue':
            formattedValue = {'nullValue': null};
            break;
          case 'timestampValue':
            formattedValue = {'timestampValue': fieldValue};
            break;
          case 'geoPointValue':
            var parts = fieldValue.split(',');
            var value = {
              'latitude': double.parse(parts[0]),
              'longitude': double.parse(parts[1])
            };
            formattedValue = {'geoPointValue': value};
            break;
          case 'referenceValue':
            formattedValue = {'referenceValue': fieldValue};
            break;
          default:
            showErrorDialog(context, 'Unsupported field type');
            return;
        }
      } catch (e) {
        showErrorDialog(context, 'Invalid value for the selected field type: $e');
        return;
      }

      // Add new fields to the existing fields
      existingFields.addAll({
        fieldName: formattedValue,
      });

      writes.add({
        "update": {
          "fields": existingFields,
          "name": documentPath
        }
      });
    }

    Map<String, dynamic> body = {
      "writes": writes
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        showToast('Field added to selected documents successfully!');
        _fetchDocuments(); // Refresh the documents list
        // trigger notification for batch operations
        notificationServices.triggerBatchOpNotification(widget.projectId, widget.databaseId, widget.collectionId);
      } else {
        showErrorDialog(context, 'Failed to add field to documents. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      showErrorDialog(context, 'Error adding field to documents: $error');
    }
  }

  Future<void> _deleteFieldFromSelectedDocuments(String fieldName) async {
    if (_selectedDocuments.isEmpty) {
      showErrorDialog(context, 'No documents selected for batch update.');
      return;
    }

    String url = 'https://firestore.googleapis.com/v1/projects/${widget.projectId}/databases/${widget.databaseId}/documents:batchWrite';
    Map<String, String> headers = {
      'Authorization': 'Bearer ${widget.accessToken}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    List<Map<String, dynamic>> writes = [];
    for (var documentPath in _selectedDocuments) {
      Map<String, dynamic> existingFields = await _fetchDocumentDetails(documentPath);

      // Remove the specified field from the existing fields
      existingFields.remove(fieldName);

      writes.add({
        "update": {
          "fields": existingFields,
          "name": documentPath
        }
      });
    }

    Map<String, dynamic> body = {
      "writes": writes
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: headers,
        body: json.encode(body),
      );

      if (response.statusCode == 200) {
        showToast('Field deleted from selected documents successfully!');
        _fetchDocuments(); // Refresh the documents list
        // trigger notification for batch operations
        notificationServices.triggerBatchOpNotification(widget.projectId, widget.databaseId, widget.collectionId);
      } else {
        showErrorDialog(context, 'Failed to delete field from documents. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      showErrorDialog(context, 'Error deleting field from documents: $error');
    }
  }

  void showDeleteFieldDialog(BuildContext context, Function(String) onDeleteField) {
    String fieldName = '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Field'),
          content: TextField(
            decoration: const InputDecoration(labelText: 'Field Name'),
            onChanged: (value) {
              fieldName = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () {
                Navigator.of(context).pop();
                onDeleteField(fieldName);
              },
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
        title: Text('${widget.collectionId}: documents'),
      ),
      body: _isLoading
          ? const Center(
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
          : Column(
        children: [
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    // Define your button action here
                    showCreateDocumentDialog(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber, // Set the background color
                  ),
                  child: const Text('Create Document'),
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _isBatchOperation = !_isBatchOperation;
                      if (!_isBatchOperation) {
                        _selectedDocuments.clear();
                      }
                    });

                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue, // Set the background color

                  ),
                  child: Text(_isBatchOperation ? 'Cancel Batch Operation' : 'Batch Operation',),
                ),
              ),

            ],
          ),

          if (_isBatchOperation)
            Row(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      // Define your button action here
                      showAddFieldDialog(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Set the background color
                    ),
                    child: const Text('Add a Field'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: ElevatedButton(
                    onPressed: () {
                      showDeleteFieldDialog(context, (fieldName) {
                        _deleteFieldFromSelectedDocuments(fieldName);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green, // Set the background color
                    ),
                    child: const Text('Delete a Field'),
                  ),
                ),
              ],
            ),

          Expanded(
            child: ListView.builder(
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
                        offset: const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: _isBatchOperation
                        ? Checkbox(
                      value: _selectedDocuments.contains(document['name']),
                      onChanged: (bool? value) {
                        setState(() {
                          if (value == true) {
                            _selectedDocuments.add(document['name']);
                          } else {
                            _selectedDocuments.remove(document['name']);
                          }

                          print("checkbox enabled");
                          if (_isBatchOperation && _selectedDocuments.isNotEmpty) {
                            print('Selected Documents: $_selectedDocuments');
                          }
                        });
                      },
                    )
                        : null,
                    title: Text("Document ID: ${extractDisplayName(document['name'])}"),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Created Time: ${_formatDateTime(document['createTime'])}'),
                        Text('Updated Time: ${_formatDateTime(document['updateTime'])}'),
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () {
                                // Define your button action here
                                _showDocumentDetails(document['name']);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.amber, // Set the background color
                              ),
                              child: const Text('View Fields'),
                            ),
                            IconButton(
                              onPressed: () {
                                _confirmDeleteDocument(document['name']);
                              },
                              icon: const Icon(Icons.delete),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );

                // return Container(
                //   margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                //   decoration: BoxDecoration(
                //     color: Colors.white,
                //     borderRadius: BorderRadius.circular(15.0),
                //     boxShadow: [
                //       BoxShadow(
                //         color: Colors.grey.withOpacity(0.5),
                //         spreadRadius: 2,
                //         blurRadius: 5,
                //         offset: const Offset(0, 3), // changes position of shadow
                //       ),
                //     ],
                //   ),
                //   child: ListTile(
                //     title: Text("Document ID: ${extractDisplayName(document['name'])}"),
                //     subtitle: Column(
                //       crossAxisAlignment: CrossAxisAlignment.start,
                //       children: [
                //         Text('Created Time: ${_formatDateTime(document['createTime'])}'),
                //         Text('Updated Time: ${_formatDateTime(document['updateTime'])}'),
                //         Row(
                //           children: [
                //             ElevatedButton(
                //               onPressed: () {
                //                 // Define your button action here
                //                 _showDocumentDetails(document['name']);
                //               },
                //               style: ElevatedButton.styleFrom(
                //                 backgroundColor: Colors.amber, // Set the background color
                //               ),
                //               child: const Text('View Fields'),
                //             ),
                //
                //             IconButton(onPressed: ()
                //             {
                //               _confirmDeleteDocument(document['name']);
                //             },
                //                 icon: const Icon(Icons.delete)),
                //           ],
                //         ),
                //       ],
                //     ),
                //   ),
                // );
              },
            ),
          ),
        ],
      ),
    );
  }

}
