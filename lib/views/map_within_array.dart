import 'dart:convert';
import 'package:firebase_editor_gsoc/views/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MapWithinArrayFieldDataPage extends StatefulWidget {
  final String arrayFieldName;
  final String mapFieldName;
  final List<dynamic> arrayValue;
  final Map<String, dynamic> mapValue;
  final Map<String, dynamic>? documentDetails;
  final String accessToken;
  final String documentPath;
  final int index;

  const MapWithinArrayFieldDataPage(
      {super.key,
      required this.arrayFieldName,
      required this.mapFieldName,
      required this.arrayValue,
      required this.mapValue,
      required this.documentDetails,
      required this.accessToken,
      required this.documentPath,
      required this.index});

  @override
  State<MapWithinArrayFieldDataPage> createState() =>
      _MapWithinArrayFieldDataPageState();
}

class _MapWithinArrayFieldDataPageState
    extends State<MapWithinArrayFieldDataPage> {
  /// ---------------------------------------------------- EDIT KEY-VALUE PAIR OF MAP WITHIN ARRAY ------------------------ ////

  /// Displays a dialog for editing a boolean value within an array element.
  ///
  /// The `_showEditBoolDialog` function presents a dialog with a dropdown menu
  /// for selecting either `true` or `false`. The selected value is updated
  /// in the specified array element within the map field. After the user confirms,
  /// the updated map is saved to Firestore.
  ///
  /// [fieldName]: The name of the field in the map to be edited.
  /// [valueType]: The type of the value, which is a boolean in this case.
  /// [value]: The current boolean value.
  /// [index]: The index of the array element being edited.
  void _showEditBoolDialog(
      String fieldName, String valueType, bool value, int index) {
    bool newValue = value; // Initial value to display in DropdownButton

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Array Element'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Field Type: $valueType'),
              DropdownButton<bool>(
                value: newValue,
                items: const [
                  DropdownMenuItem(
                    value: true,
                    child: Text('True'),
                  ),
                  DropdownMenuItem(
                    value: false,
                    child: Text('False'),
                  ),
                ],
                onChanged: (newValueValue) {
                  newValue =
                      newValueValue!; // Update the new value when user selects from the dropdown
                },
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
                setState(() {
                  // Update widget.arrayValue with the new boolean value at the specified index
                  widget.mapValue['fields'][fieldName] = {valueType: newValue};
                });

                Navigator.of(context).pop(); // Close the dialog

                // Now update the entire array in Firestore
                _updateField(
                    widget.arrayFieldName, index, widget.mapValue['fields']);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  /// Displays a dialog for editing a boolean value within an array element.
  ///
  /// The `_showEditBoolDialog` function presents a dialog with a dropdown menu
  /// for selecting either `true` or `false`. The selected value is updated
  /// in the specified array element within the map field. After the user confirms,
  /// the updated map is saved to Firestore.
  ///
  /// [fieldName]: The name of the field in the map to be edited.
  /// [valueType]: The type of the value, which is a boolean in this case.
  /// [value]: The current boolean value.
  /// [index]: The index of the array element being edited.
  void _showGeoPointEditDialog(
      String fieldName, Map<String, dynamic> geoPointValue, int index) {
    double latitude = geoPointValue['latitude']?.toDouble() ??
        0.0; // Ensure latitude is a double
    double longitude = geoPointValue['longitude']?.toDouble() ??
        0.0; // Ensure longitude is a double

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit GeoPoint: $fieldName'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
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
                if (latitude < -90.0 || latitude > 90.0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Latitude must be between -90 and 90.'),
                    ),
                  );
                  return;
                }
                if (longitude < -180.0 || longitude > 180.0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Longitude must be between -180 and 180.'),
                    ),
                  );
                  return;
                }

                setState(() {
                  widget.mapValue['fields'][fieldName] = {
                    'geoPointValue': {
                      'latitude': latitude,
                      'longitude': longitude
                    }
                  };
                });

                Navigator.of(context).pop();

                // Now update the entire map in Firestore
                _updateField(
                    widget.arrayFieldName, index, widget.mapValue['fields']);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Displays a dialog for editing a timestamp value within an array element.
  ///
  /// The `_showTimeStampEditDialog` function allows the user to select a new
  /// date and time. The selected timestamp is then updated in the specified array
  /// element within the map field. After the user confirms, the updated map is
  /// saved to Firestore.
  ///
  /// [fieldName]: The name of the timestamp field in the map to be edited.
  /// [valueType]: The type of the value, which is a timestamp in this case.
  /// [value]: The current timestamp value.
  /// [index]: The index of the array element being edited.
  void _showTimeStampEditDialog(
      String fieldName, String valueType, dynamic value, int index) {
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    // Parse the current timestamp value
    DateTime currentDateTime = DateTime.parse(value);

    // Initialize selectedDate and selectedTime with current values
    selectedDate = currentDateTime;
    selectedTime = TimeOfDay.fromDateTime(currentDateTime);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Timestamp'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Date picker
              ListTile(
                title: const Text('Date'),
                subtitle: Text(selectedDate.toString().split(' ')[0]),
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
              // Time picker
              ListTile(
                title: const Text('Time'),
                subtitle: Text(selectedTime.format(context)),
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
                  widget.mapValue['fields'][fieldName] = {
                    'timestampValue': newDateTime.toUtc().toIso8601String()
                  };
                });

                Navigator.of(context).pop(); // Close the dialog

                // Now update the entire map in Firestore
                _updateField(
                    widget.arrayFieldName, index, widget.mapValue['fields']);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  /// Displays a dialog for editing a value within a map field inside an array.
  ///
  /// The `_showEditDialog` function presents a dialog where the user can edit the value
  /// of a specific key within a map field inside an array. The dialog allows editing of
  /// various value types like `stringValue`, `integerValue`, `booleanValue`, etc. The
  /// updated value is saved, and the array is updated in Firestore.
  ///
  /// [key]: The key within the map whose value is being edited.
  /// [valueType]: The type of the value (e.g., `stringValue`, `integerValue`).
  /// [value]: The current value associated with the key.
  /// [valueController]: A controller for handling text input for the value.
  /// [index]: The index of the array element being edited.
  void _showEditDialog(String key, String valueType, dynamic value,
      TextEditingController valueController, int index) {
    dynamic newValue = value;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Map Field Value'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: key),
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Key'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: valueType),
                      readOnly: true,
                      decoration:
                          const InputDecoration(labelText: 'Value Type'),
                    ),
                  ),
                ],
              ),
              TextField(
                controller: valueController,
                onChanged: (newValueText) {
                  newValue = newValueText;
                },
                decoration: const InputDecoration(labelText: 'Value'),
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
                setState(() {
                  if (valueType == 'stringValue') {
                    widget.mapValue['fields'][key] = {valueType: newValue};
                  } else if (valueType == 'integerValue') {
                    widget.mapValue['fields']
                        [key] = {valueType: int.parse(newValue)};
                  } else if (valueType == 'nullValue') {
                    widget.mapValue['fields'][key] = {valueType: newValue};
                  } else if (valueType == 'booleanValue') {
                    widget.mapValue['fields']
                        [key] = {valueType: newValue.toLowerCase()};
                  } else if (valueType == 'referenceValue') {
                    widget.mapValue['fields'][key] = {valueType: newValue};
                  } else {
                    // Handle unsupported types
                  }
                });

                _updateField(
                    widget.arrayFieldName, index, widget.mapValue['fields']);

                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  /// ------------------------------- UPDATE KEY-VALUE PAIR OF MAP WITHIN ARRAY ------------------------------------------- ///

  /// Updates a specific map field within an array in Firestore.
  ///
  /// The `_updateField` function updates a map field within an array at a specified
  /// index in Firestore. The changes are sent to Firestore, and if the update is
  /// successful, the local document details are updated.
  ///
  /// [arrayFieldName]: The name of the array field containing the map to be updated.
  /// [index]: The index of the array element being updated.
  /// [updatedMap]: The updated map to be saved in Firestore.
  void _updateField(
      String arrayFieldName, int index, Map<String, dynamic> updatedMap) async {
    Map<String, dynamic> fields = widget.documentDetails!['fields'];

    // Update the specific map within the array
    fields[arrayFieldName]['arrayValue']['values'][index]['mapValue']
        ['fields'] = updatedMap;

    String url =
        'https://firestore.googleapis.com/v1/${widget.documentPath}?updateMask.fieldPaths=$arrayFieldName';
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
          widget.documentDetails!['fields'] = fields;
          DateTime updateTime = DateTime.now();
          // Update history here
        });
      } else {}
    } catch (error) {}
  }

  /// ------------------------------- DELETE A KEY-VALUE PAIR OF A MAP WITHIN AN ARRAY ---------------------------------- ///

  /// Displays a confirmation dialog before deleting a field within a map in an array.
  ///
  /// The `_showDeleteConfirmationDialog` function presents a dialog asking the user
  /// to confirm the deletion of a specific field within a map inside an array. If
  /// the user confirms, the specified field is deleted from Firestore.
  ///
  /// [arrayFieldName]: The name of the array field containing the map with the field to delete.
  /// [index]: The index of the array element containing the field to delete.
  /// [key]: The key of the field within the map to be deleted.
  void _showDeleteConfirmationDialog(
      String arrayFieldName, int index, String key) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Field'),
          content: const Text('Are you sure you want to delete this field?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _deleteField(
                    arrayFieldName, index, key); // Call the delete function
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  /// Deletes a specific field within a map inside an array and updates Firestore.
  ///
  /// The `_deleteField` function removes a specific field from a map within an array at
  /// the specified index. The changes are then sent to Firestore, and if the deletion is
  /// successful, the local document details are updated.
  ///
  /// [arrayFieldName]: The name of the array field containing the map with the field to delete.
  /// [index]: The index of the array element containing the field to delete.
  /// [key]: The key of the field within the map to be deleted.
  void _deleteField(String arrayFieldName, int index, String key) async {
    Map<String, dynamic> fields = widget.documentDetails!['fields'];

    // Remove the specific field from the map within the array
    fields[arrayFieldName]['arrayValue']['values'][index]['mapValue']['fields']
        .remove(key);

    String url =
        'https://firestore.googleapis.com/v1/${widget.documentPath}?updateMask.fieldPaths=$arrayFieldName';
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
          widget.documentDetails!['fields'] = fields;
          DateTime updateTime = DateTime.now();
          // Update history here
        });
      } else {}
    } catch (error) {}
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> fields = widget.mapValue['fields'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Map Field: ${widget.mapFieldName}'),
      ),
      body: ListView.builder(
        itemCount: fields.length,
        itemBuilder: (context, index) {
          String key = fields.keys.elementAt(index);
          dynamic valueData = fields[key];
          String valueType;
          dynamic value;

          if (valueData.containsKey('stringValue')) {
            valueType = 'stringValue';
            value = valueData['stringValue'];
          } else if (valueData.containsKey('integerValue')) {
            valueType = 'integerValue';
            value = valueData['integerValue'];
          } else if (valueData.containsKey('timestampValue')) {
            valueType = 'timestampValue';
            value = valueData['timestampValue'];
          } else if (valueData.containsKey('mapValue')) {
            valueType = 'mapValue';
            value = 'Map';
          } else if (valueData.containsKey('arrayValue')) {
            valueType = 'arrayValue';
            value = 'Array';
          } else if (valueData.containsKey('geoPointValue')) {
            valueType = 'geoPointValue';
            value = valueData['geoPointValue'];
          } else if (valueData.containsKey('nullValue')) {
            valueType = 'nullValue';
            value = valueData['nullValue'];
          } else if (valueData.containsKey('booleanValue')) {
            valueType = 'booleanValue';
            value = valueData['booleanValue'];
          } else if (valueData.containsKey('referenceValue')) {
            valueType = 'referenceValue';
            value = valueData['referenceValue'];
          } else {
            valueType = 'unsupported';
            value = 'Unsupported';
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
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ListTile(
              title: Text('$key ($valueType): $value'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (valueType != 'mapValue' &&
                      valueType != 'arrayValue' &&
                      valueType != 'geoPointValue' &&
                      valueType != 'booleanValue' &&
                      valueType != 'timestampValue')
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        TextEditingController valueController =
                            TextEditingController(text: value.toString());
                        _showEditDialog(key, valueType, value, valueController,
                            widget.index);
                      },
                    ),
                  if (valueType == 'geoPointValue')
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Handle GeoPoint edit
                        // don't pass simple index instead of widget.index, it will pass index of map not array
                        _showGeoPointEditDialog(key, value, widget.index);
                      },
                    ),
                  if (valueType == 'timestampValue')
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Handle Timestamp edit
                        // don't pass simple index instead of widget.index, it will pass index of map not array
                        _showTimeStampEditDialog(
                            key, valueType, value, widget.index);
                      },
                    ),
                  if (valueType == 'booleanValue')
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Handle Boolean edit
                        // don't pass simple index instead of widget.index, it will pass index of map not array
                        _showEditBoolDialog(
                            key, valueType, value, widget.index);
                      },
                    ),
                  if (valueType == 'mapValue' || valueType == 'arrayValue')
                    IconButton(
                      icon: const Icon(Icons.remove_red_eye),
                      onPressed: () {
                        // Handle nested map/array view
                        showSnackBar(context,
                            "For further editing please visit Firebase.com");
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      // Implement delete functionality
                      _showDeleteConfirmationDialog(
                          widget.arrayFieldName, widget.index, key);
                    },
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
