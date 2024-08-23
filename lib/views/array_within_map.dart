import 'package:firebase_editor_gsoc/controllers/history_controller.dart';
import 'package:firebase_editor_gsoc/views/datatypes/array.dart';
import 'package:firebase_editor_gsoc/views/map_field_data.dart';
import 'package:firebase_editor_gsoc/views/map_within_array.dart';
import 'package:firebase_editor_gsoc/views/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ArrayWithinMapFieldDataPage extends StatefulWidget {
  final String mapFieldName;
  final String arrayFieldName;
  final List<dynamic> arrayValue;
  final Map<String, dynamic> mapValue;
  final Map<String, dynamic>? documentDetails;
  final String accessToken;
  final String documentPath;

  const ArrayWithinMapFieldDataPage({
    Key? key,
    required this.mapFieldName,
    required this.arrayFieldName,
    required this.arrayValue,
    required this.mapValue,
    required this.documentDetails,
    required this.accessToken,
    required this.documentPath,
  }) : super(key: key);

  @override
  State<ArrayWithinMapFieldDataPage> createState() =>
      _ArrayWithinMapFieldDataPageState();
}

class _ArrayWithinMapFieldDataPageState
    extends State<ArrayWithinMapFieldDataPage> {
  /// Displays a dialog allowing the user to edit an element within an array field inside a map in a Firestore document.
  ///
  /// The `_showEditDialog` function presents an `AlertDialog` where the user can modify the value of an
  /// array element at a specific index. The dialog displays the field name, type, and current value,
  /// allowing the user to change the value. After editing, the new value is applied to the array, and the
  /// `_updateField` function is called to update the array field within the map in Firestore.
  ///
  /// [fieldName]: The name of the field being edited.
  /// [valueType]: The type of the value (e.g., stringValue, integerValue).
  /// [value]: The current value of the field at the specified index.
  /// [index]: The index of the element in the array to be edited.
  void _showEditDialog(
      String fieldName, String valueType, dynamic value, int index) {
    dynamic newValue = value; // Initial value to display in TextField

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Array Element'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: TextEditingController(text: fieldName),
                readOnly: true,
                decoration: const InputDecoration(labelText: 'Index'),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: valueType),
                      readOnly: true,
                      decoration:
                          const InputDecoration(labelText: 'Field Type'),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              TextField(
                controller: TextEditingController(text: newValue.toString()),
                onChanged: (newValueText) {
                  newValue = newValueText; // Update the new value as user types
                },
                decoration: const InputDecoration(labelText: 'Field Value'),
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
                  // Update widget.arrayValue with the new value at the specified index
                  if (valueType == 'stringValue') {
                    widget.arrayValue[index]['stringValue'] = newValue;
                  } else if (valueType == 'integerValue') {
                    widget.arrayValue[index]['integerValue'] =
                        int.parse(newValue); // Convert to integer if needed
                  } else if (valueType == 'timestampValue') {
                    // Handle timestamp update logic
                  } else if (valueType == 'mapValue') {
                    // Handle map update logic
                  } else if (valueType == 'arrayValue') {
                    // Handle array update logic
                  } else if (valueType == 'geoPointValue') {
                    // Handle geoPoint update logic
                  } else if (valueType == 'nullValue') {
                    widget.arrayValue[index]['nullValue'] = newValue;
                  } else if (valueType == 'booleanValue') {
                    widget.arrayValue[index]['booleanValue'] =
                        newValue.toLowerCase() == 'true' ||
                            newValue.toLowerCase() ==
                                'false'; // Convert to boolean if needed
                  } else if (valueType == 'referenceValue') {
                    // Handle reference update logic
                    widget.arrayValue[index]['referenceValue'] = newValue;
                  } else {
                    // Handle unsupported types
                  }
                });

                Navigator.of(context).pop(); // Close the dialog

                // Now update the entire array in Firestore
                _updateField(widget.mapFieldName, widget.arrayValue, 'update');
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  /// Updates an array field within a map field in a Firestore document.
  ///
  /// The `_updateField` function sends a PATCH request to the Firestore REST API to update a specified
  /// array field within a map field in a Firestore document. The function updates the array with the new
  /// value, constructs the necessary JSON body, and sends it to Firestore. It also logs the operation
  /// (e.g., 'update') and updates the local state with the new field data.
  ///
  /// [fieldName]: The name of the field to be updated.
  /// [newArrayValue]: The updated array value to replace the existing array in the map field.
  /// [operationType]: A string indicating the type of operation performed (e.g., 'update').
  void _updateField(String fieldName, List<dynamic> newArrayValue,
      String operationType) async {
    Map<String, dynamic> fields = widget.documentDetails!['fields'];

    // here i need to update the array within the map
    // fields[widget.fieldName]['mapValue']
    // print(fields);
    // print(fields[widget.mapFieldName]);

    // update the array
    fields[widget.mapFieldName]['mapValue']['fields'][widget.arrayFieldName] = {
      'arrayValue': {'values': newArrayValue}
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

  /// Prompts the user to confirm the deletion of an element from an array within a map field in a Firestore document.
  ///
  /// The `_deleteFieldFromArray` function displays a confirmation dialog asking the user whether they
  /// want to delete an element at a specified index in an array. If the user confirms the deletion, the
  /// function removes the element from the array and then calls `_updateField` to apply the changes to
  /// the array within the map field in Firestore.
  ///
  /// [index]: The index of the element in the array to be deleted.
  void _deleteFieldFromArray(int index) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Deletion'),
          content: Text(
              'Are you sure you want to delete the element at index $index?'),
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
        widget.arrayValue.removeAt(index);
      });

      // Update Firestore with the updated array
      _updateField(widget.mapFieldName, widget.arrayValue, 'delete');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Array Field: ${widget.arrayFieldName}'),
      ),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: () {
              // Action to perform when the button is pressed
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
            ),
            child: Text('Add Field'),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: widget.arrayValue.length,
              itemBuilder: (context, index) {
                dynamic valueData = widget.arrayValue[index];
                String valueType;
                String displayValueType = 'string'; // default datatype
                dynamic value;
                dynamic displayValue;

                if (valueData.containsKey('stringValue')) {
                  valueType = 'stringValue';
                  displayValueType = 'string';
                  value = valueData['stringValue'];
                  displayValue = value;
                } else if (valueData.containsKey('integerValue')) {
                  valueType = 'integerValue';
                  displayValueType = 'number';
                  value = valueData['integerValue'];
                  displayValue = value;
                } else if (valueData.containsKey('timestampValue')) {
                  valueType = 'timestampValue';
                  displayValueType = 'timestamp';
                  value = valueData['timestampValue'];
                  displayValue = value;
                } else if (valueData.containsKey('mapValue')) {
                  valueType = 'mapValue';
                  displayValueType = 'map';
                  value = valueData['mapValue'];
                  displayValue = 'Map';
                } else if (valueData.containsKey('arrayValue')) {
                  valueType = 'arrayValue';
                  displayValueType = 'array';
                  value = valueData['arrayValue'];
                  displayValue = 'Array';
                } else if (valueData.containsKey('geoPointValue')) {
                  valueType = 'geoPointValue';
                  displayValueType = 'geoPoint';
                  value = valueData['geoPointValue'];
                  displayValue =
                      "[${value['latitude']}, ${value['longitude']}]";
                } else if (valueData.containsKey('nullValue')) {
                  valueType = 'nullValue';
                  displayValueType = 'null';
                  value = valueData['nullValue'];
                  displayValue = 'null';
                } else if (valueData.containsKey('booleanValue')) {
                  valueType = 'booleanValue';
                  displayValueType = 'bool';
                  value = valueData['booleanValue'];
                  displayValue = value;
                } else if (valueData.containsKey('referenceValue')) {
                  valueType = 'referenceValue';
                  displayValueType = 'reference';
                  value = valueData['referenceValue'];
                  displayValue = value;
                } else {
                  valueType = 'unsupported';
                  value = 'Unsupported';
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
                    title: Text('$index',
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.bold)),
                    subtitle: Text('($displayValueType): $displayValue'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (valueType == 'timestampValue')
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              print(value);
                              print(value.runtimeType);
                              // _showTimeStampEditDialog(index.toString(), valueType, value, index);
                            },
                          ),
                        if (valueType == 'booleanValue')
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              // _showEditBoolDialog(index.toString(), valueType, value, index);
                            },
                          ),
                        if (valueType == 'geoPointValue')
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              // _showGeoPointEditDialog(index.toString(), valueType.toString(), value, index);
                            },
                          ),
                        if (valueType == 'mapValue')
                          IconButton(
                            icon: const Icon(Icons.remove_red_eye),
                            onPressed: () {
                              showSnackBar(context,
                                  "For further editing visit Firebase.com");
                            },
                          ),
                        if (valueType == 'arrayValue')
                          IconButton(
                            icon: const Icon(Icons.remove_red_eye),
                            onPressed: () {
                              showSnackBar(context,
                                  "For further editing visit Firebase.com");
                            },
                          ),
                        if (valueType != 'mapValue' &&
                            valueType != 'arrayValue' &&
                            valueType != 'geoPointValue' &&
                            valueType != 'booleanValue' &&
                            valueType != 'timestampValue')
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _showEditDialog(
                                  index.toString(), valueType, value, index);
                            },
                          ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            // Define your delete action here
                            _deleteFieldFromArray(index);
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
