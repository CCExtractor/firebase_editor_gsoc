import 'package:firebase_editor_gsoc/views/array_field_data.dart';
import 'package:firebase_editor_gsoc/views/edit_field_type.dart';
import 'package:firebase_editor_gsoc/views/map_field_data.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class DocumentDetailsPage extends StatefulWidget {
  final String accessToken;
  final String documentPath;
  final String projectId;
  final String databaseId;
  final String collectionId;

  const DocumentDetailsPage({super.key,
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
  Map<String, dynamic>? _documentDetails;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDocumentDetails();
  }

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
        print(data);
        setState(() {
          _documentDetails = data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Failed to call Firestore API. Status Code: ${response.statusCode}';
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

  // void _showEditDialog(String fieldName, String fieldType, String fieldValue) {
  //   String newFieldType = fieldType;
  //   String newFieldValue = fieldValue;
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text('Edit Field'),
  //         content: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             TextField(
  //               controller: TextEditingController(text: fieldName),
  //               readOnly: true,
  //               decoration: const InputDecoration(labelText: 'Field Name'),
  //             ),
  //             TextField(
  //               controller: TextEditingController(text: newFieldType),
  //               onChanged: (value) {
  //                 newFieldType = value;
  //               },
  //               decoration: const InputDecoration(labelText: 'Field Type'),
  //             ),
  //             TextField(
  //               controller: TextEditingController(text: newFieldValue),
  //               onChanged: (value) {
  //                 newFieldValue = value;
  //               },
  //               decoration: const InputDecoration(labelText: 'Field Value'),
  //             ),
  //           ],
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //               _updateField(fieldName, newFieldType, newFieldValue);
  //             },
  //             child: const Text('OK'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

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
                      decoration: const InputDecoration(labelText: 'Field Type'),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit),
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
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
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


  // void _showEditDialog(String fieldName, String fieldType, dynamic fieldValue) {
  //   String newFieldType = fieldType;
  //   String newFieldValue = fieldValue.toString();
  //
  //   showDialog(
  //     context: context,
  //     builder: (context) {
  //       return AlertDialog(
  //         title: const Text('Edit Field'),
  //         content: StatefulBuilder(
  //           builder: (context, setState) {
  //             return Column(
  //               mainAxisSize: MainAxisSize.min,
  //               children: [
  //                 TextField(
  //                   controller: TextEditingController(text: fieldName),
  //                   readOnly: true,
  //                   decoration: const InputDecoration(labelText: 'Field Name'),
  //                 ),
  //                 DropdownButton<String>(
  //                   value: newFieldType,
  //                   onChanged: (String? newValue) {
  //                     setState(() {
  //                       newFieldType = newValue!;
  //                     });
  //                   },
  //                   items: <String>[
  //                     'stringValue',
  //                     'integerValue',
  //                     'booleanValue',
  //                     'mapValue',
  //                     'arrayValue',
  //                     'nullValue',
  //                     'timestampValue',
  //                     'geoPointValue',
  //                     'referenceValue'
  //                   ].map<DropdownMenuItem<String>>((String value) {
  //                     return DropdownMenuItem<String>(
  //                       value: value,
  //                       child: Text(value),
  //                     );
  //                   }).toList(),
  //                 ),
  //                 TextField(
  //                   controller: TextEditingController(text: newFieldValue),
  //                   onChanged: (value) {
  //                     newFieldValue = value;
  //                   },
  //                   decoration: const InputDecoration(labelText: 'Field Value'),
  //                 ),
  //               ],
  //             );
  //           },
  //         ),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: const Text('Cancel'),
  //           ),
  //           TextButton(
  //             onPressed: () {
  //               if (!_validateFieldValue(newFieldType, newFieldValue)) {
  //                 ScaffoldMessenger.of(context).showSnackBar(
  //                   const SnackBar(
  //                     content: Text('Invalid value for the selected datatype.'),
  //                   ),
  //                 );
  //                 return;
  //               }
  //               Navigator.of(context).pop();
  //               _updateField(fieldName, newFieldType, newFieldValue);
  //             },
  //             child: const Text('OK'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }
  //
  // bool _validateFieldValue(String fieldType, String fieldValue) {
  //   switch (fieldType) {
  //     case 'stringValue':
  //       return true; // Any string is valid
  //     case 'integerValue':
  //       return int.tryParse(fieldValue) != null;
  //     case 'booleanValue':
  //       return fieldValue.toLowerCase() == 'true' || fieldValue.toLowerCase() == 'false';
  //     case 'nullValue':
  //       return fieldValue.isEmpty;
  //     case 'timestampValue':
  //       try {
  //         DateTime.parse(fieldValue);
  //         return true;
  //       } catch (e) {
  //         return false;
  //       }
  //     case 'geoPointValue':
  //       var parts = fieldValue.split(',');
  //       if (parts.length == 2) {
  //         var lat = double.tryParse(parts[0]);
  //         var lon = double.tryParse(parts[1]);
  //         return lat != null && lon != null && lat >= -90 && lat <= 90 && lon >= -180 && lon <= 180;
  //       }
  //       return false;
  //     case 'referenceValue':
  //       return Uri.tryParse(fieldValue) != null;
  //     case 'mapValue':
  //     // Simple validation for map as JSON
  //       try {
  //         json.decode(fieldValue);
  //         return true;
  //       } catch (e) {
  //         return false;
  //       }
  //     case 'arrayValue':
  //     // Simple validation for array as JSON
  //       try {
  //         var decoded = json.decode(fieldValue);
  //         return decoded is List;
  //       } catch (e) {
  //         return false;
  //       }
  //     default:
  //       return false;
  //   }
  // }
  //
  // void _updateField(String fieldName, String fieldType, String fieldValue) async {
  //   Map<String, dynamic> fields = _documentDetails!['fields'];
  //   dynamic value;
  //
  //   switch (fieldType) {
  //     case 'stringValue':
  //       value = fieldValue;
  //       break;
  //     case 'integerValue':
  //       value = int.parse(fieldValue);
  //       break;
  //     case 'booleanValue':
  //       value = fieldValue.toLowerCase() == 'true';
  //       break;
  //     case 'nullValue':
  //       value = null;
  //       break;
  //     case 'timestampValue':
  //       value = fieldValue; // Should be in correct timestamp format
  //       break;
  //     case 'geoPointValue':
  //       var parts = fieldValue.split(',');
  //       value = {
  //         'latitude': double.parse(parts[0]),
  //         'longitude': double.parse(parts[1])
  //       };
  //       break;
  //     case 'referenceValue':
  //       value = fieldValue; // Should be in correct reference format
  //       break;
  //     case 'mapValue':
  //       value = json.decode(fieldValue);
  //       break;
  //     case 'arrayValue':
  //       value = json.decode(fieldValue);
  //       break;
  //     default:
  //       return;
  //   }
  //
  //   fields[fieldName] = {fieldType: value};
  //
  //   String url = 'https://firestore.googleapis.com/v1/${widget.documentPath}?updateMask.fieldPaths=$fieldName';
  //   Map<String, String> headers = {
  //     'Authorization': 'Bearer ${widget.accessToken}',
  //     'Accept': 'application/json',
  //     'Content-Type': 'application/json',
  //   };
  //   Map<String, dynamic> body = {
  //     "fields": fields,
  //   };
  //
  //   try {
  //     final response = await http.patch(Uri.parse(url), headers: headers, body: json.encode(body));
  //
  //     if (response.statusCode == 200) {
  //       setState(() {
  //         _documentDetails!['fields'] = fields;
  //       });
  //       print('Field updated successfully');
  //     } else {
  //       print('Failed to update field. Status Code: ${response.statusCode}');
  //     }
  //   } catch (error) {
  //     print('Error updating field: $error');
  //   }
  // }


  void _updateField(String fieldName, String fieldType, String fieldValue) async {
    Map<String, dynamic> fields = _documentDetails!['fields'];
    fields[fieldName] = {fieldType: fieldValue};

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
          _documentDetails!['fields'] = fields;
        });
        //call function for storing history
        print('Field updated successfully');
      } else {
        print('Failed to update field. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error updating field: $error');
    }
  }

  void _showViewDialog(String fieldName, dynamic fieldValue) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('View Field'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Field Name: $fieldName'),
                const SizedBox(height: 8),
                const Text('Field Value:'),
                const SizedBox(height: 8),
                if (fieldValue is Map) ...[
                  for (var entry in fieldValue.entries)
                    // print('${entry.key}: ${entry.value}')
                    Text('${entry.key}: ${entry.value}')
                ] else if (fieldValue is List) ...[
                  for (var item in fieldValue) Text(item.toString())
                ] else
                  Text(fieldValue.toString()),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }



  void _showGeoPointDialog(String fieldName, Map<String, dynamic> geoPointValue) {
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

  void _updateGeoPointField(String fieldName, double latitude, double longitude) async {
    Map<String, dynamic> fields = _documentDetails!['fields'];
    fields[fieldName] = {'geoPointValue': {'latitude': latitude, 'longitude': longitude}};

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
          _documentDetails!['fields'] = fields;
        });
        print('GeoPoint updated successfully');
      } else {
        print('Failed to update GeoPoint. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error updating GeoPoint: $error');
    }
  }

  void _showBoolDialog(String fieldName, bool currentValue) {
    bool newValue = currentValue;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Boolean: $fieldName'),
          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  RadioListTile<bool>(
                    title: const Text('True'),
                    value: true,
                    groupValue: newValue,
                    onChanged: (value) {
                      setState(() {
                        newValue = value!;
                      });
                    },
                  ),
                  RadioListTile<bool>(
                    title: const Text('False'),
                    value: false,
                    groupValue: newValue,
                    onChanged: (value) {
                      setState(() {
                        newValue = value!;
                      });
                    },
                  ),
                ],
              );
            },
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
                _updateBoolField(fieldName, newValue);
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  void _updateBoolField(String fieldName, bool newValue) async {
    Map<String, dynamic> fields = _documentDetails!['fields'];
    fields[fieldName] = {'booleanValue': newValue};

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
          _documentDetails!['fields'] = fields;
        });
        print('Boolean value updated successfully');
      } else {
        print('Failed to update Boolean value. Status Code: ${response.statusCode}');
      }
    } catch (error) {
      print('Error updating Boolean value: $error');
    }
  }


  String _formatDateTime(String dateTimeString) {
    DateTime dateTime = DateTime.parse(dateTimeString);
    return DateFormat('dd-MM-yyyy HH:mm').format(dateTime);
  }

  String extractDisplayName(String documentName) {
    List<String> parts = documentName.split("${widget.collectionId}/");
    String displayName = parts.last;
    return displayName;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Document Details'),
      ),
      body: _isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 20),
            Text('Loading document details...'),
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
              Text('Document ID: ${extractDisplayName(_documentDetails!['name'])}',
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              Text("Collection Name: ${widget.collectionId}"),
              const SizedBox(height: 8),
              Text('Created Time: ${_formatDateTime(_documentDetails!['createTime'])}'),
              Text('Updated Time: ${_formatDateTime(_documentDetails!['updateTime'])}'),
              const SizedBox(height: 16),
              const Text('Fields:', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              if (_documentDetails!['fields'] != null)
                ..._documentDetails!['fields'].entries.map((entry) {
                  String fieldName = entry.key;
                  Map<String, dynamic> fieldData = entry.value;
                  String fieldType;
                  dynamic displayValue;
                  dynamic fieldValue;

                  if (fieldData.containsKey('stringValue')) {
                    fieldType = 'stringValue';
                    fieldValue = fieldData['stringValue'];
                    displayValue = fieldValue;
                  } else if (fieldData.containsKey('integerValue')) {
                    fieldType = 'integerValue';
                    fieldValue = fieldData['integerValue'];
                    displayValue = fieldValue;
                  } else if (fieldData.containsKey('timestampValue')) {
                    fieldType = 'timestampValue';
                    fieldValue = fieldData['timestampValue'];
                    displayValue = fieldValue;
                  } else if (fieldData.containsKey('mapValue')) {
                    fieldType = 'mapValue';
                    fieldValue = fieldData['mapValue'];
                    displayValue = 'Map';

                  } else if (fieldData.containsKey('arrayValue')) {
                    fieldType = 'arrayValue';
                    fieldValue = fieldData['arrayValue'];
                    displayValue = 'Array';
                  } else if (fieldData.containsKey('geoPointValue')) {
                    fieldType = 'geoPointValue';
                    fieldValue = fieldData['geoPointValue'];
                    displayValue = 'GeoPoint';
                    print(fieldValue);
                  } else if (fieldData.containsKey('nullValue')) {
                    fieldType = 'nullValue';
                    fieldValue = fieldData['nullValue'];
                    displayValue = fieldValue;
                  } else if (fieldData.containsKey("booleanValue")) {
                    fieldType = 'booleanValue';
                    fieldValue = fieldData['booleanValue'];
                    displayValue = fieldValue;
                  } else if (fieldData.containsKey("referenceValue")) {
                    fieldType = 'referenceValue';
                    fieldValue = fieldData['referenceValue'];
                    displayValue = fieldValue;
                  } else {
                    // Handle unsupported types or unexpected data structure
                    fieldType = 'unsupported';
                    fieldValue = 'Unsupported';
                    displayValue = fieldValue;
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
                      title: Text('$fieldName ($fieldType): $displayValue'),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (fieldType == 'mapValue')
                            IconButton(onPressed: () {
                              // _showMapDialog(fieldName, fieldValue);
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MapFieldDataPage(
                                    fieldName: fieldName,
                                    fieldValue: fieldValue,
                                  ),
                                ),
                              );
                            }, icon: const Icon(Icons.remove_red_eye)),
                          if (fieldType == 'arrayValue')
                            IconButton(
                              icon: const Icon(Icons.remove_red_eye),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ArrayFieldDataPage(
                                      fieldName: fieldName,
                                      arrayValue: fieldValue['values'],
                                    ),
                                  ),
                                );
                              },
                            ),
                          if (fieldType == 'geoPointValue')
                            IconButton(
                              icon: const Icon(Icons.remove_red_eye),
                              onPressed: () {
                                _showGeoPointDialog(fieldName, fieldValue);
                              },
                            ),
                          if (fieldType == 'booleanValue')
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _showBoolDialog(fieldName, fieldValue);
                              },
                            ),
                          if (fieldType != 'mapValue' &&
                              fieldType != 'arrayValue' &&
                              fieldType != 'geoPointValue' &&
                              fieldType != 'booleanValue')
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _showEditDialog(fieldName, fieldType, fieldValue);
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
                    ),
                  );
                }).toList(),
            ],
          ),
        ),
      )
          : const Center(child: Text('No document details found.')),
    );
  }
}
