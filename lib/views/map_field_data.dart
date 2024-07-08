import 'package:flutter/material.dart';

class MapFieldDataPage extends StatelessWidget {
  final String fieldName;
  final Map<String, dynamic> fieldValue;

  const MapFieldDataPage({
    Key? key,
    required this.fieldName,
    required this.fieldValue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, dynamic> fields = fieldValue['fields'];

    return Scaffold(
      appBar: AppBar(
        title: Text('Map Field: $fieldName'),
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
            value = 'GeoPoint';
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

          return ListTile(
            title: Text('$key ($valueType): $value'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    // Implement edit functionality
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () {
                    // Implement delete functionality
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
