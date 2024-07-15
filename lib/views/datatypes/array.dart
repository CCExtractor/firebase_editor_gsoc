import 'dart:convert';
import 'package:firebase_editor_gsoc/controllers/history.dart';
import 'package:firebase_editor_gsoc/views/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void showArrayAddFieldDialog(
    BuildContext context,
    String fieldName,
    Map<String, dynamic>? _documentDetails,
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
                    decoration: const InputDecoration(labelText: 'Field Type'),
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
                              fieldValue =
                                  '${latitudeController.text},${longitudeController.text}';
                            });
                          },
                        ),
                        TextField(
                          controller: longitudeController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(labelText: 'Longitude'),
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
                            trailing: const Icon(Icons.calendar_month_outlined),
                            onTap: () async {
                              final DateTime? pickedDate = await showDatePicker(
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
                      decoration: const InputDecoration(labelText: 'Field Value'),
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
                  addArrayField(
                      context,
                      fieldName,
                      fieldType,
                      fieldValue,
                      _documentDetails,
                      documentPath,
                      accessToken,
                      arrayValue);
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

void addArrayField(
    BuildContext context,
    String fieldName,
    String fieldType,
    String fieldValue,
    Map<String, dynamic>? _documentDetails,
    String documentPath,
    String accessToken,
    final List<dynamic> arrayValue) async {
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
        arrayValue.add(formattedValue);
        print("array after adding str field: $arrayValue");
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
  fields[fieldName] = {'arrayValue': {'values': arrayValue}};

  print(fieldName);
  print(fields[fieldName]);
  print("FIELDS AFTER ADDED NEW ARRAY FIELD: $fields");

  String url =
      'https://firestore.googleapis.com/v1/${documentPath}?updateMask.fieldPaths=$fieldName';
  Map<String, String> headers = {
    'Authorization': 'Bearer ${accessToken}',
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
      // setState(() {
      //   _documentDetails!['fields'] = fields;
      //   DateTime updateTime = DateTime.now();
      //   insertHistory(documentPath, fieldName, updateTime, 'add');
      // });
      print('Field added successfully');
    } else {
      print('Failed to add field. Status Code: ${response.statusCode}');
    }
  } catch (error) {
    print('Error adding field: $error');
  }
}

