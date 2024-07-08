import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

class EditFieldTypePage extends StatefulWidget {
  final String fieldName;
  final String fieldType;
  final String fieldValue;
  Map<String, dynamic>? documentDetails;
  final String accessToken;
  final String documentPath;



  EditFieldTypePage({
    super.key,
    required this.fieldName,
    required this.fieldType,
    required this.fieldValue,
    required this.documentDetails,
    required this.accessToken,
    required this.documentPath,
  });

  @override
  _EditFieldTypePageState createState() => _EditFieldTypePageState();
}

class _EditFieldTypePageState extends State<EditFieldTypePage> {
  late String newFieldType;
  late String newFieldValue;
  final List<String> fieldTypes = [
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

  late TextEditingController fieldValueController;
  late TextEditingController latitudeController;
  late TextEditingController longitudeController;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;


  void _updateField(String fieldName, String fieldType, String fieldValue) async {
    Map<String, dynamic> fields = widget.documentDetails!['fields'];
    dynamic value;

    switch (fieldType) {
      case 'stringValue':
        value = fieldValue;
        break;
      case 'integerValue':
        value = int.parse(fieldValue);
        break;
      case 'booleanValue':
        value = fieldValue.toLowerCase() == 'true';
        break;
      case 'nullValue':
        value = null;
        break;
      case 'timestampValue':
        value = fieldValue; // Should be in correct timestamp format
        break;
      case 'geoPointValue':
        var parts = fieldValue.split(',');
        value = {
          'latitude': double.parse(parts[0]),
          'longitude': double.parse(parts[1])
        };
        break;
      case 'referenceValue':
        value = fieldValue; // Should be in correct reference format
        break;
      case 'mapValue':
        value = json.decode(fieldValue);
        break;
      case 'arrayValue':
        value = json.decode(fieldValue);
        break;
      default:
        return;
    }

    fields[fieldName] = {fieldType: value};

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
          widget.documentDetails!['fields'] = fields;
        });
        print('Field updated successfully');
      } else {
        print('Failed to update field. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error updating field: $error');
    }
  }


  @override
  void initState() {
    super.initState();
    newFieldType = widget.fieldType;
    newFieldValue = widget.fieldValue;
    fieldValueController = TextEditingController(text: newFieldValue);
    latitudeController = TextEditingController();
    longitudeController = TextEditingController();
  }

  void _saveChanges() {
    if (_validateFieldValue(newFieldType, newFieldValue)) {
      Navigator.of(context).pop({
        'fieldType': newFieldType,
        'fieldValue': newFieldValue,
      });
    } else {
      _showErrorDialog();
    }
  }

  bool _validateFieldValue(String fieldType, String fieldValue) {
    switch (fieldType) {
      case 'stringValue':
        return true; // Any string is valid
      case 'integerValue':
        return int.tryParse(fieldValue) != null;
      case 'booleanValue':
        return fieldValue.toLowerCase() == 'true' || fieldValue.toLowerCase() == 'false';
      case 'mapValue':
        return true; // Assume valid for simplicity
      case 'arrayValue':
        return true; // Assume valid for simplicity
      case 'nullValue':
        return fieldValue.isEmpty;
      case 'timestampValue':
        try {
          DateTime.parse(fieldValue);
          return true;
        } catch (e) {
          return false;
        }
      case 'geoPointValue':
        var parts = fieldValue.split(',');
        if (parts.length == 2) {
          var lat = double.tryParse(parts[0].trim());
          var lon = double.tryParse(parts[1].trim());
          return lat != null && lon != null && lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180;
        }
        return false;
      case 'referenceValue':
        return true; // Assume valid for simplicity
      default:
        return false;
    }
  }

  void _showErrorDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Invalid Value'),
          content: const Text('The value you entered is not valid for the selected field type.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        _updateTimestampValue();
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && picked != selectedTime)
      setState(() {
        selectedTime = picked;
        _updateTimestampValue();
      });
  }

  void _updateTimestampValue() {
    if (selectedDate != null && selectedTime != null) {
      final DateTime combined = DateTime(
        selectedDate!.year,
        selectedDate!.month,
        selectedDate!.day,
        selectedTime!.hour,
        selectedTime!.minute,
      );
      setState(() {
        newFieldValue = combined.toIso8601String();
        fieldValueController.text = newFieldValue;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Field Type'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: TextEditingController(text: widget.fieldName),
              readOnly: true,
              decoration: const InputDecoration(labelText: 'Field Name'),
            ),
            DropdownButtonFormField<String>(
              value: newFieldType,
              onChanged: (value) {
                setState(() {
                  newFieldType = value!;
                  newFieldValue = '';
                  fieldValueController.text = '';
                  latitudeController.clear();
                  longitudeController.clear();
                });
              },
              items: fieldTypes.map((type) {
                return DropdownMenuItem<String>(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              decoration: const InputDecoration(labelText: 'Field Type'),
            ),
            if (newFieldType == 'booleanValue')
              DropdownButtonFormField<String>(
                value: newFieldValue.isEmpty ? null : newFieldValue,
                onChanged: (value) {
                  setState(() {
                    newFieldValue = value!;
                  });
                },
                items: ['true', 'false'].map((boolValue) {
                  return DropdownMenuItem<String>(
                    value: boolValue,
                    child: Text(boolValue),
                  );
                }).toList(),
                decoration: const InputDecoration(labelText: 'Field Value'),
              )
            else if (newFieldType == 'geoPointValue')
              Column(
                children: [
                  TextField(
                    controller: latitudeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Latitude'),
                    onChanged: (value) {
                      _updateGeoPointValue();
                    },
                  ),
                  TextField(
                    controller: longitudeController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Longitude'),
                    onChanged: (value) {
                      _updateGeoPointValue();
                    },
                  ),
                ],
              )
            else if (newFieldType == 'timestampValue')
                Column(
                  children: [
                    ElevatedButton(
                      onPressed: () => _selectDate(context),
                      child: const Text('Select Date'),
                    ),
                    ElevatedButton(
                      onPressed: () => _selectTime(context),
                      child: const Text('Select Time'),
                    ),
                    if (newFieldValue.isNotEmpty)
                      Text('Selected DateTime: $newFieldValue'),
                  ],
                )
              else if (newFieldType == 'nullValue')
                  TextField(
                    controller: fieldValueController,
                    readOnly: true,
                    decoration: const InputDecoration(labelText: 'Field Value'),
                    onChanged: (value) {
                      setState(() {
                        newFieldValue = 'null';
                      });
                    },
                  )
                else
                  TextField(
                    controller: fieldValueController,
                    onChanged: (value) {
                      setState(() {
                        newFieldValue = value;
                      });
                    },
                    decoration: const InputDecoration(labelText: 'Field Value'),
                  ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: (){
                _updateField(widget.fieldName,newFieldType,newFieldValue);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  void _updateGeoPointValue() {
    final latitude = latitudeController.text;
    final longitude = longitudeController.text;
    setState(() {
      newFieldValue = '$latitude,$longitude';
    });
  }
}
