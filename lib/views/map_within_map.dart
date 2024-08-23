import 'dart:convert';

import 'package:firebase_editor_gsoc/controllers/history_controller.dart';
import 'package:firebase_editor_gsoc/views/array_field_data.dart';
import 'package:firebase_editor_gsoc/views/array_within_map.dart';
import 'package:firebase_editor_gsoc/views/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MapWithinMapFieldDataPage extends StatefulWidget {
  final String parentMapFieldName;
  final String childMapFieldName;
  final Map<String, dynamic> parentMapValue;
  final Map<String, dynamic> childMapValue;
  final Map<String, dynamic>? documentDetails;
  final String accessToken;
  final String documentPath;

  const MapWithinMapFieldDataPage(
      {Key? key,
      required this.parentMapFieldName,
      required this.childMapFieldName,
      required this.parentMapValue,
      required this.childMapValue,
      required this.documentDetails,
      required this.accessToken,
      required this.documentPath})
      : super(key: key);

  @override
  State<MapWithinMapFieldDataPage> createState() =>
      _MapWithinMapFieldDataPageState();
}

class _MapWithinMapFieldDataPageState extends State<MapWithinMapFieldDataPage> {
  /// ------------------------------ UPDATE KEY-VALUE PAIR OF MAP NESTED IN A MAP ---------------------------------------- ///

