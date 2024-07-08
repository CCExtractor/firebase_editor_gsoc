import 'package:firebase_editor_gsoc/views/map_field_data.dart';
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
    Key? key,
    required this.fieldName,
    required this.arrayValue,
    required this.documentDetails,
    required this.accessToken,
    required this.documentPath,
  }) : super(key: key);

  @override
  State<ArrayFieldDataPage> createState() => _ArrayFieldDataPageState();
}

class _ArrayFieldDataPageState extends State<ArrayFieldDataPage> {


  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  void _showEditBoolDialog(String fieldName, String valueType, bool value, int index) {
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
                  newValue = newValueValue!; // Update the new value when user selects from the dropdown
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
                  widget.arrayValue[index]['booleanValue'] = newValue;
                });

                Navigator.of(context).pop(); // Close the dialog

                // Now update the entire array in Firestore
                _updateField(widget.fieldName, widget.arrayValue);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showGeoPointEditDialog(String fieldName, String valueType, Map<String, dynamic> geoPointValue, int index) {
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
                  widget.arrayValue[index]['geoPointValue'] = {'latitude': latitude, 'longitude': longitude};
                });

                Navigator.of(context).pop();

                // Now update the entire array in Firestore
                _updateField(widget.fieldName, widget.arrayValue);


              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }





  void _showEditDialog(String fieldName, String valueType, dynamic value, int index) {
    dynamic newValue = value; // Initial value to display in TextField

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Array Element'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Field Type: $valueType'),
              TextField(
                controller: TextEditingController(text: newValue.toString()),
                onChanged: (newValueText) {
                  newValue = newValueText; // Update the new value as user types
                },
                decoration: const InputDecoration(labelText: 'New Field Value'),
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
                    widget.arrayValue[index]['integerValue'] = int.parse(newValue); // Convert to integer if needed
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
                    widget.arrayValue[index]['booleanValue'] = newValue.toLowerCase() == 'true' || newValue.toLowerCase() == 'false' ; // Convert to boolean if needed
                  } else if (valueType == 'referenceValue') {
                    // Handle reference update logic
                    widget.arrayValue[index]['referenceValue'] = newValue;
                  } else {
                    // Handle unsupported types
                  }
                });

                Navigator.of(context).pop(); // Close the dialog

                // Now update the entire array in Firestore
                _updateField(widget.fieldName, widget.arrayValue);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void _showTimeStampEditDialog(String fieldName, String valueType, dynamic value, int index) {
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
              // Date picker
              ListTile(
                title: Text('Date'),
                subtitle: Text(selectedDate!.toString().split(' ')[0]),
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
              // Time picker
              ListTile(
                title: Text('Time'),
                subtitle: Text(selectedTime!.format(context)),
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
                  widget.arrayValue[index]['timestampValue'] = newDateTime.toUtc().toIso8601String();
                });

                Navigator.of(context).pop(); // Close the dialog

                // Now update the entire array in Firestore
                _updateField(widget.fieldName, widget.arrayValue);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }




  void _updateField(String fieldName, List<dynamic> newArrayValue) async {

    Map<String, dynamic> fields = widget.documentDetails!['fields'];

    fields[fieldName] = {'arrayValue' :{'values': newArrayValue}};

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Array Field: ${widget.fieldName}'),
      ),
      body: ListView.builder(
        itemCount: widget.arrayValue.length,
        itemBuilder: (context, index) {
          dynamic valueData = widget.arrayValue[index];
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
            value = valueData['mapValue'];
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


          /// FIREBASE DOESN'T ALLOW ARRAY WITH IN THE ARRAY SO NO NEED IMPLEMENT FOR IT

          return ListTile(
            title: Text('($valueType): $value'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (valueType == 'timestampValue')
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {

                      print(value);
                      print(value.runtimeType);
                      _showTimeStampEditDialog(index.toString(), valueType, value, index);
                    },
                  ),
                if (valueType == 'booleanValue')
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // print(widget.arrayValue);
                      // print(widget.arrayValue.runtimeType);
                      // _showEditDialog(index.toString(), valueType, value, index);
                      _showEditBoolDialog(index.toString(), valueType, value, index);
                    },
                  ),
                if(valueType == 'geoPointValue')
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      _showGeoPointEditDialog(index.toString(), valueType.toString(), value, index);
                    },
                  ),
                if(valueType == 'mapValue')
                  IconButton(
                    icon: const Icon(Icons.remove_red_eye),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapFieldDataPage(
                            fieldName: index.toString(),
                            fieldValue: value,
                          ),
                        ),
                      );
                    },
                  ),
                if (valueType != 'mapValue' && valueType != 'arrayValue' && valueType != 'geoPointValue' && valueType != 'booleanValue' && valueType != 'timestampValue')
                  IconButton(
                    icon: const Icon(Icons.edit),
                    onPressed: () {
                      // print(widget.arrayValue);
                      // print(widget.arrayValue.runtimeType);
                      _showEditDialog(index.toString(), valueType, value, index);
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // Define your delete action here
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
