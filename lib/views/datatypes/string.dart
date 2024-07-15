import 'package:flutter/material.dart';

String _updateFieldValue(DateTime date, TimeOfDay time) {
  final DateTime newDateTime = DateTime(
    date.year,
    date.month,
    date.day,
    time.hour,
    time.minute,
  );
  return newDateTime.toUtc().toIso8601String();
}

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
            title: Text('Add Field'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextField(
                    decoration: InputDecoration(labelText: 'Field Name'),
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
                          style: TextStyle(
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
                    decoration: InputDecoration(labelText: 'Field Type'),
                  ),
                  if (fieldType == 'booleanValue')
                    DropdownButtonFormField<bool>(
                      value: fieldBoolValue,
                      items: const [
                        DropdownMenuItem<bool>(
                          value: true,
                          child: Text('true', style:  TextStyle(
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
                      decoration: InputDecoration(labelText: 'Field Value'),
                    )
                  else if (fieldType == 'geoPointValue')
                    Column(
                      children: [
                        TextField(
                          controller: latitudeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: 'Latitude'),
                          onChanged: (value) {
                            setState(() {
                              fieldValue = '${latitudeController.text},${longitudeController.text}';
                            });
                          },
                        ),
                        TextField(
                          controller: longitudeController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(labelText: 'Longitude'),
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
                            child: ListTile(
                              title: Text('Date'),
                              subtitle: Text(selectedDate.toString().split(' ')[0]),
                              trailing: Icon(Icons.calendar_month_outlined),
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
                                    fieldValue = _updateFieldValue(selectedDate, selectedTime);
                                  });
                                }
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text('Time'),
                              subtitle: Text(selectedTime.format(context)),
                              trailing: Icon(Icons.watch_later_outlined),
                              onTap: () async {
                                final TimeOfDay? pickedTime = await showTimePicker(
                                  context: context,
                                  initialTime: selectedTime,
                                );
                                if (pickedTime != null && pickedTime != selectedTime) {
                                  setState(() {
                                    selectedTime = pickedTime;
                                    fieldValue = _updateFieldValue(selectedDate, selectedTime);
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
                          decoration: InputDecoration(labelText: 'Field Value'),
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
                          decoration: InputDecoration(labelText: 'Field Value'),
                        ),
                ],
              ),
            ),
            actions: <Widget>[
              TextButton(
                child: Text('Cancel'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: Text('Add'),
                onPressed: () {
                  print("timestamp: $fieldValue");
                  // _addField(fieldName, fieldType, fieldValue);
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