  /// Updates a nested map field within a parent map and saves changes to Firestore.
  ///
  /// The `_updateField` function updates a nested map field within a parent map in
  /// Firestore. The updated map is then saved, and any changes are reflected in the
  /// Firestore document.
  ///
  /// [fieldName]: The name of the parent field containing the nested map.
  /// [newChildMapValue]: The updated map to be saved in Firestore.
  /// [operationType]: A string indicating the type of operation (e.g., 'update', 'delete').
  void _updateField(String fieldName, Map<String, dynamic> newChildMapValue,
      String operationType) async {
    Map<String, dynamic> fields = widget.documentDetails!['fields'];

    fields[fieldName]['mapValue']['fields'][widget.childMapFieldName] = {
      'mapValue': {'fields': newChildMapValue}
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
          widget.documentDetails!['fields'] = fields;
          DateTime updateTime = DateTime.now();
          insertHistory(
              widget.documentPath, fieldName, updateTime, operationType);
        });
        print('Field updated successfully');
      } else {
        print('Failed to update field. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error updating field: $error');
    }
  }

  /// ----------------------------- EDIT KEY-VALUE PAIR OF MAP NESTED IN A MAP --------------------------------------------- ///

  /// Displays a dialog to edit a boolean value within a nested map.
  ///
  /// The `_showEditBoolDialog` function presents a dialog with a dropdown menu
  /// allowing the user to select `true` or `false` for a specified field within
  /// a nested map. Once confirmed, the updated value is saved to Firestore.
  ///
  /// [fieldName]: The name of the field within the nested map to be edited.
  /// [valueType]: The type of the value, which is a boolean in this case.
  /// [value]: The current boolean value of the field.
  void _showEditBoolDialog(String fieldName, String valueType, bool value) {
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
                  widget.childMapValue['fields']
                      [fieldName] = {valueType: newValue};
                });

                Navigator.of(context).pop(); // Close the dialog

                // Now update the entire array in Firestore
                _updateField(widget.parentMapFieldName,
                    widget.childMapValue['fields'], 'update');
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  /// Displays a dialog to edit a GeoPoint value within a nested map.
  ///
  /// The `_showGeoPointEditDialog` function presents a dialog with input fields
  /// for latitude and longitude. The user can modify these values, and the changes
  /// are saved in Firestore for the specified GeoPoint field within the nested map.
  ///
  /// [fieldName]: The name of the GeoPoint field within the nested map to be edited.
  /// [geoPointValue]: A map containing the current latitude and longitude values.
  void _showGeoPointEditDialog(
      String fieldName, Map<String, dynamic> geoPointValue) {
    print(fieldName);
    print(geoPointValue);
    double latitude = geoPointValue['latitude']?.toDouble() ??
        0.0; // Ensure latitude is a double
    double longitude = geoPointValue['longitude']?.toDouble() ??
        0.0; // Ensure longitude is a double
    print("here");

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
                  widget.childMapValue['fields'][fieldName] = {
                    'geoPointValue': {
                      'latitude': latitude,
                      'longitude': longitude
                    }
                  };
                });

                Navigator.of(context).pop();

                // Now update the entire map in Firestore
                _updateField(widget.parentMapFieldName,
                    widget.childMapValue['fields'], 'update');
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Displays a dialog to edit a timestamp value within a nested map.
  ///
  /// The `_showTimeStampEditDialog` function allows the user to select a new date
  /// and time, updating the timestamp value within the specified nested map field.
  /// The changes are then saved to Firestore.
  ///
  /// [fieldName]: The name of the timestamp field within the nested map to be edited.
  /// [valueType]: The type of the value, which is a timestamp in this case.
  /// [value]: The current timestamp value of the field.
  void _showTimeStampEditDialog(
      String fieldName, String valueType, dynamic value) {
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
                title: Text('Date'),
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
                title: Text('Time'),
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
                  widget.childMapValue['fields'][fieldName] = {
                    'timestampValue': newDateTime.toUtc().toIso8601String()
                  };
                });

                Navigator.of(context).pop(); // Close the dialog

                // Now update the entire map in Firestore
                _updateField(widget.parentMapFieldName,
                    widget.childMapValue['fields'], 'update');
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  /// Displays a dialog to edit a value within a nested map.
  ///
  /// The `_showEditDialog` function allows the user to edit the value of a specific
  /// field within a nested map. The dialog supports various value types like
  /// `stringValue`, `integerValue`, `booleanValue`, etc. The updated value is saved
  /// in Firestore.
  ///
  /// [key]: The key within the nested map whose value is being edited.
  /// [valueType]: The type of the value (e.g., `stringValue`, `integerValue`).
  /// [value]: The current value associated with the key.
  /// [valueController]: A controller for handling text input for the value.
  void _showEditDialog(String key, String valueType, dynamic value,
      TextEditingController valueController) {
    dynamic newValue = value; // Initial value to display in TextField

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
                  IconButton(
                    icon: Icon(Icons.edit),
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
                controller: valueController,
                onChanged: (newValueText) {
                  newValue = newValueText; // Update the new value as user types
                },
                decoration: const InputDecoration(labelText: 'Value'),
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
                  // Update the map field value with the new value for the specified key
                  if (valueType == 'stringValue') {
                    // print(widget.mapValue['fields'][key]);
                    widget.childMapValue['fields'][key] = {valueType: newValue};
                  } else if (valueType == 'integerValue') {
                    widget.childMapValue['fields'][key] = {
                      valueType: int.parse(newValue)
                    }; // Convert to integer if needed
                  } else if (valueType == 'nullValue') {
                    widget.childMapValue['fields'][key] = {valueType: newValue};
                  } else if (valueType == 'booleanValue') {
                    widget.childMapValue['fields']
                        [key] = {valueType: newValue.toLowerCase()};
                  } else if (valueType == 'referenceValue') {
                    widget.childMapValue['fields'][key] = {valueType: newValue};
                  } else {
                    // Handle unsupported types
                  }
                });

                // Update the entire map in Firestore
                // print(widget.mapValue['fields']);
                _updateField(widget.parentMapFieldName,
                    widget.childMapValue['fields'], 'update');

                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  /// ------------------------------------------ DELETE KEY-VALUE PAIR OF MAP NESTED IN A MAP  -------------------------------///
  /// Deletes a specific field within a nested map and updates Firestore.
  ///
  /// The `_deleteFieldWithinMap` function removes a specific field from a nested map
  /// and updates Firestore with the changes. A confirmation dialog is presented before
  /// the deletion is performed.
  ///
  /// [fieldName]: The name of the field within the nested map to be deleted.
  void _deleteFieldWithinMap(String fieldName) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content:
              Text('Are you sure you want to delete the field "$fieldName"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false); // User cancelled
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // User confirmed
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      setState(() {
        widget.childMapValue['fields'].remove(fieldName);
      });

      // Update Firestore with the updated fields
      _updateField(
          widget.parentMapFieldName, widget.childMapValue['fields'], 'delete');
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> fields = widget.childMapValue['fields'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Map Field: ${widget.childMapFieldName}'),
      ),
      body: ListView.builder(
        itemCount: fields.length,
        itemBuilder: (context, index) {
          String key = fields.keys.elementAt(index);
          dynamic valueData = fields[key];
          String valueType;
          dynamic value;

          // print(valueData);

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
            value = valueData['arrayValue'];
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
                  offset: const Offset(0, 3), // changes position of shadow
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
                        // print(widget.mapValue);
                        // print(widget.mapValue.runtimeType);
                        TextEditingController valueController =
                            TextEditingController(text: value.toString());
                        _showEditDialog(key, valueType, value, valueController);
                      },
                    ),
                  if (valueType == 'geoPointValue')
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showGeoPointEditDialog(key, value);
                      },
                    ),
                  if (valueType ==
                      'timestampValue') // Check if it's a timestamp value
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        // Assuming `index` is the index of the current item in your list
                        _showTimeStampEditDialog(key, valueType, value);
                      },
                    ),
                  if (valueType ==
                      'booleanValue') // Check if it's a boolean value
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _showEditBoolDialog(key, valueType, value);
                      },
                    ),
                  if (valueType ==
                      'arrayValue') // Check if it's a map or array value
                    IconButton(
                      icon: const Icon(Icons.remove_red_eye),
                      onPressed: () {
                        showSnackBar(context,
                            "For further editing please visit Firebase.com");
                      },
                    ),
                  if (valueType ==
                      'mapValue') // Check if it's a map or array value
                    IconButton(
                      icon: const Icon(Icons.remove_red_eye),
                      onPressed: () {
                        showSnackBar(context,
                            "For further editing please visit Firebase.com");
                      },
                    ),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      // Implement delete functionality
                      _deleteFieldWithinMap(key);
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
