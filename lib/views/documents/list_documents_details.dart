import 'dart:io';

import 'package:firebase_editor_gsoc/controllers/history_controller.dart';
import 'package:firebase_editor_gsoc/controllers/notification_services.dart';
import 'package:firebase_editor_gsoc/controllers/recent_entries.dart';
import 'package:firebase_editor_gsoc/utils/utils.dart';
import 'package:firebase_editor_gsoc/views/fields/array_field_data.dart';
import 'package:firebase_editor_gsoc/views/fields/map_field_data.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:firebase_editor_gsoc/views/fields/edit_field_type.dart';
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
  bool _isProcessing = false;
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

  /// ----------------------------------------- FETCH DOCUMENT DETAILS ---------------------------------------------------- ///
  /// Fetches the details of a Firestore document from the Firestore REST API.
  ///
  /// The `_fetchDocumentDetails` function sends a GET request to the Firestore REST API
  /// to retrieve the details of a specific document. The function updates the local state
  /// with the retrieved document data if the request is successful. If the request fails,
  /// it updates the state with an error message. This function also handles loading states
  /// to inform the user about the ongoing data fetch operation.
  ///
  /// [context]: The build context, used to update the UI with the fetched document details.
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

  /// ----------------- READ and UPDATE FIELD VALUES OF SCALAR DATA TYPES - string, number, reference, null etc.  -------  ///

  /// Displays a dialog allowing the user to edit a field's value.
  ///
  /// The `_showEditDialog` function presents an `AlertDialog` to the user,
  /// where they can view and edit the value of a specific field in a document.
  /// The field name and field type are displayed as read-only fields, while
  /// the field value can be edited. The user can either cancel the operation
  /// or confirm the changes, which will then trigger an update to the field.
  ///
  /// [fieldName]: The name of the field being edited.
  /// [fieldType]: The type of the field (e.g., string, integer) being edited.
  /// [fieldValue]: The current value of the field being edited.
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
              // Displays the field name (read-only).
              TextField(
                controller: TextEditingController(text: fieldName),
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Field Name'),
              ),
              // Displays the field type with an option to edit it.
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
                  // Button to navigate to the field type edit page.
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
                            projectId: widget.projectId,
                            databaseId: widget.databaseId,
                            collectionId: widget.collectionId,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
              // TextField allowing the user to edit the field value.
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
            // Cancel button to close the dialog without saving changes.
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            // OK button to save changes and update the field.
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

  /// Updates a field in the Firestore document and handles related tasks.
  ///
  /// The `_updateField` function updates the specified field in a Firestore
  /// document by sending a PATCH request to the Firestore REST API. If the
  /// update is successful, the local state is updated, and related actions
  /// are triggered, such as inserting a history entry, showing a toast message,
  /// triggering notifications, and updating recent entries.
  ///
  /// [fieldName]: The name of the field to update.
  /// [fieldType]: The type of the field to update (e.g., string, integer).
  /// [fieldValue]: The new value to set for the field.
  void _updateField(
      String fieldName, String fieldType, String fieldValue) async {
    // Update the field in the local document details.
    Map<String, dynamic> fields = _documentDetails!['fields'];
    fields[fieldName] = {fieldType: fieldValue};

    // Construct the Firestore REST API URL for the PATCH request.
    String url =
        'https://firestore.googleapis.com/v1/${widget.documentPath}?updateMask.fieldPaths=$fieldName';

    // Set up the headers for the PATCH request.
    Map<String, String> headers = {
      'Authorization': 'Bearer ${widget.accessToken}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    // Construct the body of the PATCH request.
    Map<String, dynamic> body = {
      "fields": fields,
    };

    try {
      // Send the PATCH request to update the field in Firestore.
      final response = await http.patch(Uri.parse(url),
          headers: headers, body: json.encode(body));

      if (response.statusCode == 200) {
        setState(() {
          // Update the local state with the new field data.
          _documentDetails!['fields'] = fields;

          // Record the update in the history.
          DateTime updateTime = DateTime.now();
          insertHistory(widget.documentPath, fieldName, updateTime, 'update');

          // Show a toast message indicating the update was successful.
          showToast("Field '$fieldName' updated!");

          // Trigger notifications related to the update.
          notificationServices.triggerNotification(
            widget.projectId,
            widget.databaseId,
            widget.collectionId,
            extractDisplayName(widget.documentPath),
          );

          // Update the recent entries with the new update.
          recentEntryService.triggerRecentEntry(
            widget.projectId,
            widget.databaseId,
            widget.collectionId,
          );
        });
      } else {
        // Show an error dialog if the update failed.
        showErrorDialog(context,
            'Failed to update field. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      // Show an error dialog if there was an exception during the update.
      showErrorDialog(context, "Failed to update field $error");
    }
  }

  ///  ---------------------------------  READ and UPDATE GEO-POINT DATA TYPE FIELD --------------------------------------- ///

  /// Displays a dialog allowing the user to edit a GeoPoint field's latitude and longitude.
  ///
  /// The `_showGeoPointDialog` function presents an `AlertDialog` where the user
  /// can view and edit the latitude and longitude values of a specific GeoPoint field
  /// in a Firestore document. The field name and field type are displayed as read-only
  /// fields, while the latitude and longitude values can be edited. The user can cancel
  /// the operation or confirm the changes, which will then trigger an update to the GeoPoint field.
  ///
  /// [fieldName]: The name of the field being edited.
  /// [fieldType]: The type of the field being edited (in this case, GeoPoint).
  /// [geoPointValue]: A map containing the current latitude and longitude values of the GeoPoint field.
  void _showGeoPointDialog(
      String fieldName, String fieldType, Map<String, dynamic> geoPointValue) {
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
              // Displays the field name (read-only).
              TextField(
                controller: TextEditingController(text: fieldName),
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Field Name'),
              ),
              // Displays the field type with an option to edit it (currently disabled).
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
                      // Navigation to the edit field type page is currently commented out.
                    },
                  ),
                ],
              ),
              // TextField allowing the user to edit the latitude value.
              TextField(
                controller: TextEditingController(text: latitude.toString()),
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Latitude'),
                onChanged: (value) {
                  latitude = double.tryParse(value) ?? latitude;
                },
              ),
              // TextField allowing the user to edit the longitude value.
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
            // Cancel button to close the dialog without saving changes.
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            // OK button to save changes and update the GeoPoint field.
            TextButton(
              onPressed: () {
                // Validate the latitude value.
                if (latitude < -90 || latitude > 90) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Latitude must be between -90 and 90.'),
                    ),
                  );
                  return;
                }
                // Validate the longitude value.
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

  /// Updates a GeoPoint field in the Firestore document and handles related tasks.
  ///
  /// The `_updateGeoPointField` function updates the specified GeoPoint field (latitude
  /// and longitude) in a Firestore document by sending a PATCH request to the Firestore
  /// REST API. If the update is successful, the local state is updated, and related
  /// actions are triggered, such as inserting a history entry, showing a toast message,
  /// triggering notifications, and updating recent entries.
  ///
  /// [fieldName]: The name of the field to update.
  /// [latitude]: The new latitude value to set for the GeoPoint field.
  /// [longitude]: The new longitude value to set for the GeoPoint field.
  void _updateGeoPointField(
      String fieldName, double latitude, double longitude) async {
    // Update the GeoPoint field in the local document details.
    Map<String, dynamic> fields = _documentDetails!['fields'];
    fields[fieldName] = {
      'geoPointValue': {'latitude': latitude, 'longitude': longitude}
    };

    // Construct the Firestore REST API URL for the PATCH request.
    String url =
        'https://firestore.googleapis.com/v1/${widget.documentPath}?updateMask.fieldPaths=$fieldName';

    // Set up the headers for the PATCH request.
    Map<String, String> headers = {
      'Authorization': 'Bearer ${widget.accessToken}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    // Construct the body of the PATCH request.
    Map<String, dynamic> body = {
      "fields": fields,
    };

    try {
      // Send the PATCH request to update the GeoPoint field in Firestore.
      final response = await http.patch(Uri.parse(url),
          headers: headers, body: json.encode(body));

      if (response.statusCode == 200) {
        setState(() {
          // Update the local state with the new GeoPoint data.
          _documentDetails!['fields'] = fields;

          // Record the update in the history.
          DateTime updateTime = DateTime.now();
          insertHistory(widget.documentPath, fieldName, updateTime, 'update');

          // Show a toast message indicating the update was successful.
          showToast("Field '$fieldName' updated!");

          // Trigger notifications related to the update.
          notificationServices.triggerNotification(
            widget.projectId,
            widget.databaseId,
            widget.collectionId,
            extractDisplayName(widget.documentPath),
          );

          // Update the recent entries with the new update.
          recentEntryService.triggerRecentEntry(
            widget.projectId,
            widget.databaseId,
            widget.collectionId,
          );
        });
      } else {
        // Show an error dialog if the update failed.
        showErrorDialog(context,
            'Failed to update field. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      // Show an error dialog if there was an exception during the update.
      showErrorDialog(context, "Failed to update field $error");
    }
  }

  /// ----------------------------------- READ and UPDATE BOOL DATA TYPE FIELD ---------------------------------------------- ///

  /// Displays a dialog allowing the user to edit a boolean field's value.
  ///
  /// The `_showBoolDialog` function presents an `AlertDialog` where the user
  /// can view and edit the boolean value of a specific field in a Firestore document.
  /// The field name and field type are displayed as read-only fields, while the
  /// boolean value can be selected using a dropdown menu. The user can cancel the
  /// operation or confirm the changes, which will then trigger an update to the boolean field.
  ///
  /// [fieldName]: The name of the field being edited.
  /// [fieldType]: The type of the field being edited (in this case, boolean).
  /// [currentValue]: The current boolean value of the field being edited.
  void _showBoolDialog(String fieldName, String fieldType, bool currentValue) {
    bool newValue = currentValue; // Holds the updated value
    String newFieldType = fieldType; // Holds the field type

    // Controllers for the field name and field type text fields
    TextEditingController fieldNameController =
        TextEditingController(text: fieldName);
    TextEditingController fieldTypeController =
        TextEditingController(text: newFieldType);

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
                      // Displays the field name (read-only)
                      TextField(
                        controller: fieldNameController,
                        readOnly: true,
                        decoration:
                            const InputDecoration(labelText: 'Field Name'),
                      ),
                      Row(
                        children: [
                          // Displays the field type (read-only)
                          Expanded(
                            child: TextField(
                              controller: fieldTypeController,
                              readOnly: true,
                              decoration: const InputDecoration(
                                  labelText: 'Field Type'),
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
                      // Dropdown menu for selecting the boolean value
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
            // Cancel button to close the dialog without saving changes
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            // OK button to save changes and update the boolean field
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

  /// Updates a boolean field in the Firestore document and handles related tasks.
  ///
  /// The `_updateBoolField` function updates the specified boolean field in a Firestore
  /// document by sending a PATCH request to the Firestore REST API. If the update is
  /// successful, the local state is updated, and related actions are triggered, such as
  /// inserting a history entry, showing a toast message, triggering notifications, and
  /// updating recent entries.
  ///
  /// [fieldName]: The name of the field to update.
  /// [newValue]: The new boolean value to set for the field.
  void _updateBoolField(String fieldName, bool newValue) async {
    // Update the boolean field in the local document details
    Map<String, dynamic> fields = _documentDetails!['fields'];
    fields[fieldName] = {'booleanValue': newValue};

    // Construct the Firestore REST API URL for the PATCH request
    String url =
        'https://firestore.googleapis.com/v1/${widget.documentPath}?updateMask.fieldPaths=$fieldName';

    // Set up the headers for the PATCH request
    Map<String, String> headers = {
      'Authorization': 'Bearer ${widget.accessToken}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };

    // Construct the body of the PATCH request
    Map<String, dynamic> body = {
      "fields": fields,
    };

    try {
      // Send the PATCH request to update the boolean field in Firestore
      final response = await http.patch(Uri.parse(url),
          headers: headers, body: json.encode(body));

      if (response.statusCode == 200) {
        setState(() {
          // Update the local state with the new boolean data
          _documentDetails!['fields'] = fields;

          // Record the update in the history
          DateTime updateTime = DateTime.now();
          insertHistory(widget.documentPath, fieldName, updateTime, 'update');

          // Show a toast message indicating the update was successful
          showToast("Field '$fieldName' updated!");

          // Trigger notifications related to the update
          notificationServices.triggerNotification(
            widget.projectId,
            widget.databaseId,
            widget.collectionId,
            extractDisplayName(widget.documentPath),
          );

          // Update the recent entries with the new update
          recentEntryService.triggerRecentEntry(
            widget.projectId,
            widget.databaseId,
            widget.collectionId,
          );
        });
      } else {
        // Show an error dialog if the update failed
        showErrorDialog(context,
            'Failed to update field. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      // Show an error dialog if there was an exception during the update
      showErrorDialog(context, 'Failed to update field: $error');
    }
  }

  /// -------------------------------------- READ and UPDATE TIMESTAMP DATA TYPE FIELD -------------------------------------- ///

  /// Displays a dialog allowing the user to edit a timestamp field's date and time.
  ///
  /// The `_showTimeStampEditDialog` function presents an `AlertDialog` where the user
  /// can view and edit the timestamp value of a specific field in a Firestore document.
  /// The field name and field type are displayed as read-only fields, while the user
  /// can pick a new date and time using the respective pickers. The user can cancel
  /// the operation or confirm the changes, which will then trigger an update to the
  /// timestamp field.
  ///
  /// [fieldName]: The name of the field being edited.
  /// [fieldType]: The type of the field being edited (in this case, timestamp).
  /// [fieldValue]: The current timestamp value of the field being edited, in ISO 8601 format.
  void _showTimeStampEditDialog(
      String fieldName, String fieldType, dynamic fieldValue) {
    String newFieldType = fieldType; // Holds the field type

    // Parse the current timestamp value
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
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
                  // Displays the field name (read-only)
                  TextField(
                    controller: TextEditingController(text: fieldName),
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Field Name'),
                  ),
                  Row(
                    children: [
                      // Displays the field type (read-only)
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
                                projectId: widget.projectId,
                                databaseId: widget.databaseId,
                                collectionId: widget.collectionId,
                              ),
                            ),
                          );
                          // Navigation to the edit field type page is currently commented out.
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
            // Cancel button to close the dialog without saving changes
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            // Save button to update the timestamp field with the new date and time
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
                  // Update the map field value with the new timestamp value
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

  /// Formats a DateTime string into a more human-readable format.
  ///
  /// The `_formatDateTime` function takes a DateTime string in ISO 8601 format,
  /// parses it into a DateTime object, and returns a formatted string in the
  /// 'dd-MM-yyyy HH:mm' format.
  ///
  /// [dateTimeString]: The original DateTime string in ISO 8601 format.
  /// Returns a formatted string representation of the DateTime.
  String _formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
  }

  /// Converts a selected date and time into an ISO 8601 formatted string.
  ///
  /// The `_updateTimeStampFieldValue` function combines a selected date and time
  /// into a DateTime object, converts it to UTC, and returns the corresponding
  /// ISO 8601 formatted string.
  ///
  /// [date]: The selected date.
  /// [time]: The selected time.
  /// Returns the combined date and time as an ISO 8601 formatted string.
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

  ///  ------------------------------------- READ NULL DATA TYPE FIELD ----------------------------------------------------- ///
  /// Displays a dialog allowing the user to view or confirm the presence of a null field value.
  ///
  /// The `_showNullEditDialog` function presents an `AlertDialog` where the user can
  /// view the name, type, and value of a specific field in a Firestore document that has
  /// a null value. The field name and field type are displayed as read-only fields, and
  /// the value is set to "null". The user can either cancel the operation or confirm the
  /// null value, which will then trigger an update to the field in the Firestore document.
  ///
  /// [fieldName]: The name of the field being viewed or edited.
  /// [fieldType]: The type of the field (in this case, null).
  /// [fieldValue]: The current value of the field (which should be null).
  void _showNullEditDialog(
      String fieldName, String fieldType, dynamic fieldValue) {
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
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditFieldTypePage(
                            fieldName: fieldName,
                            fieldType: fieldType,
                            fieldValue: fieldValue,
                            accessToken: widget.accessToken,
                            documentPath: widget.documentPath,
                            documentDetails: _documentDetails,
                            projectId: widget.projectId,
                            databaseId: widget.databaseId,
                            collectionId: widget.collectionId,
                          ),
                        ),
                      );
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

  /// ----------------------------------------------- ADD A NEW FIELD ---------------------------------------------------- ///

  /// Displays a dialog allowing the user to add a new field to a Firestore document.
  ///
  /// The `showAddFieldDialog` function presents an `AlertDialog` where the user
  /// can define the name, type, and value of a new field to be added to a Firestore document.
  /// The field name and type are specified by the user, and based on the selected field type,
  /// appropriate input controls (such as text fields, dropdowns, or date/time pickers) are provided
  /// for entering the field value. The user can either cancel the operation or confirm the addition
  /// of the field, which will then trigger the `_addField` method to update the Firestore document.
  ///
  /// [context]: The build context where the dialog is displayed.
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
      'mapValue',
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
                      decoration:
                          const InputDecoration(labelText: 'Field Name'),
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
                      decoration:
                          const InputDecoration(labelText: 'Field Type'),
                    ),
                    if (fieldType == 'booleanValue')
                      DropdownButtonFormField<bool>(
                        value: fieldBoolValue,
                        items: const [
                          DropdownMenuItem<bool>(
                            value: true,
                            child: Text(
                              'true',
                              style: TextStyle(
                                fontSize: 14.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                          DropdownMenuItem<bool>(
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
                        onChanged: (value) {
                          setState(() {
                            fieldBoolValue = value!;
                            fieldValue = value.toString();
                          });
                        },
                        decoration:
                            const InputDecoration(labelText: 'Field Value'),
                      )
                    else if (fieldType == 'geoPointValue')
                      Column(
                        children: [
                          TextField(
                            controller: latitudeController,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'Latitude'),
                            onChanged: (value) {
                              setState(() {
                                fieldValue =
                                    '${latitudeController.text},${longitudeController.text}';
                              });
                            },
                          ),
                          TextField(
                            controller: longitudeController,
                            keyboardType: TextInputType.number,
                            decoration:
                                const InputDecoration(labelText: 'Longitude'),
                            onChanged: (value) {
                              setState(() {
                                fieldValue =
                                    '${latitudeController.text},${longitudeController.text}';
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
                                    width:
                                        2.0), // Change color and width as needed
                              ),
                              child: ListTile(
                                title: const Text('Date'),
                                subtitle:
                                    Text(selectedDate.toString().split(' ')[0]),
                                trailing:
                                    const Icon(Icons.calendar_month_outlined),
                                onTap: () async {
                                  final DateTime? pickedDate =
                                      await showDatePicker(
                                    context: context,
                                    initialDate: selectedDate,
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime(2100),
                                  );
                                  if (pickedDate != null &&
                                      pickedDate != selectedDate) {
                                    setState(() {
                                      selectedDate = pickedDate;
                                      fieldValue = _updateTimeStampFieldValue(
                                          selectedDate, selectedTime);
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
                                    width:
                                        2.0), // Change color and width as needed
                              ),
                              child: ListTile(
                                title: const Text('Time'),
                                subtitle: Text(selectedTime.format(context)),
                                trailing:
                                    const Icon(Icons.watch_later_outlined),
                                onTap: () async {
                                  final TimeOfDay? pickedTime =
                                      await showTimePicker(
                                    context: context,
                                    initialTime: selectedTime,
                                  );
                                  if (pickedTime != null &&
                                      pickedTime != selectedTime) {
                                    setState(() {
                                      selectedTime = pickedTime;
                                      fieldValue = _updateTimeStampFieldValue(
                                          selectedDate, selectedTime);
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
                        decoration:
                            const InputDecoration(labelText: 'Field Value'),
                        onChanged: (value) {
                          setState(() {
                            fieldValue = 'null';
                          });
                        },
                      )
                    else if (fieldType == 'arrayValue' ||
                        fieldType == 'mapValue')
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                            "You can add fields after creating the $fieldType"),
                      )
                    else
                      TextField(
                        controller: fieldValueController,
                        onChanged: (value) {
                          fieldValue = value;
                        },
                        decoration:
                            const InputDecoration(labelText: 'Field Value'),
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
                    if (fieldType == 'arrayValue') {
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

  /// Adds a new field to a Firestore document and handles related tasks.
  ///
  /// The `_addField` function adds a new field to the specified Firestore document by
  /// sending a PATCH request to the Firestore REST API. The function ensures that the
  /// field value is correctly structured based on its type, updates the document's fields
  /// accordingly, and performs related actions such as logging the update, showing a toast message,
  /// and triggering notifications.
  ///
  /// [fieldName]: The name of the field to be added.
  /// [fieldType]: The type of the field to be added.
  /// [fieldValue]: The value of the field to be added.
  void _addField(String fieldName, String fieldType, dynamic fieldValue) async {
    if (_documentDetails!['fields'] == null) {
      _documentDetails!['fields'] = {};
    }

    // Handle arrayValue by calling _addArrayField
    if (fieldType == 'arrayValue') {
      _addArrayField(fieldName, []);  // Pass an empty list to initialize the array
      return;  // Return early since the array field is handled by _addArrayField
    }

    // Handle mapValue by calling _addMapField
    if (fieldType == 'mapValue') {
      _addMapField(fieldName, []);  // Pass an empty list to initialize the map
      return;  // Return early since the map field is handled by _addMapField
    }

    // Proceed with adding other types of fields
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
          formattedValue = {
            'booleanValue': fieldValue.toLowerCase() == 'true' ||
                fieldValue.toLowerCase() == 'false'
          };
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

    setState(() {
      _isProcessing = true; // Start loading
    });

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
          notificationServices.triggerNotification(
              widget.projectId,
              widget.databaseId,
              widget.collectionId,
              extractDisplayName(widget.documentPath));
          recentEntryService.triggerRecentEntry(
              widget.projectId, widget.databaseId, widget.collectionId);
        });
      } else {
        showErrorDialog(context,
            'Failed to add field. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      showErrorDialog(context, "Failed to add Field $error");
    } finally {
      setState(() {
        _isProcessing = false; // Stop loading
      });
    }
  }


  /// Adds a new array field to a Firestore document and handles related tasks.
  ///
  /// The `_addArrayField` function adds a new array field to the specified Firestore document by
  /// sending a PATCH request to the Firestore REST API. The function processes each item in the
  /// `arrayFields` list, ensuring that the value is correctly structured based on its type, and
  /// then adds the entire array to the document's fields. After the update, it performs related actions
  /// such as logging the update, showing a toast message, and triggering notifications.
  ///
  /// [fieldName]: The name of the array field to be added.
  /// [arrayFields]: A list of maps where each map contains the type and value of an item in the array.
  void _addArrayField(
      String fieldName, List<Map<String, String>> arrayFields) async {
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
            arrayValue
                .add({'booleanValue': field['value']!.toLowerCase() == 'true'});
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

    fields[fieldName] = {
      'arrayValue': {'values': arrayValue}
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
          insertHistory(widget.documentPath, fieldName, updateTime, 'add');

          // show toast
          showToast("Field '$fieldName' added!");
        });
      } else {
        // Handle error
        showErrorDialog(context,
            'Failed to add field. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      // Handle error
      showErrorDialog(context, "Failed to add Field $error");
    }
  }


  /// Adds a new map field to a Firestore document and handles related tasks.
  ///
  /// The `_addMapField` function adds a new map field to the specified Firestore document by
  /// sending a PATCH request to the Firestore REST API. The function processes each entry in the
  /// `mapFields` list, ensuring that each value is correctly structured based on its type, and
  /// then adds the entire map to the document's fields. After the update, it performs related actions
  /// such as logging the update, showing a toast message, and triggering notifications.
  ///
  /// [fieldName]: The name of the map field to be added.
  /// [mapFields]: A list of maps where each map contains the name, type, and value of an entry in the map.
  void _addMapField(
      String fieldName, List<Map<String, String>> mapFields) async {
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
            mapValue[field['name']!] = {
              'integerValue': int.parse(field['value']!)
            };
            break;
          case 'booleanValue':
            mapValue[field['name']!] = {
              'booleanValue': field['value']!.toLowerCase() == 'true'
            };
            break;
          case 'mapValue':
            mapValue[field['name']!] = {'mapValue': {'fields': {}}}; // Create an empty nested map
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

    // Add the map to the document fields
    fields[fieldName] = {
      'mapValue': {'fields': mapValue}
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
          insertHistory(widget.documentPath, fieldName, updateTime, 'add');

          // show toast
          showToast("Field '$fieldName' added!");
        });
      } else {
        // Handle error
        showErrorDialog(context,
            'Failed to add field. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      // Handle error
      showErrorDialog(context, "Failed to add Field $error");
    }
  }


  /// ----------------------------------------------- DELETE A FIELD ----------------------------------------------------- ///
  /// Prompts the user to confirm the deletion of a field from a Firestore document.
  ///
  /// The `_deleteField` function displays a confirmation dialog to the user, asking
  /// whether they want to delete the specified field from the Firestore document.
  /// If the user confirms, the function removes the field from the document's local
  /// data structure and calls `_updateDocument` to apply the changes to Firestore.
  ///
  /// [fieldName]: The name of the field to be deleted.
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

  /// Updates the Firestore document after a field has been deleted or modified.
  ///
  /// The `_updateDocument` function sends a PATCH request to the Firestore REST API
  /// to update the specified document with the updated fields after a field has been
  /// deleted or modified. It then updates the local state, logs the update, shows a toast
  /// message, triggers notifications, and handles any related actions.
  ///
  /// [fieldName]: The name of the field that was deleted or modified.
  /// [updatedFields]: The updated map of fields after the deletion or modification.
  void _updateDocument(
      String fieldName, Map<String, dynamic> updatedFields) async {
    String url = 'https://firestore.googleapis.com/v1/${widget.documentPath}';
    Map<String, String> headers = {
      'Authorization': 'Bearer ${widget.accessToken}',
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    Map<String, dynamic> body = {
      "fields": updatedFields,
    };

    setState(() {
      _isProcessing = true; // Start loading
    });

    try {
      final response = await http.patch(Uri.parse(url),
          headers: headers, body: json.encode(body));

      if (response.statusCode == 200) {
        setState(() {
          _documentDetails!['fields'] = updatedFields;

          DateTime updateTime = DateTime.now();
          insertHistory(widget.documentPath, fieldName, updateTime, 'delete');
          showToast("Field Deleted!");
          notificationServices.triggerNotification(
              widget.projectId,
              widget.databaseId,
              widget.collectionId,
              extractDisplayName(widget.documentPath));
          recentEntryService.triggerRecentEntry(
              widget.projectId, widget.databaseId, widget.collectionId);
        });
        // Call function for storing history or any other actions after successful update
      } else {
        showErrorDialog(context,
            'Failed to delete field. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      showErrorDialog(context, "Failed to delete field $error");
    } finally {
      setState(() {
        _isProcessing = false; // Stop loading
      });
    }
  }

  /// ----------------------------------- DOWNLOAD DOCUMENT IN JSON FORMAT ------------------------------------------------- ///

  /// Exports a Firestore document's data to a JSON file and allows the user to save it to their device.
  ///
  /// The `_exportDocumentToJson` function converts the provided document data into a JSON format
  /// and saves it as a file on the user's device. It first requests storage permissions from the user.
  /// If permission is granted, it writes the data to a temporary file and then prompts the user to
  /// save the file to their desired location. The function handles file saving differently based on
  /// whether the device is running Android or iOS.
  ///
  /// [documentData]: The data of the Firestore document to be exported.
  /// [documentPath]: The path of the Firestore document, used to generate the file name.
  /// [context]: The build context, used to display dialogs and manage the UI.
  Future<void> _exportDocumentToJson(Map<String, dynamic> documentData,
      String documentPath, BuildContext context) async {
    try {
      // Request storage permission before attempting to save the file
      bool permissionGranted =
          await requestManageExternalStoragePermission(context);

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

      // Prompt the user to save the file to their desired location (Downloads or other)
      if (Platform.isAndroid) {
        final params = SaveFileDialogParams(sourceFilePath: tempPath);
        final filePath = await FlutterFileDialog.saveFile(params: params);

        if (filePath != null) {
          _showExportSuccessDialog(filePath);
        } else {
          _showErrorDialog('File save was canceled.');
        }
      } else if (Platform.isIOS) {
        // Directly save to the iOS Downloads folder or handle differently if needed
        final downloadsDirectory = await getDownloadsDirectory();
        final iosPath = '${downloadsDirectory?.path}/$documentId.json';
        File iosFile = await tempFile.copy(iosPath);
        // _showExportSuccessDialog(iosPath);
      }
    } catch (e) {
      _showErrorDialog('Error exporting document: $e');
    }
  }

  /// Requests permission to manage external storage on the user's device.
  ///
  /// The `requestManageExternalStoragePermission` function checks if the app has permission
  /// to manage external storage. If not, it requests the permission from the user. If the
  /// permission is denied or permanently denied, it shows a dialog informing the user that
  /// storage permission is required.
  ///
  /// [context]: The build context, used to display dialogs if needed.
  /// Returns a boolean indicating whether the permission was granted.

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

  /// Requests permission to manage external storage on the user's device.
  ///
  /// The `requestManageExternalStoragePermission` function checks if the app has permission
  /// to manage external storage. If not, it requests the permission from the user. If the
  /// permission is denied or permanently denied, it shows a dialog informing the user that
  /// storage permission is required.
  ///
  /// [context]: The build context, used to display dialogs if needed.
  /// Returns a boolean indicating whether the permission was granted.
  Future<bool> requestManageExternalStoragePermission(
      BuildContext context) async {
    if (await Permission.manageExternalStorage.isGranted) {
      return true;
    }

    PermissionStatus status = await Permission.manageExternalStorage.request();

    if (status.isGranted) {
      return true;
    } else if (status.isDenied || status.isPermanentlyDenied) {
      await showPermissionDialog(
          context); // Show the dialog if permission is denied
      return false;
    }

    return false;
  }

  /// Displays a dialog or notification indicating that the export was successful.
  ///
  /// The `_showExportSuccessDialog` function is used to inform the user that the document
  /// was successfully exported and saved to their device. It could display the file path or
  /// trigger a notification or alert based on the implementation.
  ///
  /// [filePath]: The path where the exported file was saved.
  void _showExportSuccessDialog(String filePath) {
    // Implement your logic to show a dialog with the file path
    // You can also trigger a notification or alert here
  }

  /// -------------------------------------------- UTILITY FUNCTIONS --------------------------------------------------- ///
  String extractDisplayName(String documentName) {
    List<String> parts = documentName.split("${widget.collectionId}/");
    String displayName = parts.last;
    return displayName;
  }

  void _showErrorDialog(String message) {
    // Implement your logic to show an error dialog
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Details'),
      ),
      body: _isLoading || _isProcessing
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    _isLoading
                        ? 'Loading document details...'
                        : 'Processing...Please Wait',
                  ),
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
                                        _exportDocumentToJson(_documentDetails!,
                                            widget.documentPath, context);
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
                                print(_documentDetails!['fields']);

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
                                  displayValue =
                                      "[${fieldValue['latitude']}, ${fieldValue['longitude']}]";
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
                                                      mapValue: fieldValue ?? {},
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
                                            icon: const Icon(Icons.remove_red_eye),
                                            onPressed: () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) => ArrayFieldDataPage(
                                                    fieldName: fieldName,
                                                    arrayValue: fieldValue['values'] ?? [],
                                                    accessToken: widget.accessToken,
                                                    documentDetails: _documentDetails,
                                                    documentPath: widget.documentPath,
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        if (fieldType == 'geoPointValue')
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () {
                                              _showGeoPointDialog(fieldName,
                                                  fieldType, fieldValue);
                                            },
                                          ),
                                        if (fieldType == 'booleanValue')
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () {
                                              _showBoolDialog(fieldName,
                                                  fieldType, fieldValue);
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
                                              _showNullEditDialog(fieldName,
                                                  fieldType, fieldValue);
                                            },
                                          ),
                                        if (fieldType == 'integerValue')
                                          IconButton(
                                            icon: const Icon(Icons.edit),
                                            onPressed: () {
                                              _showEditDialog(fieldName,
                                                  fieldType, fieldValue);
                                            },
                                          ),
                                        if (fieldType != 'mapValue' &&
                                            fieldType != 'arrayValue' &&
                                            fieldType != 'geoPointValue' &&
                                            fieldType != 'booleanValue' &&
                                            fieldType != 'timestampValue' &&
                                            fieldType != 'integerValue' &&
                                            fieldType != 'nullValue')
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
