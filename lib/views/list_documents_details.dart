import 'dart:io';

import 'package:csv/csv.dart';
import 'package:firebase_editor_gsoc/controllers/history.dart';
import 'package:firebase_editor_gsoc/controllers/notification_services.dart';
import 'package:firebase_editor_gsoc/controllers/recent_entries.dart';
import 'package:firebase_editor_gsoc/controllers/user_controller.dart';
import 'package:firebase_editor_gsoc/views/array_field_data.dart';
import 'package:firebase_editor_gsoc/views/map_field_data.dart';
import 'package:firebase_editor_gsoc/views/utils/utils.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_editor_gsoc/views/edit_field_type.dart';
import 'package:dio/dio.dart';
import 'package:flutter_file_dialog/flutter_file_dialog.dart';

class DocumentDetailsPage extends StatefulWidget {
  final String accessToken;
  final String documentPath;
  final String projectId;
  final String databaseId;
  final String collectionId;

  const DocumentDetailsPage({
    super.key,
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

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  NotificationServices notificationServices = NotificationServices();
  RecentEntryService recentEntryService = RecentEntryService();


  @override
  void initState() {
    super.initState();
    _fetchDocumentDetails();
  }


  String extractDisplayName(String documentName) {
    List<String> parts = documentName.split("${widget.collectionId}/");
    String displayName = parts.last;
    return displayName;
  }

  /// FUNCTION FOR FETCHING DOCUMENT DETAILS
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
        setState(() {
          _documentDetails = data;
          print(_documentDetails);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error =
              'Failed to call Firestore API. Status Code: ${response.statusCode}';
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


  // Future<void> _exportDocumentToJson(Map<String, dynamic> documentData, String documentPath) async {
  //   // Request storage permission before attempting to save the file
  //   bool permissionGranted = await requestManageExternalStoragePermission(context);
  //
  //   if (!permissionGranted) {
  //     _showErrorDialog('Storage permission is required to save the file.');
  //     return;
  //   }
  //
  //   try {
  //     // Convert document data to JSON format
  //     String jsonString = jsonEncode(documentData);
  //
  //     // Get the directory for storing the file
  //     final directory = Directory('/storage/emulated/0/Download'); // Target the Downloads folder
  //
  //     // Ensure the directory exists
  //     if (!await directory.exists()) {
  //       await directory.create(recursive: true);
  //     }
  //
  //     // Extract document ID from the documentPath
  //     String documentId = documentPath.split('/').last;
  //
  //     // Set the path for the JSON file
  //     final path = '${directory.path}/$documentId.json';
  //
  //     // Write the JSON string to a file
  //     final file = File(path);
  //     await file.writeAsString(jsonString);
  //
  //
  //     // Show success message
  //     print('Document exported successfully to $path');
  //     _showExportSuccessDialog(path);
  //   } catch (e) {
  //     print('Error exporting document: $e');
  //     _showErrorDialog('Error exporting document: $e');
  //   }
  // }

  Future<void> _exportDocumentToJson(Map<String, dynamic> documentData, String documentPath, BuildContext context) async {
    try {
      // Request storage permission before attempting to save the file
      bool permissionGranted = await requestManageExternalStoragePermission(context);

      if (!permissionGranted) {
        _showErrorDialog('Storage permission is required to save the file.');
        return;
      }

      // Convert document data to JSON format
      String jsonString = jsonEncode(documentData);

      // Get the temporary directory to save the file initially
      Directory directory = await getTemporaryDirectory();
      String documentId = documentPath.split('/').last;
      String tempPath = '${directory.path}/$documentId.json';

      // Use Dio to save the file
      File tempFile = File(tempPath);
      await tempFile.writeAsString(jsonString);
      print('File temporarily saved at: $tempPath');

      // Prompt the user to save the file to their desired location (Downloads or other)
      if (Platform.isAndroid) {
        final params = SaveFileDialogParams(sourceFilePath: tempPath);
        final filePath = await FlutterFileDialog.saveFile(params: params);

        if (filePath != null) {
          print('File successfully saved to: $filePath');
          _showExportSuccessDialog(filePath);
        } else {
          print('File save was canceled.');
          _showErrorDialog('File save was canceled.');
        }
      } else if (Platform.isIOS) {
        // Directly save to the iOS Downloads folder or handle differently if needed
        final downloadsDirectory = await getDownloadsDirectory();
        final iosPath = '${downloadsDirectory?.path}/$documentId.json';
        File iosFile = await tempFile.copy(iosPath);
        print('File saved at: $iosPath');
        // _showExportSuccessDialog(iosPath);
      }
    } catch (e) {
      print('Error exporting document: $e');
      _showErrorDialog('Error exporting document: $e');
    }
  }


  Future<void> showPermissionDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // User must tap a button to dismiss the dialog
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Storage Permission Required'),
          content: const Text(
              'This app needs storage access to save files. Please enable storage permission in the app settings.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                openAppSettings(); // Open the app-specific settings page
              },
            ),
          ],
        );
      },
    );
  }

  // Future<bool> requestStoragePermission(BuildContext context) async {
  //   if (await Permission.storage.isGranted) {
  //     print("Storage permission is already granted.");
  //     return true;
  //   }
  //
  //   PermissionStatus status = await Permission.storage.request();
  //
  //   if (status.isGranted) {
  //     print("Storage permission granted.");
  //     return true;
  //   } else if (status.isDenied || status.isPermanentlyDenied) {
  //     print("Storage permission denied.");
  //     await showPermissionDialog(context); // Show the dialog if permission is denied
  //     return false;
  //   }
  //
  //   return false;
  // }
  Future<bool> requestManageExternalStoragePermission(BuildContext context) async {
    if (await Permission.manageExternalStorage.isGranted) {
      print("Manage External Storage permission is already granted.");
      return true;
    }

    PermissionStatus status = await Permission.manageExternalStorage.request();

    if (status.isGranted) {
      print("Manage External Storage permission granted.");
      return true;
    } else if (status.isDenied || status.isPermanentlyDenied) {
      print("Manage External Storage permission denied.");
      await showPermissionDialog(context); // Show the dialog if permission is denied
      return false;
    }

    return false;
  }



  void _showExportSuccessDialog(String filePath) {
    // Implement your logic to show a dialog with the file path
    print('File saved at: $filePath');
    // You can also trigger a notification or alert here
  }

  void _showErrorDialog(String message) {
    // Implement your logic to show an error dialog
    print('Error: $message');
  }


  /// FUNCTION TO READ and UPDATE FIELD VALUES OF SCALAR DATA TYPES - string, number, reference, null etc.
  // to update field values
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
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: newFieldType),
                      readOnly: true,
                      decoration:
                      const InputDecoration(labelText: 'Field Type'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditFieldTypePage(
                            fieldName: fieldName,
                            fieldType: fieldType,
                            fieldValue: fieldValue,
                            accessToken: widget.accessToken,
                            documentPath: widget.documentPath,
                            documentDetails: _documentDetails,
                          ),
                        ),
                      );
                    },
                  ),
                ],
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

    String url =
        'https://firestore.googleapis.com/v1/${widget.documentPath}?updateMask.fieldPaths=$fieldName';
    Map<String, String> headers = {
      'Authorization': 'Bearer ${widget.accessToken}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    Map<String, dynamic> body = {
      "fields": fields,
    };

    try {
      final response = await http.patch(Uri.parse(url),
          headers: headers, body: json.encode(body));

      if (response.statusCode == 200) {
        setState(() {
          _documentDetails!['fields'] = fields;

          DateTime updateTime = DateTime.now();
          insertHistory(widget.documentPath, fieldName, updateTime, 'update');
          showToast("Field '$fieldName' updated!");
          // trigger notifications
          notificationServices.triggerNotification(widget.projectId, widget.databaseId, widget.collectionId, extractDisplayName(widget.documentPath));
          recentEntryService.triggerRecentEntry(widget.projectId, widget.databaseId, widget.collectionId);
        });
        //call function for storing history
      } else {
        showErrorDialog(context, 'Failed to update field. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      showErrorDialog(context, "Failed to update field $error");
    }
  }


  /// FUNCTION TO SHOW NULL TYPE FIELD
  void _showNullEditDialog(String fieldName, String fieldType, dynamic fieldValue) {
    String newFieldType = fieldType;
    dynamic newFieldValue = fieldValue;

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
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: newFieldType),
                      readOnly: true,
                      decoration:
                      const InputDecoration(labelText: 'Field Type'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (context) => EditFieldTypePage(
                      //       fieldName: fieldName,
                      //       fieldType: fieldType,
                      //       fieldValue: fieldValue,
                      //       accessToken: widget.accessToken,
                      //       documentPath: widget.documentPath,
                      //       documentDetails: _documentDetails,
                      //     ),
                      //   ),
                      // );
                    },
                  ),
                ],
              ),
              TextField(
                controller: TextEditingController(text: 'null'),
                readOnly: true,
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

  /// FUNCTIONS FOR DELETING THE FIELDS OF A DOCUMENT
  void _deleteField(String fieldName) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content:
              Text('Are you sure you want to delete the field "$fieldName"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User cancelled
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      Map<String, dynamic> fields = _documentDetails!['fields'];

      // Remove the field from the fields map
      fields.remove(fieldName);

      // Update Firestore with the updated fields
      _updateDocument(fieldName, fields);
    }
  }
  // to update doc after deleting the value
  void _updateDocument(String fieldName, Map<String, dynamic> updatedFields) async {
    String url = 'https://firestore.googleapis.com/v1/${widget.documentPath}';
    Map<String, String> headers = {
      'Authorization': 'Bearer ${widget.accessToken}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    Map<String, dynamic> body = {
      "fields": updatedFields,
    };

    try {
      final response = await http.patch(Uri.parse(url),
          headers: headers, body: json.encode(body));

      if (response.statusCode == 200) {
        setState(() {
          _documentDetails!['fields'] = updatedFields;

          DateTime updateTime = DateTime.now();
          insertHistory(widget.documentPath, fieldName, updateTime, 'delete');
          showToast("Field Deleted!");
          notificationServices.triggerNotification(widget.projectId, widget.databaseId, widget.collectionId, extractDisplayName(widget.documentPath));
          recentEntryService.triggerRecentEntry(widget.projectId, widget.databaseId, widget.collectionId);
        });
        // Call function for storing history or any other actions after successful update
      } else {
        showErrorDialog(context, 'Failed to delete field. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      showErrorDialog(context, "Failed to delete field $error");
    }
  }


  /// FUNCTIONS FOR READING AND UPDATING GEO-POINT FIELD VALUE
  void _showGeoPointDialog(String fieldName, String fieldType, Map<String, dynamic> geoPointValue) {
    double latitude = geoPointValue['latitude'];
    double longitude = geoPointValue['longitude'];
    String newFieldType = fieldType;

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
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: newFieldType),
                      readOnly: true,
                      decoration:
                      const InputDecoration(labelText: 'Field Type'),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Navigator.of(context).push(
                      //   MaterialPageRoute(
                      //     builder: (context) => EditFieldTypePage(
                      //       fieldName: fieldName,
                      //       fieldType: fieldType,
                      //       fieldValue: geoPointValue,
                      //       accessToken: widget.accessToken,
                      //       documentPath: widget.documentPath,
                      //       documentDetails: _documentDetails,
                      //     ),
                      //   ),
                      // );
                    },
                  ),
                ],
              ),
              TextField(
                controller: TextEditingController(text: latitude.toString()),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Latitude'),
                onChanged: (value) {
                  latitude = double.tryParse(value) ?? latitude;
                },
              ),
              TextField(
                controller: TextEditingController(text: longitude.toString()),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Longitude'),
                onChanged: (value) {
                  longitude = double.tryParse(value) ?? longitude;
                },
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
                if (latitude < -90 || latitude > 90) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Latitude must be between -90 and 90.'),
                    ),
                  );
                  return;
                }
                if (longitude < -180 || longitude > 180) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Longitude must be between -180 and 180.'),
                    ),
                  );
                  return;
                }
                Navigator.of(context).pop();
                _updateGeoPointField(fieldName, latitude, longitude);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  void _updateGeoPointField(String fieldName, double latitude, double longitude) async {
    Map<String, dynamic> fields = _documentDetails!['fields'];
    fields[fieldName] = {
      'geoPointValue': {'latitude': latitude, 'longitude': longitude}
    };

    String url =
        'https://firestore.googleapis.com/v1/${widget.documentPath}?updateMask.fieldPaths=$fieldName';
    Map<String, String> headers = {
      'Authorization': 'Bearer ${widget.accessToken}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    Map<String, dynamic> body = {
      "fields": fields,
    };

    try {
      final response = await http.patch(Uri.parse(url),
          headers: headers, body: json.encode(body));

      if (response.statusCode == 200) {
        setState(() {
          _documentDetails!['fields'] = fields;
          DateTime updateTime = DateTime.now();
          insertHistory(widget.documentPath, fieldName, updateTime, 'update');
          showToast("Field '$fieldName' updated!");
          notificationServices.triggerNotification(widget.projectId, widget.databaseId, widget.collectionId, extractDisplayName(widget.documentPath));
          recentEntryService.triggerRecentEntry(widget.projectId, widget.databaseId, widget.collectionId);
        });
      } else {
        showErrorDialog(context, 'Failed to update field. Status Code: ${response.statusCode}');
      }
    } catch (error) {

      showErrorDialog(context, "Failed to update field $error");
    }
  }


  /// FUNCTIONS FOR READING AND UPDATING THE BOOLEAN FIELD VALUE
  void _showBoolDialog(String fieldName, String fieldType, bool currentValue) {
    bool newValue = currentValue;
    String newFieldType = fieldType;

    TextEditingController fieldNameController = TextEditingController(text: fieldName);
    TextEditingController fieldTypeController = TextEditingController(text: newFieldType);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Field'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.5,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextField(
                        controller: fieldNameController,
                        readOnly: true,
                        decoration: const InputDecoration(labelText: 'Field Name'),
                      ),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: fieldTypeController,
                              readOnly: true,
                              decoration: const InputDecoration(labelText: 'Field Type'),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                      DropdownButtonFormField<bool>(
                        value: newValue,
                        onChanged: (bool? selectedValue) {
                          setState(() {
                            newValue = selectedValue!;
                          });
                        },
                        items: const [
                          DropdownMenuItem(
                            value: true,
                            child: Text(
                              'true',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                          DropdownMenuItem(
                            value: false,
                            child: Text(
                              'false',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
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
                _updateBoolField(fieldName, newValue);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  void _updateBoolField(String fieldName, bool newValue) async {
    Map<String, dynamic> fields = _documentDetails!['fields'];
    fields[fieldName] = {'booleanValue': newValue};

    String url =
        'https://firestore.googleapis.com/v1/${widget.documentPath}?updateMask.fieldPaths=$fieldName';
    Map<String, String> headers = {
      'Authorization': 'Bearer ${widget.accessToken}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    Map<String, dynamic> body = {
      "fields": fields,
    };

    try {
      final response = await http.patch(Uri.parse(url),
          headers: headers, body: json.encode(body));

      if (response.statusCode == 200) {
        setState(() {
          _documentDetails!['fields'] = fields;
          DateTime updateTime = DateTime.now();
          insertHistory(widget.documentPath, fieldName, updateTime, 'update');
          showToast("Field '$fieldName' updated!");
          notificationServices.triggerNotification(widget.projectId, widget.databaseId, widget.collectionId, extractDisplayName(widget.documentPath));
          recentEntryService.triggerRecentEntry(widget.projectId, widget.databaseId, widget.collectionId);
        });
      } else {

        showErrorDialog(context, 'Failed to update field. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      showErrorDialog(context, 'Failed to update field: $error');
    }
  }


  /// FUNCTIONS FOR READING & UPDATING TIME STAMP FIELD VALUE
  void _showTimeStampEditDialog(String fieldName, String fieldType, dynamic fieldValue) {
    String newFieldType = fieldType;

    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    // Parse the current timestamp value
    DateTime currentDateTime = DateTime.parse(fieldValue);

    // Initialize selectedDate and selectedTime with current values
    selectedDate = currentDateTime;
    selectedTime = TimeOfDay.fromDateTime(currentDateTime);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Field:'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Column(
                children: [
                  TextField(
                    controller: TextEditingController(text: fieldName),
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Field Name'),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: TextEditingController(text: newFieldType),
                          readOnly: true,
                          decoration:
                              const InputDecoration(labelText: 'Field Type'),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () {
                          Navigator.of(context).pop();
                          // Navigator.of(context).push(
                          //   MaterialPageRoute(
                          //     builder: (context) => EditFieldTypePage(
                          //       fieldName: fieldName,
                          //       fieldType: fieldType,
                          //       fieldValue: fieldValue,
                          //       accessToken: widget.accessToken,
                          //       documentPath: widget.documentPath,
                          //       documentDetails: _documentDetails,
                          //     ),
                          //   ),
                          // );
                        },
                      ),
                    ],
                  ),
                ],
              ),
              // Date picker
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
                        });
                      }
                    },
                  ),
                ),
              ),
              // Time picker
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
                        });
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                DateTime newDateTime = DateTime(
                  selectedDate.year,
                  selectedDate.month,
                  selectedDate.day,
                  selectedTime.hour,
                  selectedTime.minute,
                );

                setState(() {
                  // Update the map field value with the new timestamp value at the specified index
                  fieldValue = newDateTime.toUtc().toIso8601String();
                });

                Navigator.of(context).pop(); // Close the dialog

                // Now update the entire map in Firestore
                _updateField(fieldName, fieldType, fieldValue);
              },
              child: const Text('Save'),
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

  // String extractDisplayName(String documentName) {
  //   List<String> parts = documentName.split("${widget.collectionId}/");
  //   String displayName = parts.last;
  //   return displayName;
  // }
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
      'arrayValue',
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
                    if(fieldType == 'arrayValue' || fieldType == "mapValue") {
                      // since we are creating empty array and empty map, field value won't matter
                      _addField(fieldName, fieldType, fieldType);
                    } else {
                      _addField(fieldName, fieldType, fieldValue);
                    }
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
  // void _addField(String fieldName, String fieldType, String fieldValue) async {
  //     if (_documentDetails!['fields'] == null) {
  //       _documentDetails!['fields'] = {};
  //     }
  //
  //     Map<String, dynamic> fields = {
  //       ..._documentDetails!['fields']
  //     }; // Copy existing fields
  //
  //     // Ensure the value is correctly structured and valid
  //     dynamic formattedValue;
  //     try {
  //       switch (fieldType) {
  //         case 'stringValue':
  //           formattedValue = {'stringValue': fieldValue};
  //           break;
  //         case 'integerValue':
  //           formattedValue = {'integerValue': int.parse(fieldValue)};
  //           break;
  //         case 'booleanValue':
  //           formattedValue = {'booleanValue': fieldValue.toLowerCase() == 'true' || fieldValue.toLowerCase() == 'false'} ;
  //           break;
  //         case 'mapValue':
  //           formattedValue = {'mapValue': ""};
  //           break;
  //         case 'arrayValue':
  //           formattedValue = {'arrayValue': ""};
  //           break;
  //         case 'nullValue':
  //           formattedValue = {'nullValue': ""};
  //           break;
  //         case 'timestampValue':
  //           formattedValue = {'timestampValue': fieldValue};
  //           break;
  //         case 'geoPointValue':
  //           var parts = fieldValue.split(',');
  //           var value = {
  //             'latitude': double.parse(parts[0]),
  //             'longitude': double.parse(parts[1])
  //           };
  //           formattedValue = {'geoPointValue': value};
  //           break;
  //         case 'referenceValue':
  //           formattedValue = {'referenceValue': fieldValue};
  //           break;
  //         default:
  //           showErrorDialog(context, 'Unsupported field type');
  //           return;
  //       }
  //     } catch (e) {
  //       showErrorDialog(
  //           context, 'Invalid value for the selected field type: $e');
  //       return;
  //     }
  //
  //     // Add new field
  //     fields[fieldName] = formattedValue;
  //
  //
  //     String url =
  //         'https://firestore.googleapis.com/v1/${widget.documentPath}?updateMask.fieldPaths=$fieldName';
  //     Map<String, String> headers = {
  //       'Authorization': 'Bearer ${widget.accessToken}',
  //       'Accept': 'application/json',
  //       'Content-Type': 'application/json',
  //     };
  //     Map<String, dynamic> body = {
  //       "fields": fields,
  //     };
  //
  //     try {
  //       final response = await http.patch(Uri.parse(url),
  //           headers: headers, body: json.encode(body));
  //
  //       if (response.statusCode == 200) {
  //         setState(() {
  //
  //           // update state
  //           _documentDetails!['fields'] = fields;
  //
  //           // log it
  //           DateTime updateTime = DateTime.now();
  //           insertHistory(widget.documentPath, fieldName, updateTime, 'add');
  //
  //           // show toast
  //           showToast("Field '$fieldName' added!");
  //         });
  //       } else {
  //         showErrorDialog(context, 'Failed to add field. Status Code: ${response.statusCode}');
  //       }
  //     } catch (error) {
  //       showErrorDialog(context, "Failed to add Field $error");
  //     }
  //   }
  void _addField(String fieldName, String fieldType, dynamic fieldValue) async {
    if (_documentDetails!['fields'] == null) {
      _documentDetails!['fields'] = {};
    }

    Map<String, dynamic> fields = {
      ..._documentDetails!['fields']
    }; // Copy existing fields

    // Ensure the value is correctly structured and valid
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

    // Add new field
    fields[fieldName] = formattedValue;

    String url =
        'https://firestore.googleapis.com/v1/${widget.documentPath}?updateMask.fieldPaths=$fieldName';
    Map<String, String> headers = {
      'Authorization': 'Bearer ${widget.accessToken}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    Map<String, dynamic> body = {
      "fields": fields,
    };

    try {
      final response = await http.patch(Uri.parse(url),
          headers: headers, body: json.encode(body));

      if (response.statusCode == 200) {
        setState(() {
          // update state
          _documentDetails!['fields'] = fields;

          // log it
          DateTime updateTime = DateTime.now();
          insertHistory(widget.documentPath, fieldName, updateTime, 'add');
          // show toast
          showToast("Field '$fieldName' added!");
          notificationServices.triggerNotification(widget.projectId, widget.databaseId, widget.collectionId, extractDisplayName(widget.documentPath));
          recentEntryService.triggerRecentEntry(widget.projectId, widget.databaseId, widget.collectionId);
        });
      } else {
        showErrorDialog(context, 'Failed to add field. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      showErrorDialog(context, "Failed to add Field $error");
    }
  }
  void _addArrayField(String fieldName, List<Map<String, String>> arrayFields) async {
    if (_documentDetails!['fields'] == null) {
      _documentDetails!['fields'] = {};
    }


    Map<String, dynamic> fields = {
      ..._documentDetails!['fields']
    }; // Copy existing fields

    List<dynamic> arrayValue = [];
    try {
      for (var field in arrayFields) {
        switch (field['type']) {
          case 'stringValue':
            arrayValue.add({'stringValue': field['value']});
            break;
          case 'integerValue':
            arrayValue.add({'integerValue': int.parse(field['value']!)});
            break;
          case 'booleanValue':
            arrayValue.add({'booleanValue': field['value']!.toLowerCase() == 'true'});
            break;
          case 'mapValue':
            arrayValue.add({'mapValue': {}});
            break;
          case 'nullValue':
            arrayValue.add({'nullValue': null});
            break;
          case 'timestampValue':
            arrayValue.add({'timestampValue': field['value']});
            break;
          case 'geoPointValue':
            var parts = field['value']!.split(',');
            var value = {
              'latitude': double.parse(parts[0]),
              'longitude': double.parse(parts[1])
            };
            arrayValue.add({'geoPointValue': value});
            break;
          case 'referenceValue':
            arrayValue.add({'referenceValue': field['value']});
            break;
          default:
            showErrorDialog(context, 'Unsupported field type in array');
            return;
        }
      }
    } catch (e) {
      showErrorDialog(context, 'Invalid value for the selected field type: $e');
      return;
    }

    // fields[fieldName] = {'values': {'arrayValue': arrayValue}};
    fields[fieldName] = {'arrayValue': {'values': arrayValue}};

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

          DateTime updateTime = DateTime.now();
          insertHistory(widget.documentPath, fieldName, updateTime, 'add');

          // show toast
          showToast("Field '$fieldName' added!");

        });
      } else {
        // Handle error
        showErrorDialog(context, 'Failed to add field. Status Code: ${response.statusCode}');;
      }
    } catch (error) {
      // Handle error
      showErrorDialog(context, "Failed to add Field $error");
    }
  }
  void _addMapField(String fieldName, List<Map<String, String>> mapFields) async {
    if (_documentDetails!['fields'] == null) {
      _documentDetails!['fields'] = {};
    }

    Map<String, dynamic> fields = {
      ..._documentDetails!['fields']
    }; // Copy existing fields

    Map<String, dynamic> mapValue = {};
    try {
      for (var field in mapFields) {
        switch (field['type']) {
          case 'stringValue':
            mapValue[field['name']!] = {'stringValue': field['value']};
            break;
          case 'integerValue':
            mapValue[field['name']!] = {'integerValue': int.parse(field['value']!)};
            break;
          case 'booleanValue':
            mapValue[field['name']!] = {'booleanValue': field['value']!.toLowerCase() == 'true'};
            break;
          case 'mapValue':
            mapValue[field['name']!] = {'mapValue': {}};
            break;
          case 'nullValue':
            mapValue[field['name']!] = {'nullValue': null};
            break;
          case 'timestampValue':
            mapValue[field['name']!] = {'timestampValue': field['value']};
            break;
          case 'geoPointValue':
            var parts = field['value']!.split(',');
            var value = {
              'latitude': double.parse(parts[0]),
              'longitude': double.parse(parts[1])
            };
            mapValue[field['name']!] = {'geoPointValue': value};
            break;
          case 'referenceValue':
            mapValue[field['name']!] = {'referenceValue': field['value']};
            break;
          default:
            showErrorDialog(context, 'Unsupported field type in map');
            return;
        }
      }
    } catch (e) {
      showErrorDialog(context, 'Invalid value for the selected field type: $e');
      return;
    }


    fields[fieldName] = {'mapValue': {'fields': mapValue}};

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

          DateTime updateTime = DateTime.now();
          insertHistory(widget.documentPath, fieldName, updateTime, 'add');

          // show toast
          showToast("Field '$fieldName' added!");
        });
      } else {
        // Handle error
        showErrorDialog(context, 'Failed to add field. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      // Handle error
      showErrorDialog(context, "Failed to add Field $error");
    }
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
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                      'Document ID: ${extractDisplayName(_documentDetails!['name'])}',
                                      style: const TextStyle(
                                          fontWeight: FontWeight.bold)),
                                  Text(
                                      "Collection Name: ${widget.collectionId}"),
                                  const SizedBox(height: 8),
                                  Text(
                                      'Created Time: ${_formatDateTime(_documentDetails!['createTime'])}'),
                                  Text(
                                      'Updated Time: ${_formatDateTime(_documentDetails!['updateTime'])}'),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text('Fields:',
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16.0)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        // Action to perform when the button is pressed
                                        showAddFieldDialog(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.amber,
                                      ),
                                      child: const Text('Add Field'),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.download),
                                      onPressed: () {
                                        // Define your delete action here
                                        _exportDocumentToJson(_documentDetails!, widget.documentPath, context);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            const Divider(),
                            if (_documentDetails!['fields'] != null)
                              ..._documentDetails!['fields']
                                  .entries
                                  .map((entry) {
                                String fieldName = entry.key;
                                Map<String, dynamic> fieldData = entry.value;
                                String fieldType;
                                String displayFieldType;
                                dynamic displayValue;
                                dynamic fieldValue;

                                if (fieldData.containsKey('stringValue')) {
                                  fieldType = 'stringValue';
                                  displayFieldType = 'string';
                                  fieldValue = fieldData['stringValue'];
                                  displayValue = fieldValue;
                                } else if (fieldData
                                    .containsKey('integerValue')) {
                                  fieldType = 'integerValue';
                                  displayFieldType = 'number';
                                  fieldValue = fieldData['integerValue'];
                                  displayValue = fieldValue;
                                } else if (fieldData
                                    .containsKey('timestampValue')) {
                                  fieldType = 'timestampValue';
                                  displayFieldType = 'timestamp';
                                  fieldValue = fieldData['timestampValue'];
                                  displayValue = fieldValue;
                                } else if (fieldData.containsKey('mapValue')) {
                                  fieldType = 'mapValue';
                                  displayFieldType = 'map';
                                  fieldValue = fieldData['mapValue'];
                                  displayValue = 'Map';
                                } else if (fieldData
                                    .containsKey('arrayValue')) {
                                  fieldType = 'arrayValue';
                                  displayFieldType = 'array';
                                  fieldValue = fieldData['arrayValue'];
                                  displayValue = 'Array';
                                } else if (fieldData
                                    .containsKey('geoPointValue')) {
                                  fieldType = 'geoPointValue';
                                  displayFieldType = 'geoPoint';
                                  fieldValue = fieldData['geoPointValue'];
                                  displayValue = "[${fieldValue['latitude']}, ${fieldValue['longitude']}]";
                                } else if (fieldData.containsKey('nullValue')) {
                                  fieldType = 'nullValue';
                                  displayFieldType = 'null';
                                  fieldValue = fieldData['nullValue'];
                                  displayValue = 'null';
                                } else if (fieldData
                                    .containsKey("booleanValue")) {
                                  fieldType = 'booleanValue';
                                  displayFieldType = 'boolean';
                                  fieldValue = fieldData['booleanValue'];
                                  displayValue = fieldValue;
                                } else if (fieldData
                                    .containsKey("referenceValue")) {
                                  fieldType = 'referenceValue';
                                  displayFieldType = 'reference';
                                  fieldValue = fieldData['referenceValue'];
                                  displayValue = fieldValue;
                                } else {
                                  // Handle unsupported types or unexpected data structure
                                  fieldType = 'unsupported';
                                  displayFieldType = fieldType;
                                  fieldValue = 'Unsupported';
                                  displayValue = fieldValue;
                                }
                                return Container(
                                  margin: const EdgeInsets.symmetric(
                                      horizontal: 16.0, vertical: 8.0),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15.0),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.grey.withOpacity(0.5),
                                        spreadRadius: 2,
                                        blurRadius: 5,
                                        offset: const Offset(
                                            0, 3), // changes position of shadow
                                      ),
                                    ],
                                  ),
                                  child: ListTile(
                                    title: Text(
                                        '$fieldName ($displayFieldType): $displayValue'),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        if (fieldType == 'mapValue')
                                          IconButton(
                                              onPressed: () {
                                                // _showMapDialog(fieldName, fieldValue);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        MapFieldDataPage(
                                                      fieldName: fieldName,
                                                      mapValue: fieldValue,
                                                      documentDetails:
                                                          _documentDetails,
                                                      accessToken:
                                                          widget.accessToken,
                                                      documentPath:
                                                          widget.documentPath,
                                                    ),
                                                  ),
                                                );
                                              },
                                              icon: const Icon(
                                                  Icons.remove_red_eye)),
                                        if (fieldType == 'arrayValue')
                                          IconButton(
                                            icon: const Icon(
                                                Icons.remove_red_eye),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ArrayFieldDataPage(
                                                    fieldName: fieldName,
                                                    arrayValue:
                                                        fieldValue['values'],
                                                    accessToken:
                                                        widget.accessToken,
                                                    documentDetails:
                                                        _documentDetails,
                                                    documentPath:
                                                        widget.documentPath,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        if (fieldType == 'geoPointValue')
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () {
                                              _showGeoPointDialog(fieldName, fieldType,fieldValue);
                                            },
                                          ),
                                        if (fieldType == 'booleanValue')
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () {
                                              _showBoolDialog(
                                                  fieldName, fieldType, fieldValue);
                                            },
                                          ),
                                        if (fieldType == 'timestampValue')
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () {
                                              _showTimeStampEditDialog(
                                                  fieldName,
                                                  fieldType,
                                                  fieldValue);
                                            },
                                          ),
                                        if (fieldType == 'nullValue')
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () {
                                              _showNullEditDialog(
                                                  fieldName,
                                                  fieldType,
                                                  fieldValue);
                                            },
                                          ),
                                        if (fieldType != 'mapValue' &&
                                            fieldType != 'arrayValue' &&
                                            fieldType != 'geoPointValue' &&
                                            fieldType != 'booleanValue' &&
                                            fieldType != 'timestampValue' &&
                                            fieldType != 'nullValue'
                                        )
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () {
                                              _showEditDialog(fieldName,
                                                  fieldType, fieldValue);
                                            },
                                          ),
                                        IconButton(
                                          icon: const Icon(Icons.delete),
                                          onPressed: () {
                                            // Define your delete action here
                                            _deleteField(fieldName);
                                          },
                                        ),



                                      ],
                                    ),
                                  ),
                                );
                              }).toList(),
                            const SizedBox(
                                height:
                                    20), // Space to separate the list from the button
                          ],
                        ),
                      ),
                    )
                  : const Center(child: Text('No document details found.')),
    );
  }
}
