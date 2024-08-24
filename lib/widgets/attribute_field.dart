import 'package:flutter/material.dart';

class AttributeField extends StatelessWidget {
  final TextEditingController attributeNameController;
  final TextEditingController attributeTypeController;

  const AttributeField({super.key,
    required this.attributeNameController,
    required this.attributeTypeController,
  });

  @override
  Widget build(BuildContext context) {
    // Define the list of unique data types
    List<String> dataTypes = ['string', 'number', 'boolean', 'map', 'array', 'null', 'timestamp', 'geopoint', 'reference'];

    // Default value for the dropdown
    String defaultValue = dataTypes[0]; // Default to the first data type

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: attributeNameController,
              decoration: InputDecoration(
                labelText: 'Field',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10.0),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: attributeTypeController.text.isNotEmpty && dataTypes.contains(attributeTypeController.text.toLowerCase()) ? attributeTypeController.text.toLowerCase() : defaultValue,
              items: dataTypes.map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: const TextStyle(fontSize: 14.0),),
                );
              }).toList(),
              onChanged: (String? newValue) {
                attributeTypeController.text = newValue ?? '';
              },
              decoration: InputDecoration(
                labelText: 'Data Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
