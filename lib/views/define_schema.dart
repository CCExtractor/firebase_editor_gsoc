// lib/views/define_schema.dart

import 'package:flutter/material.dart';

import '../controllers/define_schema_controllers.dart';
import 'attribute_field.dart';

class DefineSchema extends StatefulWidget {
  const DefineSchema({super.key});

  @override
  State<DefineSchema> createState() => _DefineSchemaState();
}

class _DefineSchemaState extends State<DefineSchema> {
  final SchemaControllers _schemaControllers = SchemaControllers();

  @override
  void dispose() {
    _schemaControllers.dispose();
    super.dispose();
  }

  void _addAttribute() {
    setState(() {
      _schemaControllers.addAttributeControllers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Define Schema'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _schemaControllers.dbNameController,
              decoration: InputDecoration(
                labelText: 'Schema Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            SizedBox(height: 15.0,),
            TextField(
              controller: _schemaControllers.primaryKeyNameController,
              decoration: InputDecoration(
                labelText: 'Primary Key Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
              ),
            ),
            // TextField(
            //   controller: _schemaControllers.primaryKeyTypeController,
            //   decoration: InputDecoration(
            //     labelText: 'Primary Key Data Type',
            //   ),
            // ),
            SizedBox(height: 15.0,),
            DropdownButtonFormField<String>(
              value: _schemaControllers.primaryKeyType,
              items: ['string', 'number', 'boolean'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value, style: TextStyle(fontSize: 18.0),),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _schemaControllers.primaryKeyType = newValue!;
                });
              },
              decoration: InputDecoration(
                labelText: 'Primary Key Data Type',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                contentPadding: EdgeInsets.fromLTRB(12, 20, 12, 20),
              ),
            ),
            SizedBox(height: 20.0),
            ...List.generate(_schemaControllers.attributeNameControllers.length, (index) {
              return AttributeField(
                attributeNameController: _schemaControllers.attributeNameControllers[index],
                attributeTypeController: _schemaControllers.attributeTypeControllers[index],
              );
            }),
            SizedBox(height: 20.0),
            ElevatedButton(
              onPressed: _addAttribute,
              child: Text('Add Field +'),
            ),
          ],
        ),
      ),
    );
  }
}
