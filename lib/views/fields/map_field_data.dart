import 'dart:convert';

import 'package:firebase_editor_gsoc/controllers/history_controller.dart';
import 'package:firebase_editor_gsoc/utils/utils.dart';
import 'package:firebase_editor_gsoc/views/nested_fields/array_within_map.dart';
import 'package:firebase_editor_gsoc/views/nested_fields/map_within_map.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MapFieldDataPage extends StatefulWidget {
  final String fieldName;
  Map<String, dynamic>? mapValue;
  Map<String, dynamic>? documentDetails;
  final String accessToken;
  final String documentPath;

  MapFieldDataPage(
      {super.key,
      required this.fieldName,
      required this.mapValue,
      required this.documentDetails,
      required this.accessToken,
      required this.documentPath});

  @override
  State<MapFieldDataPage> createState() => _MapFieldDataPageState();
}

class _MapFieldDataPageState extends State<MapFieldDataPage> {
  /// ---------------------------------------- ADD A KEY-VALUE PAIR TO MAP ------------------------------------------------  ///

  /// Displays a dialog to add a new field to a map within a Firestore document.
  ///
  /// The `showMapAddFieldDialog` function presents a dialog that allows the user to input details
  /// for a new field they wish to add to a map field in a Firestore document. Users can specify
  /// the field name, type, and value. Depending on the selected field type, additional inputs
  /// such as latitude/longitude or date/time pickers are displayed.
  ///
  /// [context]: The BuildContext in which to show the dialog.
  /// [mapFieldName]: The name of the map field to which the new field will be added.
  /// [_documentDetails]: A map containing the details of the Firestore document.
  /// [documentPath]: The Firestore document path.
  /// [accessToken]: The access token for authentication.
  /// [mapValue]: A map representing the map field within the Firestore document where the new field will be added.
  void showMapAddFieldDialog(
    BuildContext context,
    String mapFieldName,
    Map<String, dynamic>? _documentDetails,
    String documentPath,
    String accessToken,
    Map<String, dynamic>? mapValue,
  ) async {
    String fieldName = '';
    String fieldType = 'stringValue'; // Default field type
    String fieldValue = '';
    bool fieldBoolValue = true; // default value
    TextEditingController fieldValueController = TextEditingController();
    TextEditingController latitudeController = TextEditingController();
    TextEditingController longitudeController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

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
                                    fieldValue = updateTimeStampFieldValue(
                                        selectedDate, selectedTime);
                                  });
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: const Text('Time'),
                              subtitle: Text(selectedTime.format(context)),
                              trailing: const Icon(Icons.watch_later_outlined),
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
                                    fieldValue = updateTimeStampFieldValue(
                                        selectedDate, selectedTime);
                                  });
                                }
                              },
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
                    addMapField(
                        context,
                        mapFieldName,
                        fieldName,
                        fieldType,
                        fieldValue,
                        _documentDetails,
                        documentPath,
                        accessToken,
                        mapValue);
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

  /// Adds a new field to a map within a Firestore document and updates Firestore.
  ///
  /// The `addMapField` function handles adding a new field to a specified map field in a Firestore
  /// document. It ensures the field value is correctly formatted based on its type (e.g., string,
  /// integer, boolean, geoPoint, etc.), then updates the Firestore document with the new field data.
  ///
  /// [context]: The BuildContext for error dialog display.
  /// [mapFieldName]: The name of the map field to which the new field will be added.
  /// [fieldName]: The name of the new field to be added.
  /// [fieldType]: The type of the new field (e.g., stringValue, integerValue, booleanValue, etc.).
  /// [fieldValue]: The value of the new field.
  /// [_documentDetails]: A map containing the details of the Firestore document.
  /// [documentPath]: The Firestore document path.
  /// [accessToken]: The access token for authentication.
  /// [mapValue]: A map representing the map field within the Firestore document where the new field will be added.
  void addMapField(
    BuildContext context,
    String mapFieldName,
    String fieldName,
    String fieldType,
    String fieldValue,
    Map<String, dynamic>? _documentDetails,
    String documentPath,
    String accessToken,
    Map<String, dynamic>? mapValue,
  ) async {
    if (_documentDetails!['fields'] == null) {
      _documentDetails['fields'] = {};
    }

    Map<String, dynamic> fields = {
      ..._documentDetails['fields']
    }; // Copy existing fields

    // Ensure the value is correctly structured and valid
    dynamic formattedValue;
    try {
      switch (fieldType) {
        case 'stringValue':
          formattedValue = {'stringValue': fieldValue};
          mapValue!['fields'][fieldName] = formattedValue;
          break;
        case 'integerValue':
          formattedValue = {'integerValue': int.parse(fieldValue)};
          mapValue!['fields'][fieldName] = formattedValue;

          break;
        case 'booleanValue':
          formattedValue = {'booleanValue': fieldValue.toLowerCase() == 'true'};
          mapValue!['fields'][fieldName] = formattedValue;
          break;
        case 'mapValue':
          formattedValue = {
            'mapValue': {'fields': {}}
          }; // Empty map
          mapValue!['fields'][fieldName] = formattedValue;
          break;
        case 'arrayValue':
          formattedValue = {
            'arrayValue': {'values': []}
          };
          mapValue!['fields'][fieldName] = formattedValue;
        case 'nullValue':
          formattedValue = {'nullValue': null};
          mapValue!['fields'][fieldName] = formattedValue;
          break;
        case 'timestampValue':
          formattedValue = {'timestampValue': fieldValue};
          mapValue!['fields'][fieldName] = formattedValue;
          break;
        case 'geoPointValue':
          var parts = fieldValue.split(',');
          var value = {
            'latitude': double.parse(parts[0]),
            'longitude': double.parse(parts[1])
          };
          formattedValue = {'geoPointValue': value};
          mapValue!['fields'][fieldName] = formattedValue;
          break;
        case 'referenceValue':
          formattedValue = {'referenceValue': fieldValue};
          mapValue!['fields'][fieldName] = formattedValue;
          break;
        default:
          showErrorDialog(context, 'Unsupported field type');
          return;
      }
    } catch (e) {
      showErrorDialog(context, 'Invalid value for the selected field type: $e');
      return;
    }

    // Add new field to the map
    // print(fields);
    fields[mapFieldName] = {'mapValue': mapValue};

    String url =
        'https://firestore.googleapis.com/v1/$documentPath?updateMask.fieldPaths=$mapFieldName';
    Map<String, String> headers = {
      'Authorization': 'Bearer $accessToken',
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
        widget.documentDetails!['fields'] = fields;
        DateTime updateTime = DateTime.now();
        insertHistory(widget.documentPath, fieldName, updateTime, "add");
        showToast("Field Added!");
      } else {}
    } catch (error) {}
  }

  /// -------------------------------------- EDIT KEY-VALUE PAIRS IN MAP ---------------------------------------- ///

  /// Displays a dialog for editing a boolean value within a map field.
  ///
  /// The `_showEditBoolDialog` function presents a dialog with a dropdown for
  /// selecting `true` or `false`. The selected value is updated in the map field
  /// associated with the given field name. Once confirmed, the updated map is
  /// sent to Firestore.
  ///
  /// [fieldName]: The name of the field in the map to be edited.
  /// [valueType]: The type of the value, which is a boolean in this case.
  /// [value]: The current boolean value that will be edited.
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
                  widget.mapValue!['fields'][fieldName] = {valueType: newValue};
                });

                Navigator.of(context).pop(); // Close the dialog

                // Now update the entire array in Firestore
                _updateField(
                    widget.fieldName, widget.mapValue!['fields'], 'update');
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  /// Displays a dialog for editing a GeoPoint value within a map field.
  ///
  /// The `_showGeoPointEditDialog` function presents a dialog with text fields
  /// for latitude and longitude. The user can edit these values, and the changes
  /// are reflected in the GeoPoint field within the map. The updated map is then
  /// sent to Firestore.
  ///
  /// [fieldName]: The name of the GeoPoint field in the map to be edited.
  /// [geoPointValue]: A map containing the current latitude and longitude values.
  void _showGeoPointEditDialog(
      String fieldName, Map<String, dynamic> geoPointValue) {
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
                  widget.mapValue!['fields'][fieldName] = {
                    'geoPointValue': {
                      'latitude': latitude,
                      'longitude': longitude
                    }
                  };
                });

                Navigator.of(context).pop();

                // Now update the entire map in Firestore
                _updateField(
                    widget.fieldName, widget.mapValue!['fields'], 'update');
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Displays a dialog for editing a timestamp value within a map field.
  ///
  /// The `_showTimeStampEditDialog` function presents a dialog allowing the user to select
  /// a new date and time. The selected timestamp is then updated in the map field associated
  /// with the given field name. Once confirmed, the updated map is sent to Firestore.
  ///
  /// [fieldName]: The name of the timestamp field in the map to be edited.
  /// [valueType]: The type of the value, which is a timestamp in this case.
  /// [value]: The current timestamp value that will be edited.
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
                  widget.mapValue!['fields'][fieldName] = {
                    'timestampValue': newDateTime.toUtc().toIso8601String()
                  };
                });

                Navigator.of(context).pop(); // Close the dialog

                // Now update the entire map in Firestore
                _updateField(
                    widget.fieldName, widget.mapValue!['fields'], 'update');
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  /// Displays a dialog for editing a value within a map field.
  ///
  /// The `_showEditDialog` function presents a dialog where the user can edit the value
  /// of a specific key within a map. The dialog allows for different value types like
  /// `stringValue`, `integerValue`, `booleanValue`, etc. The updated value is saved and
  /// the map is updated in Firestore.
  ///
  /// [key]: The key within the map whose value is being edited.
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
                    widget.mapValue!['fields'][key] = {valueType: newValue};
                  } else if (valueType == 'integerValue') {
                    widget.mapValue!['fields'][key] = {
                      valueType: int.parse(newValue)
                    }; // Convert to integer if needed
                  } else if (valueType == 'nullValue') {
                    widget.mapValue!['fields'][key] = {valueType: newValue};
                  } else if (valueType == 'booleanValue') {
                    widget.mapValue!['fields']
                        [key] = {valueType: newValue.toLowerCase()};
                  } else if (valueType == 'referenceValue') {
                    widget.mapValue!['fields'][key] = {valueType: newValue};
                  } else {
                    // Handle unsupported types
                  }
                });

                // Update the entire map in Firestore
                // print(widget.mapValue['fields']);
                _updateField(
                    widget.fieldName, widget.mapValue!['fields'], 'update');

                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  /// -------------------------------------- DELETE A KEY-VALUE PAIR FROM MAP ------------------------------------------- ///

  /// Deletes a specified field within a map field in a Firestore document.
  ///
  /// The `_deleteFieldWithinMap` function prompts the user for confirmation before removing
  /// a specified field from a map field in a Firestore document. Upon confirmation, the field
  /// is removed from the local map and the Firestore document is updated accordingly.
  ///
  /// [fieldName]: The name of the field to be deleted from the map field.
  /// If confirmed by the user, the field is removed from the map, and Firestore is updated.
  ///
  /// Note: This function interacts with Firestore, so network connectivity is required.
  void _deleteFieldWithinMap(String fieldName) async {
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
      setState(() {
        widget.mapValue!['fields'].remove(fieldName);
      });

      // Update Firestore with the updated fields
      _updateField(widget.fieldName, widget.mapValue!['fields'], 'delete');
    }
  }

  ///  -------------------------------- UPDATE THE MAP FIELD OF THE DOCUMENT ----------------------------------------------- ///

  /// Updates a map field within a Firestore document with new data.
  ///
  /// The `_updateField` function updates a specified map field in a Firestore document
  /// with new values. The function ensures that the map field is not null before updating
  /// the document in Firestore. It also logs the operation by recording the update in
  /// the document's history.
  ///
  /// [fieldName]: The name of the map field to update.
  /// [newMapValue]: A map containing the updated fields to be stored in Firestore.
  /// [operationType]: A string indicating the type of operation (e.g., 'delete', 'update')
  ///                  for logging purposes.
  ///
  /// This function sends a PATCH request to Firestore to update the document.
  void _updateField(String fieldName, Map<String, dynamic> newMapValue,
      String operationType) async {
    Map<String, dynamic> fields = widget.documentDetails!['fields'];

    // Ensure newMapValue is not null
    if (newMapValue == null) {
      newMapValue = {};
    }

    fields[fieldName] = {
      'mapValue': {'fields': newMapValue}
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
      } else {}
    } catch (error) {}
  }

  @override
  void initState() {
    super.initState();
    if (widget.mapValue == null) {
      widget.mapValue = {'fields': {}};
    }
    if (widget.documentDetails == null) {
      widget.documentDetails = {'fields': {}};
    } else if (widget.documentDetails!['fields'] == null) {
      widget.documentDetails!['fields'] = {};
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> fields = widget.mapValue!['fields'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Map Field: ${widget.fieldName}'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Fields:", style: TextStyle(fontSize: 20.0),),
                ElevatedButton(
                  onPressed: () {
                    // Action to perform when the button is pressed
                    showMapAddFieldDialog(
                        context,
                        widget.fieldName,
                        widget.documentDetails,
                        widget.documentPath,
                        widget.accessToken,
                        widget.mapValue);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.amber,
                  ),
                  child: const Text('Add Field'),
                ),
              ],
            ),
          ),
          Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: fields.length,
              itemBuilder: (context, index) {
                String key = fields.keys.elementAt(index);
                dynamic valueData = fields[key];
                String valueType;
                String displayFieldType;
                dynamic displayValue;
                dynamic value;

                // print(valueData);

                if (valueData.containsKey('stringValue')) {
                  valueType = 'stringValue';
                  value = valueData['stringValue'];
                  displayFieldType = 'string';
                  displayValue = value;
                } else if (valueData.containsKey('integerValue')) {
                  valueType = 'integerValue';
                  value = valueData['integerValue'];
                  displayFieldType = 'number';
                  displayValue = value;
                } else if (valueData.containsKey('timestampValue')) {
                  valueType = 'timestampValue';
                  value = valueData['timestampValue'];
                  displayFieldType = 'timestamp';
                  displayValue = value;
                } else if (valueData.containsKey('mapValue')) {
                  valueType = 'mapValue';
                  value = valueData['mapValue'];
                  displayFieldType = 'map';
                  displayValue = "Map";
                } else if (valueData.containsKey('arrayValue')) {
                  valueType = 'arrayValue';
                  value = valueData['arrayValue'];
                  displayFieldType = 'array';
                  displayValue = "Array";
                } else if (valueData.containsKey('geoPointValue')) {
                  valueType = 'geoPointValue';
                  value = valueData['geoPointValue'];
                  displayFieldType = 'geopoint';
                  displayValue =
                      "[${value['latitude']}, ${value['longitude']}]";
                } else if (valueData.containsKey('nullValue')) {
                  valueType = 'nullValue';
                  value = valueData['nullValue'];
                  displayFieldType = valueType;
                  displayValue = value;
                } else if (valueData.containsKey('booleanValue')) {
                  valueType = 'booleanValue';
                  value = valueData['booleanValue'];
                  displayFieldType = 'boolean';
                  displayValue = value;
                } else if (valueData.containsKey('referenceValue')) {
                  valueType = 'referenceValue';
                  value = valueData['referenceValue'];
                  displayFieldType = 'reference';
                  displayValue = value;
                } else {
                  valueType = 'unsupported';
                  value = 'Unsupported';
                  displayFieldType = valueType;
                  displayValue = value;
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
                        offset:
                            const Offset(0, 3), // changes position of shadow
                      ),
                    ],
                  ),
                  child: ListTile(
                    title: Text('$key ($displayFieldType): $displayValue'),
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
                              _showEditDialog(
                                  key, valueType, value, valueController);
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
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ArrayWithinMapFieldDataPage(
                                            mapFieldName: widget.fieldName,
                                            arrayFieldName: key,
                                            arrayValue: value['values'],
                                            mapValue: widget.mapValue!,
                                            documentDetails:
                                                widget.documentDetails,
                                            accessToken: widget.accessToken,
                                            documentPath: widget.documentPath)),
                              );
                            },
                          ),
                        if (valueType ==
                            'mapValue') // Check if it's a map or array value
                          IconButton(
                            icon: const Icon(Icons.remove_red_eye),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        MapWithinMapFieldDataPage(
                                            parentMapFieldName:
                                                widget.fieldName,
                                            childMapFieldName: key,
                                            parentMapValue: widget.mapValue!,
                                            childMapValue: value,
                                            documentDetails:
                                                widget.documentDetails,
                                            accessToken: widget.accessToken,
                                            documentPath: widget.documentPath)),
                              );
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
          ),
        ],
      ),
    );
  }
}
