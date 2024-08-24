import 'package:firebase_editor_gsoc/controllers/history_controller.dart';
import 'package:firebase_editor_gsoc/views/map_within_array.dart';
import 'package:firebase_editor_gsoc/views/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ArrayFieldDataPage extends StatefulWidget {
  final String fieldName;
  final List<dynamic> arrayValue;
  final Map<String, dynamic>? documentDetails;
  final String accessToken;
  final String documentPath;

  const ArrayFieldDataPage({
    super.key,
    required this.fieldName,
    required this.arrayValue,
    required this.documentDetails,
    required this.accessToken,
    required this.documentPath,
  });

  @override
  State<ArrayFieldDataPage> createState() => _ArrayFieldDataPageState();
}

class _ArrayFieldDataPageState extends State<ArrayFieldDataPage> {
  DateTime? selectedDate;
  TimeOfDay? selectedTime;



  /// -------------------------------------- ADD A FIELD TO ARRAY --------------------------------------------------------- ///

  /// Displays a dialog allowing the user to add a new field to an array in a Firestore document.
  ///
  /// The `showArrayAddFieldDialog` function presents an `AlertDialog` where the user can
  /// define the type and value of a new field to be added to an array in a Firestore document.
  /// Based on the selected field type, appropriate input controls (such as text fields, dropdowns,
  /// or date/time pickers) are provided for entering the field value. The user can either cancel
  /// the operation or confirm the addition of the field, which will then trigger the `addArrayField`
  /// method to update the Firestore document.
  ///
  /// [context]: The build context, used to display the dialog.
  /// [fieldName]: The name of the array field where the new value will be added.
  /// [documentDetails]: The details of the Firestore document to which the array belongs.
  /// [documentPath]: The path of the Firestore document, used for updating the document.
  /// [accessToken]: The access token for authenticating the Firestore API request.
  /// [arrayValue]: The existing array to which the new field will be added.
  void showArrayAddFieldDialog(
      BuildContext context,
      String fieldName,
      Map<String, dynamic>? documentDetails,
      String documentPath,
      String accessToken,
      final List<dynamic> arrayValue) async {
    // String fieldName = '';
    String fieldType = 'stringValue'; // Default field type
    String fieldValue = '';
    bool fieldBoolValue = true; // default value
    TextEditingController fieldValueController = TextEditingController();
    TextEditingController latitudeController = TextEditingController();
    TextEditingController longitudeController = TextEditingController();
    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();

    // Dropdown menu items for field types
    /// NESTED ARRAYS NOT ALLOWED IN FIREBASE
    List<String> fieldTypes = [
      'stringValue',
      'integerValue',
      'booleanValue',
      'mapValue',
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
                    addArrayField(context, fieldName, fieldType, fieldValue,
                        documentDetails, documentPath, accessToken, arrayValue);
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

  /// Adds a new field to an existing array in a Firestore document and handles the update process.
  ///
  /// The `addArrayField` function adds a new field to the specified array in a Firestore document
  /// by sending a PATCH request to the Firestore REST API. The function ensures that the value is
  /// correctly structured based on its type, updates the array within the document's fields, and
  /// handles related actions such as logging the update and showing a toast message.
  ///
  /// [context]: The build context, used to display dialogs and manage the UI.
  /// [fieldName]: The name of the array field where the new value will be added.
  /// [fieldType]: The type of the field to be added to the array.
  /// [fieldValue]: The value of the field to be added to the array.
  /// [documentDetails]: The details of the Firestore document to which the array belongs.
  /// [documentPath]: The path of the Firestore document, used for updating the document.
  /// [accessToken]: The access token for authenticating the Firestore API request.
  /// [arrayValue]: The existing array to which the new field will be added.
  void addArrayField(
      BuildContext context,
      String fieldName,
      String fieldType,
      String fieldValue,
      Map<String, dynamic>? documentDetails,
      String documentPath,
      String accessToken,
      final List<dynamic> arrayValue) async {
    if (documentDetails!['fields'] == null) {
      documentDetails['fields'] = {};
    }

    Map<String, dynamic> fields = {
      ...documentDetails['fields']
    }; // Copy existing fields

    // Ensure the value is correctly structured and valid
    dynamic formattedValue;
    try {
      switch (fieldType) {
        case 'stringValue':
          formattedValue = {'stringValue': fieldValue};
          arrayValue.add(formattedValue);
          break;
        case 'integerValue':
          formattedValue = {'integerValue': int.parse(fieldValue)};
          arrayValue.add(formattedValue);
          break;
        case 'booleanValue':
          formattedValue = {
            'booleanValue': fieldValue.toLowerCase() == 'true' ||
                fieldValue.toLowerCase() == 'false'
          };
          arrayValue.add(formattedValue);
          break;
        case 'mapValue':
          formattedValue = {'mapValue': ""};
          arrayValue.add(formattedValue);
          break;
        case 'nullValue':
          formattedValue = {'nullValue': ""};
          arrayValue.add(formattedValue);
          break;
        case 'timestampValue':
          formattedValue = {'timestampValue': fieldValue};
          arrayValue.add(formattedValue);
          break;
        case 'geoPointValue':
          var parts = fieldValue.split(',');
          var value = {
            'latitude': double.parse(parts[0]),
            'longitude': double.parse(parts[1])
          };
          formattedValue = {'geoPointValue': value};
          arrayValue.add(formattedValue);
          break;
        case 'referenceValue':
          formattedValue = {'referenceValue': fieldValue};
          arrayValue.add(formattedValue);
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
    fields[fieldName] = {
      'arrayValue': {'values': arrayValue}
    };

    String url =
        'https://firestore.googleapis.com/v1/$documentPath?updateMask.fieldPaths=$fieldName';
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
        setState(() {
          documentDetails!['fields'] = fields;
          DateTime updateTime = DateTime.now();
          insertHistory(documentPath, fieldName, updateTime, 'add');
          showToast('Field Added!');
        });
      } else {}
    } catch (error) {}
  }

  /// -------------------------------------- EDIT ARRAY ELEMENTS VALUES -------------------------------------------------- ///

  /// Displays a dialog allowing the user to edit an element in an array within a Firestore document.
  ///
  /// The `_showEditDialog` function presents an `AlertDialog` where the user can edit the value
  /// of a specific element in an array. The dialog displays the field name, type, and the current
  /// value, allowing the user to modify the value. Upon saving, the updated value is applied to the
  /// array, and the entire array is updated in Firestore.
  ///
  /// [fieldName]: The name of the field being edited.
  /// [valueType]: The type of the value (e.g., stringValue, integerValue).
  /// [value]: The current value of the field.
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
                _updateField(widget.fieldName, widget.arrayValue, 'update');
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  /// Displays a dialog allowing the user to edit a boolean element in an array within a Firestore document.
  ///
  /// The `_showEditBoolDialog` function presents an `AlertDialog` where the user can edit the value
  /// of a specific boolean element in an array. The dialog provides a dropdown for selecting true or
  /// false. Upon saving, the updated boolean value is applied to the array, and the entire array is
  /// updated in Firestore.
  ///
  /// [fieldName]: The name of the field being edited.
  /// [valueType]: The type of the value (in this case, booleanValue).
  /// [value]: The current boolean value of the field.
  /// [index]: The index of the element in the array to be edited.
  void _showEditBoolDialog(
      String fieldName, String valueType, bool value, int index) {
    bool newValue = value; // Initial value to display in DropdownButton
    String newFieldType = valueType;

    TextEditingController fieldNameController =
        TextEditingController(text: fieldName);
    TextEditingController fieldTypeController =
        TextEditingController(text: newFieldType);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Array Element'),
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
                        decoration: const InputDecoration(labelText: 'Index'),
                      ),
                      Row(
                        children: [
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
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  // Update widget.arrayValue with the new boolean value at the specified index
                  widget.arrayValue[index]['booleanValue'] = newValue;
                });

                Navigator.of(context).pop(); // Close the dialog

                // Now update the entire array in Firestore
                _updateField(widget.fieldName, widget.arrayValue, 'update');
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  /// Displays a dialog allowing the user to edit a GeoPoint element in an array within a Firestore document.
  ///
  /// The `_showGeoPointEditDialog` function presents an `AlertDialog` where the user can edit the latitude
  /// and longitude of a specific GeoPoint element in an array. The dialog ensures that the input values
  /// for latitude and longitude are valid before applying the changes. Upon saving, the updated GeoPoint
  /// value is applied to the array, and the entire array is updated in Firestore.
  ///
  /// [fieldName]: The name of the field being edited.
  /// [valueType]: The type of the value (in this case, geoPointValue).
  /// [geoPointValue]: A map containing the current latitude and longitude of the GeoPoint.
  /// [index]: The index of the element in the array to be edited.
  void _showGeoPointEditDialog(String fieldName, String valueType,
      Map<String, dynamic> geoPointValue, int index) {
    double latitude = geoPointValue['latitude'];
    double longitude = geoPointValue['longitude'];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit GeoPoint: $fieldName'),
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

                setState(() {
                  // Update widget.arrayValue with the new geoPoint value at the specified index
                  widget.arrayValue[index]['geoPointValue'] = {
                    'latitude': latitude,
                    'longitude': longitude
                  };
                });

                Navigator.of(context).pop();

                // Now update the entire array in Firestore
                _updateField(widget.fieldName, widget.arrayValue, 'update');
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  /// Displays a dialog allowing the user to edit a timestamp element in an array within a Firestore document.
  ///
  /// The `_showTimeStampEditDialog` function presents an `AlertDialog` where the user can edit the date
  /// and time of a specific timestamp element in an array. The dialog allows the user to pick a new date
  /// and time, which is then converted to a UTC timestamp. Upon saving, the updated timestamp value is
  /// applied to the array, and the entire array is updated in Firestore.
  ///
  /// [fieldName]: The name of the field being edited.
  /// [valueType]: The type of the value (in this case, timestampValue).
  /// [value]: The current timestamp value of the field.
  /// [index]: The index of the element in the array to be edited.
  void _showTimeStampEditDialog(
      String fieldName, String valueType, dynamic value, int index) {
    dynamic newValue = value; // Initial value to display in TextField

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
                    subtitle: Text(selectedDate!.toString().split(' ')[0]),
                    trailing: const Icon(Icons.calendar_month_outlined),
                    onTap: () async {
                      final DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: selectedDate!,
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
                    subtitle: Text(selectedTime!.format(context)),
                    trailing: const Icon(Icons.watch_later_outlined),
                    onTap: () async {
                      final TimeOfDay? pickedTime = await showTimePicker(
                        context: context,
                        initialTime: selectedTime!,
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
                  selectedDate!.year,
                  selectedDate!.month,
                  selectedDate!.day,
                  selectedTime!.hour,
                  selectedTime!.minute,
                );

                setState(() {
                  // Update widget.arrayValue with the new timestamp value at the specified index
                  widget.arrayValue[index]['timestampValue'] =
                      newDateTime.toUtc().toIso8601String();
                });

                Navigator.of(context).pop(); // Close the dialog

                // Now update the entire array in Firestore
                _updateField(widget.fieldName, widget.arrayValue, 'update');
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  /// -------------------------------------- DELETE ARRAY ELEMENT ------------------------------------------------------- ///
  /// Prompts the user to confirm the deletion of an element from an array in a Firestore document.
  ///
  /// The `_deleteFieldFromArray` function displays a confirmation dialog asking the user whether
  /// they want to delete an element at a specified index in an array. If the user confirms the deletion,
  /// the function removes the element from the array and calls `_updateField` to apply the changes to
  /// Firestore.
  ///
  /// [index]: The index of the element in the array to be deleted.
  void _deleteFieldFromArray(int index) async {
    bool confirmed = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: Text(
              'Are you sure you want to delete the element at index $index?'),
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
        widget.arrayValue.removeAt(index);
      });

      // Update Firestore with the updated array
      _updateField(widget.fieldName, widget.arrayValue, 'delete');
    }
  }

  /// ---------------------------------- TO UPDATE THE ARRAY FIELD OF THE DOCUMENT ----------------------------------------- ///
  /// Updates a specific array field in a Firestore document with a new array value.
  ///
  /// The `_updateField` function sends a PATCH request to the Firestore REST API to update the
  /// specified array field in a Firestore document with the new array value. It also logs the
  /// operation (such as add, delete, or update) and provides feedback to the user by showing a
  /// toast message upon successful update.
  ///
  /// [fieldName]: The name of the field to be updated.
  /// [newArrayValue]: The updated array value to replace the existing array in the document.
  /// [operationType]: A string indicating the type of operation performed (e.g., 'add', 'delete', 'update').
  void _updateField(String fieldName, List<dynamic> newArrayValue,
      String operationType) async {
    Map<String, dynamic> fields = widget.documentDetails!['fields'];

    fields[fieldName] = {
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
          showToast("Field updated successfully!");
        });
      } else {}
    } catch (error) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Array Field: ${widget.fieldName}'),
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
                    showArrayAddFieldDialog(
                        context,
                        widget.fieldName,
                        widget.documentDetails,
                        widget.documentPath,
                        widget.accessToken,
                        widget.arrayValue);
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
                  value = 'Array';
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

                /// FIREBASE DOESN'T ALLOW ARRAY WITH IN THE ARRAY SO NO NEED IMPLEMENT FOR IT

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
                    title: Text(
                      '$index',
                      style: const TextStyle(
                          color: Colors.grey, fontWeight: FontWeight.bold),
                    ),
                    subtitle: Text('($displayValueType): $displayValue'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (valueType == 'timestampValue')
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _showTimeStampEditDialog(
                                  index.toString(), valueType, value, index);
                            },
                          ),
                        if (valueType == 'booleanValue')
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              // print(widget.arrayValue);
                              // print(widget.arrayValue.runtimeType);
                              // _showEditDialog(index.toString(), valueType, value, index);
                              _showEditBoolDialog(
                                  index.toString(), valueType, value, index);
                            },
                          ),
                        if (valueType == 'geoPointValue')
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              _showGeoPointEditDialog(index.toString(),
                                  valueType.toString(), value, index);
                            },
                          ),
                        if (valueType == 'mapValue')
                          IconButton(
                            icon: const Icon(Icons.remove_red_eye),
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MapWithinArrayFieldDataPage(
                                          arrayFieldName: widget.fieldName,
                                          mapFieldName: index.toString(),
                                          mapValue: value,
                                          arrayValue: widget.arrayValue,
                                          documentDetails:
                                              widget.documentDetails,
                                          documentPath: widget.documentPath,
                                          accessToken: widget.accessToken,
                                          index: index),
                                ),
                              );
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
                              // print(widget.arrayValue);
                              // print(widget.arrayValue.runtimeType);
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
